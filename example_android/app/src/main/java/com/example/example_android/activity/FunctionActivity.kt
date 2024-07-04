package com.example.example_android.activity

import android.content.Intent
import android.graphics.Color
import android.util.Log

import android.view.View
import android.widget.Toast
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.callback.BleManager
import com.example.example_android.util.FunctionUtils
import com.example.example_android.util.SPUtil
import com.google.gson.Gson
import com.idosmart.enums.IDOBindStatus
import com.idosmart.enums.IDODeviceStateType
import com.idosmart.enums.IDOLogType
import com.idosmart.enums.IDOOtaType
import com.idosmart.enums.IDOStatusNotification
import com.idosmart.enums.IDOWriteType
import com.idosmart.model.IDOBleDataRequest
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOFastMsgUpdateModel
import com.idosmart.model.IDOFastMsgUpdateParamModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.model.IDOWriteStateModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.*
import kotlinx.android.synthetic.main.activity_transfer_module_file.tvContact
import kotlinx.android.synthetic.main.layout_device_describe.*
import kotlinx.android.synthetic.main.layout_function_activity.ll_bin
import kotlinx.android.synthetic.main.layout_function_activity.ll_connect
import kotlinx.android.synthetic.main.layout_function_activity.ll_dis_connect
import kotlinx.android.synthetic.main.layout_function_activity.ll_un_bin
import kotlinx.android.synthetic.main.layout_function_activity.rl_alexa
import kotlinx.android.synthetic.main.layout_function_activity.rl_appletTransfer
import kotlinx.android.synthetic.main.layout_function_activity.rl_get_function
import kotlinx.android.synthetic.main.layout_function_activity.rl_set_function
import kotlinx.android.synthetic.main.layout_function_activity.rl_sport
import kotlinx.android.synthetic.main.layout_function_activity.rl_sync_data
import kotlinx.android.synthetic.main.layout_function_activity.rl_test
import kotlinx.android.synthetic.main.layout_function_activity.rl_transfer_file
import kotlinx.android.synthetic.main.layout_function_activity.tv_bin
import kotlinx.android.synthetic.main.layout_function_activity.tv_connect
import kotlinx.android.synthetic.main.layout_function_activity.tv_un_bin
import kotlin.math.log

class FunctionActivity : BaseActivity() {
    private var device: IDOBleDeviceModel? = null
    private lateinit var deviceState: IDODeviceStateModel
    private var mBlelisten = Blelisten()

    fun connect(view: View) {
        if (deviceState.state == IDODeviceStateType.CONNECTED) {
            Toast.makeText(this, "is connected", Toast.LENGTH_LONG).show()
        } else {
            showProgressDialog("Connecting...")
            IDOSDK.instance().ble.connect(device);
        }
    }

    fun dis_connect(view: View) {
        sdk.ble.cancelConnect(device?.macAddress) {
            if (it) {
                ll_un_bin?.visibility = View.GONE
                rl_get_function?.visibility = View.GONE
                rl_set_function?.visibility = View.GONE
                rl_sync_data?.visibility = View.GONE
                rl_transfer_file?.visibility = View.GONE
                rl_alexa?.visibility = View.GONE
                rl_sport?.visibility = View.GONE
                rl_test?.visibility = View.GONE
                rl_appletTransfer?.visibility = View.GONE

            }
        };
    }

