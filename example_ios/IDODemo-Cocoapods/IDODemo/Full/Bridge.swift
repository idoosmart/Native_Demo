//
//  Bridge.swift
//  IDODemoFull
//
//  Created by hc on 12/22/23.
//

import Foundation

import protocol_channel
import SVProgressHUD


// MARK: - Actions

extension MainPageVC {
    
    // Register sdk, 只执行一次
    func registerSDK() {
        sdk.ble.addBleDelegate(api: self)


        // protocol library
        sdk.bridge.setupBridge(delegate: self, logType: .debug)
        
        // alexa
        sdk.alexa.setupAlexa(delegate: self, clientId: clientId)
        
        
        // 蓝牙状态
        sdk.ble.getBluetoothState { [weak self] stateModel in
            self?.bleState = stateModel
            self?.funcPage?.bleState = stateModel
        }
        
        initEpoAutoUpdate()
    }
    
    func stopScan() {
        sdk.ble.stopScan()
        print("stopScan")
    }
    
    @objc func _reload() {
        print("reload \(L10n.refresh)")  
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
        //print("scanResult list count:\(String(describing: list?.count))")
        dataList.removeAll()
        if list != nil {
            dataList.append(contentsOf: list!)
            tableView.reloadData()
        }
        
        let otaModel = dataList.first {
            print("deviceId: \($0.deviceId) isOta:\($0.isOta) macAddress:\($0.macAddress)")
            return $0.isOta
        }
        if otaModel != nil {
            if sdk.device.deviceId == 0 || sdk.device.deviceId != otaModel?.deviceId {
                stopScan() // 停止扫描
                print("call bridge.markOtaMode, address:\(otaModel!.macAddress) platform:\(otaModel!.platform)")
                sdk.bridge.markOtaMode?(macAddress: otaModel!.macAddress ?? "",
                                        iosUUID: otaModel!.uuid ?? "",
                                        platform: otaModel!.platform,
                                        deviceId: otaModel!.deviceId,
                                        completion: { [weak self] _ in
                    self?._otaMode()
                })
            }else {
                _otaMode()
            }
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
        print("on deviceState callback state: \(String(describing: state.state.rawValue)) errorState: \(String(describing: state.errorState.rawValue))")
        NotificationCenter.default.post(name: Notify.onBleDeviceStateChanged, object: state)
        /*
         * This is an example.
         * device Already Bind And Not Support Rebind
         * device Has Been Reset
         */
        handlePairErrorAlert(state)
    }
    
    func handlePairErrorAlert(_ deviceState: IDODeviceStateModel){
        if (deviceState.errorState == IDOConnectErrorType.deviceAlreadyBindAndNotSupportRebind) {
            let alert = UIAlertController(title: "Note",
                                          message: "The watch has been bound and does not support repeated binding, First reset the watch on the watch side!",
                                          preferredStyle: UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "Got it", style: UIAlertAction.Style.default) { action in
                self.dismiss(animated: true)
            }
            
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else if (deviceState.errorState == IDOConnectErrorType.deviceHasBeenReset) {
            
            let alert = UIAlertController(title: "Note",
                                          message: "The watch has been reset, pls remove the watch!",
                                          preferredStyle: UIAlertController.Style.alert)
            let delete = UIAlertAction(title: "Remove it",
                                       style: UIAlertAction.Style.default) { action in
                
                SVProgressHUD.show(withStatus: "unbind...")
                guard let macAddress = deviceState.macAddress else {
                    SVProgressHUD.showSuccess(withStatus: "macAddress is nil")
                    return
                }
    
                sdk.cmd.unbind(macAddress: macAddress , isForceRemove: true, completion: { [weak self] rs in
                    self?.tableView.reloadData()
                    if rs {
                        SVProgressHUD.showSuccess(withStatus: "unbind successful")
                    } else {
                        SVProgressHUD.showError(withStatus: "unbind failure")
                    }
                    UserDefaults.standard.setBind(macAddress, isBind: false)
                    UserDefaults.standard.synchronize()
                    self?.dismiss(animated: true)
                })
               
            }
            
            alert.addAction(delete)
            present(alert, animated: true, completion: nil)
        }
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
    
    func listenWaitingOtaDevice(otaDevice: protocol_channel.IDOOtaDeviceModel) {
        print("\n otaDevice:\(otaDevice.description)\n")
        _otaMode()
    }
    
    func _otaMode() {
        SVProgressHUD.dismiss()
        let alert = UIAlertController(title: "OTA Mode", message: "当前设备处理OTA模式，现在去升级？/ The current device handles OTA mode, upgrade now?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let vc = TransferFileDetailVC(cmd: .ota)
            navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
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
