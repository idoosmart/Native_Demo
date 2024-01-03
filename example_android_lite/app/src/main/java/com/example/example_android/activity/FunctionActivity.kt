package com.example.example_android.activity

import android.Manifest
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.view.View
import android.widget.Toast
import androidx.core.app.ActivityCompat
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleGattCallback
import com.clj.fastble.callback.BleNotifyCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.example.example_android.MyApplication
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.BLEdata
import com.example.example_android.data.CurrentDevice
import com.example.example_android.data.CurrentDevice.uuid_characteristic_notify
import com.example.example_android.data.CurrentDevice.uuid_service
import com.example.example_android.util.Logutil
import com.example.example_android.util.SPUtil
import com.idosmart.enum.IDOBindStatus
import com.idosmart.enum.IDOLogType
import com.idosmart.enum.IDOOtaType
import com.idosmart.enum.IDOStatusNotification
import com.idosmart.model.IDOBleDataRequest
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBridgeDelegate
import io.flutter.Log
import kotlinx.android.synthetic.main.layout_device_describe.*
import java.util.*


class FunctionActivity : BaseActivity() {
    private val TAG:String ="function---------------"
    private var device: BleDevice? = null
    private val bind_key: String = "bindkey"
    private var isBind: Boolean = false
    private var isConnect:Boolean = false;

    fun ll_connect(view: View) {
        if(isConnect){
            return
        }
        BleManager.getInstance().connect(device, object : BleGattCallback() {
            override fun onStartConnect() {
                showProgressDialog("connecting...")
            }

            override fun onConnectFail(bleDevice: BleDevice, exception: BleException) {
                Logutil.logMessage(TAG,"onConnectFail" )
                closeProgressDialog()
                isConnect = false
            }

            override fun onConnectSuccess(bleDevice: BleDevice, gatt: BluetoothGatt, status: Int) {
                Logutil.logMessage(TAG,"onConnectSuccess" )
                closeProgressDialog()
                tv_device_state?.text = "state: connected"
                tv_device_state.setTextColor(Color.parseColor("#00ff00"))
                isConnect = true
                BLEdata.notifyData(bleDevice,false)
            }

            override fun onDisConnected(
                isActiveDisConnected: Boolean,
                bleDevice: BleDevice,
                gatt: BluetoothGatt,
                status: Int
            ) {
                Logutil.logMessage(TAG,"onDisConnected" )
                tv_device_state?.text = "state: disconnect"
                closeProgressDialog()
                isConnect = false
            }
        })
    }


    fun ll_dis_connect(view: View) {
        Logutil.logMessage(TAG,"disconnect" )
        BleManager.getInstance().disconnect(device);
    }


    fun bind(view: View) {
        if (isConnect) {
            if (isBind) {
                toast("already bond")
            } else {
                showProgressDialog("bind...")
                sdk.cmd.bind(15, {
                    println("获取到设备信息 state$it");
                }, {
                    println("获取到功能表 functableinterface state$it");
                }, {
                    closeProgressDialog()
                    when (it) {
                        IDOBindStatus.SUCCESSFUL -> {
                            toast("bind ok")
                            //save bind info
                            SPUtil.putAValue(bind_key + device?.mac, true)
                        }

                        IDOBindStatus.FAILED,
                        IDOBindStatus.BINDED,
                        IDOBindStatus.NEEDAUTH,
                        IDOBindStatus.REFUSEDBIND -> {
                            println("bind failed: ${it.name}")
                            toast("bind failed: ${it.name}")
                        }

                        else -> {

                        }
                    }
                })
            }
        } else {
            Toast.makeText(this, "please connect device", Toast.LENGTH_LONG).show()
        }
    }

    fun unbind(view: View) {
//        isBind = SPUtil.getAValue(bind_key + device?.macAddress, false) as Boolean
        if (isBind) {
            sdk.cmd.unbind(device?.mac.toString(), true) {
                if (it) {
                    toast("unbind ok")
                    SPUtil.putAValue(bind_key + device?.mac, false)
                    isBind = false
                    BleManager.getInstance().cancelScan();
                } else {
                    toast("unbind failed")
                }
            }
        } else {
            toast("not bond")
        }

    }

    fun getFunction(view: View) {
        val intent = Intent(this, GetFuntionActivity::class.java)
        startActivity(intent)
    }

    fun setFunction(view: View) {
        val intent = Intent(this, SetFuntionActivity::class.java)
        startActivity(intent)
    }

    fun syncdata(view: View) {
        val intent = Intent(this, SyncDataActivity::class.java)
        startActivity(intent)
    }

    fun transfer_file(view: View) {
        val intent = Intent(this, FileTransferModuleActivity::class.java)
        startActivity(intent)
    }

    fun alexa(view: View) {
        val intent = Intent(this, AlexaActivity::class.java)
        startActivity(intent)
    }

    fun sport(view: View) {
        val intent = Intent(this, SportExchangeActivity::class.java)
        startActivity(intent)
    }

    override fun initView() {
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setTitle("FunctionList")
       // device = intent.getParcelableExtra(MainActivity.DEVICE) as BleDevice?
        device = CurrentDevice.bleDevice
        tv_device_name?.text = "name: " + device?.name
        tv_device_mac?.text = "mac: " + device?.mac
        tv_device_rssl?.text = "rssi: " + device?.rssi.toString()
        tv_device_state?.text = "state: disconnect"

    }



    override fun onDestroy() {
        super.onDestroy()
        BleManager.getInstance().disconnect(device)
    }

    override fun getLayoutId(): Int {
        return R.layout.layout_function_activity
    }


}
