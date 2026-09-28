//
//  MainPageVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

// Alexa client id （测试用）
let clientId = "amzn1.application-oa2-client.e45ff1ade6064c24a265fe6924c6f75d"

// MARK: - MainPageVC

class MainPageVC: BaseVC {
    var boundList = [IDODeviceModel]()
    var bleState: IDOBluetoothStateModel?
    var deviceState: IDODeviceStateModel?

    weak var funcPage: FunctionPageVC?
    weak var scanPage: ScanPageVC?

    private var isUnbinding = false

    lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        v.register(BoundDeviceCell.self, forCellReuseIdentifier: BoundDeviceCell.cellIdentifier)
        return v
    }()

    lazy var emptyView: UIView = {
        let container = UIView()
        container.isHidden = true
        let label = UILabel()
        label.text = "暂无已绑定设备"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        let btn = UIButton(type: .system)
        btn.setTitle("添加设备", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.addTarget(self, action: #selector(openScanPage), for: .touchUpInside)
        container.addSubview(label)
        container.addSubview(btn)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-24)
        }
        btn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(16)
        }
        return container
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "已绑定设备"
        view.backgroundColor = .white

        view.addSubview(tableView)
        view.addSubview(emptyView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "添加",
            style: .plain,
            target: self,
            action: #selector(openScanPage)
        )

        registerSDK()
        reloadBoundDevices()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadBoundDevices()
    }

    func reloadBoundDevices() {
        boundList = UserDefaults.standard.loadBoundDevices()
        emptyView.isHidden = !boundList.isEmpty
        tableView.isHidden = boundList.isEmpty
        tableView.reloadData()
    }

    @objc func openScanPage() {
        let vc = ScanPageVC()
        scanPage = vc
        navigationController?.pushViewController(vc, animated: true)
    }

    fileprivate func forceUnbind(at indexPath: IndexPath) {
        guard !isUnbinding, indexPath.row < boundList.count else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        let device = boundList[indexPath.row]
        guard let macAddress = device.macAddress, !macAddress.isEmpty else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        isUnbinding = true
        SVProgressHUD.show(withStatus: "unbind...")
        sdk.cmd.unbind(macAddress: macAddress, isForceRemove: true) { [weak self] rs in
            guard let self = self else { return }
            self.isUnbinding = false
            if rs {
                TaskListStorage.clearOnUnbind(
                    macAddress: macAddress,
                    alternateMac: sdk.device.macAddress
                )
                UserDefaults.standard.setBind(macAddress, isBind: false)
                SVProgressHUD.showSuccess(withStatus: "unbind successful")
                self.reloadBoundDevices()
            } else {
                SVProgressHUD.showError(withStatus: "unbind failure")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension MainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boundList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BoundDeviceCell.cellIdentifier, for: indexPath) as! BoundDeviceCell
        cell.accessoryType = .disclosureIndicator
        let deviceModel = boundList[indexPath.row]
        var devName = deviceModel.name ?? ""
        if deviceModel.deviceId != 0 {
            devName += "(\(deviceModel.deviceId))"
        }
        cell.backgroundColor = UIColor(red: 232/255, green: 244/255, blue: 255/255, alpha: 1)
        cell.configure(
            title: devName,
            subtitle: "\(deviceModel.macAddress ?? "unknow") - bound"
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceModel = boundList[indexPath.row]
        let vc = FunctionPageVC()
        vc.deviceModel = deviceModel
        funcPage = vc
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "解绑") { [weak self] _, _, completion in
            self?.forceUnbind(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

fileprivate class BoundDeviceCell: UITableViewCell {
    static let cellIdentifier = "BoundDeviceCell"

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
