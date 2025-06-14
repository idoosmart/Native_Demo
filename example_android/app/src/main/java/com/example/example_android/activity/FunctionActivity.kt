package com.example.example_android.activity

import android.app.AlertDialog
import android.content.Intent
import android.graphics.Color
import android.util.Log

import android.view.View
import android.widget.Toast
import androidx.core.content.ContextCompat.startActivity
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.callback.BleManager
import com.example.example_android.sport.EditSportListActivity
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
import com.idosmart.model.IDOOtaDeviceModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.model.IDOWriteStateModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDOEpoManager
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
import kotlinx.android.synthetic.main.layout_function_activity.rl_notificationIconTransfer
import kotlinx.android.synthetic.main.layout_function_activity.rl_set_function
import kotlinx.android.synthetic.main.layout_function_activity.rl_sport
import kotlinx.android.synthetic.main.layout_function_activity.rl_sport_screen
import kotlinx.android.synthetic.main.layout_function_activity.rl_sync_data
import kotlinx.android.synthetic.main.layout_function_activity.rl_test
import kotlinx.android.synthetic.main.layout_function_activity.rl_transfer_file
import kotlinx.android.synthetic.main.layout_function_activity.tv_bin
import kotlinx.android.synthetic.main.layout_function_activity.tv_connect
import kotlinx.android.synthetic.main.layout_function_activity.tv_un_bin
import java.text.SimpleDateFormat
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
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
        println("dis_connect device btMacAddress: ${device?.btMacAddress}");
        sdk.ble.cancelPair(device)
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
                rl_notificationIconTransfer?.visibility = View.GONE
                rl_sport_screen?.visibility = View.GONE
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
                        IDOBindStatus.BINDED,
                        IDOBindStatus.SUCCESSFUL -> {
                            toast("bind ok")
                            //save bind info
                            FunctionUtils.saveDeviceMac(device!!.macAddress.toString())
                            bindState()

                        }

                        IDOBindStatus.FAILED,
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
                    sdk.ble.cancelPair(device);
                    sdk.ble.cancelConnect(device?.macAddress) {}
                    bindState()
                    // 解绑设备删除icon数据
                    sdk.messageIcon.resetIconInfoData(
                        macAddress = device?.macAddress.toString(),
                        deleteIcon = true
                    ) { success ->
                        // 在这里处理返回的结果
                    }

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
        //sdk.ble.setBtPair(device!!)
        printLastUpdateTime()
    }

    fun sport(view: View) {
        val intent = Intent(this, SportExchangeActivity::class.java)
        startActivity(intent)
        //sdk.ble.cancelPair(device!!)
    }

    fun appletTransfer(view: View) {
        if (sdk.device.deviceId == 859 || sdk.device.deviceId == 7884) {
            val intent = Intent(this, AppletTransferActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / this device is not support")
        }
    }

    fun testActivity(view: View) {
        if (sdk.device.deviceId == 859 || sdk.device.deviceId == 7884) {
            val intent = Intent(this, TestActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / this device is not support")
        }
    }

    fun notificationIconTransfer(view: View) {
        if (sdk.funcTable.setSetNotificationStatus) {
            val intent = Intent(this, NotificationIconTransferActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / this device is not support")
        }

    }
    fun sportScreen(view: View) {
        if (sdk.funcTable.supportOperateSetSportScreen) {
            val intent = Intent(this, EditSportListActivity::class.java)
            startActivity(intent)
        } else {
            toast("此设备不支持 / this device is not support")
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

        IDOEpoManager.shared.listenEpoUpgrade(
            { status ->
                println("epo---- status: $status")
            },
            { progress ->
                println("epo---- down progress: $progress")
            },
            { progress ->
                println("epo---- send progress: $progress")
            },
            { errCode ->
                println("epo---- complete: $errCode")
                printLastUpdateTime()
            }
        )
        printLastUpdateTime()

    }


    private fun printLastUpdateTime() {
        IDOEpoManager.shared.lastUpdateTimestamp {
            if (it != 0L) {
                val formatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
                val formattedDate = formatter.format(it)
                println("epo---- lastUpdateTimestamp: $formattedDate")
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        println("call sdk.ble.cancelConnect")
        sdk.ble.cancelConnect(device?.macAddress) {

        }
        BleManager.unregisterBleDelegate(mBlelisten)
        sdk.transfer.unregisterDeviceTranFileToApp()
    }

    override fun getLayoutId(): Int {
        return R.layout.layout_function_activity
    }

    fun _otaMode() {
        val alertDialog = AlertDialog.Builder(this)
            .setTitle("OTA Mode")
            .setMessage("当前设备处理OTA模式，现在去升级？/ The current device handles OTA mode, upgrade now?")
            .setPositiveButton("YES") { _, _ ->
                val intent = Intent(this, OtaFileTransferActivity::class.java)
                startActivity(intent)
            }
            .setNegativeButton("NO") { dialog, _ ->
                dialog.dismiss()
            }
            .create()
        alertDialog.show()
    }

    inner class BleData : IDOBridgeDelegate {
        override fun listenStatusNotification(status: IDOStatusNotification) {
            println("listenStatusNotification $status");
            if (status == IDOStatusNotification.FASTSYNCCOMPLETED) {
                device?.let { sdk.ble.setBtPair(it) }
            }
        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            return bindState()

        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            println("listenDeviceNotification ${status.toString()}");

            // 快速短信回复
            if (status.controlEvt == 580 && status.controlJson != null) {
                println("status.controlJson: ${status.controlJson}")
                val gson = Gson()
                val msgItem =
                    gson.fromJson(status.controlJson, IDOFastMsgUpdateModel::class.java)
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

        override fun listenWaitingOtaDevice(otaDevice: IDOOtaDeviceModel) {
            println("2listenWaitingOtaDevice ${otaDevice.toString()}");
            closeProgressDialog()
            _otaMode()
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
            rl_notificationIconTransfer?.visibility = View.VISIBLE
            rl_sport_screen?.visibility = View.VISIBLE
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
            rl_notificationIconTransfer?.visibility = View.GONE
            rl_sport_screen?.visibility = View.GONE
            ll_bin?.visibility = View.VISIBLE
            return false
        }
    }


    inner class Blelisten : IDOBleDelegate {
        override fun scanResult(list: List<IDOBleDeviceModel>?) {
        }

        override fun bluetoothState(state: IDOBluetoothStateModel) {
            println("bluetoothState: ${state.toString()}")
        }

        override fun deviceState(idoDeviceStateModel: IDODeviceStateModel) {
            println("macAddress------------${idoDeviceStateModel.macAddress} state:${idoDeviceStateModel.state}");
            deviceState = idoDeviceStateModel
            if (idoDeviceStateModel.state == IDODeviceStateType.CONNECTED) {
                closeProgressDialog()

                if (sdk.ble.bleDevice.isOta == true) {
                    println("当前设备处于ota模式")
                    return
                }

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