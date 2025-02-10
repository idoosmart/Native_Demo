package com.example.example_android.gps

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.example.example_android.MyApplication
import com.example.example_android.appContext
import com.example.example_android.util.FileUtils
import com.example.example_android.util.NetworkUtil
import com.example.example_android.util.SPUtil
import com.example.example_android.util.download.DownloadManager
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.model.IDOGpsStatusModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import com.idosmart.protocol_sdk.IDOTransBaseModel
import kotlinx.android.synthetic.main.activity_file_transfer.tv_response
import kotlinx.android.synthetic.main.activity_file_transfer.tv_start
import java.io.File

/**
 * @author jiangdz
 * @date 2022/10/20
 * @time 14:08
 * 用途:EPO升级
 */
const val NETWORK_IS_UNAVAILABLE = 0;
const val DEVICE_NOT_CONNECTED = 1;
const val FILE_DONWLOAD_FAILED = 2;
const val UPGREADE_GPS_FAILED = 3;
const val DEVICE_IS_BUSY = 4;
const val EPO_FILE_FAILED = 5;
const val ICOE_EPO_FILE_TRANSFER_FAILED = 6;
const val EPO_FILE_TRANSFER_FAILED = 6;
const val DEVICE_SIDE_EPO_UPGREADE_FAILED = 7;

// https://idoosmart.github.io/Native_GitBook/en/doc/IDODeviceEPO.html
@Deprecated("废弃，使用IDOEpoManager / Deprecated, use IDOEpoManager")
class EpoUpgradeHelper {
    private val TAG = "EpoUpgradeHelper"

    private var cancellable: IDOCancellable? = null


    var isGpsStatus = false;


    //是否正在执行升级流程
    private var mUpgrading = false

    //是否正在获取GPS状态
    private var mGetGpsStatus = false

    //EPO升级连续失败最大多少次，今天就不再执行EPO升级检测流程
    private val mEpoFailedMaxCount = 3

    //EPO检测升级流程，连续失败多少次
    private var mEpoFailedCount = 0
    private var mTotalSize = 0
    private var mCurrentIndex = 0
    private val mHandler = Handler(Looper.getMainLooper())

    //获取GPS状态超时时间
    private val mGetGpsTimeOutDuration = 15 * 1000

    private var mEpoUpgradeListener: EpoUpgradeListener? = null

    //获取GPS状态超时事件
    private val mGetGpsTimeOutAction = Runnable {

    }

    private val EPO_DIR =
        appContext.externalCacheDir?.absolutePath?.plus(File.separator)
            ?.plus("epo/")

    //三合一后的EPO文件名称
    private val AIROHA_AGPS_OFFLINE_FILENAME = "EPO.DAT"
    //三合一后的EPO文件
    private val EPO_MERGE_FILE = appContext.externalCacheDir?.absolutePath?.plus(File.separator)
        ?.plus("epo_merge/$AIROHA_AGPS_OFFLINE_FILENAME")

    private val mEpoList by lazy {
        getEpoBeanList()
    }

    companion object {
        private val mInstance: EpoUpgradeHelper by lazy {
            EpoUpgradeHelper()
        }

        @JvmStatic
        fun getInstance(): EpoUpgradeHelper {
            return mInstance
        }
    }

    fun setEpoUpgradeListener(listener: EpoUpgradeListener?) {
        mEpoUpgradeListener = listener
    }

    fun startUpgradeEpo() {
//        if (mUpgrading) {
//            printAndSaveLog("已经在执行EPO检测升级流程，不用重新执行")
//            return
//        }
        if (!NetworkUtil.isNetworkAvailable(MyApplication.instance)) {
            printAndSaveLog("准备执行EPO检测升级流程，但是此时没有网络")
            mEpoUpgradeListener?.onFailed("Network is unavailable!", NETWORK_IS_UNAVAILABLE)
            return
        }
        //TODO The release version should be upgraded every 24 hours.
        //TODO The release version should be upgraded every 24 hours.
        //TODO The release version should be upgraded every 24 hours.
//        val lastUpgradeDate = DataUtils.getInstance().epoLastUpgradeTime
//        if (lastUpgradeDate > 0 && System.currentTimeMillis() - lastUpgradeDate < 24 * 60 * 60 * 1000) {
//            printAndSaveLog("今天已经检测过了EPO检查升级流程，请明天再来")
//            mEpoUpgradeListener?.onFailed("It's not time to upgrade",0)
//            return
//        }
        mUpgrading = true
        if (isSupportGPSUpgrade()) {
            printAndSaveLog("先获取gps信息...")
            Cmds.getGpsInfo().send {
                if(it.error.code == 8){
                    printAndSaveLog("Gps异常，不能升级epo")
                    mEpoUpgradeListener?.onFailed(
                        "The gps is abnormal. Upgrade the gps firmware first",
                        UPGREADE_GPS_FAILED
                    )
                    upgradeFailed()
                } else {
                    startDownloadFile()
                }
            }
        } else {
            printAndSaveLog("start...")
            startDownloadFile()
        }
    }

