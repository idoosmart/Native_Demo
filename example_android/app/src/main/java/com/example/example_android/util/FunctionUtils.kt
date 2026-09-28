package com.example.example_android.util

import com.example.example_android.appContext
import com.idosmart.model.IDOBleDeviceModel
import org.json.JSONArray
import org.json.JSONObject

object FunctionUtils {
    private const val BIND_KEY = "bindkey"
    private const val BOUND_DEVICES_KEY = "bound_devices"
    /** 与 [SPUtil] 默认文件 `idodemo` 对应，实际文件名为 `sp_idodemo` */
    private const val SP_FILE = "sp_idodemo"

    /**
     * 获取设备绑定状态
     * */
    fun getDeviceMac(macAddress: String): Boolean {
        return SPUtil.getAValue(BIND_KEY + macAddress, false) as Boolean
    }
    /**
     * 保存设备绑定状态
     * */
    fun saveDeviceMac(macAddress: String) {
        SPUtil.putAValue(BIND_KEY + macAddress, true)
        upsertBoundDeviceIfAbsent(macAddress)
    }

    /**
     * 保存已绑定设备快照，供首页列表还原并连接
     */
    fun saveBoundDevice(device: IDOBleDeviceModel) {
        val mac = device.macAddress ?: return
        SPUtil.putAValue(BIND_KEY + mac, true)
        upsertBoundDevice(device)
    }

    /**
     * 改变设备绑定状态
     * */
    fun upDataDeviceMac(macAddress: String) {
        SPUtil.putAValue(BIND_KEY + macAddress, false)
        removeBoundDevice(macAddress)
    }

    fun loadBoundDevices(): MutableList<IDOBleDeviceModel> {
        migrateBoundFlagsIfNeeded()
        return loadBoundDeviceList()
    }

    private fun upsertBoundDevice(device: IDOBleDeviceModel) {
        val mac = device.macAddress ?: return
        val list = loadBoundDeviceList()
        list.removeAll { it.macAddress == mac }
        list.add(0, device)
        persistBoundDevices(list)
    }

    private fun upsertBoundDeviceIfAbsent(macAddress: String) {
        if (macAddress.isEmpty()) {
            return
        }
        val list = loadBoundDeviceList()
        if (list.any { it.macAddress == macAddress }) {
            return
        }
        list.add(0, IDOBleDeviceModel(name = macAddress, macAddress = macAddress))
        persistBoundDevices(list)
    }

    private fun removeBoundDevice(macAddress: String) {
        val list = loadBoundDeviceList()
        list.removeAll { it.macAddress == macAddress }
        persistBoundDevices(list)
    }

    private fun loadBoundDeviceList(): MutableList<IDOBleDeviceModel> {
        val json = SPUtil.getAValue(BOUND_DEVICES_KEY, "") as? String ?: ""
        if (json.isEmpty()) {
            return mutableListOf()
        }
        return try {
            val array = JSONArray(json)
            val list = mutableListOf<IDOBleDeviceModel>()
            for (i in 0 until array.length()) {
                list.add(fromJson(array.getJSONObject(i)))
            }
            list
        } catch (_: Exception) {
            mutableListOf()
        }
    }

    private fun persistBoundDevices(list: List<IDOBleDeviceModel>) {
        val array = JSONArray()
        list.forEach { array.put(toJson(it)) }
        SPUtil.putAValue(BOUND_DEVICES_KEY, array.toString())
    }

    private fun toJson(device: IDOBleDeviceModel): JSONObject {
        return JSONObject().apply {
            put("rssi", device.rssi ?: 0)
            put("name", device.name ?: "")
            put("uuid", device.uuid ?: "")
            put("macAddress", device.macAddress ?: "")
            put("otaMacAddress", device.otaMacAddress ?: "")
            put("btMacAddress", device.btMacAddress ?: "")
            put("deviceId", device.deviceId ?: 0)
            put("deviceType", device.deviceType ?: 0)
            put("isOta", device.isOta ?: false)
            put("isTlwOta", device.isTlwOta ?: false)
            put("bltVersion", device.bltVersion ?: 0)
            put("isPair", device.isPair ?: false)
            put("platform", device.platform)
        }
    }

    private fun fromJson(obj: JSONObject): IDOBleDeviceModel {
        return IDOBleDeviceModel(
            rssi = obj.optInt("rssi", 0),
            name = obj.optString("name"),
            uuid = obj.optString("uuid"),
            macAddress = obj.optString("macAddress"),
            otaMacAddress = obj.optString("otaMacAddress"),
            btMacAddress = obj.optString("btMacAddress"),
            deviceId = obj.optInt("deviceId", 0),
            deviceType = obj.optInt("deviceType", 0),
            isOta = obj.optBoolean("isOta", false),
            isTlwOta = obj.optBoolean("isTlwOta", false),
            bltVersion = obj.optInt("bltVersion", 0),
            isPair = obj.optBoolean("isPair", false),
            platform = obj.optInt("platform", 0)
        )
    }

    /**
     * 将仅有绑定标记、尚无快照的设备补进列表
     */
    private fun migrateBoundFlagsIfNeeded() {
        val existing = loadBoundDeviceList()
        val existingMacs = existing.mapNotNull { it.macAddress }.toSet()
        val prefs = appContext.getSharedPreferences(SP_FILE, android.content.Context.MODE_PRIVATE)
        var changed = false
        for ((key, value) in prefs.all) {
            if (key == BOUND_DEVICES_KEY || !key.startsWith(BIND_KEY) || value != true) {
                continue
            }
            val mac = key.removePrefix(BIND_KEY)
            if (mac.isNotEmpty() && !existingMacs.contains(mac)) {
                existing.add(IDOBleDeviceModel(name = mac, macAddress = mac))
                changed = true
            }
        }
        if (changed) {
            persistBoundDevices(existing)
        }
    }
}
