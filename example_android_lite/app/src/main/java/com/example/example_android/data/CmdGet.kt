package com.example.example_android.data

import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeongen.api_evt_type.ApiEvtType
import com.idosmart.protocol_sdk.IDOCancellable

/**
 * @author tianwei
 * @date 2023/11/21
 * @time 10:14
 * 用途:获取指令
 */
object CmdGet {

    fun get(evtType: ApiEvtType, request: (String) -> Unit, result: (String) -> Unit): IDOCancellable? {
        val cmd = when (evtType) {
            ApiEvtType.GETACTIVITYSWITCH -> Cmds.getActivitySwitch()
            ApiEvtType.GETALARMV3 -> Cmds.getAlarm()
            ApiEvtType.GETALLHEALTHSWITCHSTATE -> Cmds.getAllHealthSwitchState()
            ApiEvtType.GETBATTERYINFO -> Cmds.getBatteryInfo()
            ApiEvtType.GETBLEBEEPV3 -> Cmds.getBleBeep()
            ApiEvtType.GETBLEMUSICINFO -> Cmds.getBleMusicInfo()
            ApiEvtType.GETBPALGVERSION -> Cmds.getBpAlgVersion()
            ApiEvtType.GETBTNAME -> Cmds.getBtName()
            ApiEvtType.GETBTNOTICE -> Cmds.getBtNotice()
            ApiEvtType.GETCONTACTREVISETIME -> Cmds.getContactReviseTime()
            ApiEvtType.GETDEVICELOGSTATE -> Cmds.getDeviceLogState()
            ApiEvtType.GETDEVICENAME -> Cmds.getDeviceName()
            ApiEvtType.GETDOWNLANGUAGE -> Cmds.getDownloadLanguage()
            ApiEvtType.GETERRORRECORD -> Cmds.getErrorRecord()
            ApiEvtType.GETFLASHBININFO -> Cmds.getFlashBinInfo()
            ApiEvtType.GETGPSINFO -> Cmds.getGpsInfo()
            ApiEvtType.GETGPSSTATUS -> Cmds.getGpsStatus()
            ApiEvtType.GETHABITINFOV3 -> Cmds.getHabitInfo()
            ApiEvtType.GETHEARTRATEMODE -> Cmds.getHeartRateMode()
            ApiEvtType.GETHIDINFO -> Cmds.getHidInfo()
            ApiEvtType.GETHOTSTARTPARAM -> Cmds.getHotStartParam()
            ApiEvtType.GETLANGUAGELIBRARYDATAV3 -> Cmds.getLanguageLibrary()
            ApiEvtType.GETMENULIST -> Cmds.getMenuList()
            ApiEvtType.GETMTUINFO -> Cmds.getMtuInfo()
            ApiEvtType.GETNOTDISTURBSTATUS -> Cmds.getNotDisturbStatus()
            ApiEvtType.GETNOTICESTATUS -> Cmds.getNoticeStatus()
            ApiEvtType.GETSCREENBRIGHTNESS -> Cmds.getScreenBrightness()
            ApiEvtType.GETSNINFO -> Cmds.getSn()
            ApiEvtType.GETSTEPGOAL -> Cmds.getStepGoal()
            ApiEvtType.GETSTRESSVAL -> Cmds.getStressVal()
            ApiEvtType.GETSUPPORTMAXSETITEMSNUM -> Cmds.getSupportMaxSetItemsNum()
            ApiEvtType.GETUNERASABLEMEUNLIST -> Cmds.getUnerasableMeunList()
            ApiEvtType.GETUNREADAPPREMINDER -> Cmds.getUnreadAppReminder()
            ApiEvtType.GETUPDATESTATUS -> Cmds.getUpdateStatus()
            ApiEvtType.GETUPHANDGESTURE -> Cmds.getUpHandGesture()
            ApiEvtType.GETVERSIONINFO -> Cmds.getVersionInfo()
            ApiEvtType.GETWALKREMIND -> Cmds.getWalkRemind()
            ApiEvtType.GETWATCHDIALID -> Cmds.getWatchDialId()
            ApiEvtType.GETWATCHDIALINFO -> Cmds.getWatchDialInfo()
            ApiEvtType.GETWATCHFACELIST -> Cmds.getWatchListV2()
            ApiEvtType.GETWATCHLISTV3 -> Cmds.getWatchListV3()
            ApiEvtType.GETLIVEDATA -> Cmds.getLiveData(0)
            ApiEvtType.GETMAINSPORTGOAL -> Cmds.getMainSportGoal(0)
            else -> {
                null
            }
        }
        request(cmd?.json ?: "")
        return cmd?.send {
            result(it.res.toString())

        }
    }
}