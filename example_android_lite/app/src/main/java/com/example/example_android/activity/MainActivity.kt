package com.example.example_android.activity

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.clj.fastble.BleManager
import com.example.example_android.R
import com.example.example_android.adapter.ScanDeviceAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.CurrentDevice
import com.example.example_android.util.BoundDeviceInfo
import com.example.example_android.util.FunctionUtils
import com.idosmart.pigeon_implement.IDOEpoManager
import com.idosmart.pigeon_implement.IDOEpoManagerDelegate
import com.idosmart.pigeon_implement.IDOOtaGpsInfo
import com.idosmart.protocol_channel.sdk

/**
 * 首页：已绑定设备列表。添加设备进入 [ScanActivity]。
 */
class MainActivity : BaseActivity() {
    private var lvBoundDevice: RecyclerView? = null
    private var layoutBoundContent: LinearLayout? = null
    private var layoutEmpty: LinearLayout? = null
    private var btnAddDevice: Button? = null
    private var mBoundAdapter: ScanDeviceAdapter? = null
    private var isUnbinding = false
    private var pendingBound: BoundDeviceInfo? = null

    companion object {
        val DEVICE: String = "device"
        private const val CONNECT_PERMISSION_REQUEST = 2
    }

    inner class EpoListen : IDOEpoManagerDelegate {
        override fun getAppGpsInfo(): IDOOtaGpsInfo {
            // !!!: 此处的经纬度是伪代码 | The latitude and longitude here are pseudocode
            return IDOOtaGpsInfo(114.0579f, 22.5431f, 10.0f)
        }
    }

    override fun initView() {
        supportActionBar?.setDisplayHomeAsUpEnabled(false)
        title = "已绑定设备"
        layoutBoundContent = findViewById(R.id.layout_bound_content)
        layoutEmpty = findViewById(R.id.layout_empty)
        lvBoundDevice = findViewById(R.id.lv_bound_device)
        btnAddDevice = findViewById(R.id.btn_add_device)
        IDOEpoManager.shared.enableAutoUpgrade = true
        IDOEpoManager.shared.delegateGetGps = EpoListen()

        lvBoundDevice?.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))
        lvBoundDevice?.layoutManager = LinearLayoutManager(this)
        mBoundAdapter = ScanDeviceAdapter(boundStyle = true)
        lvBoundDevice?.adapter = mBoundAdapter
        mBoundAdapter?.setOnSelectDeviceListenter(object : ScanDeviceAdapter.onSelectDeviceListenter {
            override fun select(position: Int) {
                val info = mBoundAdapter?.getBoundItem(position) ?: return
                openBoundDevice(info)
            }
        })
        setupSwipeToUnbind()
        btnAddDevice?.setOnClickListener { openScanPage() }
        refreshBoundList()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_home, menu)
        mMenuBleStatus = menu?.findItem(R.id.menu_ble_status)
        val connected = device?.mac?.let { BleManager.getInstance().isConnected(it) } ?: false
        updateBleStatus(connected)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.menu_add_device) {
            openScanPage()
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    private fun openScanPage() {
        startActivity(Intent(this, ScanActivity::class.java))
    }

    private fun setupSwipeToUnbind() {
        val helper = ItemTouchHelper(object : ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.LEFT) {
            override fun onMove(
                recyclerView: RecyclerView,
                viewHolder: RecyclerView.ViewHolder,
                target: RecyclerView.ViewHolder
            ): Boolean = false

            override fun onSwiped(viewHolder: RecyclerView.ViewHolder, direction: Int) {
                val position = viewHolder.adapterPosition
                val info = mBoundAdapter?.getBoundItem(position)
                if (info == null || isUnbinding) {
                    mBoundAdapter?.notifyItemChanged(position)
                    return
                }
                forceUnbind(info, position)
            }
        })
        helper.attachToRecyclerView(lvBoundDevice)
    }

    private fun forceUnbind(info: BoundDeviceInfo, position: Int) {
        isUnbinding = true
        showProgressDialog("解绑中...")
        sdk.cmd.unbind(info.mac, true) { success ->
            runOnUiThread {
                closeProgressDialog()
                isUnbinding = false
                if (success) {
                    FunctionUtils.removeBindState(info.mac)
                    toast("解绑成功")
                    refreshBoundList()
                } else {
                    toast("解绑失败")
                    mBoundAdapter?.notifyItemChanged(position)
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        refreshBoundList()
    }

    override fun getLayoutId(): Int = R.layout.activity_main

    private fun refreshBoundList() {
        val list = FunctionUtils.loadBoundDevices()
        val hasBound = list.isNotEmpty()
        layoutBoundContent?.visibility = if (hasBound) View.VISIBLE else View.GONE
        layoutEmpty?.visibility = if (hasBound) View.GONE else View.VISIBLE
        mBoundAdapter?.setBoundData(list)
    }

    private fun openBoundDevice(info: BoundDeviceInfo) {
        if (!hasConnectPermission()) {
            pendingBound = info
            val permissions = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT, Manifest.permission.BLUETOOTH_SCAN)
            } else {
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,
                    Manifest.permission.BLUETOOTH
                )
            }
            ActivityCompat.requestPermissions(this, permissions, CONNECT_PERMISSION_REQUEST)
            return
        }
        val ble = info.toBleDevice()
        if (ble == null) {
            toast("无法还原设备")
            return
        }
        CurrentDevice.bleDevice = ble
        device = ble
        val intent = Intent(this, FunctionActivity::class.java)
        intent.putExtra(DEVICE, ble)
        startActivity(intent)
    }

    private fun hasConnectPermission(): Boolean {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            Manifest.permission.BLUETOOTH_CONNECT
        } else {
            Manifest.permission.BLUETOOTH
        }
        return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CONNECT_PERMISSION_REQUEST && hasConnectPermission()) {
            pendingBound?.let { openBoundDevice(it) }
            pendingBound = null
        }
    }
}
