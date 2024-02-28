package com.example.example_android.data

import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_sdk.IDOCancellable

/**
 * @author tianwei
 * @date 2023/11/21
 * @time 10:14
 * 用途:获取指令
 */
object CmdGet {

    fun get(evtType: CustomEvtType, request: (String) -> Unit, result: (String) -> Unit): IDOCancellable? {
        val cmd = when (evtType) {
            CustomEvtType.GETACTIVITYSWITCH -> Cmds.getActivitySwitch()
            CustomEvtType.GETALARMV3 -> Cmds.getAlarm()
            CustomEvtType.GETALLHEALTHSWITCHSTATE -> Cmds.getAllHealthSwitchState()
            CustomEvtType.GETBATTERYINFO -> Cmds.getBatteryInfo()
            CustomEvtType.GETBLEBEEPV3 -> Cmds.getBleBeep()
            CustomEvtType.GETBLEMUSICINFO -> Cmds.getBleMusicInfo()
            CustomEvtType.GETBPALGVERSION -> Cmds.getBpAlgVersion()
            CustomEvtType.GETBTNAME -> Cmds.getBtName()
            CustomEvtType.GETBTNOTICE -> Cmds.getBtNotice()
            CustomEvtType.GETCONTACTREVISETIME -> Cmds.getContactReviseTime()
            CustomEvtType.GETDEVICELOGSTATE -> Cmds.getDeviceLogState()
            CustomEvtType.GETDEVICENAME -> Cmds.getDeviceName()
            CustomEvtType.GETDOWNLANGUAGE -> Cmds.getDownloadLanguage()
            CustomEvtType.GETERRORRECORD -> Cmds.getErrorRecord()
            CustomEvtType.GETFLASHBININFO -> Cmds.getFlashBinInfo()
            CustomEvtType.GETGPSINFO -> Cmds.getGpsInfo()
            CustomEvtType.GETGPSSTATUS -> Cmds.getGpsStatus()
            CustomEvtType.GETHABITINFOV3 -> Cmds.getHabitInfo()
            CustomEvtType.GETHEARTRATEMODE -> Cmds.getHeartRateMode()
            CustomEvtType.GETHIDINFO -> Cmds.getHidInfo()
            CustomEvtType.GETHOTSTARTPARAM -> Cmds.getHotStartParam()
            CustomEvtType.GETLANGUAGELIBRARYDATAV3 -> Cmds.getLanguageLibrary()
            CustomEvtType.GETMENULIST -> Cmds.getMenuList()
            CustomEvtType.GETMTUINFO -> Cmds.getMtuInfo()
            CustomEvtType.GETNOTDISTURBSTATUS -> Cmds.getNotDisturbStatus()
            CustomEvtType.GETNOTICESTATUS -> Cmds.getNoticeStatus()
            CustomEvtType.GETSCREENBRIGHTNESS -> Cmds.getScreenBrightness()
            CustomEvtType.GETSNINFO -> Cmds.getSn()
            CustomEvtType.GETSTEPGOAL -> Cmds.getStepGoal()
            CustomEvtType.GETSTRESSVAL -> Cmds.getStressVal()
            CustomEvtType.GETSUPPORTMAXSETITEMSNUM -> Cmds.getSupportMaxSetItemsNum()
            CustomEvtType.GETUNERASABLEMEUNLIST -> Cmds.getUnerasableMeunList()
            CustomEvtType.GETUNREADAPPREMINDER -> Cmds.getUnreadAppReminder()
            CustomEvtType.GETUPDATESTATUS -> Cmds.getUpdateStatus()
            CustomEvtType.GETUPHANDGESTURE -> Cmds.getUpHandGesture()
            CustomEvtType.GETVERSIONINFO -> Cmds.getVersionInfo()
            CustomEvtType.GETWALKREMIND -> Cmds.getWalkRemind()
            CustomEvtType.GETWATCHDIALID -> Cmds.getWatchDialId()
            CustomEvtType.GETWATCHDIALINFO -> Cmds.getWatchDialInfo()
            CustomEvtType.GETWATCHFACELIST -> Cmds.getWatchListV2()
            CustomEvtType.GETWATCHLISTV3 -> Cmds.getWatchListV3()
            CustomEvtType.GETLIVEDATA -> Cmds.getLiveData(0)
            CustomEvtType.GETMAINSPORTGOAL -> Cmds.getMainSportGoal(0)
            CustomEvtType.OTASTART -> Cmds.otaStart()
            CustomEvtType.REBOOT -> Cmds.reboot()
            CustomEvtType.FACTORYRESET -> Cmds.factoryReset()
            CustomEvtType.FINDDEVICESTART -> Cmds.findDeviceStart()
            CustomEvtType.FINDDEVICESTOP -> Cmds.findDeviceStop()
            CustomEvtType.GETBTCONNECTPHONEMODEL -> Cmds.getBtConnectPhoneModel()
            
            else -> {
                null
            }
        }
        request(cmd?.json ?: "")
        return cmd?.send {
            if(it.res == null){
                result(if (it.error.code === 0) "success" else "failed")
            }else {
                result(it.res.toString())
            }


        }
    }
}