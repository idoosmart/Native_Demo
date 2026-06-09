package com.example.example_android.activity

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.widget.Toast
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.TransType
import com.example.example_android.util.GetFilePathFromUri
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_file_hint
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_file_name
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_progress_tv
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_progressBar
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_response
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_select_file
import kotlinx.android.synthetic.main.activity_applet_transfer.applet_send
import java.io.File

/**
 * AppletFileTransfer Class
 * Used for transferring Applet files
 * */
class AppletTransferActivity : BaseActivity() {

    private var selectedFilePath: String? = null
    private var result: String? = null
    private val REQUEST_CODE_FILE_CHOOSER = 3001

    override fun getLayoutId(): Int {
        return R.layout.activity_applet_transfer
    }

    override fun initView() {
        super.initView()

        supportActionBar?.title = TransType.APP.title()
        applet_file_hint.text = TransType.APP.fileHint()
        applet_send.isEnabled = false

        applet_select_file.setOnClickListener {
            openFilePicker()
        }

        applet_send.setOnClickListener {
            val path = selectedFilePath ?: return@setOnClickListener
            val file = File(path)

            applet_send.isEnabled = false
            var appFilemutableList = mutableListOf<IDOTransNormalModel>()
            appFilemutableList.add(
                IDOTransNormalModel(
                    fileType = IDOTransType.APP,
                    filePath = path,
                    fileName = file.name,
                    fileSize = file.length().toInt()
                )
            )

            Log.d(
                "AppletTransferActivity",
                "initView: ${appFilemutableList}+  type:${IDOTransType.APP}   +${path}"
            )
            sdk.transfer.transferFiles(
                appFilemutableList,
                true,
                { currentIndex, totalCount, currentProgress, totalProgress ->
                    applet_progress_tv.text = "index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}%/100%\n"
                    applet_progressBar.progress = (currentProgress * 100).toInt()
                },
                { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
                result += "result: [${it[0]}]\n"
                applet_response.text = result
                applet_send.isEnabled = true
            }
        }
    }

    private fun openFilePicker() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "*/*"
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        startActivityForResult(intent, REQUEST_CODE_FILE_CHOOSER)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_FILE_CHOOSER && resultCode == Activity.RESULT_OK) {
            val uri = data?.data ?: return
            val filePath = GetFilePathFromUri.getFileAbsolutePath(this, uri) ?: return

            // 校验文件后缀
            val fileName = File(filePath).name
            if (!TransType.APP.isExtensionValid(fileName)) {
                val supported = TransType.APP.allowedExtensions().joinToString(", ") { ".$it" }
                Toast.makeText(this, "Unsupported format: $fileName\nSupported: $supported", Toast.LENGTH_LONG).show()
                return
            }

            selectedFilePath = filePath
            applet_file_name.text = fileName
            applet_file_name.setTextColor(android.graphics.Color.parseColor("#228B22"))
            applet_send.isEnabled = true
        }
    }
}