    fun bind(view: View) {
        if (deviceState.state == IDODeviceStateType.CONNECTED) {
            if (bindState()) {
                toast("already bond")
            } else {
                showProgressDialog("bind...")
                sdk.cmd.bind(15, {
                    println("获取到设备信息 state$it");
                }, {
                    println("获取到功能表 functableinterface state$it");
                }, { it ->
                    closeProgressDialog()
                    println("返回状态：$it")
                    when (it) {
                        IDOBindStatus.SUCCESSFUL -> {
                            toast("bind ok")
                            //save bind info
                            FunctionUtils.saveDeviceMac(device!!.macAddress.toString())
                            bindState()

                        }

                        IDOBindStatus.FAILED,
                        IDOBindStatus.BINDED,
                        IDOBindStatus.NEEDAUTH,
                        IDOBindStatus.REFUSEDBIND -> {
                            println("bind failed: ${it.name}")
                            toast("bind failed: ${it.name}")
                        }

                        IDOBindStatus.NEEDCONFIRMBYAPP -> {
                            Cmds.sendBindResult(true).send {
                                if (it.error.code == 0) {
                                    toast("bind ok")
                                    //save bind info
                                    FunctionUtils.saveDeviceMac(device!!.macAddress.toString())
                                    bindState()
                                    sdk.cmd.appMarkBindResult(true)
                                } else {
                                    println("bind failed: ")
                                    toast("bind failed: ")
                                    sdk.cmd.appMarkBindResult(false)
                                }
                            }
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
        if (bindState()) {
            sdk.cmd.unbind(device?.macAddress.toString(), true) {
                if (it) {
                    toast("unbind ok")
                    FunctionUtils.upDataDeviceMac(device!!.macAddress.toString())
                    sdk.ble.cancelConnect(device?.macAddress) {}
                    bindState()
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

    fun appletTransfer(view: View) {
        if (sdk.device.deviceId == 859) {
            val intent = Intent(this, AppletTransferActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / not support")
        }
    }

    fun testActivity(view: View) {
        if (sdk.device.deviceId == 859) {
            val intent = Intent(this, TestActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / not support")
        }
    }


    override fun initView() {
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setTitle("FunctionList")
        BleManager.registerBleDelegate(mBlelisten)
        sdk.bridge.setupBridge(BleData(), IDOLogType.DEBUG)
        device = intent.getSerializableExtra(MainActivity.DEVICE) as IDOBleDeviceModel?
        sdk.ble.autoConnect(device)
        showProgressDialog("Connecting...")
        ll_connect?.visibility = View.GONE
        ll_dis_connect?.visibility = View.VISIBLE

        tv_device_name?.text = "name: " + device?.name
        tv_device_mac?.text = "mac: " + device?.macAddress
        tv_device_rssl?.text = "rssi: " + device?.rssi.toString()
        tv_device_state?.text = "state: disconnect"

        val path1 = sdk.messageIcon.iconDirPath
        val path2 = sdk.deviceLog.logDirPath
        println("iconDirPath === $path1 logDirPath === $path2")
    }

    override fun onDestroy() {
        super.onDestroy()
        println("call sdk.ble.cancelConnect")
        sdk.ble.cancelConnect(device?.macAddress) {

        }
        BleManager.unregisterBleDelegate(mBlelisten)

    }

    override fun getLayoutId(): Int {
        return R.layout.layout_function_activity
    }

    inner class BleData : IDOBridgeDelegate {
//        override fun registerWriteDataToBle(bleData: IDOBleDataRequest) {
//            println("registerWriteDataToBle $bleData");
//            bleData?.run {
//                //  if(deviceState?.macAddress == bleData.macAddress){
//                sdk.ble.writeData(bleData.data, device, bleData.type) {
//                    println("writeData $it");
//                }
//                //  }
//            }
//        }

        override fun listenStatusNotification(status: IDOStatusNotification) {
            println("listenStatusNotification $status");
        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            return bindState()

        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            println("listenDeviceNotification $status");

            // 快速短信回复
            if (status.controlEvt == 580 && status.controlJson != null) {
                println("status.controlJson: ${status.controlJson}")
                val gson = Gson()
                val msgItem = gson.fromJson(status.controlJson, IDOFastMsgUpdateModel::class.java)
                // 1 表示来电快捷回复
                if (msgItem.msgType == 1) {
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(
                        1,
                        msgItem.msgID,
                        msgItem.msgType,
                        msgItem.msgNotice
                    )
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                } else {
                    // 第三方消息
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(
                        1,
                        msgItem.msgID,
                        msgItem.msgType,
                        msgItem.msgNotice
                    )
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                }


            }
        }


    }

    fun bindState(): Boolean {
        if (FunctionUtils.getDeviceMac(device!!.macAddress.toString())) {
            ll_un_bin?.visibility = View.VISIBLE
            rl_get_function?.visibility = View.VISIBLE
            rl_set_function?.visibility = View.VISIBLE
            rl_sync_data?.visibility = View.VISIBLE
            rl_transfer_file?.visibility = View.VISIBLE
            rl_alexa?.visibility = View.VISIBLE
            rl_sport?.visibility = View.VISIBLE
            rl_test?.visibility = View.VISIBLE
            rl_appletTransfer?.visibility = View.VISIBLE
            ll_bin?.visibility = View.GONE
            return true
        } else {
            ll_un_bin?.visibility = View.GONE
            rl_get_function?.visibility = View.GONE
            rl_set_function?.visibility = View.GONE
            rl_sync_data?.visibility = View.GONE
            rl_transfer_file?.visibility = View.GONE
            rl_alexa?.visibility = View.GONE
            rl_sport?.visibility = View.GONE
            rl_test?.visibility = View.GONE
            rl_appletTransfer?.visibility = View.GONE
            ll_bin?.visibility = View.VISIBLE
            return false
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
                ll_connect?.visibility = View.GONE
                ll_dis_connect?.visibility = View.VISIBLE
                //sdk.bridge.markConnectedDevice(deviceState.macAddress!!, type, isBind, device?.name)
            } else if (idoDeviceStateModel.state == IDODeviceStateType.CONNECTING) {
                tv_device_state?.text = "state: connecting"
            } else if (idoDeviceStateModel.state == IDODeviceStateType.DISCONNECTED) {
                tv_device_state?.text = "state: disconnected"
                ll_connect?.visibility = View.VISIBLE
                ll_dis_connect?.visibility = View.GONE
                closeProgressDialog()
            }
        }

        override fun receiveData(data: IDOReceiveData) {
            println("data------------${data.data}");
        }

        override fun stateSPP(state: IDOSppStateModel) {

        }

        override fun writeSPPCompleteState(btMacAddress: String) {

        }

    }


    private fun deviceID() {

    }
}