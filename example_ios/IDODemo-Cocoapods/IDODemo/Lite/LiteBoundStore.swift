//
//  LiteBoundStore.swift
//  IDODemoLite
//
//  本地已绑定设备快照（面向 ScanInfo / uuid）
//

import Foundation
import CoreBluetooth

struct LiteBoundSnapshot: Codable {
    var mac: String
    var name: String
    var uuid: String
}

extension UserDefaults {
    private static let liteBoundDevicesKey = "lite-bound-devices"

    func saveLiteBoundDevice(mac: String, name: String?, uuid: String) {
        guard !mac.isEmpty, !uuid.isEmpty else { return }
        var list = loadLiteBoundSnapshots()
        list.removeAll { $0.mac.caseInsensitiveCompare(mac) == .orderedSame || $0.uuid == uuid }
        list.insert(LiteBoundSnapshot(mac: mac, name: name ?? mac, uuid: uuid), at: 0)
        persistLiteBoundSnapshots(list)
    }

    func removeLiteBoundDevice(mac: String) {
        var list = loadLiteBoundSnapshots()
        list.removeAll { $0.mac.caseInsensitiveCompare(mac) == .orderedSame }
        persistLiteBoundSnapshots(list)
    }

    func loadLiteBoundDevices() -> [LiteBoundSnapshot] {
        migrateLiteBoundFlagsIfNeeded()
        return loadLiteBoundSnapshots()
    }

    /// 通过 uuid 尝试还原 ScanInfo（需系统仍可 retrieve）
    func restoreScanInfo(from snapshot: LiteBoundSnapshot) -> ScanInfo? {
        guard let uuid = UUID(uuidString: snapshot.uuid) else { return nil }
        let peripherals = XYCBBase.shared.xyCentralManager.retrievePeripherals(withIdentifiers: [uuid])
        guard let peripheral = peripherals.first else { return nil }
        var adv: [String: Any] = [:]
        if !snapshot.name.isEmpty {
            adv["kCBAdvDataLocalName"] = snapshot.name
        }
        return ScanInfo(peripheral: peripheral, advertisementData: adv, rssi: 0)
    }

    private func loadLiteBoundSnapshots() -> [LiteBoundSnapshot] {
        guard let data = data(forKey: Self.liteBoundDevicesKey) else { return [] }
        return (try? JSONDecoder().decode([LiteBoundSnapshot].self, from: data)) ?? []
    }

    private func persistLiteBoundSnapshots(_ list: [LiteBoundSnapshot]) {
        let data = (try? JSONEncoder().encode(list)) ?? Data()
        set(data, forKey: Self.liteBoundDevicesKey)
    }

    private func migrateLiteBoundFlagsIfNeeded() {
        var list = loadLiteBoundSnapshots()
        let existingMacs = Set(list.map { $0.mac.uppercased() })
        var changed = false
        for (key, value) in dictionaryRepresentation() {
            guard key.hasPrefix(Constant.bindKey + "-"), let flag = value as? Bool, flag else { continue }
            let mac = String(key.dropFirst((Constant.bindKey + "-").count))
            guard !mac.isEmpty, !existingMacs.contains(mac.uppercased()) else { continue }
            list.append(LiteBoundSnapshot(mac: mac, name: mac, uuid: ""))
            changed = true
        }
        if changed {
            persistLiteBoundSnapshots(list)
        }
    }
}
