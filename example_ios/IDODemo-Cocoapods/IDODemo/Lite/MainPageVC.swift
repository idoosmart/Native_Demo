//
//  MainPageVC.swift
//  IDODemoLite
//

import UIKit

import SnapKit
import SVProgressHUD

import protocol_channel

// Alexa client id （测试用）
let clientId = "amzn1.application-oa2-client.e45ff1ade6064c24a265fe6924c6f75d"

// MARK: - MainPageVC

class MainPageVC: BaseVC {
    var boundList = [LiteBoundSnapshot]()
    var currentDeviceModel: ScanInfo?
    weak var scanPage: ScanPageVC?

    private var isUnbinding = false

    lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
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
        boundList = UserDefaults.standard.loadLiteBoundDevices()
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
        let item = boundList[indexPath.row]
        let macAddress = item.mac
        guard !macAddress.isEmpty else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        isUnbinding = true
        SVProgressHUD.show(withStatus: "unbind...")
        sdk.cmd.unbind(macAddress: macAddress, isForceRemove: true) { [weak self] rs in
            guard let self = self else { return }
            self.isUnbinding = false
            if rs {
                UserDefaults.standard.setBind(macAddress, isBind: false)
                UserDefaults.standard.removeLiteBoundDevice(mac: macAddress)
                SVProgressHUD.showSuccess(withStatus: "unbind successful")
                self.reloadBoundDevices()
            } else {
                SVProgressHUD.showError(withStatus: "unbind failure")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    fileprivate func openFunction(with scanInfo: ScanInfo) {
        currentDeviceModel = scanInfo
        let vc = FunctionPageVC()
        vc.deviceModel = scanInfo
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boundList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "BoundCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.accessoryType = .disclosureIndicator
        let item = boundList[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.mac) - bound"
        cell.backgroundColor = UIColor(red: 232/255, green: 244/255, blue: 255/255, alpha: 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = boundList[indexPath.row]
        if let scanInfo = UserDefaults.standard.restoreScanInfo(from: item) {
            openFunction(with: scanInfo)
        } else {
            SVProgressHUD.showInfo(withStatus: "无法还原设备，请重新扫描添加")
            tableView.deselectRow(at: indexPath, animated: true)
        }
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
