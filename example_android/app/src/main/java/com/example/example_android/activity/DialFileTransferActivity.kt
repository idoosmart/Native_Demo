package com.example.example_android.activity

import android.app.Activity
import android.content.Intent
import android.view.View
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.util.FileUtils
import com.example.example_android.util.GetFilePathFromUri
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import kotlinx.android.synthetic.main.activity_dial_transfer.btInstall
import kotlinx.android.synthetic.main.activity_dial_transfer.btStopInstall
import kotlinx.android.synthetic.main.activity_dial_transfer.etDialPath
import kotlinx.android.synthetic.main.activity_dial_transfer.tvResult
import java.io.File

class DialFileTransferActivity : BaseActivity() {
    private var cancellable: IDOCancellable? = null
    private var tasks: MutableList<IDOTransNormalModel> = mutableListOf()
    private var cancelPre = false
    private val REQUEST_CODE_FILE_CHOOSER = 1

    private var getDialPath: String? = null
    override fun getLayoutId(): Int {
        return R.layout.activity_dial_transfer
    }


    fun btSelectDialFile(view: View) {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "*/*"
        startActivityForResult(intent, REQUEST_CODE_FILE_CHOOSER)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_FILE_CHOOSER && resultCode == Activity.RESULT_OK) {

            var uri = data?.data

            getDialPath = GetFilePathFromUri.getFileAbsolutePath(this, uri)
            etDialPath.setText(getDialPath)

        }
    }

    private fun getDialFileUniqueName(): String {
        return if (sdk.device.platform == 99 || sdk.device.platform == 98) ".watch" else ".iwf"
    }


    private fun getTransType(): IDOTransType {
        return if (sdk.device.platform == 99 || sdk.device.platform == 98) IDOTransType.WATCH else IDOTransType.IWFLZ
    }


    override fun initView() {
        super.initView()
        cancelPre = true
        btInstall.setOnClickListener {
            val file = File(getDialPath)
            tasks.add(
                IDOTransNormalModel(
                    fileType = getTransType(),
                    filePath = getDialPath!!,
                    fileName = getDialFileUniqueName(),
                    fileSize = file.length().toInt()
                )
            )
            btInstall.isEnabled = false
            tvResult.text = "start..."
            cancellable = sdk.transfer.transferFiles(tasks, cancelPre, { currentIndex, totalCount, currentProgress, totalProgress ->
                tvResult.text = "index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}%/${totalProgress * 100}%"
            }, { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
                tvResult.text = "${it[0]}"
                btInstall.isEnabled = true
            }
        }

        btStopInstall.setOnClickListener {
            cancellable?.cancel()
            btInstall.isEnabled = true
        }
    }
}