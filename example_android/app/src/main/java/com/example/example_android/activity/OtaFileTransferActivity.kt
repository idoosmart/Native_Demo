package com.example.example_android.activity

import android.app.Activity
import android.content.Intent
import android.widget.Toast
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.TransType
import com.example.example_android.util.GetFilePathFromUri
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import com.idosmart.protocol_sdk.IDOTransBaseModel
import kotlinx.android.synthetic.main.activity_file_transfer.tv_file_hint
import kotlinx.android.synthetic.main.activity_file_transfer.tv_file_name
import kotlinx.android.synthetic.main.activity_file_transfer.tv_ota_warning
import kotlinx.android.synthetic.main.activity_file_transfer.tv_response
import kotlinx.android.synthetic.main.activity_file_transfer.tv_select_file
import kotlinx.android.synthetic.main.activity_file_transfer.tv_start
import kotlinx.android.synthetic.main.activity_file_transfer.tv_stop
import java.io.File

class OtaFileTransferActivity : BaseActivity() {
    private var cancellable: IDOCancellable? = null
    private var selectedFilePath: String? = null
    private val REQUEST_CODE_FILE_CHOOSER = 2001

    private var tasks: MutableList<IDOTransNormalModel> = mutableListOf()
    private var cancelPre = false

    var result = ""

    override fun getLayoutId(): Int {
        return R.layout.activity_file_transfer
    }

    override fun initView() {
        super.initView()

        supportActionBar?.title = TransType.OTA.title()
        tv_file_hint.text = TransType.OTA.fileHint()
        tv_ota_warning.text = TransType.OTA.otaWarning()
        tv_ota_warning.visibility = android.view.View.VISIBLE
        tv_start.isEnabled = false

        tv_select_file.setOnClickListener {
            openFilePicker()
        }

        tv_start.setOnClickListener {
            val path = selectedFilePath ?: return@setOnClickListener
            val file = File(path)

            cancelPre = true
            tasks.clear()
            tasks.add(
                IDOTransNormalModel(
                    fileType = IDOTransType.FW,
                    filePath = path,
                    fileName = file.name,
                    fileSize = file.length().toInt()
                )
            )

            val isRingOta = intent.getBooleanExtra("isRingOta", false)
            if (isRingOta) {
                val macAddress = sdk.device.macAddressFull
                sdk.ble.cancelConnect(macAddress) {
                    sdk.bridge.markOtaMode(macAddress = macAddress, platform = sdk.device.platform, deviceId = sdk.device.deviceId) {
                        _startTransfer()
                    }
                }
            } else {
                _startTransfer()
            }
        }

        tv_stop.setOnClickListener {
            cancellable?.cancel()
            tv_start.isEnabled = selectedFilePath != null
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
            if (!TransType.OTA.isExtensionValid(fileName)) {
                val supported = TransType.OTA.allowedExtensions().joinToString(", ") { ".$it" }
                Toast.makeText(this, "Unsupported format: $fileName\nSupported: $supported", Toast.LENGTH_LONG).show()
                return
            }

            selectedFilePath = filePath
            tv_file_name.text = fileName
            tv_file_name.setTextColor(android.graphics.Color.parseColor("#228B22"))
            tv_start.isEnabled = true
            tv_response.text = ""
        }
    }

    private fun _startTransfer() {
        result = ""
        tv_start.isEnabled = false
        tv_response.text = "start..."
        cancellable = sdk.transfer.transferFiles(tasks, cancelPre, { currentIndex, totalCount, currentProgress, totalProgress ->
            result += "index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}%/${totalProgress * 100}%\n"
            tv_response.text = result
        }, { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
            result += "result: [${it[0]}]\n"
            tv_response.text = result
            tv_start.isEnabled = true
        }
    }
}
