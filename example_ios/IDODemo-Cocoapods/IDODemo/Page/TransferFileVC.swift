//
//  TransferFileVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/31.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class TransferFileVC: UIViewController {
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    private lazy var items: [TransType] = {
        var list: [TransType] = [
            .contact,
            .ota,
            .watchFace
        ]
        if sdk.funcTable.getSupportV3BleMusic {
            list.insert(.mp3, at: 0)
        }
        
        if (sdk.device.deviceId == 859 || sdk.device.deviceId == 7884) {
            list.append(.app)
        }
        
        if (sdk.device.deviceId == 7883 || sdk.device.deviceId == 7882) {
            list.append(.gps)
        }
        
        // gps fw
        if (sdk.funcTable.getSupportUpdateGps) {
            list.append(.gpsFw)
        }
        
        return list
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transfer File"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
            make.left.right.equalTo(0)
        }
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension TransferFileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .default, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .black
        cell.textLabel?.textAlignment = .left
        let cmd = items[indexPath.row]
        cell.textLabel?.text = cmd.title()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = items[indexPath.row]
        if (cmd == .watchFace) {
            let vc = WatchFaceVC();
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        let vc = TransferFileDetailVC(cmd: cmd)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - TransType

enum TransType {
    case mp3
    case wallpaper
    case contact
    case watchFace
    case ota
    case app
    case gps
    case gpsFw
}

extension TransType {

    func title() -> String {
        switch self {
        case .mp3:
            return "传输音乐 Upload music"
        case .wallpaper:
            return "壁纸表盘 Wallpaper watch face"
        case .contact:
            return "上传通讯录 Upload contacts"
        case .watchFace:
            return "表盘升级 Watch face upgrade"
        case .ota:
            return "固件升级 Firmware upgrade"
        case .app:
            return "小程序 App"
        case .gps:
            return "GPS"
        case .gpsFw:
            return "GPS Firmware"
        }
    }

    /// 允许的文件后缀列表 / Allowed file extensions
    func allowedExtensions() -> [String] {
        switch self {
        case .mp3:       return ["mp3"]
        case .wallpaper: return ["png", "jpg", "jpeg"]
        case .contact:   return ["json"]
        case .watchFace: return []
        case .ota:
            switch sdk.device.platform {
            case 98, 99: return ["zip"]
            default:
                return ["zip", "bin", "fw"]
            }
        case .app:       return ["app"]
        case .gps:       return ["dat"]
        case .gpsFw:     return ["gps"]
        }
    }

    /// 文件选择提示 / File selection hint
    func fileHint() -> String {
        let exts = allowedExtensions().map { ".\($0)" }.joined(separator: " / ")
        switch self {
        case .mp3:
            return "选择音乐文件 (\(exts))\nNote: Only 44.1k sample rate"
        case .wallpaper:
            return "选择壁纸图片 (\(exts))"
        case .contact:
            return "选择通讯录 (\(exts))"
        case .ota:
            return "选择固件文件 (\(exts))"
        case .app:
            return "选择小程序 (\(exts))"
        case .gps:
            return "选择EPO文件 (\(exts))"
        case .gpsFw:
            return "选择GPS固件 (\(exts))"
        case .watchFace:
            return ""
        }
    }

    /// OTA 醒目警告提示 / OTA prominent warning
    func otaWarning() -> String {
        return "注意：需使用正确的固件文件，错误的固件包会导致安装失败，严重的会导致设备变砖无法开机！\nWARNING: Use the correct firmware file. An incorrect firmware package may cause installation failure or brick the device!"
    }
}

// MARK: - TransferFileDetailVC

class TransferFileDetailVC: UIViewController {
    private var cmd: TransType
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    @objc dynamic private var isTransferring = false

    /// 用户选择的文件URL / User-selected file URL
    private var selectedFileURL: URL?

    // 98/99 平台ota过程会重启设备，然后会接着传输，需要标记ota模式
    var _isSiceOta: Bool = false
    var _devInfo: (address: String, uuid: String, platform: Int, deviceId: Int)

    // MARK: - UI

    private lazy var btnSelectFile: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("📂 选择文件 Select File", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.selectFile()
        }).disposed(by: disposeBag)
        return btn
    }()

    private lazy var lblFileHint: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.text = cmd.fileHint()
        return lbl
    }()

    private lazy var lblOtaWarning: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.text = cmd.otaWarning()
        lbl.backgroundColor = UIColor(red: 204/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        lbl.layer.cornerRadius = 8
        lbl.clipsToBounds = true
        lbl.isHidden = true
        return lbl
    }()

    private lazy var lblFileName: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .darkGray
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.text = "未选择文件 No file selected"
        return lbl
    }()

    private lazy var btnSend: UIButton = {
        let btn = UIButton.createNormalButton(title: "Send")
        btn.isEnabled = false
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.send()
        }).disposed(by: disposeBag)
        return btn
    }()

    private lazy var btnStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop")
        btn.isEnabled = false
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.stop()
        }).disposed(by: disposeBag)
        return btn
    }()

    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .lightGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()

    // MARK: - Init

    required init(cmd: TransType) {
        self.cmd = cmd
        self._devInfo = ("","",0,0)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = cmd.title()
        view.backgroundColor = .white

        view.addSubview(btnSelectFile)
        view.addSubview(lblFileHint)
        view.addSubview(lblOtaWarning)
        view.addSubview(lblFileName)
        view.addSubview(btnSend)
        view.addSubview(btnStop)
        view.addSubview(textConsole)

        // OTA 场景显示醒目警告
        if cmd == .ota {
            lblOtaWarning.isHidden = false
        }

        btnSelectFile.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(250)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                make.top.equalTo(20)
            }
        }

        lblFileHint.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnSelectFile.snp.bottom).offset(8)
        }

        lblOtaWarning.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lblFileHint.snp.bottom).offset(8)
        }

        lblFileName.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lblOtaWarning.snp.bottom).offset(8)
        }

        btnSend.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.top.equalTo(lblFileName.snp.bottom).offset(20)
        }

        btnStop.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.top.equalTo(btnSend.snp.bottom).offset(15)
        }

        textConsole.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(btnStop.snp.bottom).offset(15)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalTo(0)
            }
        }

        self.rx.observeWeakly(Bool.self, "isTransferring").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
    }

    override func viewDidDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewDidDisappear(animated)
    }

    // MARK: - File Selection

    private func selectFile() {
        if isTransferring {
            SVProgressHUD.showInfo(withStatus: "传输中，请先停止\nPlease stop transfer first")
            return
        }

        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            var utTypes: [UTType] = []
            for ext in cmd.allowedExtensions() {
                if let t = UTType(filenameExtension: ext) {
                    utTypes.append(t)
                }
            }
            if utTypes.isEmpty { utTypes = [.data] }
            picker = UIDocumentPickerViewController(forOpeningContentTypes: utTypes, asCopy: true)
        } else {
            // iOS 12/13 回退使用 public.data，选择后再校验后缀
            picker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        }

        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    // MARK: - Send / Stop

    private func send() {
        guard let fileURL = selectedFileURL else {
            SVProgressHUD.showInfo(withStatus: "请先选择文件\nPlease select a file first")
            return
        }

        cancellable?.cancel()
        cancellable = nil
        textConsole.text = "📄 \(fileURL.lastPathComponent)\n"

        let path = fileURL.path
        switch cmd {
        case .mp3:
            _mp3(filePath: path, fileName: fileURL.lastPathComponent)
        case .wallpaper:
            _wallpaper(filePath: path)
        case .contact:
            _contact(filePath: path, fileName: fileURL.deletingPathExtension().lastPathComponent)
        case .watchFace:
            break
        case .ota:
            _ota(filePath: path)
        case .app:
            _app(filePath: path, fileName: fileURL.lastPathComponent)
        case .gps:
            _gps(filePath: path, fileName: fileURL.lastPathComponent)
        case .gpsFw:
            _gpsFw(filePath: path)
        }
    }

    private func stop() {
        if (cmd == .ota) {
            SVProgressHUD.showInfo(withStatus: "OTA不支持取消\nThe upgrade process cannot be canceled")
            return
        }
        cancellable?.cancel()
        isTransferring = false
    }

    // MARK: - Transfer Implementations

    private func _mp3(filePath: String, fileName: String) {
        /*
         !!!: 音乐传输注意事项：
         1、只支持44.1k采样率的mp3文件
         2、相同音乐（名称)，需要先删除设备上的该音乐，再创建
         3、音乐传输前需要先调用接口创建相关音乐，提供musicID + 文件大小 + 名称
         4、执行音乐传输时，需提供musicID + 文件大小 + 名称
         */
        var musicFileSize = 0
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? Int64 {
                musicFileSize = Int(fileSize)
            }
        } catch {
            SVProgressHUD.showError(withStatus: "获取音乐大小出错！Error getting music size")
            return
        }

        let musicItem = IDOMusicItem(musicID: 1, musicMemory: musicFileSize, musicName: fileName, singerName: "")
        // 1、先删除设备上的该音乐（如果存在）
        let param = IDOMusicOpearteParamModel(musicOperate: 1, folderOperate: 0, folderItem: nil, musicItem: musicItem)
        Cmds.setMusicOperate(param).send { [weak self] res in
            // 2、创建音乐
            let param = IDOMusicOpearteParamModel(musicOperate: 2, folderOperate: 0, folderItem: nil, musicItem: musicItem)
            Cmds.setMusicOperate(param).send { [weak self] res in
                if case .success(let val) = res {
                    if (val?.errCode == 0) {
                        // 3、执行传输
                        self?._trans([
                            IDOTransMusicModel(filePath: filePath, fileName: musicItem.musicName, musicId: musicItem.musicID)
                        ])
                    }else {
                        SVProgressHUD.showError(withStatus: "创建歌曲信息出错\n Error creating song information\ncode:\(String(describing: val?.errCode))")
                    }
                } else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: err.message)
                }
            }
        }
    }

    private func _contact(filePath: String, fileName: String) {
        _trans([
            IDOTransNormalModel(fileType: .ml, filePath: filePath, fileName: fileName)
        ])
    }

    private func _wallpaper(filePath: String) {
        _trans([
            IDOTransNormalModel(fileType: .wallpaperZ, filePath: filePath, fileName: "wallpaper.z")
        ])
    }

    private func _ota(filePath: String) {
        _isSiceOta = false
        switch(sdk.device.deviceId) {
        case 8170:
            // 98平台需标记OTA模式
            self._isSiceOta = true
            self._devInfo = (sdk.device.macAddressFull,
                             sdk.device.uuid,
                             sdk.device.platform,
                             sdk.device.deviceId)
            _trans([
                IDOTransNormalModel(fileType: .fw, filePath: filePath, fileName: "test")
            ])
        case 877:
            // !!!: 戒指ota需要特殊处理
            _otaRing(filePath: filePath)
        default:
            _trans([
                IDOTransNormalModel(fileType: .fw, filePath: filePath, fileName: "test")
            ])
        }
    }

    private func _app(filePath: String, fileName: String) {
        _trans([
            IDOTransNormalModel(fileType: .app, filePath: filePath, fileName: fileName)
        ])
    }

    private func _gps(filePath: String, fileName: String) {
        // !!!: epo传输完需要等设备通知安装完成，进度100%后还需等约40秒
        _trans([
            IDOTransNormalModel(fileType: .epo, filePath: filePath, fileName: fileName)
        ])
    }

    private func _gpsFw(filePath: String) {
        // 1.获取版本
        Cmds.getGpsInfo().send { res in
            if case .success(let gpsInfoModel) = res {
                print("gpsInfo version:\(gpsInfoModel?.fwVersionString)")
            }
        }
        // 2.执行传输（注意：文件后缀必须为.gps）
        _trans([
            IDOTransNormalModel(fileType: .gps, filePath: filePath, fileName: "gps")
        ])
    }

    private func _otaRing(filePath: String) {
        Task { [weak self] in
            guard let self else { return }

            let macAddress = sdk.device.macAddressFull
            let uuid = sdk.device.uuid
            let platform = sdk.device.platform
            let did = sdk.device.deviceId

            // 1. 断开连接
            _ = await withCheckedContinuation { continuation in
                sdk.ble.cancelConnect(macAddress: macAddress) { rs in
                    continuation.resume(returning: rs)
                }
            }

            // 2. 标记 OTA 模式
            _ = await withCheckedContinuation { continuation in
                sdk.bridge.markOtaMode?(macAddress: macAddress, iosUUID: uuid, platform: platform, deviceId: did) { rs in
                    continuation.resume(returning: rs)
                }
            }

            // 3. 传输 OTA
            _trans([
                IDOTransNormalModel(fileType: .fw, filePath: filePath, fileName: "test")
            ])
        }
    }

    // MARK: - Core Transfer

    private func _trans<T: IDOTransBaseModel>(_ items: [T]) {
        isTransferring = true
        cancellable = sdk.transfer.transferFiles(fileItems: items, cancelPrevTranTask: true) { [weak self] currentIndex, totalCount, currentProgress, totalProgress in
            let txt = "index: \(currentIndex + 1)/\(totalCount) "
            + String(format: "%.2f% / %.2f%\n", currentProgress * 100, totalProgress * 100)
            self?.textConsole.text = txt
            self?.textConsole.scrollToBottom()
        } transStatus: { [weak self] currentIndex, status, errorCode, _ in
            if status != .finished || errorCode != 0 {
                let txt = (self?.textConsole.text ?? "") + "failure, currentIndex:\(currentIndex) errorCode:\(errorCode)\n"
                self?.textConsole.text = txt
                self?.textConsole.scrollToBottom()
            }
        } completion: { [weak self] rs in
            self?.isTransferring = false
            let txt = (self?.textConsole.text ?? "") + "result: \(rs)\n"
            self?.textConsole.text = txt
            self?.textConsole.scrollToBottom()

            // 98平台设备传输失败（如中途关闭蓝牙），此处添加重试
            if(self?._isSiceOta ?? false && rs.last == false) {
                self?._retryOtaAlert()
            }
        }
    }

    // MARK: - State

    private func refreshState() {
        btnSelectFile.isEnabled = !isTransferring
        btnSelectFile.alpha = isTransferring ? 0.5 : 1.0
        btnSend.isEnabled = !isTransferring && selectedFileURL != nil
        btnStop.isEnabled = isTransferring
    }

    // MARK: - OTA Retry (SICE)

    private func _retryOtaAlert() {
        let alert = UIAlertController(title: "OTA", message: "升级失败，确认蓝牙开启后重试？\n\nUpgrade failed. Please confirm that Bluetooth is enabled and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self._retrySiceOta()
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // 部分ota添加重试操作（98平台设备）
    private func _retrySiceOta() {
        guard let fileURL = selectedFileURL else { return }

        Task { [weak self] in
            guard let self else { return }

            let macAddress = _devInfo.address
            let uuid = _devInfo.uuid
            let platform = _devInfo.platform
            let did = _devInfo.deviceId

            // 1. 标记 OTA 模式
            _ = await withCheckedContinuation { continuation in
                sdk.bridge.markOtaMode?(macAddress: macAddress, iosUUID: uuid, platform: platform, deviceId: did) { rs in
                    continuation.resume(returning: rs)
                }
            }

            // 2. 再次执行OTA升级
            _ota(filePath: fileURL.path)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension TransferFileDetailVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }

        // 校验文件后缀 / Validate file extension
        let ext = url.pathExtension.lowercased()
        let allowedExts = cmd.allowedExtensions().map { $0.lowercased() }

        if !allowedExts.isEmpty && !allowedExts.contains(ext) {
            let supported = allowedExts.map { ".\($0)" }.joined(separator: ", ")
            SVProgressHUD.showError(withStatus:
                "不支持的格式: .\(ext)\nUnsupported: .\(ext)\n\n支持 Supported: \(supported)")
            return
        }

        selectedFileURL = url
        lblFileName.text = "✅ \(url.lastPathComponent)"
        lblFileName.textColor = UIColor(red: 34/255.0, green: 139/255.0, blue: 34/255.0, alpha: 1)
        btnSend.isEnabled = !isTransferring
        textConsole.text = ""
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消，不做处理 / User cancelled
    }
}
