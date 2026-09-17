//
//  ScanPageVC.swift
//  IDODemoLite
//

import UIKit

import SnapKit
import SVProgressHUD

import protocol_channel

class ScanPageVC: BaseVC {
    var dataList = [ScanInfo]()

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

    func stopScan() {
        bleMgr.stopScan()
    }

    func startScan() {
        bleMgr.startScan { [weak self] _ in
            guard let self = self else { return }
            self.dataList = bleMgr.scanInfoListSorted
            self.tableView.reloadData()
        }
    }

    @objc func _reload() {
        stopScan()
        dataList.removeAll()
        tableView.reloadData()
        startScan()
    }
}

extension ScanPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "扫描结果 / Scan"
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "ScanCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.accessoryType = .disclosureIndicator
        let scanInfo = dataList[indexPath.row]
        cell.textLabel?.text = scanInfo.peripheralName
        cell.detailTextLabel?.text = "\(scanInfo.uuid) - rssi:\(scanInfo.rssi.intValue)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scanInfo = dataList[indexPath.row]
        stopScan()
        if let main = navigationController?.viewControllers.first as? MainPageVC {
            main.currentDeviceModel = scanInfo
            let vc = FunctionPageVC()
            vc.deviceModel = scanInfo
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
