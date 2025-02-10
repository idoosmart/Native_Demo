package com.example.example_android.activity

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.util.Log
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
import com.idosmart.pigeon_implement.IDOEpoManager
import com.idosmart.pigeon_implement.IDOEpoManagerDelegate
import com.idosmart.pigeon_implement.IDOOtaGpsInfo
import kotlinx.android.synthetic.main.activity_main.*
import java.util.*

/**
 * 扫描设备，为了程序能运行，使用了第三方的蓝牙，接入的时候可以使用自己的
 */
class MainActivity : BaseActivity(), ScanDeviceAdapter.onSelectDeviceListenter {
    var requestPermissionCount = 0;
    val SDK_PERMISSION_REQUEST = 1;
    var permission_list = ArrayList<String>()
    val TAG = "MainActivity";
    var mDevice: BleDevice? = null
    var lv_device: RecyclerView? = null
    var mAdapter: ScanDeviceAdapter? = null

    private var mDeviceList = mutableListOf<BleDevice?>()

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
        supportActionBar?.setDisplayHomeAsUpEnabled(false)
        lv_device = findViewById(R.id.lv_device)
        intPermission();
        // epo upgrade
        IDOEpoManager.shared.enableAutoUpgrade = true
        IDOEpoManager.shared.delegateGetGps = EpoListen()
        var driver: DividerItemDecoration =
            DividerItemDecoration(this, DividerItemDecoration.VERTICAL)
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
            BleManager.getInstance()
                .enableLog(true)
                .setReConnectCount(1, 5000)
                .setConnectOverTime(20000).operateTimeout = 5000
            startScan()
        }
        initconfig()
    }

    override fun getLayoutId(): Int {
        return R.layout.activity_main
    }

    //第三方蓝牙，可以修改称自己的
    fun startScan() {
        showProgressDialog("scan ing...")
        BleManager.getInstance().scan(object : BleScanCallback() {
            override fun onScanStarted(success: Boolean) {

            }

            override fun onScanning(bleDevice: BleDevice?) {

            }

            override fun onScanFinished(scanResultList: List<BleDevice?>?) {
                closeProgressDialog()
                if (scanResultList != null) {
                    mDeviceList = scanResultList.toMutableList();
                    mDeviceList.sortBy {
                        Math.abs(it!!.rssi) }
                }
                mAdapter?.updateData(mDeviceList)
            }
        })
    }

    //第三方蓝牙，可以修改称自己的
    fun initconfig() {
        val scanRuleConfig = BleScanRuleConfig.Builder()
            .setScanTimeOut(10000)
            .build()
        BleManager.getInstance().initScanRule(scanRuleConfig)
    }

    override fun select(position: Int) {
        Log.d(TAG, "select:" + position)
        mDevice = mDeviceList.get(position)
        mAdapter?.setSelectDevice(mDevice!!)
        val intent = Intent(lv_device?.context, FunctionActivity::class.java)
        intent.putExtra(DEVICE, mDevice)
        CurrentDevice.bleDevice = mDevice!!
        device = CurrentDevice.bleDevice
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.getInstance().cancelScan()
    }

    inner class EpoListen : IDOEpoManagerDelegate {
        override fun getAppGpsInfo(): IDOOtaGpsInfo {
            // !!!: 此处的经纬度是伪代码 | The latitude and longitude here are pseudocode
            return IDOOtaGpsInfo(114.0579f,  22.5431f, 10.0f)
        }

    }
}

