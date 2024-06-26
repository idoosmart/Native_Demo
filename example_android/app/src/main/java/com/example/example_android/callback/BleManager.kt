package com.example.example_android.callback

import com.idosmart.enums.IDOBluetoothStateType
import com.idosmart.enums.IDODeviceStateType
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.model.IDOWriteStateModel
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBleDelegate

/**
 * @author tianwei
 * @date 2023/11/23
 * @time 10:13
 * 用途:
 */
object BleManager {

    private var mBleState: IDODeviceStateModel? = null
    private val delegates: MutableList<IDOBleDelegate> = mutableListOf()

    fun getConnectState() = mBleState

    fun registerBleDelegate(delegate: IDOBleDelegate) {
        if (!delegates.contains(delegate)) {
            delegates.add(delegate)
        }
    }

    fun unregisterBleDelegate(delegate: IDOBleDelegate) {
        if (delegates.contains(delegate)) {
            delegates.remove(delegate)
        }
    }

    private val bleDelegate = object : IDOBleDelegate {

        override fun scanResult(list: List<IDOBleDeviceModel>?) {
            delegates.forEach { it.scanResult(list) }
        }

        override fun bluetoothState(state: IDOBluetoothStateModel) {
            delegates.forEach { it.bluetoothState(state) }
        }

        override fun deviceState(state: IDODeviceStateModel) {
            mBleState = state
            delegates.forEach { it.deviceState(state) }
        }

        override fun receiveData(data: IDOReceiveData) {

        }

        override fun stateSPP(state: IDOSppStateModel) {
            delegates.forEach { it.stateSPP(state) }
        }

        override fun writeSPPCompleteState(btMacAddress: String) {
            delegates.forEach { it.writeSPPCompleteState(btMacAddress) }
        }

    }

    fun initSdk() {
        sdk.ble.addBleDelegate(bleDelegate)
        sdk.ble.getBluetoothState {

        }
    }

}