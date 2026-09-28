package com.example.example_android.activity

import android.Manifest
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
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleScanCallback
import com.clj.fastble.data.BleDevice
import com.clj.fastble.scan.BleScanRuleConfig
import com.example.example_android.R
import com.example.example_android.adapter.ScanDeviceAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.CurrentDevice
import com.example.example_android.util.AdvUtils
import com.example.example_android.util.FunctionUtils
import java.util.*
import kotlin.math.abs

/**
 * 扫描添加设备页。扫描栈仍使用 FastBle。
 */
class ScanActivity : BaseActivity(), ScanDeviceAdapter.onSelectDeviceListenter {
    var requestPermissionCount = 0
    val SDK_PERMISSION_REQUEST = 1
    var permission_list = ArrayList<String>()
    val TAG = "ScanActivity"
    var mDevice: BleDevice? = null
    var lv_device: RecyclerView? = null
    var mAdapter: ScanDeviceAdapter? = null

    private var mDeviceList = mutableListOf<BleDevice?>()

    fun intPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permission_list.add(Manifest.permission.BLUETOOTH_SCAN)
            permission_list.add(Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            permission_list.add(Manifest.permission.ACCESS_FINE_LOCATION)
            permission_list.add(Manifest.permission.ACCESS_COARSE_LOCATION)
            permission_list.add(Manifest.permission.BLUETOOTH_ADMIN)
            permission_list.add(Manifest.permission.BLUETOOTH)
        }
        getPermmison()
    }

    fun getPermmison() {
        Log.d(TAG, "PERMISSION size:" + permission_list.size)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && requestPermissionCount < 5) {
            if (permission_list.size != 0) {
                requestPermissionCount++
                ActivityCompat.requestPermissions(
                    this,
                    permission_list.toTypedArray<String>(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                Log.d(TAG, "PERMISSION OK,开始扫描")
                startScan()
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && requestPermissionCount < 3) {
            if (permission_list.size != 0) {
                requestPermissionCount++
                ActivityCompat.requestPermissions(
                    this,
                    permission_list.toTypedArray<String>(),
                    SDK_PERMISSION_REQUEST
                )
            } else {
                Log.d(TAG, "PERMISSION OK,开始扫描")
                startScan()
            }
        } else {
            Log.d(TAG, "PERMISSION OK,开始扫描")
            startScan()
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

    override fun initView() {
        title = "添加设备"
        lv_device = findViewById(R.id.lv_device)
        intPermission()
        val driver = DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
        lv_device?.addItemDecoration(driver)
        lv_device?.layoutManager = LinearLayoutManager(this)

        mAdapter = ScanDeviceAdapter(mDeviceList)
        lv_device?.adapter = mAdapter
        mAdapter?.setOnSelectDeviceListenter(this)
        val btnRefresh = findViewById<Button>(R.id.btn_refresh)
        btnRefresh.setTextColor(Color.WHITE)
        btnRefresh.setOnClickListener {
            refresh()
        }
        initconfig()
    }

    private fun refresh() {
        mAdapter?.clear()
        mDeviceList.clear()
        mDevice = null
        BleManager.getInstance()
            .enableLog(true)
            .setReConnectCount(1, 5000)
            .setConnectOverTime(20000).operateTimeout = 5000
        startScan()
    }

    override fun onRestart() {
        super.onRestart()
        refresh()
    }

    override fun onStop() {
        super.onStop()
        BleManager.getInstance().cancelScan()
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_scan
    }

    fun startScan() {
        BleManager.getInstance().scan(object : BleScanCallback() {
            override fun onScanStarted(success: Boolean) {
            }

            override fun onScanning(bleDevice: BleDevice?) {
                if (bleDevice == null || !AdvUtils.isInNormalMode(bleDevice.scanRecord)) {
                    return
                }
                val mac = bleDevice.mac ?: return
                if (FunctionUtils.isBind(mac)) {
                    FunctionUtils.saveBoundDevice(bleDevice)
                    return
                }
                if (mDeviceList.any { it?.mac == mac }) {
                    return
                }
                mDeviceList.add(bleDevice)
                mDeviceList.sortBy {
                    abs(it!!.rssi)
                }
                mAdapter?.updateData(mDeviceList)
            }

            override fun onScanFinished(scanResultList: List<BleDevice?>?) {
            }
        })
    }

    fun initconfig() {
        val scanRuleConfig = BleScanRuleConfig.Builder()
            .setScanTimeOut(10000)
            .build()
        BleManager.getInstance().initScanRule(scanRuleConfig)
    }

    override fun select(position: Int) {
        Log.d(TAG, "select:" + position)
        BleManager.getInstance().cancelScan()
        mDevice = mDeviceList.get(position)
        mAdapter?.setSelectDevice(mDevice!!)
        val intent = Intent(lv_device?.context, FunctionActivity::class.java)
        intent.putExtra(MainActivity.DEVICE, mDevice)
        CurrentDevice.bleDevice = mDevice!!
        device = CurrentDevice.bleDevice
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.getInstance().cancelScan()
    }
}
