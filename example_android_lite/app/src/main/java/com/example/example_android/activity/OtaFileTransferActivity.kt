package com.example.example_android.activity

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.text.format.DateUtils
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.util.ZipUtil.copyRawZipFile
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
import java.text.SimpleDateFormat
import java.util.Date
import kotlin.math.log

class OtaFileTransferActivity : BaseActivity() {
    private var cancellable: IDOCancellable? = null
    private val REQUEST_CODE_STORAGE_PERMISSION = 1001
   private var copiedFile:File? =null
    private var  tasks : MutableList<IDOTransNormalModel> =mutableListOf()
    private var  cancelPre =false
    private var FileExtension =""


    var result = ""
    private var resourceDir = ""
    override fun getLayoutId(): Int {
        return R.layout.activity_file_transfer
    }

    override fun initView() {
        super.initView()
        var rawZipFileName =""
        when(sdk.device.deviceId){
            7877->{
                 rawZipFileName = "ota_7877_v01_01_00"
                FileExtension =".zip"
            }
            543->{
                 rawZipFileName = "ota_543_v01_61_99"
                 FileExtension =".zip"
            }
            7814->{
                rawZipFileName = "ota_7814_v1_00_07"
                FileExtension =".bin"
            }
            537->{
                rawZipFileName = "ota_full_537_v1_01_03"
                FileExtension =".bin"
            }
            517->{
                rawZipFileName = "ota_full_517_v1_01_01"
                FileExtension =".bin"
            }
            845->{
                rawZipFileName = "ota_845_v1_00_10"
                FileExtension = ".fw"
            }
        }

        // 检查是否已经授予 WRITE_EXTERNAL_STORAGE 权限
            // 已经具有权限，执行读写操作
             copiedFile = copyRawZipFile(this, rawZipFileName,FileExtension)
//        try {

            val filePath = copiedFile?.path
            // 获取文件长度
            val fileLength = filePath?.length
            cancelPre =true
            tasks.add(
                IDOTransNormalModel(
                    fileType = IDOTransType.FW,
                    filePath = filePath!!,
                    fileName = rawZipFileName,
                    fileSize = fileLength!!.toInt()
                )
            )

        tv_start.setOnClickListener {
                result = "${format(System.currentTimeMillis())}\n"
            val startTime = System.currentTimeMillis()
                tv_start.isEnabled = false
                tv_response.text = "start..."
                cancellable = sdk.transfer.transferFiles(tasks, cancelPre, { currentIndex, totalCount, currentProgress, totalProgress ->
                    result += "index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}%/${totalProgress * 100}%, update time: ${(System.currentTimeMillis()-startTime)/1000}\n"
                    tv_response.text = result
                }, { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
                    result += "result: [${it[0]}]\n"
                    result+="${format(System.currentTimeMillis())}\n"
                    tv_response.text = result
                    tv_start.isEnabled = true
                }
        }

        tv_stop.setOnClickListener {
            cancellable?.cancel()
            tv_start.isEnabled = true
        }
    }

    fun format(time:Long):String{
        val format = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.sss")
        return format.format(Date(time))
    }
}