//
//  TaskListStorage.swift
//  Runner
//
//  15.114 任务清单 — Example 本地缓存（key = 设备 MAC + task_list）
//  对齐 protocol_lib/example task_list_storage.dart
//

import Foundation

enum TaskListStorage {
    static func cacheKey(_ macAddress: String) -> String {
        "\(macAddress)task_list"
    }

    static func load(_ macAddress: String) -> [TaskListItemDraft] {
        guard !macAddress.isEmpty,
              let data = UserDefaults.standard.data(forKey: cacheKey(macAddress)),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return arr.map { TaskListItemDraft.fromCacheMap($0) }
    }

    static func save(_ macAddress: String, items: [TaskListItemDraft]) {
        guard !macAddress.isEmpty else { return }
        let maps = items.map { $0.toCacheMap() }
        if let data = try? JSONSerialization.data(withJSONObject: maps, options: []) {
            UserDefaults.standard.set(data, forKey: cacheKey(macAddress))
        }
    }

    static func clear(_ macAddress: String) {
        guard !macAddress.isEmpty else { return }
        UserDefaults.standard.removeObject(forKey: cacheKey(macAddress))
    }

    /// 设备解绑时清除任务清单缓存（同时清 short / full MAC，避免键不一致）
    static func clearOnUnbind(macAddress: String, alternateMac: String? = nil) {
        var keys = Set<String>()
        if !macAddress.isEmpty { keys.insert(macAddress) }
        if let alt = alternateMac, !alt.isEmpty { keys.insert(alt) }
        for mac in keys {
            clear(mac)
        }
        guard !keys.isEmpty else { return }
        NotificationCenter.default.post(name: Notify.onTaskListCacheCleared, object: nil)
    }
}
