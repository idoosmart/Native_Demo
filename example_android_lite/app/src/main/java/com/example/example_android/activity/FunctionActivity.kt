package com.example.example_android.activity

import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothProfile
import android.content.Intent
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.Toast
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleGattCallback
import com.clj.fastble.callback.BleMtuChangedCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.exception.BleException
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.BLEdata
import com.example.example_android.data.CmdGet
import com.example.example_android.data.CurrentDevice
import com.example.example_android.data.CustomEvtType
import com.example.example_android.data.GetFuntionData
import com.example.example_android.util.FunctionUtils
import com.example.example_android.util.Logutil
import com.google.gson.GsonBuilder
import com.idosmart.enums.IDOBindStatus
import com.idosmart.model.IDOMtuInfoModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.layout_comme_send_data.paramter_tv
import kotlinx.android.synthetic.main.layout_comme_send_data.tv_response
import kotlinx.android.synthetic.main.layout_device_describe.*
import kotlinx.android.synthetic.main.layout_function_activity.ll_bin
import kotlinx.android.synthetic.main.layout_function_activity.ll_connect
import kotlinx.android.synthetic.main.layout_function_activity.ll_dis_connect
import kotlinx.android.synthetic.main.layout_function_activity.ll_un_bin
import kotlinx.android.synthetic.main.layout_function_activity.rl_alexa
import kotlinx.android.synthetic.main.layout_function_activity.rl_epo
import kotlinx.android.synthetic.main.layout_function_activity.rl_get_function
import kotlinx.android.synthetic.main.layout_function_activity.rl_set_function
import kotlinx.android.synthetic.main.layout_function_activity.rl_sport
import kotlinx.android.synthetic.main.layout_function_activity.rl_sync_data
import kotlinx.android.synthetic.main.layout_function_activity.rl_transfer_file


class FunctionActivity : BaseActivity() {
    private val TAG: String = "function---------------"
    private var device: BleDevice? = null
    private var getFunctionData: GetFuntionData? = null
    private var isConnect: Boolean = false;

    fun connect(view: View) {
        connectDevice()
    }


    fun connectDevice() {
        if (isConnect) {
            return
        }
        BleManager.getInstance().connect(device, object : BleGattCallback() {
            override fun onStartConnect() {
                showProgressDialog("connecting...")
            }

            override fun onConnectFail(bleDevice: BleDevice, exception: BleException) {
                Logutil.logMessage(TAG, "onConnectFail")
                closeProgressDialog()
                isConnect = false
                updateBleStatus(isConnect)
                ll_connect?.visibility = View.VISIBLE
                ll_dis_connect?.visibility = View.GONE
            }

            override fun onConnectSuccess(bleDevice: BleDevice, gatt: BluetoothGatt, status: Int) {
                Logutil.logMessage(TAG, "onConnectSuccess")
                closeProgressDialog()
                tv_device_state?.text = "state: connected"
                tv_device_state.setTextColor(Color.parseColor("#00ff00"))
                isConnect = true
                ll_connect?.visibility = View.GONE
                ll_dis_connect?.visibility = View.VISIBLE
                bindState()
                updateBleStatus(isConnect)



                BLEdata.notifyData(bleDevice, false)



            }

            override fun onDisConnected(
                isActiveDisConnected: Boolean,
                bleDevice: BleDevice,
                gatt: BluetoothGatt,
                status: Int
            ) {
                Logutil.logMessage(TAG, "onDisConnected")
                tv_device_state?.text = "state: disconnect"
                tv_device_state.setTextColor(Color.parseColor("#ff0000"))

                closeProgressDialog()
                isConnect = false
                updateBleStatus(isConnect)
                ll_connect?.visibility = View.VISIBLE
                ll_dis_connect?.visibility = View.GONE
            }
        })
    }


    fun dis_connect(view: View) {
        Logutil.logMessage(TAG, "disconnect")
        BleManager.getInstance().disconnect(device);
        tv_device_state?.text = "state: disconnect"
        tv_device_state.setTextColor(Color.parseColor("#ff0000"))


        ll_un_bin?.visibility = View.GONE
        rl_get_function?.visibility = View.GONE
        rl_set_function?.visibility = View.GONE
        rl_sync_data?.visibility = View.GONE
        rl_transfer_file?.visibility = View.GONE
        rl_alexa?.visibility = View.GONE
        rl_sport?.visibility = View.GONE
        ll_dis_connect?.visibility = View.GONE
        ll_connect?.visibility = View.VISIBLE

        updateBleStatus(false)
    }


    fun bind(view: View) {
        if (isConnect) {
            if (bindState()) {
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
                            FunctionUtils.saveDeviceMac(device!!.mac.toString())
                            bindState()



                        }

                        IDOBindStatus.FAILED,
                        IDOBindStatus.BINDED,
                        IDOBindStatus.NEEDAUTH,
                        IDOBindStatus.REFUSEDBIND -> {
                            println("bind failed: ${it.name}")
                            toast("bind failed: ${it.name}")


                        }

                        IDOBindStatus.REFUSEDBIND -> {
                            println("bind failed: ${it.name}")
                            toast("bind failed: ${it.name}")
                        }

                        IDOBindStatus.NEEDCONFIRMBYAPP -> {
                            Cmds.sendBindResult(true).send {
                                if (it.error.code == 0) {
                                    toast("bind ok")
                                    //save bind info
                                    FunctionUtils.saveDeviceMac(device!!.mac.toString())
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
            sdk.cmd.unbind(device?.mac.toString(), true) {
                if (it) {
                    toast("unbind ok")
                    FunctionUtils.upDataDeviceMac(device!!.mac.toString())
                    BleManager.getInstance().disconnect(device);
                    tv_device_state?.text = "state: connected"
                    bindState()
                    tv_device_state.setTextColor(Color.parseColor("#ff0000"))

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

    fun epo_transfer(view: View){
        val intent = Intent(this, GpsMainActivity::class.java)
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
        connectDevice()
        showProgressDialog("Connecting...")
        ll_connect?.visibility = View.GONE
        ll_dis_connect?.visibility = View.VISIBLE
    }

    fun bindState(): Boolean {
        if (FunctionUtils.getDeviceMac(device!!.mac.toString())) {
            ll_un_bin?.visibility = View.VISIBLE
            rl_get_function?.visibility = View.VISIBLE
            rl_set_function?.visibility = View.VISIBLE
            rl_sync_data?.visibility = View.VISIBLE
            rl_transfer_file?.visibility = View.VISIBLE
            rl_alexa?.visibility = View.VISIBLE
            rl_sport?.visibility = View.VISIBLE
            rl_epo?.visibility = View.VISIBLE
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
            rl_epo?.visibility = View.GONE
            ll_bin?.visibility = View.VISIBLE
            return false
        }
    }

    override fun onResume() {
        super.onResume()
        if (!isConnect) {
            tv_device_state?.text = "state: disconnect"
            tv_device_state.setTextColor(Color.parseColor("#ff0000"))

            ll_un_bin?.visibility = View.GONE
            rl_get_function?.visibility = View.GONE
            rl_set_function?.visibility = View.GONE
            rl_sync_data?.visibility = View.GONE
            rl_transfer_file?.visibility = View.GONE
            rl_alexa?.visibility = View.GONE
            rl_sport?.visibility = View.GONE
            ll_dis_connect?.visibility = View.GONE
            ll_connect?.visibility = View.VISIBLE
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.getInstance().disconnect(device)
    }

    override fun getLayoutId(): Int {
        return R.layout.layout_function_activity
    }


}
