package com.example.example_android.data

import android.Manifest
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
import com.idosmart.enum.IDOLogType
import com.idosmart.enum.IDOOtaType
import com.idosmart.enum.IDOStatusNotification
import com.idosmart.model.IDOBleDataRequest
import com.idosmart.model.IDODeviceNotificationModel
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

        override fun writeDataToBle(request: IDOBleDataRequest) {
            Logutil.logMessage("bledata","writeDataToBle:${ByteUtil.bytesToHexString(request.data)}")
            var bluetoothGatt: BluetoothGatt =  BleManager.getInstance().getBleBluetooth(CurrentDevice.bleDevice).bluetoothGatt

            var characteristic: BluetoothGattCharacteristic? = getCharacteristic(bluetoothGatt, UUID.fromString(
                CurrentDevice.uuid_service
            ), UUID.fromString(CurrentDevice.uuid_characteristic_write))
            characteristic?.value =request.data
            characteristic?.writeType = BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            if (ActivityCompat.checkSelfPermission(
                    MyApplication.instance.applicationContext,
                    Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return
            }
            bluetoothGatt.writeCharacteristic(characteristic)

        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            TODO("Not yet implemented")
        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            Logutil.logMessage("bledata","listenDeviceNotification:${status}")
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