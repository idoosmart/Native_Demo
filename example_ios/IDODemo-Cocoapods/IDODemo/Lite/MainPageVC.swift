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
    var boundList = [LiteBoundSnapshot]()
    var currentDeviceModel: ScanInfo?
    weak var scanPage: ScanPageVC?

    private var isUnbinding = false
    private var isRestoring = false

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

    fileprivate func openFunction(scanInfo: ScanInfo) {
        currentDeviceModel = scanInfo
        let vc = FunctionPageVC()
        vc.deviceModel = scanInfo
        navigationController?.pushViewController(vc, animated: true)
    }

    fileprivate func forceUnbind(at indexPath: IndexPath) {
        guard !isUnbinding, indexPath.row < boundList.count else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        let item = boundList[indexPath.row]
        guard !item.mac.isEmpty else {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        isUnbinding = true
        SVProgressHUD.show(withStatus: "unbind...")
        sdk.cmd.unbind(macAddress: item.mac, isForceRemove: true) { [weak self] rs in
            guard let self = self else { return }
            self.isUnbinding = false
            if rs {
                UserDefaults.standard.setBind(item.mac, isBind: false)
                UserDefaults.standard.removeLiteBoundDevice(mac: item.mac)
                SVProgressHUD.showSuccess(withStatus: "unbind successful")
                self.reloadBoundDevices()
            } else {
                SVProgressHUD.showError(withStatus: "unbind failure")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
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
        let cellId = "LiteBoundCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        cell.accessoryType = .disclosureIndicator
        let item = boundList[indexPath.row]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = "\(item.mac) - bound"
        cell.backgroundColor = UIColor(red: 232/255, green: 244/255, blue: 255/255, alpha: 1)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isRestoring, indexPath.row < boundList.count else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let item = boundList[indexPath.row]
        isRestoring = true
        // 静默还原，避免与详情页 Connecting HUD 叠闪；失败再提示
        item.restoreScanInfo { [weak self] scanInfo in
            guard let self = self else { return }
            self.isRestoring = false
            tableView.deselectRow(at: indexPath, animated: true)
            guard let scanInfo = scanInfo else {
                SVProgressHUD.showInfo(withStatus: "无法还原设备，请重新扫描添加")
                return
            }
            self.openFunction(scanInfo: scanInfo)
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
