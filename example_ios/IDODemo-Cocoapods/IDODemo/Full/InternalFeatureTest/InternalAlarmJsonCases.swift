//
//  InternalAlarmJsonCases.swift
//  IDODemo (native Full temp — temp sync to native Full)
//
//  闹钟 JSON：空 item / 脏 name（先 raw FAIL，再 repair OK）/ 越界 type·status
//

import Foundation
import protocol_channel

enum InternalAlarmJsonCases {

    struct Result {
        let okCount: Int
        let total: Int
        let failNames: [String]
        let lines: [String]

        var summary: String {
            "AlarmDecode ok=\(okCount)/\(total) fail=\(failNames.joined(separator: ","))"
        }

        /// customer_dirty_raw 预期 FAIL；其余失败为意外
        var unexpectedFails: [String] {
            failNames.filter { $0 != "customer_dirty_raw" }
        }

        var passed: Bool { unexpectedFails.isEmpty }
    }

    /// 跑全部用例，返回日志行与汇总（不弹 HUD）
    static func runAll() -> Result {
        let customerDirtyPacket =
            #"{"item":[{"alarm_id":10,"delay_min":10,"hour":64,"minute":0,"name":"\u0002\udeae\udc3c\u0013<`\u0004","repeat":0,"repeat_times":3,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":84}],"num":1,"version":3}"#
        let type236LogPacket =
            #"{"item":[{"alarm_id":1,"delay_min":10,"hour":24,"minute":201,"name":"\u0a0a`","repeat":119,"repeat_times":3,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":236}],"num":1,"version":0}"#

        // name, json, useRepair, assertTypeOther, assertStatusInvalid, assertNameKeepsBacktick
        let cases: [(String, String, Bool, Bool, Bool, Bool)] = [
            ("empty_object", "{}", false, false, false, false),
            ("item_null", #"{"item":null}"#, false, false, false, false),
            ("item_empty", #"{"item":[]}"#, false, false, false, false),
            ("item_null_with_num", #"{"item":null,"num":0,"version":3}"#, false, false, false, false),
            ("missing_item_has_num", #"{"num":0,"version":3}"#, false, false, false, false),
            ("normal_one", #"{"item":[{"alarm_id":1,"delay_min":0,"hour":7,"minute":30,"name":"Wake","repeat":254,"repeat_times":0,"shock_on_off":0,"status":1,"tsnooze_duration":0,"type":100}],"num":1,"version":3}"#, false, true, false, false),
            // raw：不 repair，预期 FAIL（对照 getAlarm 首次失败）
            ("customer_dirty_raw", customerDirtyPacket, false, false, false, false),
            // repair：只删非法代理对，预期 OK；name 仍含 `
            ("customer_dirty_repaired", customerDirtyPacket, true, true, false, true),
            ("type_236_log", type236LogPacket, false, true, false, false),
            ("type_244", #"{"item":[{"alarm_id":1,"delay_min":10,"hour":1,"minute":7,"name":"","repeat":0,"repeat_times":0,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":244}],"num":1,"version":0}"#, false, true, false, false),
            ("status_unknown", #"{"item":[{"alarm_id":1,"delay_min":0,"hour":8,"minute":0,"name":"","repeat":0,"repeat_times":0,"shock_on_off":0,"status":99,"tsnooze_duration":0,"type":0}],"num":1,"version":0}"#, false, false, true, false),
        ]

        var okCount = 0
        var failNames: [String] = []
        var lines: [String] = []

        for (name, json, useRepair, assertTypeOther, assertStatusInvalid, assertNameKeepsBacktick) in cases {
            let payload = useRepair ? IDOAlarmNameCompat.repairIllegalNameEscapes(json) : json
            if useRepair {
                lines.append("[AlarmDecode] repair applied for \(name); changed=\(payload != json)")
            }
            do {
                let data = Data(payload.utf8)
                let model = try JSONDecoder().decode(IDOAlarmModel.self, from: data)
                let objc = try JSONDecoder().decode(IDOAlarmModelObjc.self, from: data)
                let firstName = model.items.first?.name ?? ""
                let firstType = model.items.first?.type.rawValue
                let firstStatus = model.items.first?.status
                if assertTypeOther, firstType != IDOAlarmType.other.rawValue {
                    failNames.append(name)
                    lines.append("[AlarmDecode] FAIL \(name) assert type=\(String(describing: firstType)) expect=7")
                    continue
                }
                if assertStatusInvalid, firstStatus != .invalid {
                    failNames.append(name)
                    lines.append("[AlarmDecode] FAIL \(name) assert status=\(String(describing: firstStatus)) expect=invalid")
                    continue
                }
                if assertNameKeepsBacktick {
                    if firstName.isEmpty || !firstName.contains("`") {
                        failNames.append(name)
                        lines.append("[AlarmDecode] FAIL \(name) assert name keeps backtick, got=\"\(firstName)\"")
                        continue
                    }
                }
                okCount += 1
                lines.append(
                    "[AlarmDecode] OK \(name) count=\(model.items.count) objc=\(objc.items.count) name=\"\(firstName)\" type=\(String(describing: firstType)) status=\(String(describing: firstStatus)) repair=\(useRepair)"
                )
            } catch {
                failNames.append(name)
                lines.append("[AlarmDecode] FAIL \(name) repair=\(useRepair): \(error)")
            }
        }

        var allLines = lines
        let summary = "AlarmDecode ok=\(okCount)/\(cases.count) fail=\(failNames.joined(separator: ","))"
        allLines.append("[AlarmDecode] \(summary)")
        return Result(okCount: okCount, total: cases.count, failNames: failNames, lines: allLines)
    }
}
