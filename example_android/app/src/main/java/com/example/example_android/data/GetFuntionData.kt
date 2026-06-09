package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.protocol_channel.sdk

/**
 * 此类做用是统一管理各功能列表操作
 * 实际开发时，根据事件类型，关注单个功能直接调用接口即可，在使用前请参考该类中的功能表判断逻辑
 * This class is used to manage the list of functions in a unified manner
 * In actual development, you can directly invoke the interface of a single function based on the event type.
 * You can refer to the function table in this class to determine the logic before using it
 * */

class GetFuntionData(
    type: CustomEvtType,
    title: String? = null,
    sub_title: String? = null,
    isSupported: Boolean = true
) : IDoDataBean(type, title, sub_title, isSupported) {
    companion object {
        fun getFunctions(context: Context): MutableList<GetFuntionData> {
            val mutableListOf = mutableListOf<GetFuntionData>()

            mutableListOf.add(GetFuntionData(CustomEvtType.GETDEVICEINFO, "getDeviceInfo", context.getString(R.string.desc_getdeviceinfo), isSupported = true))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETFUNCTIONTABLE, "getFunctionTable", context.getString(R.string.desc_getfunctiontable), isSupported = true))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSNINFO, "getSn", context.getString(R.string.desc_getsn), isSupported = sdk.funcTable.getSupportGetSnInfo))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBATTERYREMINDERSWITCH, "getBatteryReminderSwitch", context.getString(R.string.desc_getbatteryreminderswitch), isSupported = sdk.funcTable.supportBatteryReminderSwitch))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETFINDPHONESWITCH, "getFindPhoneSwitch", context.getString(R.string.desc_getfindphoneswitch), isSupported = sdk.funcTable.supportGetFindPhoneSwitch))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETPETINFO, "getPetInfo", context.getString(R.string.desc_getpetinfo), isSupported = sdk.funcTable.supportPetInfo))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUNREADAPPREMINDER, "getUnreadAppReminder", context.getString(R.string.desc_getunreadappreminder), isSupported = sdk.funcTable.setSetUnreadAppReminder))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETWATCHDIALINFO, "getWatchDialInfo", context.getString(R.string.desc_getwatchdialinfo), isSupported = true))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBATTERYINFO, "getBatteryInfo", context.getString(R.string.desc_getbatteryinfo), isSupported = sdk.funcTable.getBatteryInfo))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETDEVICELOGSTATE, "getDeviceLogState", context.getString(R.string.desc_getdevicelogstate), isSupported = sdk.funcTable.getDeviceLogState))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETNOTICESTATUS, "getNoticeStatus", context.getString(R.string.desc_getnoticestatus), isSupported = sdk.funcTable.reminderAncs))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETALARMV3, "getAlarm", context.getString(R.string.desc_getalarm), isSupported = sdk.funcTable.syncV3SyncAlarm))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETCONTACTREVISETIME, "getContactReviseTime", context.getString(R.string.desc_getcontactrevisetime), isSupported = sdk.funcTable.reminderGetAllContact))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETWALKREMIND, "getWalkRemind", context.getString(R.string.desc_getwalkremind), isSupported = sdk.funcTable.getWalkReminderV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSUPPORTMAXSETITEMSNUM, "getSupportMaxSetItemsNum", context.getString(R.string.desc_getsupportmaxsetitemsnum), isSupported = sdk.funcTable.getSetMaxItemsNum))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSCREENBRIGHTNESS, "getScreenBrightness", context.getString(R.string.desc_getscreenbrightness), isSupported = sdk.funcTable.getScreenBrightnessMain9))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETMAINSPORTGOAL, "getMainSportGoal", context.getString(R.string.desc_getmainsportgoal), isSupported = sdk.funcTable.getSupportGetMainSportGoalV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETNOTDISTURBSTATUS, "getNotDisturbStatus", context.getString(R.string.desc_getnotdisturbstatus), isSupported = sdk.funcTable.getDoNotDisturbMain3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUPHANDGESTURE, "getUpHandGesture", context.getString(R.string.desc_getuphandgesture), isSupported = sdk.funcTable.getUpHandGestureEx))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBTNOTICE, "getBtNotice", context.getString(R.string.desc_getbtnotice), isSupported = sdk.funcTable.getBleAndBtVersion))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETFLASHBININFO, "getFlashBinInfo", context.getString(R.string.desc_getflashbininfo), isSupported = sdk.funcTable.getFlashLog))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETACTIVITYSWITCH, "getActivitySwitch", context.getString(R.string.desc_getactivityswitch), isSupported = sdk.funcTable.getActivitySwitch))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBTNAME, "getBtName", context.getString(R.string.desc_getbtname), isSupported = sdk.funcTable.getBtAddrV2))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETMTUINFO, "getMtuInfo", context.getString(R.string.desc_getmtuinfo), isSupported = sdk.funcTable.getMtu))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETALLHEALTHSWITCHSTATE, "getAllHealthSwitchState", context.getString(R.string.desc_getallhealthswitchstate), isSupported = sdk.funcTable.getHealthSwitchStateSupportV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETERRORRECORD, "getErrorRecord", context.getString(R.string.desc_geterrorrecord), isSupported = sdk.funcTable.getFlashLog))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETGPSINFO, "getGpsInfo", context.getString(R.string.desc_getgpsinfo), isSupported = sdk.funcTable.getSupportUpdateGps))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETVERSIONINFO, "getVersionInfo", context.getString(R.string.desc_getversioninfo), isSupported = true))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETGPSSTATUS, "getGpsStatus", context.getString(R.string.desc_getgpsstatus), isSupported = sdk.funcTable.getSupportUpdateGps))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUNERASABLEMEUNLIST, "getUnerasableMeunList", context.getString(R.string.desc_getunerasablemeunlist), isSupported = sdk.funcTable.getDeletableMenuListV2))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBPALGVERSION, "getBpAlgVersion", context.getString(R.string.desc_getbpalgversion), isSupported = sdk.funcTable.setSupportV3Bp))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUPDATESTATUS, "getUpdateStatus", context.getString(R.string.desc_getupdatestatus), isSupported = sdk.funcTable.getDeviceUpdateState))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETDOWNLOADLANGUAGE, "getDownloadLanguage", context.getString(R.string.desc_getdownloadlanguage), isSupported = sdk.funcTable.getDownloadLanguage))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBLEMUSICINFO, "getBleMusicInfo", context.getString(R.string.desc_getblemusicinfo), isSupported = (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3)))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETLANGUAGELIBRARYDATAV3, "getLanguageLibrary", context.getString(R.string.desc_getlanguagelibrary), isSupported = sdk.funcTable.getLangLibraryV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBLEBEEPV3, "getBleBeep", context.getString(R.string.desc_getblebeep), isSupported = sdk.funcTable.getSupportGetBleBeepV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSTEPGOAL, "getStepGoal", context.getString(R.string.desc_getstepgoal), isSupported = sdk.funcTable.getStepDataTypeV2))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBTCONNECTPHONEMODEL, "getBtConnectPhoneModel", context.getString(R.string.desc_getbtconnectphonemodel), isSupported = sdk.funcTable.getSupportGetV3DeviceBtConnectPhoneModel))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUNIT, "getUnit", context.getString(R.string.desc_getunit), isSupported = sdk.funcTable.getSupportGetUnit))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETAPPLETCONTROL, "getAppletControl", context.getString(R.string.desc_getappletcontrol), isSupported = sdk.funcTable.setSupportControlMiniProgram))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETALGFILE, "getAlgFileInfo", context.getString(R.string.desc_getalgfileinfo), isSupported = sdk.funcTable.getSupportDeviceOperateAlgFile))
            mutableListOf.add(GetFuntionData(CustomEvtType.REQUESTALGFILE, "requestAlgFile", context.getString(R.string.desc_requestalgfile), isSupported = sdk.funcTable.getSupportDeviceOperateAlgFile))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSPORTSTYPEV3, "getSportsTypeV3", context.getString(R.string.desc_getsportstypev3), isSupported = sdk.funcTable.getSportsTypeV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETUSERINFO, "getUserInfo", context.getString(R.string.desc_setuserinfo), isSupported = sdk.funcTable.supportGetUserInfo))
            mutableListOf.add(GetFuntionData(CustomEvtType.SETSCHEDULEREMINDER, "setScheduleReminder", context.getString(R.string.desc_getschedulereminder), isSupported = sdk.funcTable.setScheduleReminder))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETLEFTRIGHTWEARSETTINGS, "getLeftRightWearSettings", context.getString(R.string.desc_sethand), isSupported = sdk.funcTable.getLeftRightHandWearSettings))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSIMPLEHEARTRATEZONE, "getSimpleHeartRateZone", context.getString(R.string.desc_setsimpleheartratezone), isSupported = sdk.funcTable.supportSimpleHrZoneSetting))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSPORTINGREMINDSETTING, "getSportingRemindSetting", context.getString(R.string.desc_setsportingremindsetting), isSupported = sdk.funcTable.supportSportingRemindSetting))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSETTINGSDURINGEXERCISE, "getSettingsDuringExercise", context.getString(R.string.desc_setduringexercise), isSupported = sdk.funcTable.supportSettingsDuringExercise))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETHIDINFO, "getHidInfo", context.getString(R.string.desc_gethidinfo), isSupported = true))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSTRESSVAL, "getStressVal", context.getString(R.string.desc_getstressval), isSupported = sdk.funcTable.setSetStressCalibration))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETHABITINFOV3, "getHabitInfo", context.getString(R.string.desc_gethabitinfo), isSupported = sdk.funcTable.getSupportGetBleBeepV3))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSMARTHEARTRATEMODE, "getSmartHeartRateMode", context.getString(R.string.desc_getsmartheartratemode), isSupported = sdk.funcTable.getSupportGetSmartHeartRate))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSPO2SWITCH, "getSpo2Switch", context.getString(R.string.desc_getspo2switch), isSupported = sdk.funcTable.setSpo2Data))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETSTRESSSWITCH, "getStressSwitch", context.getString(R.string.desc_getstressswitch), isSupported = sdk.funcTable.setPressureData))
            mutableListOf.add(GetFuntionData(CustomEvtType.GETBIKELOCKLIST, "getBikeLockList", context.getString(R.string.desc_getbikelocklist), isSupported = sdk.funcTable.supportBikeLockManager))

            // 优先使用v3协议接口
            if (sdk.funcTable.supportProtocolV3MenuList) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETMENULISTV3, "getMenuListV3", context.getString(R.string.desc_getmenulistv3), isSupported = true))
            } else if (sdk.funcTable.getMenuList) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETMENULIST, "getMenuList", context.getString(R.string.desc_getmenulist), isSupported = true))
            } else {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETMENULISTV3, "getMenuListV3", context.getString(R.string.desc_getmenulistv3), isSupported = false))
            }

            if (sdk.funcTable.getNewWatchList) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETWATCHLISTV3, "getWatchListV3", context.getString(R.string.desc_getwatchlistv3), isSupported = true))
            } else {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETWATCHLISTV2, "getWatchListV2", context.getString(R.string.desc_getwatchlistv2), isSupported = true))
            }

            // 心率模式获取逻辑同步 (Heart Rate Modes)
            if (sdk.funcTable.setSmartHeartRate) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETHEARTMODE, "getHeartMode", context.getString(R.string.desc_getheartmode), isSupported = sdk.funcTable.getSupportGetSmartHeartRate))
            } else if (sdk.funcTable.syncV3Hr) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETHEARTMODE, "getHeartMode", context.getString(R.string.desc_getheartmode), isSupported = true))
            } else if (sdk.funcTable.getHeartRateModeV2) {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETHEARTMODE, "getHeartMode", context.getString(R.string.desc_getheartmode), isSupported = true))
            } else {
                mutableListOf.add(GetFuntionData(CustomEvtType.GETHEARTMODE, "getHeartMode", context.getString(R.string.desc_getheartmode), isSupported = false))
            }

            mutableListOf.sortBy { it.title?.lowercase() }
            return mutableListOf
        }
    }
}
