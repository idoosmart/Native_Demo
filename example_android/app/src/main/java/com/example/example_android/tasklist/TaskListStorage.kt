package com.example.example_android.tasklist

import com.example.example_android.util.SPUtil
import org.json.JSONArray

/**
 * 15.114 任务清单 — Example 本地缓存（key = 设备 MAC + task_list）
 * 对齐 protocol_lib/example task_list_storage.dart
 */
object TaskListStorage {
    fun cacheKey(macAddress: String): String = "${macAddress}task_list"

    fun load(macAddress: String): MutableList<TaskListItemDraft> {
        if (macAddress.isEmpty()) return mutableListOf()
        val raw = SPUtil.getAValue(cacheKey(macAddress), "") as? String
        if (raw.isNullOrEmpty()) return mutableListOf()
        return try {
            val arr = JSONArray(raw)
            val list = mutableListOf<TaskListItemDraft>()
            for (i in 0 until arr.length()) {
                list.add(TaskListItemDraft.fromCacheJson(arr.getJSONObject(i)))
            }
            list
        } catch (_: Exception) {
            mutableListOf()
        }
    }

    fun save(macAddress: String, items: List<TaskListItemDraft>) {
        if (macAddress.isEmpty()) return
        val arr = JSONArray()
        items.forEach { arr.put(it.toCacheJson()) }
        SPUtil.putAValue(cacheKey(macAddress), arr.toString())
    }

    fun clear(macAddress: String) {
        if (macAddress.isEmpty()) return
        SPUtil.putAValue(cacheKey(macAddress), "[]")
    }

    /** 设备解绑时清除任务清单缓存 */
    fun clearOnUnbind(macAddress: String?) {
        val mac = macAddress.orEmpty()
        if (mac.isEmpty()) return
        clear(mac)
    }
}
