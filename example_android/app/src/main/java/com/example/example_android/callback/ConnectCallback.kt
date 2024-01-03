package com.example.example_android.callback

import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.model.IDOWriteStateModel
import com.idosmart.protocol_sdk.IDOBleDelegate

/**
 * @author tianwei
 * @date 2023/11/23
 * @time 9:50
 * 用途:
 */
interface ConnectCallback : IDOBleDelegate {

    override fun scanResult(list: List<IDOBleDeviceModel>?) {
    }

    override fun bluetoothState(state: IDOBluetoothStateModel) {
    }

    override fun deviceState(state: IDODeviceStateModel) {
    }

    override fun stateSPP(state: IDOSppStateModel) {
    }

    override fun writeSPPCompleteState(btMacAddress: String) {
    }
}