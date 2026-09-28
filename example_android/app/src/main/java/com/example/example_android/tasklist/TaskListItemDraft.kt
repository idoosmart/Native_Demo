package com.example.example_android.tasklist

import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * 15.114 任务清单 — Example 联调用条目（非对外 API）
 * 对齐 iOS TaskListModels / Dart task_list_models
 * 协议 task_id / remind_timestamp / complete_timestamp 均为 uint32_t
 */
data class TaskListItemDraft(
    /** 任务 ID（协议 uint32_t：0…4294967295） */
    var taskId: Long,
    /** 提醒时间：UTC 时间戳（秒），协议 uint32_t */
    var remindTimestamp: Long,
    var taskDetail: String = "",
    /** 0 未完成；1 已完成 */
    var status: Int = STATUS_PENDING,
    /** 完成时间：UTC 时间戳（秒）；status=0 时为 0，协议 uint32_t */
    var completeTimestamp: Long = 0,
) {
    init {
        taskDetail = clampTaskDetail(taskDetail)
    }

    fun toSetJson(): JSONObject {
        val detail = clampTaskDetail(taskDetail)
        val map = JSONObject()
        map.put("task_id", taskId)
        map.put("remind_timestamp", remindTimestamp)
        if (detail.isNotEmpty()) {
            map.put("task_detail", detail)
        }
        return map
    }

    fun toCacheJson(): JSONObject {
        return JSONObject()
            .put("task_id", taskId)
            .put("remind_timestamp", remindTimestamp)
            .put("task_detail", taskDetail)
            .put("status", status)
            .put("complete_timestamp", completeTimestamp)
    }

    fun statusLabel(): String = if (status == STATUS_DONE) "已完成" else "未完成"

    fun listDisplayText(): String {
        val detail = taskDetail.trim().ifEmpty { "(无详情)" }
        val sb = StringBuilder()
        sb.append("任务ID：").append(taskId).append('\n')
        sb.append("任务状态：").append(statusLabel()).append('\n')
        sb.append("提醒时间UTC 时间戳：").append(remindTimestamp).append('\n')
        sb.append("日期（本地）：").append(formatLocalDateTime(remindTimestamp)).append('\n')
        sb.append("任务详情：").append(detail)
        if (status == STATUS_DONE && completeTimestamp > 0L) {
            sb.append('\n')
                .append("完成时间UTC 时间戳：").append(completeTimestamp).append('\n')
                .append("完成日期（本地）：").append(formatLocalDateTime(completeTimestamp))
        }
        return sb.toString()
    }

    fun summary(): String = listDisplayText()

    /** 下发 SDK：channel Model 用 Long 承载协议 uint32_t */
    fun taskIdForSdk(): Long = taskId and UINT32_MAX

    fun remindTimestampForSdk(): Long = remindTimestamp and UINT32_MAX

    fun completeTimestampForSdk(): Long = completeTimestamp and UINT32_MAX

    companion object {
        const val TASK_DETAIL_MAX_CHARS = 70
        const val STATUS_PENDING = 0
        const val STATUS_DONE = 1
        /** 协议 uint32_t 最大值（task_id / remind_timestamp / complete_timestamp） */
        const val UINT32_MAX = 0xFFFFFFFFL
        /** 兼容旧名 */
        const val TASK_ID_MAX = UINT32_MAX

        private val DETAILS = listOf(
            "开会提醒",
            "吃药提醒",
            "运动打卡",
            "喝水提醒",
            "回电客户",
            "提交日报",
            "取快递",
            "健身训练",
            "超市采购",
            "整理邮件",
            "午休闹钟",
            "家人通话",
        )

        fun detailPool(): List<String> = DETAILS

        fun isValidUInt32(value: Long): Boolean = value in 0L..UINT32_MAX

        fun isValidTaskId(id: Long): Boolean = id in 1L..UINT32_MAX

        fun parseUInt32(value: Any?): Long? {
            return when (value) {
                is Number -> {
                    val v = value.toLong()
                    if (v in 0L..UINT32_MAX) v else null
                }
                is String -> value.toLongOrNull()?.takeIf { it in 0L..UINT32_MAX }
                else -> null
            }
        }

        fun clampTaskDetail(value: String): String {
            val trimmed = value.trim()
            if (trimmed.isEmpty()) return ""
            return if (trimmed.length <= TASK_DETAIL_MAX_CHARS) {
                trimmed
            } else {
                trimmed.substring(0, TASK_DETAIL_MAX_CHARS)
            }
        }

        fun makeRandom(
            taskId: Long,
            remindTimestamp: Long,
            taskDetail: String,
        ): TaskListItemDraft {
            return TaskListItemDraft(
                taskId = taskId,
                remindTimestamp = remindTimestamp,
                taskDetail = clampTaskDetail(taskDetail),
            )
        }

        fun sample(taskId: Long): TaskListItemDraft {
            val nowSec = System.currentTimeMillis() / 1000L
            return TaskListItemDraft(
                taskId = taskId,
                remindTimestamp = nowSec + 600L,
                taskDetail = "示例任务 $taskId",
            )
        }

        fun fromCacheJson(json: JSONObject): TaskListItemDraft {
            return TaskListItemDraft(
                taskId = parseUInt32(json.opt("task_id")) ?: 0L,
                remindTimestamp = parseUInt32(json.opt("remind_timestamp")) ?: 0L,
                taskDetail = json.optString("task_detail", ""),
                status = json.optInt("status", STATUS_PENDING),
                completeTimestamp = parseUInt32(json.opt("complete_timestamp")) ?: 0L,
            )
        }

        fun formatLocalDateTime(sec: Long): String {
            val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
            sdf.timeZone = TimeZone.getDefault()
            return sdf.format(Date(sec * 1000L))
        }

        fun formatUtcDateTime(sec: Long): String = formatLocalDateTime(sec)

        /** UTC 秒 → 本地 Calendar（用于日期时间选择器） */
        fun localCalendarFromUtcSec(sec: Long): Calendar {
            return Calendar.getInstance().apply {
                timeInMillis = sec.coerceIn(0L, UINT32_MAX) * 1000L
            }
        }

        /**
         * 本地墙钟年月日时分秒 → UTC 秒时间戳。
         * [month] 为 1…12（与用户选择一致，内部转 Calendar 0-based）。
         */
        fun utcSecFromLocal(
            year: Int,
            month: Int,
            day: Int,
            hour: Int,
            minute: Int,
            second: Int,
        ): Long {
            val cal = Calendar.getInstance()
            cal.set(Calendar.YEAR, year)
            cal.set(Calendar.MONTH, (month - 1).coerceIn(0, 11))
            cal.set(Calendar.DAY_OF_MONTH, day.coerceIn(1, 31))
            cal.set(Calendar.HOUR_OF_DAY, hour.coerceIn(0, 23))
            cal.set(Calendar.MINUTE, minute.coerceIn(0, 59))
            cal.set(Calendar.SECOND, second.coerceIn(0, 59))
            cal.set(Calendar.MILLISECOND, 0)
            return (cal.timeInMillis / 1000L).coerceIn(0L, UINT32_MAX)
        }
    }
}
