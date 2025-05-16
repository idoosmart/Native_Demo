package com.example.example_android.data

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.util.Log
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleNotifyCallback
import com.clj.fastble.callback.BleWriteCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.clj.fastble.logs.LogTool
import com.clj.fastble.utils.HexUtil
import com.example.example_android.util.ByteUtil
import com.example.example_android.util.Logutil
import com.example.example_android.util.PairedDeviceUtils
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
import java.util.*

/**
 * 蓝牙数据桥接
 */
object BLEdata  {

    var TAG:String = "BLEDATA"


    fun registBridge(){
        Logutil.logMessage(TAG,"sdk.bridge.setupBridge")
        sdk.bridge.setupBridge(BleDataBrige(), IDOLogType.DEBUG)
    }

    fun createBtPair(mac:String){
        PairedDeviceUtils.createBond(BluetoothAdapter.getDefaultAdapter().getRemoteDevice(mac))
    }

    fun notifyDisconnect(bleDevice: BleDevice){
        LogTool.p(TAG, "sdk.bridge.markDisconnectedDevice");
        sdk.bridge.markDisconnectedDevice(bleDevice.mac)
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
                    LogTool.p(TAG, "call markConnectedDevice");
                    sdk.bridge.markConnectedDevice(
                        bleDevice?.mac.toString(),
                        IDOOtaType.NONE,
                        isBind,
                        bleDevice?.name
                    ) {
                        println("markConnected rs:$it")
                    }
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
            Logutil.logMessage("bledata","sdk.state: ${sdk.state}")
            if (status==IDOStatusNotification.FASTSYNCCOMPLETED){
                createBtPair(CurrentDevice.bleDevice.mac)
            }
        }

        @SuppressLint("MissingPermission")
        override fun writeDataToBle(request: IDOBleDataRequest) {
            Logutil.logMessage("bledata", "writeDataToBle:${HexUtil.formatHexString(request.data, true)}")
//            var bluetoothGatt: BluetoothGatt =  BleManager.getInstance().getBleBluetooth(CurrentDevice.bleDevice).bluetoothGatt
//            val writeType = if (isNoNeedWaitResponseCmd(request.data))BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE else BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            BleManager.getInstance().write(CurrentDevice.bleDevice,CurrentDevice.uuid_service, CurrentDevice.uuid_characteristic_write,request.data,this)
//            var characteristic: BluetoothGattCharacteristic? = getCharacteristic(bluetoothGatt, UUID.fromString(
//                CurrentDevice.uuid_service
//            ), UUID.fromString(CurrentDevice.uuid_characteristic_write))
//            characteristic?.value =request.data
//            characteristic?.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
//            bluetoothGatt.writeCharacteristic(characteristic)

        }

        private fun isNoNeedWaitResponseCmd(data: ByteArray): Boolean {
            //针对Agps文件的协议、Alexa语音
            return (data[0].toInt() and 0xff) == 0xD1 || (data[0].toInt() and 0xff) == 0x13
        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            return false
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

            if (status.notifyType == 1) {
                print("闹钟已经修改")
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
            sdk.bridge.writeDataComplete()
        }

    }


}