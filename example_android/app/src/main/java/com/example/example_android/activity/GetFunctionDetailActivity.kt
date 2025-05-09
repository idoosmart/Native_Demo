package com.example.example_android.activity

import androidx.appcompat.app.AlertDialog
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.CustomEvtType
import com.example.example_android.data.GetFuntionData
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDODeviceFileToAppTask
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import com.idosmart.protocol_sdk.IDOCmdPriority
import kotlinx.android.synthetic.main.layout_comme_send_data.*

class GetFunctionDetailActivity : BaseActivity() {
    private var getFunctionData: GetFuntionData? = null
    private var mIDOCancellable: IDOCancellable? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_send_data
    }

    override fun initView() {
        super.initView()
        getFunctionData =
            intent.getSerializableExtra(GetFuntionActivity.FUNCTION_DATA) as GetFuntionData?
        supportActionBar?.title = getFunctionData?.title
        val myType = getFunctionData?.type ?: return
        send_btn.setOnClickListener {

            //根据功能列表传入过来的事件类型进行不同操作
            //Different operations are performed depending on the type of event passed in from the function list
            when (myType) {
                CustomEvtType.GETACTIVITYSWITCH -> getActivitySwitch()
                CustomEvtType.GETALARMV3 -> getAlarm()
                CustomEvtType.GETALLHEALTHSWITCHSTATE -> getAllHealthSwitchState()
                CustomEvtType.GETBATTERYINFO -> getBatteryInfo()
                CustomEvtType.GETBLEBEEPV3 -> getBleBeep()
                CustomEvtType.GETBLEMUSICINFO -> getBleMusicInfo()
                CustomEvtType.GETBPALGVERSION -> getBpAlgVersion()
                CustomEvtType.GETBTNOTICE -> getBtNotice()
                CustomEvtType.GETCONTACTREVISETIME -> getContactReviseTime()
                CustomEvtType.GETDEVICELOGSTATE -> getDeviceLogState()
                CustomEvtType.GETDOWNLANGUAGE -> getDownloadLanguage()
                CustomEvtType.GETERRORRECORD -> getErrorRecord()
                CustomEvtType.GETFLASHBININFO -> getFlashBinInfo()
                CustomEvtType.GETGPSINFO -> getGpsInfo()
                CustomEvtType.GETGPSSTATUS -> getGpsStatus()
                CustomEvtType.GETHABITINFOV3 -> getHabitInfo()
                CustomEvtType.GETHEARTRATEMODE -> getHeartRateMode()
                CustomEvtType.GETHOTSTARTPARAM -> getHotStartParam()
                CustomEvtType.GETLANGUAGELIBRARYDATAV3 -> getLanguageLibrary()
                CustomEvtType.GETMENULIST -> getMenuList()
                CustomEvtType.GETMTUINFO -> getMtuInfo()
                CustomEvtType.GETNOTDISTURBSTATUS -> getNotDisturbStatus()
                CustomEvtType.GETNOTICESTATUS -> getNoticeStatus()
                CustomEvtType.GETSCREENBRIGHTNESS -> getScreenBrightness()
                CustomEvtType.GETSTEPGOAL -> getStepGoal()
                CustomEvtType.GETSTRESSVAL -> getStressVal()
                CustomEvtType.GETSUPPORTMAXSETITEMSNUM -> getSupportMaxSetItemsNum()
                CustomEvtType.GETUNERASABLEMEUNLIST -> getUnerasableMeunList()
                CustomEvtType.GETUNREADAPPREMINDER -> getUnreadAppReminder()
                CustomEvtType.GETUPDATESTATUS -> getUpdateStatus()
                CustomEvtType.GETUPHANDGESTURE -> getUpHandGesture()
                CustomEvtType.GETVERSIONINFO -> getVersionInfo()
                CustomEvtType.GETWALKREMIND -> getWalkRemind()
                CustomEvtType.GETWATCHDIALID -> getWatchDialId()
                CustomEvtType.GETWATCHDIALINFO -> getWatchDialInfo()
                CustomEvtType.GETWATCHFACELIST -> getWatchListV2()
                CustomEvtType.GETWATCHLISTV3 -> getWatchListV3()
                CustomEvtType.GETLIVEDATA -> getLiveData(1)
                CustomEvtType.GETMAINSPORTGOAL -> getMainSportGoal(0)
                CustomEvtType.OTASTART -> otaStart()
                CustomEvtType.REBOOT -> reboot()
                CustomEvtType.FACTORYRESET -> getFactoryreset()
                CustomEvtType.FINDDEVICESTART -> getFindDeviceStart()
                CustomEvtType.FINDDEVICESTOP -> getFindDeviceStop()
                CustomEvtType.GETDEFAULTSPORTTYPE -> getDefaultSportType()
                CustomEvtType.GETSPORTTYPEV3 -> getSportTypeV3()
                //这几个方法与上面的的逻辑有一点区别，使用时请注意，参考给出代码逻辑编写
                //These methods have a little difference from the above logic, please note when using, refer to the code logic written
                CustomEvtType.GETHIDINFO -> getHidInfo()
                CustomEvtType.GETSNINFO -> getSn()
                CustomEvtType.GETBTCONNECTPHONEMODEL -> getBtConnectPhoneModel()
                CustomEvtType.GETBTNAME -> getBtName()
                CustomEvtType.GETDEVICENAME -> getDeviceName()
                CustomEvtType.GETALGFILE-> getAlgFile()
                CustomEvtType.REQUESTALGFILE-> requestAlgFile()
                CustomEvtType.GETLEFTRIGHTWEARSETTINGS -> getLeftRightWearSettings()
                CustomEvtType.GETSETTINGSDURINGEXERCISE -> getSettingsDuringExercise()
                CustomEvtType.GETSIMPLEHEARTRATEZONE -> getSimpleHeartRateZone()
                CustomEvtType.SETSPORTINGREMINDSETTING -> getSportingRemindSetting()
                else -> {}
            }
        }

        sdk.transfer.registerDeviceTranFileToApp {
            deviceTransFileToApp(it)
        }
    }

    private fun getSportingRemindSetting(){
        val param = listOf(48)
        Cmds.getSportingRemindSetting(param).send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = GsonBuilder().create().toJson(param).toString()
    }

    private fun getSimpleHeartRateZone(){
        Cmds.getSimpleHeartRateZone().send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = "{}"
    }
    private fun getSettingsDuringExercise(){
        Cmds.getSettingsDuringExercise().send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = "{}"
    }

    private fun getLeftRightWearSettings(){
        Cmds.getLeftRightWearSettings().send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = "{}"
    }

    private fun deviceTransFileToApp(task: IDODeviceFileToAppTask) {
        println("收到设备传输文件 名称：${task.deviceTransItem.fileName} 大小：${task.deviceTransItem.fileSize} 到App")
                task.acceptReceiveFile(onProgress = { progress ->
                    // Handle progress updates here
                    println("Progress: $progress")
                    tv_response?.text ="Progress: $progress"
                },
                    onComplete = { isCompleted, receiveFilePath ->
                        // Handle completion here
                        if (isCompleted) {
                            println("File received successfully at: $receiveFilePath")
                            tv_response?.text ="File received successfully at: $receiveFilePath"
                        } else {
                            tv_response?.text ="File transfer failed."

                        }
                    })
                /*
                // Note: Receiving can be terminated at any time
                // Abort receiving file
                task.stopReceiveFile { rs ->
                    println("已终止接收文件${task.deviceTransItem.fileName)")
                }
                 */
            }

    /**
     * Request firmware algorithm file information (ACC/GPS)
     * type: 1:ACC file 、2:GPS file
     *
     * */
    private fun requestAlgFile() {
        var rquestAlgFile = Cmds.rquestAlgFile(2)
        rquestAlgFile.send {
            if (it.error.code==0){
                if (it.error.code == 0) {
                    val res = it.res?.toJsonString() ?: "{ok}"
                    tv_response?.text = res
                } else {
                    val res = it.res?.toJsonString() ?: "{erro}"
                    tv_response?.text = "erro: $res"
                }
            }
        }
        paramter_tv?.text = rquestAlgFile?.json
    }

    /**
     * Get firmware algorithm file information (ACC/GPS)
     *
     * */
    private fun getAlgFile() {
        var algFileInfo = Cmds.getAlgFileInfo()
        algFileInfo.send {
            if (it.error.code==0){
                if (it.error.code == 0) {
                    val res = it.res?.toJsonString() ?: "{ok}"
                    tv_response?.text = res
                } else {
                    val res = it.res?.toJsonString() ?: "{erro}"
                    tv_response?.text = "erro: $res"
                }
            }
        }
        paramter_tv?.text = algFileInfo?.json
    }

    /**
     *  v3 app获取ble的闹钟
     *  v3 app obtains the ble alarm clock
     * */
    private fun getAlarm() {
        var alarm = Cmds.getAlarm(IDOCmdPriority.HIGH)
        alarm.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = alarm?.json
    }


    /**
     * 获取所有的健康监测开关
     * Access all health monitoring switches
     * */
    private fun getAllHealthSwitchState() {
        var allHealthSwitchState = Cmds.getAllHealthSwitchState()
        allHealthSwitchState.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = allHealthSwitchState?.json
    }


    /**
     * 获取电池信息
     * Get Battery Information
     * */
    private fun getBatteryInfo() {
        var batteryInfo = Cmds.getBatteryInfo()
        batteryInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = batteryInfo?.json
    }


    /**
     * v3获取固件本地提示音文件信息
     * v3 obtains firmware local tone file information
     * */
    private fun getBleBeep() {
        var bleBeep = Cmds.getBleBeep()
        bleBeep.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = bleBeep?.json
    }

    /**
     * 获取固件的歌曲名和文件夹
     * Get firmware for song names and folders
     * */
    private fun getBleMusicInfo() {
        var bleMusicInfo = Cmds.getBleMusicInfo()
        bleMusicInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = bleMusicInfo?.json
    }

    /**
     * 获取血压算法三级版本号信息事件号
     * Get blood pressure algorithm version 3 information event number
     * */
    private fun getBpAlgVersion() {
        var bpAlgVersion = Cmds.getBpAlgVersion()
        bpAlgVersion.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = bpAlgVersion?.json
    }


    /**
     * 查询bt配对开关、连接、a2dp连接、hfp连接状态(仅支持带bt蓝牙的设备)
     * Query the status of bt pairing switch, connection, a2dp connection, hfp connection (only for devices with bt Bluetooth)
     * */
    private fun getBtNotice() {
        var btNotice = Cmds.getBtNotice()
        btNotice.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = btNotice?.json
    }

    /**
     * 获取固件本地保存联系人文件修改时间
     * Obtain the modification time of the locally saved contact file in the firmware
     * */
    private fun getContactReviseTime() {
        var contactReviseTime = Cmds.getContactReviseTime()
        contactReviseTime.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = contactReviseTime?.json
    }

    /**
     * 获取设备的日志状态
     * Obtain the log status of the device
     * */
    private fun getDeviceLogState() {
        var deviceLogState = Cmds.getDeviceLogState()
        deviceLogState.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = deviceLogState?.json
    }

    /**
     * 获取下载语言支持
     * Get download language support
     * */
    private fun getDownloadLanguage() {
        var downloadLanguage = Cmds.getDownloadLanguage()
        downloadLanguage.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = downloadLanguage?.json
    }

    /**
     * 获取错误记录
     * Get error record
     * */
    private fun getErrorRecord() {
        var errorRecord = Cmds.getErrorRecord()
        errorRecord.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = errorRecord?.json
    }

    /**
     * 获取字库信息
     * Get font information
     * */
    private fun getFlashBinInfo() {
        var flashBinInfo = Cmds.getFlashBinInfo()
        flashBinInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = flashBinInfo?.json
    }


    /**
     * 获取gps信息
     * Get gps information
     * */
    private fun getGpsInfo() {
        var gpsInfo = Cmds.getGpsInfo()
        gpsInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = gpsInfo?.json
    }

    /**
     * 获取gps状态
     * Get gps status
     * */
    private fun getGpsStatus() {
        var gpsStatus = Cmds.getGpsStatus()
        gpsStatus.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = gpsStatus?.json
    }

    /**
     * v3获取固件本地提示音文件信息
     * v3 obtains firmware local tone file information
     * */
    private fun getHabitInfo() {
        var habitInfo = Cmds.getHabitInfo()
        habitInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = habitInfo?.json
    }


    /**
     * 获取心率监测模式
     * Get heart rate monitoring mode
     * */
    private fun getHeartRateMode() {
        var heartRateMode = Cmds.getHeartRateMode()
        heartRateMode.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = heartRateMode?.json
    }

    /**
     * 获取热启动参数
     * Obtain hot start parameters
     * */
    private fun getHotStartParam() {
        var hotStartParam = Cmds.getHotStartParam()
        hotStartParam.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = hotStartParam?.json
    }

    /**
     * v3 获取设备字库列表
     * v3 Gets the device font list
     * */
    private fun getLanguageLibrary() {
        var languageLibrary = Cmds.getLanguageLibrary()
        languageLibrary.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = languageLibrary?.json
    }

    /**
     * 获取设备支持的列表
     * Gets a list of supported devices
     * */
    private fun getMenuList() {
        var menuList = Cmds.getMenuList()
        menuList.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = menuList?.json
    }

    /**
     * 获取mtu信息
     * Obtaining mtu Information
     * */
    private fun getMtuInfo() {
        var mtuInfo = Cmds.getMtuInfo()
        mtuInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = mtuInfo?.json
    }

    /**
     * 获取通知中心的状态
     * Gets the status of the notification center
     * */
    private fun getNoticeStatus() {
        var noticeStatus = Cmds.getNoticeStatus()
        noticeStatus.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = noticeStatus?.json
    }

    /**
     * 获取勿扰模式状态
     * Get the Do not disturb mode status
     * */
    private fun getNotDisturbStatus() {
        var notDisturbStatus = Cmds.getNotDisturbStatus()
        notDisturbStatus.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = notDisturbStatus?.json
    }

    /**
     * 获取屏幕亮度
     * Get screen brightness
     * */
    private fun getScreenBrightness() {
        var screenBrightness = Cmds.getScreenBrightness()
        screenBrightness.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = screenBrightness?.json
    }

    /**
     * 获取全天步数目标
     * Get an all-day step goal
     * */
    private fun getStepGoal() {
        var stepGoal = Cmds.getStepGoal()
        stepGoal.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = stepGoal?.json
    }


    /**
     * 获取压力值
     * Obtain pressure value
     * */
    private fun getStressVal() {
        var stressVal = Cmds.getStressVal()
        stressVal.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = stressVal?.json
    }

    /**
     * 获取固件支持的详情最大设置数量
     * Get maximum number of Settings supported by firmware details
     * */
    private fun getSupportMaxSetItemsNum() {
        var supportMaxSetItemsNum = Cmds.getSupportMaxSetItemsNum()
        supportMaxSetItemsNum.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = supportMaxSetItemsNum?.json
    }


    /**
     * 获取固件不可删除的快捷应用列表
     * Obtain a list of shortcut applications whose firmware cannot be deleted
     * */
    private fun getUnerasableMeunList() {
        var unerasableMeunList = Cmds.getUnerasableMeunList()
        unerasableMeunList.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = unerasableMeunList?.json
    }

    /**
     * 获取红点提醒开关
     * Get the red dot reminder switch
     * */
    private fun getUnreadAppReminder() {
        var unreadAppReminder = Cmds.getUnreadAppReminder()
        unreadAppReminder.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = unreadAppReminder?.json
    }


    /**
     * 获取设备升级状态
     * Obtain the upgrade status of the device
     * */
    private fun getUpdateStatus() {
        var updateStatus = Cmds.getUpdateStatus()
        updateStatus.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = updateStatus?.json
    }


    /**
     * 获取抬腕数据
     * Obtain wrist lift data
     * */
    private fun getUpHandGesture() {
        var upHandGesture = Cmds.getUpHandGesture()
        upHandGesture.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = upHandGesture?.json
    }

    /**
     * 获取版本信息
     * Get version information
     * */
    private fun getVersionInfo() {
        var versionInfo = Cmds.getVersionInfo()
        versionInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = versionInfo?.json
    }

    /**
     * 获取走动提醒
     * Get a walk alert
     * */
    private fun getWalkRemind() {
        var walkRemind = Cmds.getWalkRemind()
        walkRemind.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = walkRemind?.json
    }

    /**
     * 获取表盘id
     * Gets the dial id
     * */
    private fun getWatchDialId() {
        var watchDialId = Cmds.getWatchDialId()
        watchDialId.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = watchDialId?.json
    }

    /**
     * 获取屏幕信息
     * Get screen information
     * */
    private fun getWatchDialInfo() {
        var watchDialInfo = Cmds.getWatchDialInfo()
        watchDialInfo.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = watchDialInfo?.json
    }

    /**
     * V2 获取表盘列表
     * V2 Obtains the dial list
     *
     * */
    private fun getWatchListV2() {
        var watchListV2 = Cmds.getWatchListV2()
        watchListV2.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = watchListV2?.json
    }

    /**
     * v3 获取表盘列表
     * v3 Obtains the dial list
     * */
    private fun getWatchListV3() {
        var watchListV3 = Cmds.getWatchListV3()
        watchListV3.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = watchListV3?.json
    }

    /**
     * 获得实时数据
     * Get real-time data
     * flag :
     * */
    private fun getLiveData(flag: Int) {
        var liveData = Cmds.getLiveData(flag)
        liveData.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = liveData?.json
    }


    /**
     * 获取设置的卡路里/距离/中高运动时长 主界面
     * Get the calorie/distance/medium/high exercise duration set main screen
     * timeGoalType:
     * */
    private fun getMainSportGoal(timeGoalType: Int) {
        var mainSportGoal = Cmds.getMainSportGoal(timeGoalType)
        mainSportGoal.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = mainSportGoal?.json
    }

    /**
     * 进入升级模式
     * Enter upgrade mode
     * */
    private fun otaStart() {
        var otaStart = Cmds.otaStart()
        otaStart.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = otaStart?.json
    }

    /**
     * 重启设备
     * Restart the device
     * */
    private fun reboot() {
        var reboot = Cmds.reboot()
        reboot.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = reboot?.json
    }

    /**
     * v3 获取运动默认的类型
     * v3 Gets the default type of motion
     * */
    private fun getSportTypeV3() {
        var sportTypeV3 = Cmds.getSportTypeV3()
        sportTypeV3.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = sportTypeV3?.json
    }

    /**
     * 获取活动开关
     * get Activity Switch
     * */
    private fun getActivitySwitch() {
        var activitySwitch = Cmds.getActivitySwitch()
        activitySwitch.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = activitySwitch?.json
    }

    /**
     * 获取默认运动类型
     * get Activity Switch
     * */
    private fun getDefaultSportType() {
        var defaultSportType = Cmds.getDefaultSportType()
        defaultSportType.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = defaultSportType?.json
    }

    /**
     * 恢复出厂设置
     * factory data reset
     * */
    private fun getFactoryreset() {
        var factoryReset = Cmds.factoryReset()
        factoryReset.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = factoryReset?.json
    }

    /**
     * 开始查找设备
     * Start looking for equipment
     * */
    private fun getFindDeviceStart() {
        var findDeviceStart = Cmds.findDeviceStart()
        findDeviceStart.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ ok }"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{ erro }"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = findDeviceStart?.json
    }

    /**
     * 停止查找设备
     * Stop looking for equipment
     * */
    private fun getFindDeviceStop() {
        var findDeviceStop = Cmds.findDeviceStop()
        findDeviceStop.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{ok}"
                tv_response?.text = res
            } else {
                val res = it.res?.toJsonString() ?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = findDeviceStop?.json
    }

    /**
     * 获取hid信息
     * get hid information
     * */
    private fun getHidInfo() {
        var hidInfo = Cmds.getHidInfo()
        hidInfo.send {
            if (it.error.code == 0) {
                val res = it.res?: "{ok}"
                tv_response?.text = res.toString()
            } else {
                val res = it.res?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = hidInfo?.json
    }
    /**
     * 获取sn
     * get sn
     * */
    private fun getSn() {
        var sn = Cmds.getSn()
        sn.send {
            if (it.error.code == 0) {
                val res = it.res?: "{ok}"
                tv_response?.text = res.toString()
            } else {
                val res = it.res?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = sn?.json
    }

    /**
     * 获取BT连接手机型号
     * Get BT connected phone model
     * */
    private fun getBtConnectPhoneModel() {
        var btConnectPhoneModel = Cmds.getBtConnectPhoneModel()
        btConnectPhoneModel.send {
            if (it.error.code == 0) {
                val res = it.res?: "{ok}"
                tv_response?.text = res.toString()
            } else {
                val res = it.res?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = btConnectPhoneModel?.json
    }


    /**
     * 获取bt蓝牙名称
     * Get the bt Bluetooth name
     * */
    private fun getBtName() {
        var btName = Cmds.getBtName()
        btName.send {
            if (it.error.code == 0) {
                val res = it.res?: "{ok}"
                tv_response?.text = res.toString()
            } else {
                val res = it.res?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = btName?.json
    }



    /**
     * 获取手表名字
     * get watch name
     * */
    private fun getDeviceName() {
        var deviceName = Cmds.getDeviceName()
        deviceName.send {
            if (it.error.code == 0) {
                val res = it.res?: "{ok}"
                tv_response?.text = res.toString()
            } else {
                val res = it.res?: "{erro}"
                tv_response?.text = "erro: $res"
            }
        }
        paramter_tv?.text = deviceName?.json
    }


    override fun onDestroy() {
        super.onDestroy()
        if (mIDOCancellable != null && !mIDOCancellable!!.isCancelled) {
            mIDOCancellable?.cancel()
        }
    }
}