    private fun isSupportGPSUpgrade(): Boolean {
        return sdk.funcTable.getSupportUpdateGps
    }

    private fun isSupportEPO(): Boolean {
//        val functionInfo = LocalDataManager.getSupportFunctionInfo()
//        return functionInfo != null && functionInfo.Airoha_gps_chip
        return true
    }


    private fun startDownloadFile() {
        FileUtils.deleteDirectory(File(EPO_DIR))
        printAndSaveLog("开始去下载EPO资源文件")
        unregisterListener()
        val file = File(EPO_DIR)
        if (!file.exists()) {
            file.mkdirs()
        }
        mTotalSize = mEpoList.size
        mCurrentIndex = 0
        startDownloadFile(mEpoList[mCurrentIndex])
    }

    private fun startDownloadFile(epoBean: EpoBean) {
        val file = File(epoBean.filePath)
        if (file.exists() && file.isFile) file.delete()
        val deviceId = System.currentTimeMillis()
        DownloadManager.download(
            epoBean.url.plus(deviceId),
            epoBean.filePath,
            object : DownloadManager.DownloadListener {
                /**
                 * 开始下载
                 */
                override fun onDownloadStart() {
                    printAndSaveLog("开始下载EPO文件 epoBean=$epoBean")
                    mHandler.post {
                        mEpoUpgradeListener?.onDownloadStart()
                    }
                }

                /**
                 * 下载进度
                 *
                 * @param progress
                 */
                override fun onDownloadProgress(progress: Int) {
                    printAndSaveLog("EPO文件下载进度 fileName=${epoBean.fileName},progress=$progress")
                    mHandler.post {
                        mEpoUpgradeListener?.onDownloadProgress(
                            mCurrentIndex,
                            mTotalSize,
                            progress
                        )
                    }
                }

                /**
                 * 下载完成
                 *
                 * @param path
                 */
                override fun onDownloadFinish(path: String?) {
                    mHandler.post {
                        printAndSaveLog("EPO文件下载成功 epoBean=$epoBean")
                        mCurrentIndex++
                        if (mCurrentIndex < mTotalSize) {
                            startDownloadFile(mEpoList[mCurrentIndex])
                        } else {
                            mEpoUpgradeListener?.onDownloadSuccess()
                            if (isSupportEPO()) {
                                mHandler.removeCallbacks(mGetGpsTimeOutAction)
                                mHandler.postDelayed(
                                    mGetGpsTimeOutAction,
                                    mGetGpsTimeOutDuration.toLong()
                                )
                                mGetGpsStatus = true
                                Cmds.getGpsStatus().send {
                                    printAndSaveLog("Gps状态获取成功，开始传输GPS文件,gpsStatus=${it.res?.gpsRunStatus},mUpgrading=$mUpgrading,mGetGpsStatus=$mGetGpsStatus")
                                    if(it.error.code == 0){
                                        if(it.res?.gpsRunStatus == 0){
                                            isGpsStatus = true
                                        } else {
                                            mEpoUpgradeListener?.onFailed("Device is busy", DEVICE_IS_BUSY)
                                            upgradeFailed()
                                        }
                                    } else {
                                        upgradeFailed()
                                    }
                                }
                            } else {
                                mEpoUpgradeListener?.onFailed(
                                    "Device not connected or not supported",
                                    DEVICE_NOT_CONNECTED
                                )
                                upgradeFailed()
                                printAndSaveLog("EPO文件下载完成，但是此时用户连接的设备不支持EPO升级")
                            }
                        }
                    }

                }

                /**
                 * 下载失败
                 *
                 * @param errCode
                 * @param errInfo
                 */
                override fun onDownloadFailed(errCode: Int, errInfo: String?) {
                    printAndSaveLog("EPO文件下载失败 epoBean=$epoBean,errCode=$errCode,errInfo=$errInfo")
                    mHandler.post {
                        mEpoUpgradeListener?.onFailed("Download failed!", FILE_DONWLOAD_FAILED)
                        upgradeFailed()
                    }
                }

            })
    }

