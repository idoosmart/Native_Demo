//
//  Bridge.swift
//  IDODemoFull
//
//  Created by hc on 12/22/23.
//

import Foundation

import protocol_channel


// MARK: - Actions

extension MainPageVC {
    
    // Register sdk, 只执行一次
    func registerSDK() {
        sdk.ble.addBleDelegate(api: self)


        // protocol library
        sdk.bridge.setupBridge(delegate: self, logType: .release)
        
        // alexa
        sdk.alexa.setupAlexa(delegate: self, clientId: clientId)
        
        
        // 蓝牙状态
        sdk.ble.getBluetoothState { [weak self] stateModel in
            self?.bleState = stateModel
            self?.funcPage?.bleState = stateModel
        }
    }
    
    func stopScan() {
        sdk.ble.stopScan()
        print("stopScan")
    }
    
    @objc func _reload() {
        if case .scanning = bleState?.scanType {
            sdk.ble.stopScan()
        } else {
            sdk.ble.startScan(macAddress: nil) { list in
                //print("list count: \(String(describing: list?.count))")
            }
        }
    }
    
    @objc func scan() {
        
        sdk.ble.startScan(macAddress: nil) { list in
           //print("list count: \(String(describing: list?.count))")
        }
    }
    
}


// MARK: - IDOBleDelegate

extension MainPageVC: IDOBleDelegate {
    
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
}



// MARK: - IDOBridgeDelegate

extension MainPageVC: IDOBridgeDelegate {
    
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
