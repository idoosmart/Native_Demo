package com.example.example_android.activity

import android.net.Uri
import android.util.Log
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.util.ZipUtil
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOTransBaseModel
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_path
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_progressBar
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_progress_tv
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_response
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_send
import kotlinx.android.synthetic.main.activity_file_transfer.tv_response
import kotlinx.android.synthetic.main.activity_file_transfer.tv_start
import java.io.File

/**
 * AppletFileTransfer Class
 * Used for transferring Applet files
 * */
class AppletTransferActivity : BaseActivity() {

    private var appFile: File? = null
    private var result: String? = null
    override fun getLayoutId(): Int {
        return R.layout.activity_applet_transfer
    }


    override fun initView() {
        super.initView()
        appFile = ZipUtil.copyRawZipFile(this, "dyn_plane", ".app")
        var appFilemutableList = mutableListOf<IDOTransNormalModel>()
        appFilemutableList.add(
            IDOTransNormalModel(
                fileType = IDOTransType.APP,
                filePath = appFile!!.path,
                fileName = "dyn_test.app",
                fileSize = appFile!!.path.length
            )
        )
        applet_path.text = appFile!!.path
        applet_send.setOnClickListener {
            applet_send.isEnabled = false
            Log.d(
                "AppletTransferActivity",
                "initView: ${appFilemutableList}+  type:${IDOTransType.APP}   +${appFile!!.path}"
            )
            sdk.transfer.transferFiles(
                appFilemutableList,
                true,
                { currentIndex, totalCount, currentProgress, totalProgress ->
                    applet_progress_tv.text= "index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}%/100%\n"
//            tv_response.text = result
                    applet_progressBar.progress = (currentProgress * 100).toInt()
                },
                { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
                result += "result: [${it[0]}]\n"
                applet_response.text = result
                applet_send.isEnabled = true
            }
        }


    }

}