package com.example.example_android.activity

import android.os.Bundle
import android.view.View
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.gps.EpoUpgradeHelper
import com.example.example_android.gps.EpoUpgradeListener
import kotlinx.android.synthetic.main.activity_gps_main.tvEPOProgress

class GpsMainActivity: BaseActivity(), EpoUpgradeListener {


    override fun getLayoutId(): Int {
        return R.layout.activity_gps_main
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EpoUpgradeHelper.getInstance().setEpoUpgradeListener(this)
        EpoUpgradeHelper.getInstance().startUpgradeEpo()
    }

    fun btTransferEPO(view : View){
        EpoUpgradeHelper.getInstance().startTransferEpoFile()
    }

    override fun onDownloadStart() {
        tvEPOProgress?.setText("starting...")
    }

    override fun onDownloadProgress(index: Int, totalCount: Int, progress: Int) {
        tvEPOProgress?.text = "($index/$totalCount)download progress = $progress"
    }

    override fun onDownloadSuccess() {
        tvEPOProgress?.text = "download success!"
    }

    override fun onPackaging() {
        tvEPOProgress?.text = "packaging..."
    }

    override fun onTransferStart() {
        tvEPOProgress?.text = "transfer starting..."
    }

    override fun onTransferProgress(progress: Int) {
        tvEPOProgress?.text = "transfer progress = $progress"
    }

    override fun onTransferSuccess() {
        tvEPOProgress?.text = "Transfer success, Wait for the device end upgrade to complete"
    }

    override fun onFailed(errorMsg: String, code: Int) {
        tvEPOProgress?.text = "failed: $errorMsg"
    }

    override fun onSuccess() {
        tvEPOProgress?.text = "upgrade success!"
    }
}