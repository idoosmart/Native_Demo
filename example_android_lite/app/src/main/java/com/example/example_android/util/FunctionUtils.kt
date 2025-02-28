package com.example.example_android.util

object FunctionUtils {
    private val bind_key: String = "bindkey"

    /**
     * 获取设备绑定状态
     * */
    fun isBind(macAddress: String): Boolean {
        return SPUtil.getAValue(bind_key + macAddress, false) as Boolean
    }
    /**
     * 保存设备绑定状态
     * */
    fun saveBindState(macAddress: String) {
        return SPUtil.putAValue(bind_key +macAddress, true)
    }
    /**
     * 改变设备绑定状态
     * */
    fun removeBindState(macAddress: String) {
        return SPUtil.putAValue(bind_key + macAddress, false)

    }


}