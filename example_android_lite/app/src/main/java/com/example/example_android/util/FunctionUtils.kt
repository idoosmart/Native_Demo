package com.example.example_android.util

import android.bluetooth.BluetoothAdapter
import com.clj.fastble.data.BleDevice
import com.example.example_android.appContext
import org.json.JSONArray
import org.json.JSONObject

/** 首页展示用的已绑定设备快照。点击时再用系统蓝牙还原 [BleDevice]。 */
data class BoundDeviceInfo(val mac: String, val name: String) {
    fun toBleDevice(): BleDevice? {
        if (mac.isEmpty()) {
            return null
        }
        return try {
            val remote = BluetoothAdapter.getDefaultAdapter()?.getRemoteDevice(mac) ?: return null
            BleDevice(remote)
        } catch (_: Exception) {
            null
        }
    }
}

object FunctionUtils {
    private const val BIND_KEY = "bindkey"
    private const val BOUND_DEVICES_KEY = "bound_devices"
    /** 与 [SPUtil] 默认文件 `idodemo` 对应，实际文件名为 `sp_idodemo` */
    private const val SP_FILE = "sp_idodemo"

    /**
     * 获取设备绑定状态
     * */
    fun isBind(macAddress: String): Boolean {
        return SPUtil.getAValue(BIND_KEY + macAddress, false) as Boolean
    }

    /**
     * 保存设备绑定状态
     * */
    fun saveBindState(macAddress: String) {
        SPUtil.putAValue(BIND_KEY + macAddress, true)
        upsertBoundDeviceIfAbsent(macAddress)
    }

    /**
     * 保存已绑定设备快照（mac + 名称），供首页列表展示
     */
    fun saveBoundDevice(device: BleDevice) {
        val mac = device.mac ?: return
        if (mac.isEmpty()) {
            return
        }
        val name = device.name?.takeIf { it.isNotEmpty() } ?: mac
        SPUtil.putAValue(BIND_KEY + mac, true)
        upsertBoundDevice(BoundDeviceInfo(mac, name))
    }

    /**
     * 改变设备绑定状态
     * */
    fun removeBindState(macAddress: String) {
        SPUtil.putAValue(BIND_KEY + macAddress, false)
        removeBoundDevice(macAddress)
    }

    fun loadBoundDevices(): MutableList<BoundDeviceInfo> {
        migrateBoundFlagsIfNeeded()
        return loadBoundDeviceList()
    }

    private fun upsertBoundDevice(info: BoundDeviceInfo) {
        val list = loadBoundDeviceList()
        list.removeAll { it.mac == info.mac }
        list.add(0, info)
        persistBoundDevices(list)
    }

    private fun upsertBoundDeviceIfAbsent(macAddress: String) {
        if (macAddress.isEmpty()) {
            return
        }
        val list = loadBoundDeviceList()
        if (list.any { it.mac == macAddress }) {
            return
        }
        list.add(0, BoundDeviceInfo(macAddress, macAddress))
        persistBoundDevices(list)
    }

    private fun removeBoundDevice(macAddress: String) {
        val list = loadBoundDeviceList()
        list.removeAll { it.mac == macAddress }
        persistBoundDevices(list)
    }

    private fun loadBoundDeviceList(): MutableList<BoundDeviceInfo> {
        val json = SPUtil.getAValue(BOUND_DEVICES_KEY, "") as? String ?: ""
        if (json.isEmpty()) {
            return mutableListOf()
        }
        return try {
            val array = JSONArray(json)
            val list = mutableListOf<BoundDeviceInfo>()
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                val mac = obj.optString("mac")
                if (mac.isEmpty()) {
                    continue
                }
                val name = obj.optString("name").ifEmpty { mac }
                list.add(BoundDeviceInfo(mac, name))
            }
            list
        } catch (_: Exception) {
            mutableListOf()
        }
    }

    private fun persistBoundDevices(list: List<BoundDeviceInfo>) {
        val array = JSONArray()
        list.forEach {
            array.put(JSONObject().apply {
                put("mac", it.mac)
                put("name", it.name)
            })
        }
        SPUtil.putAValue(BOUND_DEVICES_KEY, array.toString())
    }

    /**
     * 将仅有绑定标记、尚无快照的设备补进列表
     */
    private fun migrateBoundFlagsIfNeeded() {
        val existing = loadBoundDeviceList()
        val existingMacs = existing.map { it.mac }.toSet()
        val prefs = appContext.getSharedPreferences(SP_FILE, android.content.Context.MODE_PRIVATE)
        var changed = false
        for ((key, value) in prefs.all) {
            if (key == BOUND_DEVICES_KEY || !key.startsWith(BIND_KEY) || value != true) {
                continue
            }
            val mac = key.removePrefix(BIND_KEY)
            if (mac.isNotEmpty() && !existingMacs.contains(mac)) {
                existing.add(BoundDeviceInfo(mac, mac))
                changed = true
            }
        }
        if (changed) {
            persistBoundDevices(existing)
        }
    }
}
