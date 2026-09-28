package com.example.example_android.tasklist

import com.idosmart.model.IDODeviceNotificationModel
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Example 内设备通知分发（Bridge 回调在 FunctionActivity，子页通过此总线接收）
 */
object DeviceNotificationBus {
    private val listeners = CopyOnWriteArrayList<(IDODeviceNotificationModel) -> Unit>()

    fun addListener(listener: (IDODeviceNotificationModel) -> Unit) {
        listeners.add(listener)
    }

    fun removeListener(listener: (IDODeviceNotificationModel) -> Unit) {
        listeners.remove(listener)
    }

    fun emit(model: IDODeviceNotificationModel) {
        listeners.forEach { it(model) }
    }
}
