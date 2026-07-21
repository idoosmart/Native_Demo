//
//  Ida01FuncVC.swift
//  IDODemo
//
//  对齐 ido_android_sdk Demo/Ida01FuncActivity：IDA01 等设备真实联调（已购表盘 / 下载状态 / APP 基本信息）
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

/// IDA01 功能联调页（参考 Android `Ida01FuncActivity` + `activity_ida01.xml`）
final class Ida01FuncVC: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let tfBaseUserName = UITextField()
    private let tfBaseUserId = UITextField()
    private let tfBaseToken = UITextField()
    private let tfBaseDomain = UITextField()
    private let tfBaseAppVersion = UITextField()

    private let payStatusControl = UISegmentedControl(items: ["取消", "失败", "成功"])
    private let tfPayUserId = UITextField()
    private let tfPayWatchId = UITextField()

    private let tfDownloadId = UITextField()
    private let downloadTypeControl = UISegmentedControl(items: ["表盘", "小程序", "OTA"])
    private let downloadStatusControl = UISegmentedControl(items: ["需要下载"])
    private let progressSlider = UISlider()
    private let lblProgress = UILabel()

    private let tvResult = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "IDA01 功能联调"
        view.backgroundColor = .white
        setupLayout()
        fillDefaults()
    }

    private func setupLayout() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        scrollView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.edges.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.edges.equalToSuperview()
            }
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }

        appendSection("APP 基本信息 (15.79 setAppBaseInfo)")
        contentStack.addArrangedSubview(row(label: "user_name", field: tfBaseUserName))
        contentStack.addArrangedSubview(row(label: "user_id", field: tfBaseUserId))
        contentStack.addArrangedSubview(row(label: "token", field: tfBaseToken))
        contentStack.addArrangedSubview(row(label: "domain_name", field: tfBaseDomain))
        contentStack.addArrangedSubview(row(label: "app_version", field: tfBaseAppVersion))
        contentStack.addArrangedSubview(actionButton("设置 APP 基本信息", action: #selector(onSetAppBaseInfo)))

        appendSection("已购表盘 (15.91 setPurchasedWatchFaceInfo)")
        payStatusControl.selectedSegmentIndex = 2
        contentStack.addArrangedSubview(payStatusControl)
        contentStack.addArrangedSubview(row(label: "用户 id", field: tfPayUserId))
        contentStack.addArrangedSubview(row(label: "表盘 id", field: tfPayWatchId))
        contentStack.addArrangedSubview(actionButton("下发已购表盘信息", action: #selector(onSetPayStatus)))

        appendSection("下载状态 (15.92 setAppDownloadStatusInfo)")
        contentStack.addArrangedSubview(row(label: "资源 id", field: tfDownloadId))
        downloadTypeControl.selectedSegmentIndex = 1
        contentStack.addArrangedSubview(downloadTypeControl)
        downloadStatusControl.selectedSegmentIndex = 0
        contentStack.addArrangedSubview(downloadStatusControl)
        let progressRow = UIStackView(arrangedSubviews: [lblProgress, progressSlider])
        progressRow.axis = .horizontal
        progressRow.spacing = 8
        lblProgress.setContentHuggingPriority(.required, for: .horizontal)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 100
        progressSlider.addTarget(self, action: #selector(onProgressChanged), for: .valueChanged)
        contentStack.addArrangedSubview(progressRow)
        contentStack.addArrangedSubview(actionButton("设置下载状态", action: #selector(onSetDownloadStatus)))

        appendSection("结果")
        tvResult.isEditable = false
        tvResult.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        tvResult.backgroundColor = UIColor(white: 0.94, alpha: 1)
        tvResult.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        tvResult.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(120)
        }
        contentStack.addArrangedSubview(tvResult)
    }

    private func fillDefaults() {
        tfBaseUserName.text = "raojc1@idoosmart.com"
        tfBaseUserId.text = "123456"
        tfBaseToken.text = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRldGltZSI6MTc4MzQ5NzI3OTc4MiwidXNlcl90eXBlIjoiVVNFUiIsInVzZXJfaWQiOiI5MTIwNDU1NDY3NDI3ODQwMCIsInNvdXJjZSI6ImFwcCIsInR5cGUiOiJhcHAiLCJhcHBfaWQiOiIxMDAwMCIsImFjY291bnQiOiJyYW9qYzFAaWRvb3NtYXJ0LmNvbSIsImlhdCI6MTc4MzQ5NzI3OSwiZXhwIjo0OTM3MDk3Mjc5fQ.lQekz6Rje5xozs-fNg-D_KKE4KtJnJ0SU6nG8xVD5yDJcfqva-fmL53biKJXguY2ha_TXJMe3Pgx3qw1q2I0qA"
        tfBaseDomain.text = "https://ali-user.idoocloud.com/"
        tfBaseAppVersion.text = "3.0.9.20251231"
        progressSlider.value = 50
        lblProgress.text = "50"
    }

    private func appendSection(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .darkGray
        contentStack.addArrangedSubview(label)
    }

    private func row(label: String, field: UITextField) -> UIStackView {
        let title = UILabel()
        title.text = label
        title.font = .systemFont(ofSize: 13)
        title.setContentHuggingPriority(.required, for: .horizontal)
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 13)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        let row = UIStackView(arrangedSubviews: [title, field])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        title.snp.makeConstraints { make in
            make.width.equalTo(100)
        }
        return row
    }

    private func actionButton(_ title: String, action: Selector) -> UIButton {
        let btn = UIButton.createNormalButton(title: title)
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        return btn
    }

    @objc private func onProgressChanged() {
        lblProgress.text = "\(Int(progressSlider.value.rounded()))"
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            appendResult("错误：设备未连接")
            SVProgressHUD.showError(withStatus: "未连接设备")
            return false
        }
        return true
    }

    private func appendResult(_ text: String) {
        let line = "[\(Self.timeStamp())] \(text)"
        if tvResult.text.isEmpty {
            tvResult.text = line
        } else {
            tvResult.text += "\n" + line
        }
        let bottom = NSRange(location: tvResult.text.count - 1, length: 1)
        tvResult.scrollRangeToVisible(bottom)
        print("[Ida01Func] \(text)")
    }

    private static func timeStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: Date())
    }

    @objc private func onSetAppBaseInfo() {
        guard ensureConnected() else { return }
        let userName = tfBaseUserName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !userName.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入 user_name")
            return
        }
        var model = IDOAppInfoModel(userName: userName, operate: 1)
        model.userId = tfBaseUserId.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        model.token = tfBaseToken.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        model.domainName = tfBaseDomain.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        model.appVersion = tfBaseAppVersion.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        model.phoneSystem = 2
        model.isFilterWatch = 2
        appendResult("请求 setAppBaseInfo: \(model.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "设置 APP 基本信息")
        Cmds.setAppBaseInfo(model).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.handleSetResult("setAppBaseInfo", res)
        }
    }

    @objc private func onSetPayStatus() {
        guard ensureConnected() else { return }
        let userId = tfPayUserId.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let watchId = tfPayWatchId.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !userId.isEmpty, !watchId.isEmpty else {
            SVProgressHUD.showError(withStatus: "请输入用户 id 与表盘 id")
            return
        }
        let paymentStatus: Int
        switch payStatusControl.selectedSegmentIndex {
        case 0: paymentStatus = 1
        case 1: paymentStatus = 2
        default: paymentStatus = 3
        }
        let param = IDOPurchasedWatchFaceInfoModel(
            paymentStatus: paymentStatus,
            userId: userId,
            watchId: watchId
        )
        appendResult("请求 setPurchasedWatchFaceInfo: \(param.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "下发已购表盘信息")
        Cmds.setPurchasedWatchFaceInfo(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.handleModelResult("setPurchasedWatchFaceInfo", res)
        }
    }

    @objc private func onSetDownloadStatus() {
        guard ensureConnected() else { return }
        let downloadType: Int
        switch downloadTypeControl.selectedSegmentIndex {
        case 0: downloadType = 1
        case 2: downloadType = 3
        default: downloadType = 2
        }
        let status = 1
        let progress = Int(progressSlider.value.rounded())
        let id = tfDownloadId.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let param = IDOAppDownloadStatusInfoModel(
            type: downloadType,
            status: status,
            progress: progress,
            id: id?.isEmpty == false ? id : nil
        )
        appendResult("请求 setAppDownloadStatusInfo: \(param.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "设置下载状态")
        Cmds.setAppDownloadStatusInfo(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.handleModelResult("setAppDownloadStatusInfo", res)
        }
    }

    private func handleSetResult<T>(_ title: String, _ res: Result<T?, CmdError>) {
        switch res {
        case .success(let val):
            appendResult("\(title) 成功 code=0")
            if let model = val as? IDOBaseModel {
                appendResult("  json: \(model.toJsonString() ?? "NULL")")
            }
            SVProgressHUD.showSuccess(withStatus: "成功")
        case .failure(let err):
            appendResult("\(title) 失败 code=\(err.code) msg=\(err.message ?? "")")
            SVProgressHUD.showError(withStatus: "失败 \(err.code)")
        }
    }

    private func handleModelResult<T: IDOBaseModel>(_ title: String, _ res: Result<T?, CmdError>) {
        switch res {
        case .success(let val):
            appendResult("\(title) 成功 code=0")
            appendResult("  json: \(val?.toJsonString() ?? "NULL")")
            SVProgressHUD.showSuccess(withStatus: "成功")
        case .failure(let err):
            appendResult("\(title) 失败 code=\(err.code) msg=\(err.message ?? "")")
            SVProgressHUD.showError(withStatus: "失败 \(err.code)")
        }
    }
}
