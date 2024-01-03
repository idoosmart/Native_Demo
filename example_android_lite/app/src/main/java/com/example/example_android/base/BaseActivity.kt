package com.example.example_android.base

import android.app.ProgressDialog
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.get
import com.example.example_android.R
import com.idosmart.enum.IDODeviceStateType
import com.idosmart.model.IDODeviceStateModel

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

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu, menu)
        mMenuBleStatus = menu?.get(0)
        return super.onCreateOptionsMenu(menu)
    }


    abstract fun getLayoutId(): Int

    @Override
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.getItemId() == android.R.id.home) {
            finish();
            return true;
        }
        return super.onOptionsItemSelected(item)
    }



    private fun updateBleStatus(state: IDODeviceStateModel?) {
        val mBleState = state?.state ?: IDODeviceStateType.DISCONNECTED
        mMenuBleStatus?.setIcon(if (mBleState == IDODeviceStateType.CONNECTED) R.drawable.ble_connect else R.drawable.ble_disconnect)
        mMenuBleStatus?.title = state?.state?.name?.toLowerCase() ?: ""
    }
}