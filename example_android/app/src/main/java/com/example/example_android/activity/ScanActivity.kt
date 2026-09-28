package com.example.example_android.activity

import android.Manifest
import android.app.AlertDialog
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.util.Log
import android.widget.Button
import androidx.core.app.ActivityCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.R
import com.example.example_android.adapter.ScanDeviceAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.callback.BleManager
import com.example.example_android.util.FunctionUtils
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOBluetoothStateModel
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.model.IDOSppStateModel
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBleDelegate

/**
 * 扫描添加设备页。
 */
class ScanActivity : BaseActivity(), ScanDeviceAdapter.onSelectDeviceListenter {
    private var requestPermissionCount = 0
    private val SDK_PERMISSION_REQUEST = 1
    private var permissionList = ArrayList<String>()
    private val TAG = "ScanActivity"
    private var mDevice: IDOBleDeviceModel? = null
    private var lvDevice: RecyclerView? = null
    private var mAdapter: ScanDeviceAdapter? = null
    private var mDeviceList = mutableListOf<IDOBleDeviceModel?>()
    private val bleListen = Blelisten()

    fun intPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissionList.add(Manifest.permission.BLUETOOTH_SCAN)
            permissionList.add(Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            permissionList.add(Manifest.permission.ACCESS_FINE_LOCATION)
            permissionList.add(Manifest.permission.ACCESS_COARSE_LOCATION)
            permissionList.add(Manifest.permission.BLUETOOTH_ADMIN)
            permissionList.add(Manifest.permission.BLUETOOTH)
        }
        getPermmison()
    }

    fun getPermmison() {
        Log.d(TAG, "PERMISSION size:" + permissionList.size)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && requestPermissionCount < 5) {
            if (permissionList.size != 0) {
                requestPermissionCount++
                ActivityCompat.requestPermissions(
                    this,
                    permissionList.toTypedArray(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                startScan()
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && requestPermissionCount < 3) {
            if (permissionList.size != 0) {
                requestPermissionCount++
                ActivityCompat.requestPermissions(
                    this,
                    permissionList.toTypedArray(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                startScan()
            }
        } else {
            startScan()
        }
    }

    inner class Blelisten : IDOBleDelegate {
        override fun scanResult(list: List<IDOBleDeviceModel>?) {
            mergeScanResult(list)
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
                                } else {
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

        override fun receiveData(data: IDOReceiveData) {}
        override fun stateSPP(state: IDOSppStateModel) {}
        override fun writeSPPCompleteState(btMacAddress: String) {}
        override fun stateBT(isPair: Boolean) {
            Log.d(TAG, "stateBT:$isPair")
        }

        fun _otaMode() {
            val alertDialog = AlertDialog.Builder(this@ScanActivity)
                .setTitle("OTA Mode")
                .setMessage("当前设备处理OTA模式，现在去升级？/ The current device handles OTA mode, upgrade now?")
                .setPositiveButton("YES") { _, _ ->
                    startActivity(Intent(this@ScanActivity, OtaFileTransferActivity::class.java))
                }
                .setNegativeButton("NO") { dialog, _ -> dialog.dismiss() }
                .create()
            alertDialog.show()
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
                    permissionList.remove(permissions[i])
                }
            }
            getPermmison()
        }
    }

    override fun initView() {
        title = "添加设备"
        lvDevice = findViewById(R.id.lv_device)
        BleManager.registerBleDelegate(bleListen)
        intPermission()
        lvDevice?.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))
        lvDevice?.layoutManager = LinearLayoutManager(this)
        mAdapter = ScanDeviceAdapter(mDeviceList)
        lvDevice?.adapter = mAdapter
        mAdapter?.setOnSelectDeviceListenter(this)
        val btnRefresh = findViewById<Button>(R.id.btn_refresh)
        btnRefresh.setTextColor(Color.WHITE)
        btnRefresh.setOnClickListener {
            mAdapter?.clear()
            mDeviceList.clear()
            mDevice = null
            startScan()
        }
    }

    override fun onDestroy() {
        BleManager.unregisterBleDelegate(bleListen)
        IDOSDK.instance().ble.stopScan()
        super.onDestroy()
    }

    override fun getLayoutId(): Int = R.layout.activity_scan

    fun startScan() {
        IDOSDK.instance().ble.stopScan()
        IDOSDK.instance().ble.startScan {}
    }

    private fun mergeScanResult(list: List<IDOBleDeviceModel>?) {
        val scanned = list?.toMutableList() ?: mutableListOf()
        scanned.filter { FunctionUtils.getDeviceMac(it.macAddress ?: "") }.forEach {
            FunctionUtils.saveBoundDevice(it)
        }
        val boundMacs = FunctionUtils.loadBoundDevices().mapNotNull { it.macAddress }.toSet()
        mDeviceList = scanned.filter { !boundMacs.contains(it.macAddress) }
            .map { it as IDOBleDeviceModel? }
            .toMutableList()
        mAdapter?.updateData(mDeviceList)
    }

    private fun openDevice(device: IDOBleDeviceModel?) {
        if (device == null) {
            return
        }
        IDOSDK.instance().ble.stopScan()
        mDevice = device
        mAdapter?.setSelectDevice(device)
        val intent = Intent(this, FunctionActivity::class.java)
        intent.putExtra(MainActivity.DEVICE, device)
        startActivity(intent)
    }

    override fun select(position: Int) {
        openDevice(mDeviceList.getOrNull(position))
    }
}

private fun Intent.putExtra(device: String, mDevice: IDOBleDeviceModel?) {
}
