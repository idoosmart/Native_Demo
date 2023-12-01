package com.example.example_android.activity

import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.layout_comme_exchange_data.*

class SyncDataActivity : BaseActivity() {
    private var result = ""
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_exchange_data
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("Sync data")
        tv_start?.text = getString(R.string.start_sync_data)
        tv_stop?.text = getString(R.string.stop_sync_data)
        ll_progress?.visibility = View.VISIBLE
    }

    fun start(view: View) {
        result = ""
        sdk.syncData.startSync({

        }, { type, jsonStr, errorCode ->
            result += jsonStr + "\n"
        }, {

        })
    }

    fun stop(view: View) {
        sdk.syncData.stopSync()
    }

}
