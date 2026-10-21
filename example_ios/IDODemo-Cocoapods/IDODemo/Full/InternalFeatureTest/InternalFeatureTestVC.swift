//
//  InternalFeatureTestVC.swift
//  IDODemo (native Full temp — temp sync to native Full)
//
//  内部功能测试：脏数据 / 边界 JSON / 本地解码 / 绑定加密授权等，临时同步到 native Full（联调）。
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

class InternalFeatureTestVC: UIViewController {

    /// 来自 Function 页的当前设备（加密鉴权标记绑定时需要）
    var deviceModel: IDODeviceModel?

    private var logBuffer = ""

    private lazy var buttonScrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = false
        v.alwaysBounceVertical = true
        return v
    }()

    private lazy var buttonStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 10
        v.alignment = .fill
        return v
    }()

    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233 / 255.0, green: 233 / 255.0, blue: 233 / 255.0, alpha: 1)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "内部功能测试"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(onClearLog)
        )
        setupLayout()
        setupActions()
        appendLog("Internal Feature Test — native Full temp\n不同步六端 Demo")
        if let mac = resolveMacAddress() {
            appendLog("current mac=\(mac)")
        } else {
            appendLog("current mac=(none) — set/get 需 mac；可从 Function 页带入设备")
        }
    }

    private func setupLayout() {
        view.addSubview(buttonScrollView)
        view.addSubview(textConsole)
        buttonScrollView.addSubview(buttonStack)

        buttonScrollView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            } else {
                make.top.equalTo(8)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
        }

        buttonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            make.width.equalTo(buttonScrollView.snp.width).offset(-24)
        }

        textConsole.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(buttonScrollView.snp.bottom).offset(8)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            } else {
                make.bottom.equalTo(-8)
            }
        }
    }

    private func setupActions() {
        appendSection(
            title: "绑定加密授权",
            buttons: [
                ("bind + onEncryptedAuthData", { [weak self] in self?.bindWithEncryptedAuthCallback() }),
                ("setEncryptedAuthData(样例)", { [weak self] in self?.setEncryptedAuthSample() }),
                ("getEncryptedAuthData", { [weak self] in self?.getEncryptedAuthCached() }),
                ("get → 复制 JSON", { [weak self] in self?.getEncryptedAuthAndCopy() }),
                ("粘贴 → set", { [weak self] in self?.pasteEncryptedAuthAndSet() }),
                ("setEncryptedAuth + 标记已绑定", { [weak self] in self?.runSetEncryptedAuthAndMarkBound() }),
            ]
        )
        appendSection(
            title: "闹钟 JSON",
            buttons: [
                ("空 item / 脏 name / 越界 type·status", { [weak self] in self?.runAlarmJsonCases() }),
            ]
        )
    }

    private func appendSection(title: String, buttons: [(String, () -> Void)]) {
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 14)
        label.textColor = .darkGray
        buttonStack.addArrangedSubview(label)

        for (title, action) in buttons {
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 15)
            btn.contentHorizontalAlignment = .left
            btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
            buttonStack.addArrangedSubview(btn)
        }
    }

    private func runAlarmJsonCases() {
        let result = InternalAlarmJsonCases.runAll()
        for line in result.lines {
            appendLog(line)
        }
        if result.passed {
            SVProgressHUD.showSuccess(withStatus: result.summary)
        } else {
            SVProgressHUD.showError(withStatus: result.summary)
        }
    }

    private func encryptedAuthSample() -> IDOEncryptedAuthData {
        return IDOEncryptedAuthData(
            authData: [0xAF, 0x83, 0xDA, 0x7B, 0xAE, 0x93, 0x47, 0x3C, 0xF4, 0x75, 0xB3, 0xB6],
            encryptedVersion: 0,
            authLength: 12
        )
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            SVProgressHUD.showError(withStatus: "未连接设备")
            appendLog("错误：设备未连接")
            return false
        }
        return true
    }

    private func bindWithEncryptedAuthCallback() {
        if !ensureConnected() { return }
        appendLog("--- bind + onEncryptedAuthData ---")
        SVProgressHUD.show(withStatus: "binding...")
        sdk.cmd.bind(
            osVersion: 15,
            onDeviceInfo: { [weak self] info in
                self?.appendLog("  onDeviceInfo battLevel=\(info.battLevel)")
            },
            onFuncTable: { [weak self] _ in
                self?.appendLog("  onFuncTable received")
            },
            onEncryptedAuthData: { [weak self] authData in
                self?.appendLog(
                    "  onEncryptedAuthData encryptedVersion=\(authData.encryptedVersion) authLength=\(authData.authLength) authData=\(Self.formatAuthBytes(authData.authData))"
                )
                SVProgressHUD.showInfo(withStatus: "encrypted auth len=\(authData.authLength)")
            },
            completion: { [weak self] status in
                SVProgressHUD.dismiss()
                self?.appendLog("  bind status=\(status)")
                if status == .needConfirmByApp {
                    Cmds.sendBindResult(isSuccess: true).send { rs in
                        if case .success = rs {
                            sdk.cmd.appMarkBindResult(success: true)
                            self?.appendLog("  appMarkBindResult success=true")
                        } else {
                            sdk.cmd.appMarkBindResult(success: false)
                            self?.appendLog("  appMarkBindResult success=false")
                        }
                    }
                }
            }
        )
    }

    private func setEncryptedAuthSample() {
        guard let mac = resolveMacAddress(), !mac.isEmpty else {
            SVProgressHUD.showError(withStatus: "no macAddress")
            appendLog("错误：无 macAddress")
            return
        }
        appendLog("--- setEncryptedAuthData mac=\(mac) ---")
        sdk.cmd.setEncryptedAuthData(macAddress: mac, data: encryptedAuthSample()) { [weak self] ok in
            self?.appendLog("  result=\(ok)")
            if ok {
                SVProgressHUD.showSuccess(withStatus: "set encrypted auth ok")
            } else {
                SVProgressHUD.showError(withStatus: "set encrypted auth failed")
            }
        }
    }

    private func getEncryptedAuthCached() {
        guard let mac = resolveMacAddress(), !mac.isEmpty else {
            SVProgressHUD.showError(withStatus: "no macAddress")
            appendLog("错误：无 macAddress")
            return
        }
        appendLog("--- getEncryptedAuthData mac=\(mac) ---")
        sdk.cmd.getEncryptedAuthData(macAddress: mac) { [weak self] cached in
            guard let cached = cached else {
                self?.appendLog("  no cache")
                SVProgressHUD.showInfo(withStatus: "no cache")
                return
            }
            self?.appendLog(
                "  encryptedVersion=\(cached.encryptedVersion) authLength=\(cached.authLength) authData=\(Self.formatAuthBytes(cached.authData))"
            )
            SVProgressHUD.showSuccess(withStatus: "len=\(cached.authLength) ver=\(cached.encryptedVersion)")
        }
    }

    /// 无符号 0–255，与协议 uint8 / JSON auth_data 一致
    private static func formatAuthBytes(_ bytes: [UInt8]) -> String {
        "[" + bytes.map { String($0) }.joined(separator: ", ") + "]"
    }

    /// get 缓存并复制 JSON 到剪贴板（跨手机粘贴用）
    private func getEncryptedAuthAndCopy() {
        guard let mac = resolveMacAddress(), !mac.isEmpty else {
            SVProgressHUD.showError(withStatus: "no macAddress")
            appendLog("错误：无 macAddress")
            return
        }
        appendLog("--- get → 复制 JSON mac=\(mac) ---")
        sdk.cmd.getEncryptedAuthData(macAddress: mac) { [weak self] cached in
            guard let self else { return }
            guard let cached = cached else {
                self.appendLog("  no cache")
                SVProgressHUD.showInfo(withStatus: "no cache")
                return
            }
            guard let json = cached.jsonString() else {
                self.appendLog("  jsonString failed")
                SVProgressHUD.showError(withStatus: "json encode failed")
                return
            }
            UIPasteboard.general.string = json
            self.appendLog("  copied: \(json)")
            SVProgressHUD.showSuccess(withStatus: "已复制 JSON")
        }
    }

    /// 从剪贴板读 JSON 并 setEncryptedAuthData
    private func pasteEncryptedAuthAndSet() {
        guard let mac = resolveMacAddress(), !mac.isEmpty else {
            SVProgressHUD.showError(withStatus: "no macAddress")
            appendLog("错误：无 macAddress")
            return
        }
        guard let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            SVProgressHUD.showError(withStatus: "剪贴板为空")
            appendLog("错误：剪贴板为空")
            return
        }
        guard let data = IDOEncryptedAuthData(jsonString: text) else {
            SVProgressHUD.showError(withStatus: "剪贴板不是合法 auth JSON")
            appendLog("错误：解析失败\n  clipboard=\(text)")
            return
        }
        appendLog("--- 粘贴 → set mac=\(mac) ---")
        appendLog("  json=\(text)")
        sdk.cmd.setEncryptedAuthData(macAddress: mac, data: data) { [weak self] ok in
            self?.appendLog("  result=\(ok)")
            if ok {
                SVProgressHUD.showSuccess(withStatus: "paste set ok")
            } else {
                SVProgressHUD.showError(withStatus: "paste set failed")
            }
        }
    }

    /// 连接前写入加密授权并标记本地已绑定（模拟换机略过绑定）
    private func runSetEncryptedAuthAndMarkBound() {
        guard let mac = resolveMacAddress(), !mac.isEmpty else {
            appendLog("错误：无 macAddress")
            SVProgressHUD.showError(withStatus: "no macAddress")
            return
        }
        guard let data = InternalEncryptedAuthCases.parseSampleJson() else {
            appendLog("错误：JSON parse failed")
            SVProgressHUD.showError(withStatus: "JSON parse failed")
            return
        }
        appendLog("--- setEncryptedAuthData mac=\(mac) ver=\(data.encryptedVersion) len=\(data.authLength) ---")
        SVProgressHUD.show(withStatus: "setEncryptedAuthData...")
        sdk.cmd.setEncryptedAuthData(macAddress: mac, data: data) { [weak self] ok in
            guard let self else { return }
            if ok {
                UserDefaults.standard.setBind(mac, isBind: true, device: self.deviceModel)
                self.appendLog("  ok → setBind true")
                SVProgressHUD.showSuccess(withStatus: "setAuth ok, bind=true")
            } else {
                self.appendLog("  failed")
                SVProgressHUD.showError(withStatus: "setEncryptedAuthData failed")
            }
        }
    }

    private func resolveMacAddress() -> String? {
        if let mac = deviceModel?.macAddress, !mac.isEmpty {
            return mac
        }
        let full = sdk.device.macAddressFull
        if !full.isEmpty { return full }
        let short = sdk.device.macAddress
        return short.isEmpty ? nil : short
    }

    private func appendLog(_ msg: String) {
        // 任意线程回调（含 bind/onEncryptedAuthData）都能打到 Xcode 控制台
        NSLog("[InternalFeatureTest] %@", msg)
        let applyUI = { [weak self] in
            guard let self else { return }
            if self.logBuffer.isEmpty {
                self.logBuffer = msg
            } else {
                self.logBuffer += "\n" + msg
            }
            self.textConsole.text = self.logBuffer
            let bottom = NSRange(location: max(0, (self.textConsole.text as NSString).length - 1), length: 1)
            self.textConsole.scrollRangeToVisible(bottom)
        }
        if Thread.isMainThread {
            applyUI()
        } else {
            DispatchQueue.main.async(execute: applyUI)
        }
    }

    @objc private func onClearLog() {
        logBuffer = ""
        textConsole.text = ""
    }
}
