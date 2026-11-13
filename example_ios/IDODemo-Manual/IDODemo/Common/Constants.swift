//
//  Constants.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import Foundation

struct Word {
    static let deviceConnect = "Device Connect"
    static let deviceDisconnect = "Device Disconnect"
    static let deviceBind = "Device Bind"
    static let deviceUnbind = "Device Unbind"
    static let setFunction = "Set Function"
    static let getFunction = "Get Function"
    static let syncData = "Sync Data"
    static let alexa = "Alexa"
    static let transFile = "Transfer File"
    static let sport = "Sport"
    static let testOC = "Test OC"
    static let exportLog = "Export logs"
    static let testBleChannel = "Test ble channel"
    static let epoUpgrade = "Epo Upgrade"
}


struct Constant {
    static let bindKey = "bind-state"
    
    /// 2秒一次交换简要运动数据
    /// 2-second interval for exchanging brief sport data
    static let intervalExchangeData = 2

    /// 40秒一次交换运动完整数据
    /// 40-second interval for exchanging complete sport data
    static let intervalExchangeCompleteData = 40

    /// 30秒一次交换V3心率数据
    /// 30-second interval for exchanging V3 heart rate data
    static let intervalExchangeHrData = 30
}


struct Notify {
    static let onSdkStatusChanged = Notification.Name("ido-sdk-onSdkStatusChanged")
    static let onSdkDeviceStateChanged = Notification.Name("ido-sdk-onSdkDeviceStateChanged")
    static let onBleDeviceStateChanged = Notification.Name("ido-sdk-onBleDeviceStateChanged")
    static let onBleStateChanged = Notification.Name("ido-sdk-onBleStateChanged")
    static let onBleReceiveDataChanged = Notification.Name("ido-sdk-onBleReceiveDataChanged")
}
