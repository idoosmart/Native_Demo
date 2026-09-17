package com.example.example_android.activity

import android.content.Intent
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.ItemTouchHelper
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.R
import com.example.example_android.adapter.ScanDeviceAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.callback.BleManager
import com.example.example_android.util.FunctionUtils
import com.idosmart.enums.IDODeviceStateType
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.pigeon_implement.IDOEpoManager
import com.idosmart.pigeon_implement.IDOEpoManagerDelegate
import com.idosmart.pigeon_implement.IDOOtaGpsInfo
import com.idosmart.protocol_channel.sdk

class MainActivity : BaseActivity() {
    private var lvBoundDevice: RecyclerView? = null
    private var layoutBoundContent: LinearLayout? = null
    private var layoutEmpty: LinearLayout? = null
    private var btnAddDevice: Button? = null
    private var mBoundAdapter: ScanDeviceAdapter? = null
    private var mBoundList = mutableListOf<IDOBleDeviceModel?>()
    private var isUnbinding = false

    companion object {
        val DEVICE: String = "device"
    }

    inner class EpoListen : IDOEpoManagerDelegate {
        override fun getAppGpsInfo(): IDOOtaGpsInfo {
            return IDOOtaGpsInfo(114.0579f, 22.5431f, 10.0f)
        }
    }

    fun initSdk() {
        BleManager.initSdk()
        IDOEpoManager.shared.enableAutoUpgrade = true
        IDOEpoManager.shared.delegateGetGps = EpoListen()
    }

    override fun initView() {
        supportActionBar?.setDisplayHomeAsUpEnabled(false)
        title = "已绑定设备"
        layoutBoundContent = findViewById(R.id.layout_bound_content)
        layoutEmpty = findViewById(R.id.layout_empty)
        lvBoundDevice = findViewById(R.id.lv_bound_device)
        btnAddDevice = findViewById(R.id.btn_add_device)
        initSdk()

        lvBoundDevice?.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL))
        lvBoundDevice?.layoutManager = LinearLayoutManager(this)
        mBoundAdapter = ScanDeviceAdapter(mBoundList, boundStyle = true)
        lvBoundDevice?.adapter = mBoundAdapter
        mBoundAdapter?.setOnSelectDeviceListenter(object : ScanDeviceAdapter.onSelectDeviceListenter {
            override fun select(position: Int) {
                openDevice(mBoundAdapter?.mDeviceList?.getOrNull(position))
            }
        })
        setupSwipeToUnbind()
        btnAddDevice?.setOnClickListener { openScanPage() }
        refreshBoundList()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_home, menu)
        mMenuBleStatus = menu?.findItem(R.id.menu_ble_status)
        updateBleStatusIcon()
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.menu_add_device) {
            openScanPage()
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    private fun updateBleStatusIcon() {
        val state = BleManager.getConnectState()
        mMenuBleStatus?.setIcon(
            if (state?.state == IDODeviceStateType.CONNECTED) R.drawable.ble_connect
            else R.drawable.ble_disconnect
        )
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
                val device = mBoundList.getOrNull(position)
                if (device == null || isUnbinding) {
                    mBoundAdapter?.notifyItemChanged(position)
                    return
                }
                forceUnbind(device, position)
            }
        })
        helper.attachToRecyclerView(lvBoundDevice)
    }

    private fun forceUnbind(device: IDOBleDeviceModel, position: Int) {
        val mac = device.macAddress ?: run {
            mBoundAdapter?.notifyItemChanged(position)
            return
        }
        isUnbinding = true
        showProgressDialog("解绑中...")
        sdk.cmd.unbind(mac, true) { success ->
            runOnUiThread {
                closeProgressDialog()
                isUnbinding = false
                if (success) {
                    FunctionUtils.upDataDeviceMac(mac)
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
        updateBleStatusIcon()
    }

    override fun getLayoutId(): Int = R.layout.activity_main

    private fun refreshBoundList() {
        mBoundList = FunctionUtils.loadBoundDevices().map { it as IDOBleDeviceModel? }.toMutableList()
        val hasBound = mBoundList.isNotEmpty()
        layoutBoundContent?.visibility = if (hasBound) View.VISIBLE else View.GONE
        layoutEmpty?.visibility = if (hasBound) View.GONE else View.VISIBLE
        mBoundAdapter?.updateData(mBoundList)
    }

    private fun openDevice(device: IDOBleDeviceModel?) {
        if (device == null) return
        mBoundAdapter?.setSelectDevice(device)
        val intent = Intent(this, FunctionActivity::class.java)
        intent.putExtra(DEVICE, device)
        startActivity(intent)
    }
}

private fun Intent.putExtra(device: String, mDevice: IDOBleDeviceModel?) {
}
