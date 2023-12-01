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
}


struct Constant {
    static let bindKey = "bind-state"
}


struct Notify {
    static let onSdkStatusChanged = Notification.Name("ido-sdk-onSdkStatusChanged")
    static let onSdkDeviceStateChanged = Notification.Name("ido-sdk-onSdkDeviceStateChanged")
}
