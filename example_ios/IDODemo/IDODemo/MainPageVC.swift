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

// Alexa client id
private let clientId = "amzn1.application-oa2-client.e45ff1ade6064c24a265fe6924c6f75d"

// MARK: - MainPageVC

class MainPageVC: UIViewController {
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
        btn.setTitle("Refresh", for: .normal)
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
        
        sdk.ble.stopScan()
        print("stopScan")
    }
}

// MARK: - Actions

extension MainPageVC {
    
    // Register sdk
    func registerSDK() {
        // ble
        sdk.ble.addBleDelegate(api: self)
        sdk.ble.bluetoothRegister(heartPingSecond: 5, outputToConsole: false)
        sdk.ble.getBluetoothState { [weak self] stateModel in
            self?.bleState = stateModel
            self?.funcPage?.bleState = stateModel
        }

        // protocol library
        sdk.bridge.setupBridge(delegate: self, logType: .release)
        
        // alexa
        sdk.alexa.setupAlexa(delegate: self, clientId: clientId)
    }
    
    @objc func _reload() {
        if case .scanning = bleState?.scanType {
            sdk.ble.stopScan()
        } else {
            sdk.ble.startScan(macAddress: nil) { list in
                print("list count: \(String(describing: list?.count))")
            }
        }
    }
    
    @objc func scan() {
        sdk.ble.startScan(macAddress: nil) { list in
            print("list count: \(String(describing: list?.count))")
        }
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

// MARK: - IDOBleDelegate

extension MainPageVC: IDOBleDelegate {
    func writeState(state: IDOWriteStateModel) {
        if state.state == true && state.type == .withResponse {
            // 发送蓝牙数据完成
            sdk.bridge.writeDataComplete()
        }
    }
    
    func receiveData(data: IDOReceiveData) {
        if data.data != nil {
            // 蓝牙响应数据
            sdk.bridge.receiveDataFromBle(data: data.data!, macAddress: data.macAddress, useSPP: data.spp ?? false)
        } else {
            print("receiveData data is null")
        }
    }
    
    func scanResult(list: [IDODeviceModel]?) {
        print("scanResult list count:\(String(describing: list?.count))")
        dataList.removeAll()
        if list != nil {
            dataList.append(contentsOf: list!)
            tableView.reloadData()
        }
    }
    
    func bluetoothState(state: IDOBluetoothStateModel) {
        bleState = state
        funcPage?.bleState = state
        print("on bluetoothState callback: \(String(describing: state.scanType?.rawValue))")
    }
    
    func deviceState(state: IDODeviceStateModel) {
        deviceState = state
        funcPage?.deviceState = state
        print("on deviceState callback: \(String(describing: state.state))")
    }
    
    func stateSPP(state: IDOSppStateModel) {}
    
    func writeSPPCompleteState(btMacAddress: String) {}
}

// MARK: - IDOBridgeDelegate

extension MainPageVC: IDOBridgeDelegate {
    func registerWriteDataToBle(bleData: IDOBleData) {
        if bleData.data != nil {
            var tmpDevice: IDODeviceModel?
            if deviceState != nil {
                tmpDevice?.macAddress = deviceState?.macAddress
                tmpDevice?.uuid = deviceState?.uuid
            }
            // 写数据到蓝牙设备
            sdk.ble.writeData(data: bleData.data!, device: tmpDevice, type: bleData.type!) { rs in
                guard let type = rs.type else { return }
                if case .withoutResponse = type {
                    // 发送蓝牙数据完成
                    sdk.bridge.writeDataComplete()
                }
            }
        }
    }
    
    func listenStatusNotification(status: IDOStatusNotification) {
        print("StatusNotification: \(status)")
        NotificationCenter.default.post(name: Notify.onSdkStatusChanged, object: status)
    }
    
    func listenDeviceNotification(model: IDODeviceNotificationModel) {
        print("DeviceNotification: \(model)")
        NotificationCenter.default.post(name: Notify.onSdkDeviceStateChanged, object: model)
    }
}

// MARK: - IDOAlexaDelegate

extension MainPageVC: IDOAlexaDelegate {
    func getHealthValue(valueType: IDOGetValueType) -> Int {
        return 0
    }
    
    func getHrValue(dataType: Int, timeType: Int) -> Int {
        return 0
    }
    
    func functionControl(funType: Int) {}
}
