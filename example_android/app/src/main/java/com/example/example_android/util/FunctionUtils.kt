package com.example.example_android.util

import com.example.example_android.appContext
import com.idosmart.model.IDOBleDeviceModel
import org.json.JSONArray
import org.json.JSONObject

object FunctionUtils {
    private const val BIND_KEY = "bindkey"
    private const val BOUND_DEVICES_KEY = "bound_devices"
    private const val SP_FILE = "idodemo"

    fun getDeviceMac(macAddress: String): Boolean {
        return SPUtil.getAValue(BIND_KEY + macAddress, false) as Boolean
    }

    fun saveDeviceMac(macAddress: String) {
        SPUtil.putAValue(BIND_KEY + macAddress, true)
        upsertBoundDeviceIfAbsent(macAddress)
    }

    fun saveBoundDevice(device: IDOBleDeviceModel) {
        val mac = device.macAddress ?: return
        SPUtil.putAValue(BIND_KEY + mac, true)
        upsertBoundDevice(device)
    }

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
