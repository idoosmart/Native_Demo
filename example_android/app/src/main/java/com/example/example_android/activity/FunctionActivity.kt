package com.example.example_android.activity

import android.content.Intent
import android.graphics.Color

import android.view.View
import android.widget.Toast
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.activity.SportExchangeActivity
import com.example.example_android.callback.BleManager
import com.example.example_android.util.SPUtil
import com.idosmart.enum.IDOBindStatus
import com.idosmart.enum.IDODeviceStateType
import com.idosmart.enum.IDOLogType
import com.idosmart.enum.IDOOtaType
import com.idosmart.enum.IDOStatusNotification
import com.idosmart.enum.IDOWriteType
import com.idosmart.model.IDOBleDataRequest
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.model.IDOWriteStateModel
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.*
import kotlinx.android.synthetic.main.layout_device_describe.*

class FunctionActivity : BaseActivity() {
    private var device: IDOBleDeviceModel? = null
    private val bind_key: String = "bindkey"
    private lateinit var deviceState: IDODeviceStateModel
    private var mBlelisten = Blelisten()
    private var isBind: Boolean = false

    fun ll_connect(view: View) {
        if (deviceState?.state == IDODeviceStateType.CONNECTED) {
            Toast.makeText(this, "is connected", Toast.LENGTH_LONG).show()
        } else {
            showProgressDialog("Connecting...")
            IDOSDK.instance().ble.connect(device);
        }
    }

    fun ll_dis_connect(view: View) {
        sdk.ble.cancelConnect(device?.macAddress) {

        };
    }

    fun bind(view: View) {
        if (deviceState.state == IDODeviceStateType.CONNECTED) {
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
                            SPUtil.putAValue(bind_key + device?.macAddress, true)
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
            sdk.cmd.unbind(device?.macAddress.toString(), true) {
                if (it) {
                    toast("unbind ok")
                    SPUtil.putAValue(bind_key + device?.macAddress, false)
                    isBind = false
                    sdk.ble.cancelConnect(device?.macAddress) {}
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
        BleManager.registerBleDelegate(mBlelisten)
        sdk.bridge.setupBridge(BleData(), IDOLogType.DEBUG)
        device = intent.getSerializableExtra(MainActivity.DEVICE) as IDOBleDeviceModel?
//        isBind = SPUtil.getAValue(bind_key + device?.macAddress, false) as Boolean
//        if (isBind) {
        sdk.ble.autoConnect(device)
        showProgressDialog("Connecting...")
//        }
        tv_device_name?.text = "name: " + device?.name
        tv_device_mac?.text = "mac: " + device?.macAddress
        tv_device_rssl?.text = "rssi: " + device?.rssi.toString()
        tv_device_state?.text = "state: disconnect"
    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.unregisterBleDelegate(mBlelisten)
    }

    override fun getLayoutId(): Int {
        return R.layout.layout_function_activity
    }

    inner class BleData : IDOBridgeDelegate {

        override fun listenStatusNotification(status: IDOStatusNotification) {
            println("listenStatusNotification $status");
        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            println("listenDeviceNotification $status");
        }

    }


    inner class Blelisten : IDOBleDelegate {

        override fun scanResult(list: List<IDOBleDeviceModel>?) {

        }

        override fun bluetoothState(state: IDOBluetoothStateModel) {

        }

        override fun deviceState(idoDeviceStateModel: IDODeviceStateModel) {
            println("state------------${idoDeviceStateModel.macAddress}");
            deviceState = idoDeviceStateModel
            if (idoDeviceStateModel.state == IDODeviceStateType.CONNECTED) {
                closeProgressDialog()
                tv_device_state?.text = "state: connected"
                tv_device_state.setTextColor(Color.parseColor("#00ff00"))
                var type = IDOOtaType.NONE
                val isOta = device?.isOta ?: false
                val isTlwOta = device?.isTlwOta ?: false
                if (isOta) {
                    type = IDOOtaType.NORDIC
                } else if (isTlwOta) {
                    type = IDOOtaType.TELINK
                }
               // sdk.bridge.markConnectedDevice(deviceState.macAddress!!, type, isBind, device?.name)
            } else if (idoDeviceStateModel.state == IDODeviceStateType.CONNECTING) {
                tv_device_state?.text = "state: connecting"
            } else if (idoDeviceStateModel.state == IDODeviceStateType.DISCONNECTED) {
                tv_device_state?.text = "state: disconnected"
            }
        }

        override fun stateSPP(state: IDOSppStateModel) {

        }

        override fun writeSPPCompleteState(btMacAddress: String) {

        }

    }
}