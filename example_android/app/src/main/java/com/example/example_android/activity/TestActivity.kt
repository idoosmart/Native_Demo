package com.example.example_android.activity

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.View
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.callback.BleManager
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBleDelegate
import kotlinx.android.synthetic.main.activity_test.test_et
import kotlinx.android.synthetic.main.activity_test.test_tv

class TestActivity : BaseActivity() {

    private var mBlelisten = Blelisten()
    override fun getLayoutId(): Int {
        return R.layout.activity_test
    }

    override fun initView() {
        super.initView()
        //注册监听
        BleManager.registerBleDelegate(mBlelisten)
    }


    fun sendData(view: View){
        var content = test_et.text.toString()
        //发送
        Log.d("TestActivity", "receiveData: ${"发送数据:${sdk.ble.bleDevice!!}" }")

        sdk.ble.writeData(hexStringToByteArray(content), sdk.ble.bleDevice!!, 0,2) {
        }
    }

    inner class Blelisten : IDOBleDelegate {
        override fun bluetoothState(state: IDOBluetoothStateModel) {

        }

        override fun deviceState(state: IDODeviceStateModel) {
        }

        override fun receiveData(data: IDOReceiveData) {
            Log.d("TestActivity", "receiveData: ${"收到数据:" + data.data?.size + " Byte, platform:" + data.platform}")
            //显示接收到的数据
            if (data.platform == 2.toLong()) {
                test_tv.text = "收到数据:" + data.data?.size + " Byte, platform:" + data.platform + "\n" + data.data?.toHexString()
            }
        }

        override fun scanResult(list: List<IDOBleDeviceModel>?) {
        }

        override fun stateSPP(state: IDOSppStateModel) {
        }

        override fun writeSPPCompleteState(btMacAddress: String) {
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.unregisterBleDelegate(mBlelisten)
    }
}
fun ByteArray.toHexString(): String {
    return joinToString("") { "%02x".format(it) }
}

fun hexStringToByteArray(hexString: String): ByteArray {
    val cleanedHexString = hexString.replace(" ", "")
    val len = cleanedHexString.length

    require(len % 2 == 0) { "Hex string must have an even length" }

    return ByteArray(len / 2) { i ->
        val index = i * 2
        cleanedHexString.substring(index, index + 2).toInt(16).toByte()
    }
}