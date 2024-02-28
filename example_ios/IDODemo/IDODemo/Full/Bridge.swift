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
        print("on bluetoothState callback: \(String(describing: state.scanType.rawValue))")
    }
    
    func deviceState(state: IDODeviceStateModel) {
        deviceState = state
        funcPage?.deviceState = state
        print("on deviceState callback: \(String(describing: state.state))")
    }
}



// MARK: - IDOBridgeDelegate

extension MainPageVC: IDOBridgeDelegate {
    
    // SDK状态通知
    func listenStatusNotification(status: IDOStatusNotification) {
        print("StatusNotification: \(status)")
        NotificationCenter.default.post(name: Notify.onSdkStatusChanged, object: status)
        switch (status) {
        case .protocolConnectCompleted:
            break
        case .functionTableUpdateCompleted:
            break
        case .deviceInfoUpdateCompleted:
            break
        case .deviceInfoFwVersionCompleted:
            break
        case .unbindOnAuthCodeError:
            // 绑定授权码异常，设备强制解绑，APP可根据该通知更新绑定状态
            break
        case .unbindOnBindStateError:
            // 出现该情况，可能是设备重置了
            // 绑定状态异常，需要APP解绑 (APP记录的绑定状态和设备信息里的绑定状态不一致时触发)
            break
        case .fastSyncCompleted:
            // 快速配置完成
            break
        case .fastSyncFailed:
            // 快速配置失败（需要APP重新连设备）
            break
        case .deviceInfoBtAddressUpdateCompleted:
            break
        case .macAddressError:
            break
        case .syncHealthDataIng:
            // 同步健康数据中
            break
        case .syncHealthDataCompleted:
            // 同步健康数据完成
            break
        @unknown default:
            break
        }
    }
    
    // 设备通知
    func listenDeviceNotification(model: IDODeviceNotificationModel) {
        print("DeviceNotification: \(model)")
        NotificationCenter.default.post(name: Notify.onSdkDeviceStateChanged, object: model)
    }
    
    // APP提供设备绑定状态, 设备蓝牙连接时会调用该方法，如何返回true，将会走快速配置（获取设备功能表、设备信息、三级版本号、更新手表时间等）
    func checkDeviceBindState(macAddress: String) -> Bool {
        let isBinded = UserDefaults.standard.isBind(macAddress)
        print("checkDeviceBindState mac\(macAddress) isBinded:\(isBinded)")
        return isBinded
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
