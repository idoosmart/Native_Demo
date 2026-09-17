//
//  Extension.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import Foundation
import UIKit
import protocol_channel
import SVProgressHUD
import CoreBluetooth

extension UIView {
    func showBorder(borderWidth: Float = 0.5, cornerRadius: Float = 12) {
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderWidth = CGFloat(borderWidth)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
    }
}

extension UIButton {
    static func createNormalButton(title: String? = nil, borderWidth: Float = 0.5, cornerRadius: Float = 12) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        let imgBg = UIColor.blue.createImage()
        btn.setBackgroundImage(imgBg, for: .normal)
        btn.showBorder(borderWidth: borderWidth, cornerRadius: cornerRadius)
        return btn
    }
}

private struct BoundDeviceSnapshot: Codable {
    var rssi: Int
    var name: String?
    var uuid: String?
    var macAddress: String?
    var otaMacAddress: String?
    var btMacAddress: String?
    var deviceId: Int
    var deviceType: Int
    var isOta: Bool
    var isTlwOta: Bool
    var bltVersion: Int
    var isPair: Bool
    var platform: Int

    func toModel() -> IDODeviceModel {
        IDODeviceModel(
            rssi: rssi,
            name: name,
            state: .disconnected,
            uuid: uuid,
            macAddress: macAddress,
            otaMacAddress: otaMacAddress,
            btMacAddress: btMacAddress,
            deviceId: deviceId,
            deviceType: deviceType,
            isOta: isOta,
            isTlwOta: isTlwOta,
            bltVersion: bltVersion,
            isPair: isPair,
            platform: platform
        )
    }

    static func from(_ device: IDODeviceModel) -> BoundDeviceSnapshot {
        BoundDeviceSnapshot(
            rssi: device.rssi,
            name: device.name,
            uuid: device.uuid,
            macAddress: device.macAddress,
            otaMacAddress: device.otaMacAddress,
            btMacAddress: device.btMacAddress,
            deviceId: device.deviceId,
            deviceType: device.deviceType,
            isOta: device.isOta,
            isTlwOta: device.isTlwOta,
            bltVersion: device.bltVersion,
            isPair: device.isPair,
            platform: device.platform
        )
    }
}

extension UserDefaults {
    private static let boundDevicesKey = "bound-devices"

    func isBind(_ macAddress: String) -> Bool {
        let key = Constant.bindKey + "-" + macAddress
        return bool(forKey: key)
    }

    func setBind(_ macAddress: String, isBind: Bool, device: IDODeviceModel? = nil) {
        let key = Constant.bindKey + "-" + macAddress
        setValue(isBind, forKey: key)
        if isBind {
            if let device = device {
                upsertBoundDevice(device)
            } else {
                upsertBoundDeviceIfAbsent(macAddress: macAddress)
            }
        } else {
            removeBoundDevice(macAddress)
        }
        synchronize()
    }

    func loadBoundDevices() -> [IDODeviceModel] {
        migrateBoundFlagsIfNeeded()
        return loadBoundSnapshots().map { $0.toModel() }
    }

    private func upsertBoundDevice(_ device: IDODeviceModel) {
        guard let mac = device.macAddress, !mac.isEmpty else { return }
        var list = loadBoundSnapshots()
        list.removeAll { $0.macAddress == mac }
        list.insert(BoundDeviceSnapshot.from(device), at: 0)
        persistBoundSnapshots(list)
    }

    private func upsertBoundDeviceIfAbsent(macAddress: String) {
        guard !macAddress.isEmpty else { return }
        var list = loadBoundSnapshots()
        if list.contains(where: { $0.macAddress == macAddress }) {
            return
        }
        list.insert(
            BoundDeviceSnapshot(
                rssi: 0,
                name: macAddress,
                uuid: nil,
                macAddress: macAddress,
                otaMacAddress: nil,
                btMacAddress: nil,
                deviceId: 0,
                deviceType: 0,
                isOta: false,
                isTlwOta: false,
                bltVersion: 0,
                isPair: false,
                platform: 0
            ),
            at: 0
        )
        persistBoundSnapshots(list)
    }

    private func removeBoundDevice(_ macAddress: String) {
        var list = loadBoundSnapshots()
        list.removeAll { $0.macAddress == macAddress }
        persistBoundSnapshots(list)
    }

    private func loadBoundSnapshots() -> [BoundDeviceSnapshot] {
        guard let data = data(forKey: Self.boundDevicesKey) else { return [] }
        return (try? JSONDecoder().decode([BoundDeviceSnapshot].self, from: data)) ?? []
    }

    private func persistBoundSnapshots(_ list: [BoundDeviceSnapshot]) {
        let data = (try? JSONEncoder().encode(list)) ?? Data()
        set(data, forKey: Self.boundDevicesKey)
    }

    /// 将仅有 bind-state 标记、尚无快照的已绑定设备补进列表
    private func migrateBoundFlagsIfNeeded() {
        var list = loadBoundSnapshots()
        let existingMacs = Set(list.compactMap { $0.macAddress })
        var changed = false
        for (key, value) in dictionaryRepresentation() {
            guard key.hasPrefix(Constant.bindKey + "-"), let flag = value as? Bool, flag else {
                continue
            }
            let mac = String(key.dropFirst((Constant.bindKey + "-").count))
            guard !mac.isEmpty, !existingMacs.contains(mac) else { continue }
            list.append(
                BoundDeviceSnapshot(
                    rssi: 0,
                    name: mac,
                    uuid: nil,
                    macAddress: mac,
                    otaMacAddress: nil,
                    btMacAddress: nil,
                    deviceId: 0,
                    deviceType: 0,
                    isOta: false,
                    isTlwOta: false,
                    bltVersion: 0,
                    isPair: false,
                    platform: 0
                )
            )
            changed = true
        }
        if changed {
            persistBoundSnapshots(list)
        }
    }
}




extension UIColor {
    func createImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            setFill()
            let path = UIBezierPath(rect: CGRect(origin: .zero, size: size))
            path.fill()
        }
        return image
    }
}

extension UITextView {
    func scrollToBottom() {
        guard contentSize.height > bounds.height else { return }
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height)
        setContentOffset(bottomOffset, animated: true)
    }
}

extension CBPeripheralState {
    var name: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting: 
            return "Connecting"
        case .connected: 
            return "Connected"
        case .disconnecting: 
            return "Disconnecting"
        @unknown default: 
            return "Unknown"
        }
    }
}

extension IDODeviceStateType {
    var name: String {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        @unknown default:
            return "Unknown"
        }
    }
}


func printProperties(_ obj: Any?) -> String? {
    guard let obj = obj else {
        return nil
    }
    let mirror = Mirror(reflecting: obj)
    var rs = "\(type(of: obj)) : {\n"
    for case let (label?, value) in mirror.children {
        rs += "\(label): \(value)\n"
    }
    rs += "}"
    return rs
}


