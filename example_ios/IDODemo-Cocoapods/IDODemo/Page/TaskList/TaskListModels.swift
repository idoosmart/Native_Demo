//
//  TaskListModels.swift
//  Runner
//
//  15.114 任务清单 — Example 联调用条目（非对外 API）
//  对齐 protocol_lib/example task_list_models.dart
//

import Foundation

final class TaskListItemDraft {
    /// 协议 uint32_t 最大值：task_id / remind_timestamp / complete_timestamp
    static let uint32Max = Int(UInt32.max)
    /// 兼容旧名
    static let taskIdMax = uint32Max

    static let taskDetailMaxChars = 70
    static let statusPending = 0
    static let statusDone = 1

    /// 任务 ID（协议 `uint32_t`，APP 分配）
    var taskId: Int
    /// 提醒时间：UTC 时间戳（秒，协议 `uint32_t`）
    var remindTimestamp: Int
    var taskDetail: String
    var status: Int
    /// 完成时间：UTC 时间戳（秒，协议 `uint32_t`）；status=0 时为 0
    var completeTimestamp: Int

    init(
        taskId: Int,
        remindTimestamp: Int,
        taskDetail: String = "",
        status: Int = statusPending,
        completeTimestamp: Int = 0
    ) {
        self.taskId = taskId
        self.remindTimestamp = remindTimestamp
        self.taskDetail = TaskListItemDraft.clampTaskDetail(taskDetail)
        self.status = status
        self.completeTimestamp = completeTimestamp
    }

    static func clampTaskDetail(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "" }
        if trimmed.count <= taskDetailMaxChars { return trimmed }
        let idx = trimmed.index(trimmed.startIndex, offsetBy: taskDetailMaxChars)
        return String(trimmed[..<idx])
    }

    static func sample(taskId: Int) -> TaskListItemDraft {
        let nowSec = Int(Date().timeIntervalSince1970)
        return TaskListItemDraft(
            taskId: taskId,
            remindTimestamp: nowSec,
            taskDetail: String(format: L10n.taskListSampleTask, taskId)
        )
    }

    func toCacheMap() -> [String: Any] {
        [
            "task_id": taskId,
            "remind_timestamp": remindTimestamp,
            "task_detail": taskDetail,
            "status": status,
            "complete_timestamp": completeTimestamp,
        ]
    }

    static func fromCacheMap(_ json: [String: Any]) -> TaskListItemDraft {
        let rawId = Self.parseUInt32(json["task_id"]) ?? 0
        return TaskListItemDraft(
            taskId: rawId,
            remindTimestamp: Self.parseUInt32(json["remind_timestamp"]) ?? 0,
            taskDetail: json["task_detail"] as? String ?? "",
            status: json["status"] as? Int ?? statusPending,
            completeTimestamp: Self.parseUInt32(json["complete_timestamp"]) ?? 0
        )
    }

    /// 解析协议 uint32 字段（兼容 Int / NSNumber）
    static func parseUInt32(_ value: Any?) -> Int? {
        if let n = value as? Int {
            guard n >= 0, n <= uint32Max else { return nil }
            return n
        }
        if let n = value as? UInt32 {
            return Int(n)
        }
        if let n = value as? NSNumber {
            let v = n.uint64Value
            guard v <= UInt64(UInt32.max) else { return nil }
            return Int(v)
        }
        return nil
    }

    /// 合法协议 uint32 数值：0…UInt32.max
    static func isValidUInt32(_ value: Int) -> Bool {
        value >= 0 && value <= uint32Max
    }

    /// 合法 uint32 任务 ID：1…UInt32.max（0 保留不用）
    static func isValidTaskId(_ id: Int) -> Bool {
        id >= 1 && id <= uint32Max
    }

    func statusLabel() -> String {
        status == Self.statusDone ? L10n.taskListStatusDone : L10n.taskListStatusPending
    }

    /// UTC 时间戳 + 本地时区格式化日期，例如 `1735689600 (2025-01-01 08:00:00)`
    static func formatUtcTimestamp(_ sec: Int) -> String {
        "\(sec) (\(formatLocalDateTime(sec)))"
    }

    /// 将 UTC 秒时间戳格式化为手机系统时区的 `yyyy-MM-dd HH:mm:ss`
    static func formatLocalDateTime(_ sec: Int) -> String {
        localDateTimeFormatter.timeZone = .current
        return localDateTimeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(sec)))
    }

    /// 兼容旧名：列表展示用本地时区
    static func formatUtcDateTime(_ sec: Int) -> String {
        formatLocalDateTime(sec)
    }

    static func dateFromUtcTimestamp(_ sec: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(sec))
    }

    static func utcTimestamp(from date: Date) -> Int {
        let sec = Int(date.timeIntervalSince1970)
        guard sec >= 0 else { return 0 }
        return min(sec, uint32Max)
    }

    private static let localDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    /// 列表统一展示：时间戳为 UTC；格式化日期为手机系统时区
    func listDisplayText() -> String {
        let detail = taskDetail.trimmingCharacters(in: .whitespacesAndNewlines)
        let detailText = detail.isEmpty ? L10n.taskListNoDetail : detail
        var lines = String(
            format: L10n.taskListItemDisplay,
            taskId,
            statusLabel(),
            remindTimestamp,
            Self.formatLocalDateTime(remindTimestamp),
            detailText
        )
        if status == Self.statusDone, completeTimestamp > 0 {
            lines += String(
                format: L10n.taskListCompleteDisplay,
                completeTimestamp,
                Self.formatLocalDateTime(completeTimestamp)
            )
        }
        return lines
    }

    func summary() -> String { listDisplayText() }

    func pendingSummary() -> String { listDisplayText() }
}
