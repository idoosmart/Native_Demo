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
    // Register sdk, run only once
    func registerSDK() {
        sdk.ble.addBleDelegate(api: self)


        // protocol library
        sdk.bridge.setupBridge(delegate: self, logType: .debug)
        
        // alexa
        sdk.alexa.setupAlexa(delegate: self, clientId: clientId)
        
        
        // 蓝牙状态
        // Bluetooth state
        sdk.ble.getBluetoothState { [weak self] stateModel in
            self?.bleState = stateModel
            self?.funcPage?.bleState = stateModel
        }
        
        // epo upgrade
        IDOEpoManager.shared.enableAutoUpgrade = true
        IDOEpoManager.shared.delegateGetGps = self
        IDOEpoManager.shared.listenEpoUpgrade { status in
            print("epo---- status:\(status)")
        } downProgress: { progress in
            print("epo---- down progress:\(progress)")
        } sendProgress: { progress in
            print("epo---- send progress:\(progress)")
        } funcComplete: { errCode in
            print("epo---- complete:\(errCode)")
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
    func receiveData(data: protocol_channel.IDOReceiveData) {
        print("IDOBleDelegate - receiveData: \(data.data?.count ?? 0) Byte platform:\(data.platform)")
        if (data.platform == 2) {
            NotificationCenter.default.post(name: Notify.onBleReceiveDataChanged, object: data)
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
        print("on bluetoothState callback: \(String(describing: state.type.rawValue))")
        NotificationCenter.default.post(name: Notify.onBleStateChanged, object: state.type)
    }
    
    func deviceState(state: IDODeviceStateModel) {
        deviceState = state
        funcPage?.deviceState = state
        print("on deviceState callback: \(String(describing: state.state))")
        NotificationCenter.default.post(name: Notify.onBleDeviceStateChanged, object: state)
    }
}



// MARK: - IDOBridgeDelegate

extension MainPageVC: IDOBridgeDelegate {
    func listenWaitingOtaDevice(otaDevice: protocol_channel.IDOOtaDeviceModel) {
        
    }
    
    
    // SDK状态通知
    // SDK status notification
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
            // Bind auth code error, the device is force-unbound; the APP can update the bind state based on this notification
            break
        case .unbindOnBindStateError:
            // 出现该情况，可能是设备重置了
            // If this happens, the device may have been reset
            // 绑定状态异常，需要APP解绑 (APP记录的绑定状态和设备信息里的绑定状态不一致时触发)
            // Bind state error, the APP must unbind (APP-recorded bind state does not match the bind state in the device info)
            break
        case .fastSyncCompleted:
            // 快速配置完成
            // Fast config completed
            break
        case .fastSyncFailed:
            // 快速配置失败（需要APP重新连设备）
            // Fast config failed (the APP needs to reconnect the device)
            break
        case .deviceInfoBtAddressUpdateCompleted:
            break
        case .macAddressError:
            break
        case .syncHealthDataIng:
            // 同步健康数据中
            // Syncing health data
            break
        case .syncHealthDataCompleted:
            // 同步健康数据完成
            // Health data sync completed
            break
        @unknown default:
            break
        }
    }
    
    // 设备通知
    // Device notification
    func listenDeviceNotification(model: IDODeviceNotificationModel) {
        print("DeviceNotification: \(model)")
        NotificationCenter.default.post(name: Notify.onSdkDeviceStateChanged, object: model)
    }
    
    // APP提供设备绑定状态, 设备蓝牙连接时会调用该方法，如何返回true，将会走快速配置（获取设备功能表、设备信息、三级版本号、更新手表时间等）
    // APP provides the device bind state; this method is called when the device connects over Bluetooth. If it returns true, fast config runs (get the function table, device info, three-level version number, update the watch time, etc.)
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

// MARK: - IDOEpoManagerDelegate
extension MainPageVC: IDOEpoManagerDelegate{
    
    func getAppGpsInfo() -> protocol_channel.IDOOtaGpsInfo? {
        // !!!: 此处的经纬度是伪代码 | The latitude and longitude here are pseudocode
        return IDOOtaGpsInfo(longitude: 114.0579, latitude: 22.5431, altitude: 10)
    }
    
    
}