    private fun getEpoBeanList(): List<EpoBean> {
        return mutableListOf(
            EpoBean(
                url = "https://elpo.airoha.com/ELPO_GR3_1.DAT?vendor=IDOO&project=J3zLAKQJ4vy_81un3vc89qcvBcfjY6GiuiZZs4gn_LM&device_id=",
                fileName = "EPO_GR_3_1.DAT",
                filePath = EPO_DIR.plus("EPO_GR_3_1.DAT")
            ),
            EpoBean(
                url = "https://elpo.airoha.com/ELPO_GAL_3.DAT?vendor=IDOO&project=J3zLAKQJ4vy_81un3vc89qcvBcfjY6GiuiZZs4gn_LM&device_id=",
                fileName = "EPO_GAL_3.DAT",
                filePath = EPO_DIR.plus("EPO_GAL_3.DAT")
            ),

            EpoBean(
                url = "https://elpo.airoha.com/ELPO_BDS_3.DAT?vendor=IDOO&project=J3zLAKQJ4vy_81un3vc89qcvBcfjY6GiuiZZs4gn_LM&device_id=",
                fileName = "EPO_BDS_3.DAT",
                filePath = EPO_DIR.plus("EPO_BDS_3.DAT")
            )
        )
    }

    /**
     *EPO升级成功
     */
    private fun upgradeSuccess() {
        mEpoFailedCount = 0
        mUpgrading = false
        mGetGpsStatus = false
        unregisterListener()
        SPUtil.putAValue("KEY_EPO_LAST_UPGRADE_TIME",System.currentTimeMillis())
    }

    /**
     *EPO升级失败
     */
    private fun upgradeFailed() {
        mEpoFailedCount++
        mUpgrading = false
        mGetGpsStatus = false
        unregisterListener()
        if (mEpoFailedCount >= mEpoFailedMaxCount) {
            SPUtil.putAValue("KEY_EPO_LAST_UPGRADE_TIME",System.currentTimeMillis())
        }
    }

    data class EpoBean(
        val url: String,
        val fileName: String,
        val filePath: String
    )

    private fun printAndSaveLog(message: String?) {
        if (message.isNullOrEmpty()) return
        Log.d(TAG, message)
    }



    //三个文件合并成一个
    private fun makeAirohaGpsFile(dirPath: String) {
        printAndSaveLog("开始将三个文件合并成一个文件")
        val target = File(EPO_MERGE_FILE).parentFile
        if(!target.exists()){
            target.mkdirs()
        }
        sdk.tool.makeEpoFile(dirPath,EPO_MERGE_FILE!!) { status ->
            if (status) {
                printAndSaveLog("EPO文件三合一成功")
                realTransferEpo()
            } else {
                printAndSaveLog("EPO文件制作失败")
                mEpoUpgradeListener?.onFailed("EPO file creation failed", EPO_FILE_FAILED)
                upgradeFailed()
            }
        }
    }

    private fun realTransferEpo(){
        var cancelPre = false
        val tasks = mutableListOf<IDOTransBaseModel>()
        val file = File("$EPO_MERGE_FILE")
        tasks.add(
            IDOTransNormalModel(
                fileType = IDOTransType.EPO,
                filePath = "$EPO_MERGE_FILE",
                fileName = AIROHA_AGPS_OFFLINE_FILENAME,
                fileSize = file.length().toInt()
            )
        )

        cancellable = sdk.transfer.transferFiles(tasks, cancelPre, { currentIndex, totalCount, currentProgress, totalProgress ->

            printAndSaveLog("index: ${currentIndex}/${totalCount} progress: ${currentProgress * 100}/${totalProgress * 100}\n")
            mEpoUpgradeListener?.onTransferProgress((currentProgress * 100).toInt())
        }, { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? -> }) {
            mEpoUpgradeListener?.onTransferSuccess()
            if(it[0]){
                mEpoUpgradeListener?.onSuccess()
                upgradeSuccess()
                printAndSaveLog("升级成功")
            } else {
                upgradeFailed()
                mEpoUpgradeListener?.onFailed("error",-1)
                printAndSaveLog("升级失败")
            }
        }
    }


    /**
     *开始传输EPO文件
     */
    fun startTransferEpoFile() {
        if (isGpsStatus) {
            EPO_DIR?.let { makeAirohaGpsFile(it) }
        } else {
            mEpoUpgradeListener?.onFailed("Gps状态获取失败", 1)
        }
        mEpoUpgradeListener?.onTransferStart()
    }


    fun unregisterListener() {
        mHandler.removeCallbacks(mGetGpsTimeOutAction)
    }

    /**
     *是否正在执行EPO升级流程
     */
    fun isUpgrading() = mUpgrading
}

// https://idoosmart.github.io/Native_GitBook/en/doc/IDODeviceEPO.html
@Deprecated("废弃，使用IDOEpoManager / Deprecated, use IDOEpoManager")
interface EpoUpgradeListener {
    fun onDownloadStart()
    fun onDownloadProgress(index: Int, totalCount: Int, progress: Int)
    fun onDownloadSuccess()
    fun onPackaging()
    fun onTransferStart()
    fun onTransferProgress(progress: Int)
    fun onTransferSuccess()
    fun onFailed(errorMsg: String, code: Int)
    fun onSuccess()
}