package com.example.example_android.activity

import android.Manifest
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat.startActivity
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.adapter.ScanDeviceAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.callback.BleManager
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.pigeon_implement.IDOEpoManager
import com.idosmart.pigeon_implement.IDOEpoManagerDelegate
import com.idosmart.pigeon_implement.IDOOtaGpsInfo
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_sdk.*
import kotlinx.android.synthetic.main.activity_main.*
import java.util.*

import com.idosmart.protocol_channel.*

class MainActivity : BaseActivity(), ScanDeviceAdapter.onSelectDeviceListenter {
    var requestPermissionCount = 0;
    val SDK_PERMISSION_REQUEST = 1;
    var permission_list = ArrayList<String>()
    val TAG = "MainActivity";
    var mDevice: IDOBleDeviceModel? = null
    var lv_device: RecyclerView? = null
    var mAdapter: ScanDeviceAdapter? = null

    private var mDeviceList = mutableListOf<IDOBleDeviceModel?>()

    companion object {
        val DEVICE: String = "device"
    }

    fun intPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permission_list.add(Manifest.permission.BLUETOOTH_SCAN);
            permission_list.add(Manifest.permission.BLUETOOTH_CONNECT);
        } else {
            permission_list.add(Manifest.permission.ACCESS_FINE_LOCATION);
            permission_list.add(Manifest.permission.ACCESS_COARSE_LOCATION);
            permission_list.add(Manifest.permission.BLUETOOTH_ADMIN);
            permission_list.add(Manifest.permission.BLUETOOTH);
        }
        getPermmison();
    }

    fun getPermmison() {
        Log.d(TAG, "PERMISSION size:" + permission_list.size);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && requestPermissionCount < 5) {
            if (permission_list.size != 0) {
                requestPermissionCount++;
                ActivityCompat.requestPermissions(
                    this,
                    permission_list.toTypedArray<String>(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                Log.d(TAG, "PERMISSION OK,开始扫描");
                startScan()
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && requestPermissionCount < 3) {
            if (permission_list.size != 0) {
                requestPermissionCount++;
                ActivityCompat.requestPermissions(
                    this,
                    permission_list.toTypedArray<String>(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                Log.d(TAG, "PERMISSION OK,开始扫描");
                startScan()
            }
        } else {
            Log.d(TAG, "PERMISSION OK,开始扫描");
            startScan()
        }
    }

    inner class Blelisten : IDOBleDelegate {

        override fun scanResult(list: List<IDOBleDeviceModel>?) {
            if (list != null) {
                mDeviceList = list.toMutableList();
            }
            mAdapter?.updateData(mDeviceList)

            // 检查ota中的设备，并跳转至文件传输页
            if (mDeviceList.size > 0) {
                mDeviceList.firstOrNull { it?.isOta == true }?.let {
                    println("OTA Mode Device: ${it.toString()}")
                    if (sdk.device.deviceId == 0 || sdk.device.deviceId != it.deviceId) {
                        sdk.ble.stopScan()
                        sdk.bridge.markOtaMode(
                            macAddress = it.macAddress ?: "",
                            platform = it.platform,
                            deviceId = it.deviceId ?: 0,
                            completion = { rs ->
                                if (rs) {
                                    _otaMode()
                                }else {
                                    println("OTA Mode Failed")
                                }
                            }
                        )
                    }
                }
            }
        }

        override fun bluetoothState(state: IDOBluetoothStateModel) {
            println("bluetoothState: ${state.toString()}")

        }

        override fun deviceState(state: IDODeviceStateModel) {
            println("deviceState: ${state.toString()} errorState:${state.errorState}")
        }

        override fun receiveData(data: IDOReceiveData) {

        }

        override fun stateSPP(state: IDOSppStateModel) {

        }

        override fun writeSPPCompleteState(btMacAddress: String) {

        }

        override fun stateBT(isPair: Boolean) {
            Log.d(TAG, "stateBT:$isPair")
        }

        fun _otaMode() {
            val alertDialog = AlertDialog.Builder(lv_device?.context)
                .setTitle("OTA Mode")
                .setMessage("当前设备处理OTA模式，现在去升级？/ The current device handles OTA mode, upgrade now?")
                .setPositiveButton("YES") { _, _ ->
                    val intent = Intent(lv_device?.context, OtaFileTransferActivity::class.java)
                    startActivity(intent)
                }
                .setNegativeButton("NO") { dialog, _ ->
                    dialog.dismiss()
                }
                .create()
            alertDialog.show()
        }
    }

    inner class EpoListen : IDOEpoManagerDelegate {
        override fun getAppGpsInfo(): IDOOtaGpsInfo {
            // !!!: 此处的经纬度是伪代码 | The latitude and longitude here are pseudocode
            return IDOOtaGpsInfo(114.0579f,  22.5431f, 10.0f)
        }

    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SDK_PERMISSION_REQUEST) {
            for (i in permissions.indices) {
                if (grantResults[i] == PackageManager.PERMISSION_GRANTED) {
                    permission_list.remove(permissions[i])
                }
            }
            Log.d(TAG, "权限请求成功")
            getPermmison()
        }
    }

    fun initSdk() {
        BleManager.initSdk()
        BleManager.registerBleDelegate(Blelisten())

        // epo upgrade
        IDOEpoManager.shared.enableAutoUpgrade = true
        IDOEpoManager.shared.delegateGetGps = EpoListen()
    }

    override fun initView() {
        supportActionBar?.setDisplayHomeAsUpEnabled(false)
        lv_device = findViewById(R.id.lv_device)
        intPermission();
        initSdk()
        var driver: DividerItemDecoration = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
        lv_device?.addItemDecoration(driver)
        lv_device?.layoutManager = LinearLayoutManager(this)
        mAdapter = ScanDeviceAdapter(mDeviceList)
        lv_device?.adapter = mAdapter
        mAdapter?.setOnSelectDeviceListenter(this)
        btn_refresh.setTextColor(Color.WHITE)
        btn_refresh.setOnClickListener {
            mAdapter?.clear()
            mDeviceList.clear()
            mDevice = null
            startScan()
        }
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_main
    }

    fun startScan() {
        IDOSDK.instance().ble.stopScan()
        IDOSDK.instance().ble.startScan {}
    }

    override fun select(position: Int) {
        Log.d(TAG, "select:" + position)
        IDOSDK.instance().ble.stopScan()
        mDevice = mDeviceList.get(position)
        mAdapter?.setSelectDevice(mDevice!!)
        val intent = Intent(lv_device?.context, FunctionActivity::class.java)
        intent.putExtra(DEVICE, mDevice)
        startActivity(intent)
    }


}

private fun Intent.putExtra(device: String, mDevice: IDOBleDeviceModel?) {

}
