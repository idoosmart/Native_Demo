//
//  ScanPageVC.swift
//  IDODemo
//
//  扫描添加设备页
//

import UIKit

import SnapKit
import SVProgressHUD

import protocol_channel

class ScanPageVC: BaseVC {
    var scanList = [IDODeviceModel]()

    lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        v.register(ScanDeviceCell.self, forCellReuseIdentifier: ScanDeviceCell.cellIdentifier)
        return v
    }()

    lazy var btnReload: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(L10n.refresh, for: .normal)
        btn.addTarget(self, action: #selector(_reload), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "添加设备"
        view.backgroundColor = .white

        view.addSubview(tableView)
        view.addSubview(btnReload)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        btnReload.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.bottom.equalTo(tableView.snp.bottom).offset(-30)
            make.right.equalTo(tableView.snp.right).offset(-20)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startScan()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScan()
    }

    override func languageChanged() {
        super.languageChanged()
        btnReload.setTitle(L10n.refresh, for: .normal)
    }

    func applyScanResult(_ list: [IDODeviceModel]?) {
        scanList.removeAll()
        if let list = list {
            for device in list {
                if let mac = device.macAddress, UserDefaults.standard.isBind(mac) {
                    UserDefaults.standard.setBind(mac, isBind: true, device: device)
                } else {
                    scanList.append(device)
                }
            }
        }
        tableView.reloadData()
    }

    func stopScan() {
        sdk.ble.stopScan()
    }

    func startScan() {
        sdk.ble.startScan(macAddress: nil) { _ in }
    }

    @objc func _reload() {
        stopScan()
        scanList.removeAll()
        tableView.reloadData()
        startScan()
    }

    fileprivate func _goOta(otaModel: IDODeviceModel) {
        stopScan()
        let isSiceOta = [98, 99].contains(otaModel.platform)
        if isSiceOta {
            Task {
                _ = await withCheckedContinuation { continuation in
                    sdk.bridge.markOtaMode?(
                        macAddress: otaModel.macAddress ?? "",
                        iosUUID: otaModel.uuid ?? "",
                        platform: otaModel.platform,
                        deviceId: otaModel.deviceId,
                        completion: { _ in
                            continuation.resume(returning: true)
                        }
                    )
                }
            }
        }
        let vc = TransferFileDetailVC(cmd: .ota)
        if isSiceOta {
            vc._isSiceOta = true
            vc._devInfo = (
                sdk.device.macAddressFull,
                sdk.device.uuid,
                sdk.device.platform,
                sdk.device.deviceId
            )
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ScanPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanList.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "扫描结果 / Scan"
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ScanDeviceCell.cellIdentifier, for: indexPath) as! ScanDeviceCell
        cell.accessoryType = .disclosureIndicator
        let deviceModel = scanList[indexPath.row]
        var devName = deviceModel.name ?? ""
        cell.backgroundColor = .white
        if deviceModel.deviceId != 0 {
            devName += "(\(deviceModel.deviceId))"
        }
        cell.configure(
            title: devName,
            subtitle: "\(deviceModel.macAddress ?? "unknow") - rssi:\(deviceModel.rssi)",
            buttonTitle: deviceModel.isOta ? "OTA" : ""
        )
        cell.buttonAction = { [weak self] in
            self?._goOta(otaModel: deviceModel)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceModel = scanList[indexPath.row]
        if deviceModel.isOta && deviceModel.deviceId == 0 {
            SVProgressHUD.showInfo(withStatus: "设备处理ota状态，先去升级")
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        stopScan()
        let vc = FunctionPageVC()
        vc.deviceModel = deviceModel
        if let main = navigationController?.viewControllers.first as? MainPageVC {
            main.funcPage = vc
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

fileprivate class ScanDeviceCell: UITableViewCell {
    static let cellIdentifier = "ScanDeviceCell"

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let actionButton = UIButton(type: .system)
    var buttonAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(actionButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        buttonAction?()
    }

    func configure(title: String, subtitle: String, buttonTitle: String = "") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.isHidden = buttonTitle.isEmpty
    }
}
