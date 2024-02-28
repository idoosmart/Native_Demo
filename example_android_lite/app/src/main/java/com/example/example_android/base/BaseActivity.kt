package com.example.example_android.base

import android.app.ProgressDialog
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.FileProvider
import androidx.core.view.get
import com.clj.fastble.BleManager
import com.clj.fastble.data.BleDevice
import com.example.example_android.R
import com.example.example_android.util.BaseUtil
import com.example.example_android.util.ZipUtil
import com.idosmart.enum.IDODeviceLogType
import com.idosmart.enum.IDODeviceStateType
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.protocol_channel.sdk
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


abstract class BaseActivity : AppCompatActivity() {

    private var progressDialog: ProgressDialog? = null
    var mMenuBleStatus: MenuItem? = null
    private var mainHandler = Handler(Looper.getMainLooper())

    companion object {
        var device: BleDevice? = null
    }

    protected open fun toast(msg: String) {
        if (Looper.getMainLooper() != Looper.myLooper()) {
            mainHandler.post { Toast.makeText(this, msg, Toast.LENGTH_LONG).show() }
        } else {
            Toast.makeText(this, msg, Toast.LENGTH_LONG).show()
        }
    }

    protected open fun showProgressDialog(title: String?) {
        if (progressDialog != null && progressDialog!!.isShowing) {
            progressDialog!!.dismiss()
        }
        progressDialog = ProgressDialog(this)
        progressDialog!!.setProgressStyle(ProgressDialog.STYLE_SPINNER)
        progressDialog!!.setTitle(title)
        progressDialog!!.setCancelable(false)
        progressDialog!!.show()
    }

    protected open fun closeProgressDialog() {
        if (progressDialog != null && progressDialog!!.isShowing) {
            progressDialog!!.dismiss()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(getLayoutId())
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        initView()

    }

    open fun initView() {

    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        if (device != null) {
            var connected = BleManager.getInstance().isConnected(device!!.mac)
            Log.d("TAG", "deviceStatus -- blestatus: "+connected+"  "+device!!.mac)
            updateBleStatus(connected)
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu, menu)
        mMenuBleStatus = menu?.get(0)
        if (device != null) {
            var connected = BleManager.getInstance().isConnected(device!!.mac)
            Log.d("TAG", "deviceStatus -- blestatus: "+connected+"  "+device!!.mac)
            updateBleStatus(connected)
        }
        return super.onCreateOptionsMenu(menu)
    }


    abstract fun getLayoutId(): Int


    @Override
    override fun onOptionsItemSelected(item: MenuItem): Boolean {

        when (item.itemId) {
            android.R.id.home -> {
                finish();
                return true
            }

            R.id.menu_log_export -> {

                showProgressDialog("Compressed log")
                var logType = listOf(IDODeviceLogType.GENERAL)
                sdk.deviceLog.startGet(logType, 60, { progress ->
                    Log.d("TAG", "onOptionsItemSelected_progress: $progress")
                }, {
                    if (it) {
                        closeProgressDialog()
                        val path = sdk.deviceLog.logDirPath
                        var currentTimeMillis = System.currentTimeMillis()
                        var simpleDateFormat =
                            SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
                        var fileName = simpleDateFormat.format(currentTimeMillis)
                        var filePath = filesDir.parentFile.path.plus("/ido_sdk").plus("/devices")
                        ZipUtil.zip(path, filePath, fileName.plus("_log.zip"))
                        Log.d("TAG", "onOptionsItemSelected filePath: $filePath")
                        BaseUtil.share(this, filePath.plus("/".plus(fileName.plus("_log.zip"))))
                    } else {
                        closeProgressDialog()
                        toast("Please link the watch to use this feature ")
                    }
                })
            }

            R.id.menu_log_app -> {
                sdk.tool.exportLog {
                    BaseUtil.share(this, it)
                }
            }

        }
        return super.onOptionsItemSelected(item)
    }

    open fun updateBleStatus(state: Boolean) {
        Log.d("TAG", "updateBleStatus: "+state+ mMenuBleStatus)
        mMenuBleStatus?.setIcon(if (state) R.drawable.ble_connect else R.drawable.ble_disconnect)
    }
}