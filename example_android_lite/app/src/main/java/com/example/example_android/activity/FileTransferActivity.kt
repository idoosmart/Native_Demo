package com.example.example_android.activity

import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import com.idosmart.protocol_sdk.IDOTransBaseModel
import kotlinx.android.synthetic.main.activity_file_transfer.tv_response
import kotlinx.android.synthetic.main.activity_file_transfer.tv_start
import kotlinx.android.synthetic.main.activity_file_transfer.tv_stop
import java.io.File

class FileTransferActivity : BaseActivity() {
    private var cancellable: IDOCancellable? = null

    var result = ""
    private var resourceDir = ""
    override fun getLayoutId(): Int {
        return R.layout.activity_file_transfer
    }

    override fun initView() {
        super.initView()
        resourceDir = filesDir.absolutePath + "/resources"
        var cancelPre = false
        val tasks = mutableListOf<IDOTransBaseModel>()
        when (intent.getIntExtra("type", -1)) {
            1 -> {//表盘
                supportActionBar?.setTitle("Transfer Wallpaper File")
                cancelPre = true
                val file = File("${resourceDir}/imgs/0.png")
                tasks.add(
                    IDOTransNormalModel(
                        fileType = IDOTransType.WALLPAPERZ,
                        filePath = "${resourceDir}/imgs/0.png",
                        fileName = "wallpaper.z",
                        fileSize = file.length().toInt()
                    )
                )
            }

            2 -> {//联系人
                supportActionBar?.setTitle("Transfer Contact File")
                tasks.add(
                    IDOTransNormalModel(
                        fileType = IDOTransType.ML,
                        filePath = "${resourceDir}/ml/a.json",
                        fileName = "v2_conta.ml",
                        fileSize = 0
                    )
                )
            }

            3 -> {//音乐
                supportActionBar?.setTitle("Transfer Music File")
                val file = File("${resourceDir}/mp3/3.mp3")
                tasks.add(
                    IDOTransNormalModel(
                        fileType = IDOTransType.MP3,
                        filePath = "${resourceDir}/mp3/3.mp3",
                        fileName = "3.mp3",
                        fileSize = file.length().toInt()
                    )
                )
            }
        }
        tv_start.setOnClickListener {
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
            tv_start.isEnabled = true
        }
    }
}