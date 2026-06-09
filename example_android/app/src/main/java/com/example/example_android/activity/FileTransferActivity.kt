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
import kotlinx.android.synthetic.main.activity_file_transfer.tv_file_hint
import kotlinx.android.synthetic.main.activity_file_transfer.tv_file_name
import kotlinx.android.synthetic.main.activity_file_transfer.tv_response
import kotlinx.android.synthetic.main.activity_file_transfer.tv_select_file
import kotlinx.android.synthetic.main.activity_file_transfer.tv_start
import kotlinx.android.synthetic.main.activity_file_transfer.tv_stop
import java.io.File

class FileTransferActivity : BaseActivity() {
    private var cancellable: IDOCancellable? = null

    var result = ""
    private var selectedFilePath: String? = null
    private var transType: TransType? = null
    private val REQUEST_CODE_FILE_CHOOSER = 1001

    override fun getLayoutId(): Int {
        return R.layout.activity_file_transfer
    }

    override fun initView() {
        super.initView()

        val typeInt = intent.getIntExtra("type", -1)
        transType = when (typeInt) {
            1 -> TransType.WALLPAPER
            2 -> TransType.CONTACT
            3 -> TransType.MP3
            else -> null
        }

        if (transType == null) {
            toast("Unknown transfer type")
            finish()
            return
        }

        supportActionBar?.title = transType!!.title()
        tv_file_hint.text = transType!!.fileHint()
        tv_start.isEnabled = false

        tv_select_file.setOnClickListener {
            if (selectedFilePath != null && tv_start.isEnabled.not()) {
                // 已经在传输中
                return@setOnClickListener
            }
            openFilePicker()
        }

        tv_start.setOnClickListener {
            val path = selectedFilePath ?: return@setOnClickListener
            val file = File(path)
            val tasks = mutableListOf<IDOTransNormalModel>()
            val cancelPre: Boolean

            when (transType) {
                TransType.WALLPAPER -> {
                    cancelPre = true
                    tasks.add(
                        IDOTransNormalModel(
                            fileType = IDOTransType.WATCH,
                            filePath = path,
                            fileName = "wallpaper.z",
                            fileSize = file.length().toInt()
                        )
                    )
                }
                TransType.CONTACT -> {
                    cancelPre = false
                    tasks.add(
                        IDOTransNormalModel(
                            fileType = IDOTransType.ML,
                            filePath = path,
                            fileName = "v2_conta.ml",
                            fileSize = 0
                        )
                    )
                }
                TransType.MP3 -> {
                    cancelPre = false
                    tasks.add(
                        IDOTransNormalModel(
                            fileType = IDOTransType.MP3,
                            filePath = path,
                            fileName = file.name,
                            fileSize = file.length().toInt()
                        )
                    )
                }
                else -> return@setOnClickListener
            }

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
            if (!transType!!.isExtensionValid(fileName)) {
                val supported = transType!!.allowedExtensions().joinToString(", ") { ".$it" }
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
}
