package com.example.example_android.base

import android.app.ProgressDialog
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Menu
import android.view.MenuInflater
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.get
import com.example.example_android.R
import com.example.example_android.callback.BleManager
import com.example.example_android.callback.ConnectCallback
import com.example.example_android.util.BaseUtil
import com.example.example_android.util.ZipUtil
import com.idosmart.enums.IDODeviceLogType
import com.idosmart.enums.IDODeviceStateType
import com.idosmart.model.IDODeviceStateModel
import com.idosmart.model.IDOReceiveData
import com.idosmart.protocol_channel.sdk
import java.io.File
import java.text.SimpleDateFormat
import java.util.Locale

abstract class BaseActivity : AppCompatActivity() {

    private var progressDialog: ProgressDialog? = null
    var mMenuBleStatus: MenuItem? = null
    private var mainHandler = Handler(Looper.getMainLooper())


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
    protected open fun showProgressCanCancelDialog(title: String?) {
        if (progressDialog != null && progressDialog!!.isShowing) {
            progressDialog!!.dismiss()
        }
        progressDialog = ProgressDialog(this)
        progressDialog!!.setProgressStyle(ProgressDialog.STYLE_SPINNER)
        progressDialog!!.setTitle(title)
        progressDialog!!.setCancelable(true)
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
        BleManager.registerBleDelegate(mConnectCallback)
        initView()
    }

    open fun initView() {

    }

    override fun onDestroy() {
        super.onDestroy()
        BleManager.unregisterBleDelegate(mConnectCallback)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu, menu)
        mMenuBleStatus = menu?.get(0)
        updateBleStatus(BleManager.getConnectState())
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
                        var filePath = filesDir.parentFile.path.plus("/ido_sdk").plus("/devices/logs")
                        var file = File(filePath)
                        if (file.exists()) {
                            if (file.isDirectory) {
                                file.deleteRecursively() // 删除目录及其内容
                            } else {
                                file.delete() // 删除文件
                            }
                        }
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

            R.id.menu_log_ble -> {
                sdk.ble.exportLog {
                    if (it != null) {
                        BaseUtil.share(this, it)
                    }
                }
            }

        }
        return super.onOptionsItemSelected(item)
    }


    private val mConnectCallback = object : ConnectCallback {
        override fun deviceState(state: IDODeviceStateModel) {
            println("设备状态变化：$state")
            super.deviceState(state)
            updateBleStatus(state)
        }

        override fun receiveData(data: IDOReceiveData) {
            println("收到数据：$data")
        }

    }

    private fun updateBleStatus(state: IDODeviceStateModel?) {
        val mBleState = state?.state ?: IDODeviceStateType.DISCONNECTED
        mMenuBleStatus?.setIcon(if (mBleState == IDODeviceStateType.CONNECTED) R.drawable.ble_connect else R.drawable.ble_disconnect)
        mMenuBleStatus?.title = state?.state?.name?.toLowerCase() ?: ""
    }
}