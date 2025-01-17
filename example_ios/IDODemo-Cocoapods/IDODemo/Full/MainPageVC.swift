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
    var dataList = [IDODeviceModel]()
    var bleState: IDOBluetoothStateModel?
    var deviceState: IDODeviceStateModel?
    
    weak var funcPage: FunctionPageVC?
    
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
        // Do any additional setup after loading the view.

        title = "IDO Demo"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(btnReload)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btnReload.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(80, 80))
            make.bottom.equalTo(tableView.snp.bottom).offset(-30)
            make.right.equalTo(tableView.snp.right).offset(-20)
        }
        
        registerSDK()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopScan()
    }
    
    override func languageChanged() {
        super.languageChanged()
        
        btnReload.setTitle(L10n.refresh, for: .normal)
    }
}


// MARK: UITableViewDelegate, UITableViewDataSource

extension MainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        let deviceModel = dataList[indexPath.row]
        cell.textLabel?.text = deviceModel.name
        cell.detailTextLabel?.text = "\(deviceModel.macAddress ?? "unknow") - rssi:\(deviceModel.rssi ?? 0)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceModel = dataList[indexPath.row]
        let vc = FunctionPageVC()
        vc.deviceModel = deviceModel
        funcPage = vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

