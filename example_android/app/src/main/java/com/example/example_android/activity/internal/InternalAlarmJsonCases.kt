package com.example.example_android.activity.internal

import com.google.gson.GsonBuilder
import com.idosmart.model.IDOAlarmModel
import com.idosmart.model.IDOAlarmNameCompat
import com.idosmart.model.IDOAlarmStatus
import com.idosmart.model.IDOAlarmType

/**
 * 闹钟 JSON：空 item / 脏 name（raw 对照 + repair）/ 越界 type·status。
 * 临时从 channel example 同步到 native Full（联调）。
 */
object InternalAlarmJsonCases {

    data class Result(
        val okCount: Int,
        val total: Int,
        val failNames: List<String>,
        val lines: List<String>
    ) {
        val summary: String
            get() = "AlarmDecode ok=$okCount/$total fail=${failNames.joinToString(",")}"

        /** customer_dirty_raw 在 iOS 上预期 FAIL；Android Gson 可能放过，故仍排除 */
        val unexpectedFails: List<String>
            get() = failNames.filter { it != "customer_dirty_raw" }

        val passed: Boolean
            get() = unexpectedFails.isEmpty()
    }

    private data class Case(
        val name: String,
        val json: String,
        val useRepair: Boolean,
        val assertTypeOther: Boolean,
        val assertStatusInvalid: Boolean,
        val assertNameKeepsBacktick: Boolean
    )

    fun runAll(): Result {
        // 双反斜杠：模拟线格式 JSON 中的 \uXXXX 转义文本（勿写成 Kotlin 的 \u 字面量）
        val customerDirtyPacket =
            """{"item":[{"alarm_id":10,"delay_min":10,"hour":64,"minute":0,"name":"\\u0002\\udeae\\udc3c\\u0013<`\\u0004","repeat":0,"repeat_times":3,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":84}],"num":1,"version":3}"""
        val type236LogPacket =
            """{"item":[{"alarm_id":1,"delay_min":10,"hour":24,"minute":201,"name":"\\u0a0a`","repeat":119,"repeat_times":3,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":236}],"num":1,"version":0}"""

        val cases = listOf(
            Case("empty_object", "{}", false, false, false, false),
            Case("item_null", """{"item":null}""", false, false, false, false),
            Case("item_empty", """{"item":[]}""", false, false, false, false),
            Case("item_null_with_num", """{"item":null,"num":0,"version":3}""", false, false, false, false),
            Case("missing_item_has_num", """{"num":0,"version":3}""", false, false, false, false),
            Case(
                "normal_one",
                """{"item":[{"alarm_id":1,"delay_min":0,"hour":7,"minute":30,"name":"Wake","repeat":254,"repeat_times":0,"shock_on_off":0,"status":1,"tsnooze_duration":0,"type":100}],"num":1,"version":3}""",
                false, true, false, false
            ),
            Case("customer_dirty_raw", customerDirtyPacket, false, false, false, false),
            Case("customer_dirty_repaired", customerDirtyPacket, true, true, false, true),
            Case("type_236_log", type236LogPacket, false, true, false, false),
            Case(
                "type_244",
                """{"item":[{"alarm_id":1,"delay_min":10,"hour":1,"minute":7,"name":"","repeat":0,"repeat_times":0,"shock_on_off":1,"status":0,"tsnooze_duration":0,"type":244}],"num":1,"version":0}""",
                false, true, false, false
            ),
            Case(
                "status_unknown",
                """{"item":[{"alarm_id":1,"delay_min":0,"hour":8,"minute":0,"name":"","repeat":0,"repeat_times":0,"shock_on_off":0,"status":99,"tsnooze_duration":0,"type":0}],"num":1,"version":0}""",
                false, false, true, false
            ),
        )

        val gsonBuilder = GsonBuilder()
        IDOAlarmModel().getDeSerializer()?.let { deSerializer ->
            gsonBuilder.registerTypeAdapter(IDOAlarmModel::class.java, deSerializer)
        }
        val gson = gsonBuilder.create()

        var okCount = 0
        val failNames = mutableListOf<String>()
        val lines = mutableListOf<String>()

        for (c in cases) {
            val payload =
                if (c.useRepair) IDOAlarmNameCompat.repairIllegalNameEscapes(c.json) else c.json
            if (c.useRepair) {
                lines.add("[AlarmDecode] repair applied for ${c.name}; changed=${payload != c.json}")
            }
            try {
                val model = gson.fromJson(payload, IDOAlarmModel::class.java)
                val first = model.items?.firstOrNull()
                val firstName = first?.name ?: ""
                val firstType = first?.type?.rawValue
                val firstStatus = first?.status
                if (c.assertTypeOther && firstType != IDOAlarmType.OTHER.rawValue) {
                    failNames.add(c.name)
                    lines.add("[AlarmDecode] FAIL ${c.name} assert type=$firstType expect=7")
                    continue
                }
                if (c.assertStatusInvalid && firstStatus != IDOAlarmStatus.INVALID) {
                    failNames.add(c.name)
                    lines.add("[AlarmDecode] FAIL ${c.name} assert status=$firstStatus expect=INVALID")
                    continue
                }
                if (c.assertNameKeepsBacktick) {
                    if (firstName.isEmpty() || !firstName.contains('`')) {
                        failNames.add(c.name)
                        lines.add("[AlarmDecode] FAIL ${c.name} assert name keeps backtick, got=\"$firstName\"")
                        continue
                    }
                }
                okCount += 1
                lines.add(
                    "[AlarmDecode] OK ${c.name} count=${model.items?.size ?: 0} name=\"$firstName\" type=$firstType status=$firstStatus repair=${c.useRepair}"
                )
            } catch (e: Exception) {
                failNames.add(c.name)
                lines.add("[AlarmDecode] FAIL ${c.name} repair=${c.useRepair}: $e")
            }
        }

        val summary = "AlarmDecode ok=$okCount/${cases.size} fail=${failNames.joinToString(",")}"
        lines.add("[AlarmDecode] $summary")
        return Result(okCount, cases.size, failNames, lines)
    }
}
