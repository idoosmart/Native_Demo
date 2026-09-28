//
//  LiteBoundStore.swift
//  IDODemoLite
//
//  Lite 已绑定设备快照（mac / name / uuid）。与 Full 快照隔离。
//

import Foundation
import CoreBluetooth

struct LiteBoundSnapshot: Codable {
    var mac: String
    var name: String
    var uuid: String

    /// 等 Central poweredOn 后还原 ScanInfo，供功能页连接。
    func restoreScanInfo(completion: @escaping (ScanInfo?) -> Void) {
        bleMgr.retrieveScanInfo(uuid: uuid, name: name, completion: completion)
    }
}

extension UserDefaults {
    private static let liteBoundDevicesKey = "lite-bound-devices"

    /// Lite：只写绑定标志；展示列表用 saveLiteBoundDevice / removeLiteBoundDevice。
    func setBind(_ macAddress: String, isBind: Bool) {
        let key = Constant.bindKey + "-" + macAddress
        setValue(isBind, forKey: key)
        synchronize()
    }

    func loadLiteBoundDevices() -> [LiteBoundSnapshot] {
        guard let data = data(forKey: Self.liteBoundDevicesKey) else { return [] }
        return (try? JSONDecoder().decode([LiteBoundSnapshot].self, from: data)) ?? []
    }

    func isLiteBound(uuid: String) -> Bool {
        loadLiteBoundDevices().contains { $0.uuid == uuid }
    }

    func saveLiteBoundDevice(mac: String, name: String, uuid: String) {
        // uuid 为空无法 retrieve，拒绝写入列表（绑定标志仍可由 setBind 单独写入）
        guard !mac.isEmpty, !uuid.isEmpty, UUID(uuidString: uuid) != nil else { return }
        var list = loadLiteBoundDevices()
        list.removeAll { $0.mac == mac || $0.uuid == uuid }
        list.insert(LiteBoundSnapshot(mac: mac, name: name.isEmpty ? mac : name, uuid: uuid), at: 0)
        persistLiteBoundDevices(list)
    }

    func removeLiteBoundDevice(mac: String) {
        var list = loadLiteBoundDevices()
        list.removeAll { $0.mac == mac }
        persistLiteBoundDevices(list)
    }

    private func persistLiteBoundDevices(_ list: [LiteBoundSnapshot]) {
        let data = (try? JSONEncoder().encode(list)) ?? Data()
        set(data, forKey: Self.liteBoundDevicesKey)
        synchronize()
    }
}
