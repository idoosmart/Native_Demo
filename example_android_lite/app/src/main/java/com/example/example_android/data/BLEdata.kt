package com.example.example_android.data

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleNotifyCallback
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.example.example_android.MyApplication
import com.example.example_android.util.ByteUtil
import com.example.example_android.util.Logutil
import com.google.gson.Gson
import com.idosmart.enums.IDOLogType
import com.idosmart.enums.IDOOtaType
import com.idosmart.enums.IDOStatusNotification
import com.idosmart.model.IDOBleDataRequest
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDOFastMsgUpdateModel
import com.idosmart.model.IDOFastMsgUpdateParamModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBridgeDelegate
import io.flutter.Log
import java.util.*
import java.util.logging.Handler

/**
 * 蓝牙数据桥接
 */
object BLEdata  {

    var TAG:String = "BLEDATA"


    fun registBridge(){
        Logutil.logMessage(TAG,"sdk.bridge.setupBridge")
        sdk.bridge.setupBridge(BleDataBrige(), IDOLogType.DEBUG)
    }
    //使能通知
    fun notifyData(bleDevice: BleDevice,isBind:Boolean){
        Logutil.logMessage(TAG,"notify data")
        BleManager.getInstance().notify(
            bleDevice,
            CurrentDevice.uuid_service,
            CurrentDevice.uuid_characteristic_notify,
            object : BleNotifyCallback() {
                override fun onNotifySuccess() {
                    Logutil.logMessage(TAG,"onNotifySuccess" )
                    sdk.bridge.markConnectedDevice(bleDevice?.mac.toString(), IDOOtaType.NONE, isBind, bleDevice?.name)
                }
                override fun onNotifyFailure(exception: BleException) {
                    Logutil.logMessage(TAG,"onNotifyFailure" )
                }
                override fun onCharacteristicChanged(data: ByteArray) {
                    var dataString =ByteUtil.bytesToHexString(data)
                    Logutil.logMessage(TAG,"onCharacteristicChanged  $dataString   data len:${data.size}" )
                    sdk.bridge.receiveDataFromBle(data,bleDevice?.mac,false)
                }
            })
    }

    class BleDataBrige : IDOBridgeDelegate,BleWriteCallback() {

        override fun listenStatusNotification(status: IDOStatusNotification) {
            Logutil.logMessage("bledata","status:$status")
        }

        @SuppressLint("MissingPermission")
        override fun writeDataToBle(request: IDOBleDataRequest) {
            Logutil.logMessage("bledata","writeDataToBle:${ByteUtil.bytesToHexString(request.data)}")
            val bluetoothGatt: BluetoothGatt =  BleManager.getInstance().getBleBluetooth(CurrentDevice.bleDevice).bluetoothGatt

            val characteristic: BluetoothGattCharacteristic? = getCharacteristic(bluetoothGatt, UUID.fromString(
                CurrentDevice.uuid_service
            ), UUID.fromString(CurrentDevice.uuid_characteristic_write))
            characteristic?.value =request.data
            characteristic?.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            bluetoothGatt.writeCharacteristic(characteristic)
        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            TODO("Not yet implemented")
        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            Logutil.logMessage("bledata","listenDeviceNotification:${status}")

            // 快速短信回复
            if (status.controlEvt == 580 && status.controlJson != null) {
                println("status.controlJson: ${status.controlJson}")
                val gson = Gson()
                val msgItem = gson.fromJson(status.controlJson, IDOFastMsgUpdateModel::class.java)
                // 1 表示来电快捷回复
                if (msgItem.msgType == 1) {
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(1,msgItem.msgID, msgItem.msgType, msgItem.msgNotice)
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                }else{
                    // 第三方消息
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(1,msgItem.msgID, msgItem.msgType, msgItem.msgNotice)
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                }


            }
        }

        private fun getCharacteristic(
            gatt: BluetoothGatt?,
            serviceId: UUID,
            characteristicId: UUID
        ): BluetoothGattCharacteristic? {
            if (gatt == null) {
                return null
            }
            val service = gatt.getService(serviceId)
                ?: //        	DebugLog.p("service is nullllll");
                return null
            return service.getCharacteristic(characteristicId)
        }

        override fun onWriteSuccess(current: Int, total: Int, justWrite: ByteArray?) {
            sdk.bridge.writeDataComplete()

        }

        override fun onWriteFailure(exception: BleException?) {

        }

    }


}