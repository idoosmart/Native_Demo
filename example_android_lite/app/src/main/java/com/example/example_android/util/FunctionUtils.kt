package com.example.example_android.util

import com.idosmart.model.IDOBleDeviceModel

object FunctionUtils {
    private val bind_key: String = "bindkey"

    /**
     * 获取设备绑定状态
     * */
    fun getDeviceMac(macAddress: String): Boolean {
        return SPUtil.getAValue(bind_key + macAddress, false) as Boolean
    }
    /**
     * 保存设备绑定状态
     * */
    fun saveDeviceMac(macAddress: String) {
        return SPUtil.putAValue(bind_key +macAddress, true)
    }
    /**
     * 改变设备绑定状态
     * */
    fun upDataDeviceMac(macAddress: String) {
        return SPUtil.putAValue(bind_key + macAddress, false)

    }


}