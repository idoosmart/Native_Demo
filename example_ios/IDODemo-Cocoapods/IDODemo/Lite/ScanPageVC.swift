//
//  ScanPageVC.swift
//  IDODemoLite
//
//  扫描添加设备页。扫描仍走 XYCentralManager。
//

import UIKit

import SnapKit
import SVProgressHUD

import protocol_channel

class ScanPageVC: BaseVC {
    var scanList = [ScanInfo]()

    lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
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

    func applyScanResult(_ list: [ScanInfo]) {
        scanList = list.filter { !UserDefaults.standard.isLiteBound(uuid: $0.uuid) }
        tableView.reloadData()
    }

    func stopScan() {
        bleMgr.stopScan()
    }

    func startScan() {
        bleMgr.startScan { [weak self] _ in
            self?.applyScanResult(bleMgr.scanInfoListSorted)
        }
    }

    @objc func _reload() {
        stopScan()
        scanList.removeAll()
        tableView.reloadData()
        startScan()
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
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "LiteScanCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        cell.accessoryType = .disclosureIndicator
        let scanInfo = scanList[indexPath.row]
        cell.textLabel?.text = scanInfo.peripheralName
        cell.detailTextLabel?.text = "\(scanInfo.uuid) - rssi:\(scanInfo.rssi.intValue)"
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scanInfo = scanList[indexPath.row]
        stopScan()
        if let main = navigationController?.viewControllers.first as? MainPageVC {
            main.currentDeviceModel = scanInfo
        }
        let vc = FunctionPageVC()
        vc.deviceModel = scanInfo
        navigationController?.pushViewController(vc, animated: true)
    }
}
