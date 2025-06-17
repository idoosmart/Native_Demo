//
//  Bridge.swift
//  IDODemoLite
//
//  Created by hc on 12/22/23.
//

import Foundation

import protocol_channel
import CoreBluetooth

let bleMgr = XYCentralManager.shared


// MARK: - Actions

extension MainPageVC {
    
    // Register sdk, 只执行一次
    func registerSDK() {
        // protocol library 注册（必需）（!!!重要）
        sdk.bridge.setupBridge(delegate: self, logType: .debug)
        
        // 如需使用Alexa， 需先注册
        sdk.alexa.setupAlexa(delegate: self, clientId: clientId)
        
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
        bleMgr.stopScan()
        print("stopScan")
    }
    
    
    
    @objc func _reload() {
        print("reload")
        bleMgr.stopScan()
        scan()
    }
    
    @objc func scan() {
        bleMgr.startScan { [weak self] obj in
            //print("list count: \(String(describing: bleMgr.scanInfoArray.count))")
            self?.dataList.removeAll()
            self?.dataList.append(contentsOf: bleMgr.scanInfoListSorted)
            self?.tableView.reloadData()
        }
    }
}


// MARK: - IDOBridgeDelegate

extension MainPageVC: IDOBridgeDelegate {
    func listenWaitingOtaDevice(otaDevice: protocol_channel.IDOOtaDeviceModel) {
        
    }
    
    
    // 需要将指令数据发到蓝牙设备（!!!重要）
    func writeDataToBle(bleData: protocol_channel.IDOBleData) {
        guard let device = currentDeviceModel else { return }
        
        guard let data = bleData.data else { return }
        guard data.count >= 2 else {
            print("空数据")
            return
        }
        let data0 = data[0]
        let data1 = data[1]
        let isTrans = (((data0 == 0xD1 || data0 == 0x13) && data1 == 0x02) || (data0 == 0x02 && data1 == 0x03))
        guard let characteristic = device.peripheral.writeCharacteristic() else { return }
        if (!isTrans) {
            bleMgr.write(peripheral: characteristic.0, characteristic: characteristic.1, data: data) { err in
                if err != nil {
                    print("写失败：\(err.debugDescription)")
                }else {
                    // 写完成 （!!!重要）
                    sdk.bridge.writeDataComplete()
                }
            }
        }else {
            // 不需要响应
            bleMgr.writeWithoutResponse(peripheral: characteristic.0, characteristic: characteristic.1, data: data)
            // 写完成 （!!!重要）
            sdk.bridge.writeDataComplete()
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
