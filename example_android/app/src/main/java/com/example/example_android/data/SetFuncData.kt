package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.*
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDOCmdSetResponseModel
import com.idosmart.protocol_channel.sdk

class SetFuncData(
    type: CustomEvtType = CustomEvtType.GETACTIVITYSWITCH,
    title: String? = null,
    sub_title: String? = null,
    isSupported: Boolean = true
) : IDoDataBean(type, title, sub_title, isSupported) {
    companion object {
        fun getFunctions(context: Context): MutableList<SetFuncData> {
            val mutableListOf = mutableListOf<SetFuncData>()

            mutableListOf.add(SetFuncData(CustomEvtType.SETDATETIME, "setDateTime", context.getString(R.string.desc_setdatetime), isSupported = true))
            mutableListOf.add(SetFuncData(CustomEvtType.SETALARMV3, "setAlarm", context.getString(R.string.desc_setalarm), isSupported = sdk.funcTable.syncV3SyncAlarm))
            mutableListOf.add(SetFuncData(CustomEvtType.SETLONGSIT, "setLongSit", context.getString(R.string.desc_setlongsit), isSupported = sdk.funcTable.setSedentariness))
            mutableListOf.add(SetFuncData(CustomEvtType.SETDRINKWATERREMIND, "setDrinkWaterRemind", context.getString(R.string.desc_setdrinkwaterremind), isSupported = sdk.funcTable.setDrinkWaterReminder))
            mutableListOf.add(SetFuncData(CustomEvtType.SETHAND, "setHand", context.getString(R.string.desc_sethand), isSupported = sdk.funcTable.getLeftRightHandWearSettings))
            mutableListOf.add(SetFuncData(CustomEvtType.SETUPHANDGESTURE, "setUpHandGesture", context.getString(R.string.desc_setuphandgesture), isSupported = sdk.funcTable.getUpHandGesture))
            
            // Heart Rate Modes
            mutableListOf.add(SetFuncData(CustomEvtType.SETHEARTMODE, "setHeartMode", context.getString(R.string.desc_setheartmode), 
                isSupported = (sdk.funcTable.setSmartHeartRate || sdk.funcTable.syncV3Hr || sdk.funcTable.setHeartRateMonitor || sdk.funcTable.syncHeartRateMonitor)))

            mutableListOf.add(SetFuncData(CustomEvtType.SETNOTIFICATIONSTATUS, "setNotificationStatus", context.getString(R.string.desc_setnotificationstatus), isSupported = sdk.funcTable.setSetNotificationStatus))
            mutableListOf.add(SetFuncData(CustomEvtType.SETFINDPHONE, "setFindPhone", context.getString(R.string.desc_setfindphone), isSupported = sdk.funcTable.getFindPhone))
            mutableListOf.add(SetFuncData(CustomEvtType.SETOVERFINDPHONE, "setOverFindPhone", context.getString(R.string.desc_setoverfindphone), isSupported = sdk.funcTable.setOverFindPhone))
            mutableListOf.add(SetFuncData(CustomEvtType.SETUNIT, "setUnit", context.getString(R.string.desc_setunit), isSupported = sdk.funcTable.getSupportGetUnit))
            mutableListOf.add(SetFuncData(CustomEvtType.SETNOTDISTURB, "setNotDisturb", context.getString(R.string.desc_setnotdisturb), isSupported = sdk.funcTable.setDoNotDisturb))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSCREENBRIGHTNESS, "setScreenBrightness", context.getString(R.string.desc_setscreenbrightness), isSupported = sdk.funcTable.setScreenBrightness))
            mutableListOf.add(SetFuncData(CustomEvtType.SETMUSICONOFF, "setMusicOnOff", context.getString(R.string.desc_setmusiconoff), isSupported = sdk.funcTable.setBleControlMusic))
            
            // Display Mode: Using a common flag or true
            mutableListOf.add(SetFuncData(CustomEvtType.SETDISPLAYMODE, "setDisplayMode", context.getString(R.string.desc_setdisplaymode), isSupported = true))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETWEATHERV3, "setWeatherV3", context.getString(R.string.desc_setweatherv3), isSupported = sdk.funcTable.setSetV3Weather))
            mutableListOf.add(SetFuncData(CustomEvtType.SETWALKREMIND, "setWalkRemind", context.getString(R.string.desc_setwalkremind), isSupported = sdk.funcTable.setWalkReminder))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSPORTGOAL, "setSportGoal", context.getString(R.string.desc_setsportgoal), isSupported = sdk.funcTable.setCalorieGoal))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSLEEPPERIOD, "setSleepPeriod", context.getString(R.string.desc_setsleepperiod), isSupported = sdk.funcTable.syncV3Sleep))
            mutableListOf.add(SetFuncData(CustomEvtType.SETMENSTRUATION, "setMenstruation", context.getString(R.string.desc_setmenstruation), isSupported = sdk.funcTable.setMenstruation))
            mutableListOf.add(SetFuncData(CustomEvtType.SETMENSTRUATIONREMIND, "setMenstruationRemind", context.getString(R.string.desc_setmenstruationremind), isSupported = sdk.funcTable.getSupportSetMenstrualReminderOnOff))
            
            // Shortcut: Common
            mutableListOf.add(SetFuncData(CustomEvtType.SETSHORTCUT, "setShortcut", context.getString(R.string.desc_setshortcut), isSupported = true))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETWEATHERSUNTIME, "setWeatherSunTime", context.getString(R.string.desc_setweathersuntime), isSupported = sdk.funcTable.setWeatherSunTime))
            mutableListOf.add(SetFuncData(CustomEvtType.SETWATCHDIALSORT, "setWatchDialSort", context.getString(R.string.desc_setwatchdialsort), isSupported = sdk.funcTable.setWatchDialSort))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSPORTMODESORT, "setSportModeSort", context.getString(R.string.desc_setsportmodesort), isSupported = sdk.funcTable.setSportModeSort))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETGPSCONTROL, "setGpsControl", context.getString(R.string.desc_setgpscontrol), isSupported = sdk.funcTable.syncV3Gps))
            mutableListOf.add(SetFuncData(CustomEvtType.SETHOTSTARTPARAM, "setHotStartParam", context.getString(R.string.desc_sethotstartparam), isSupported = sdk.funcTable.syncV3Gps))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETNOTICEAPPNAME, "setNoticeAppName", context.getString(R.string.desc_setnoticeappname), isSupported = sdk.funcTable.getNoticeIconInformation))
            mutableListOf.add(SetFuncData(CustomEvtType.NOTICEMESSAGEV3, "noticeMessageV3", context.getString(R.string.desc_noticemessagev3), isSupported = sdk.funcTable.getNotifyMsgV3))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETBPCALIBRATION, "setBpCalibration", context.getString(R.string.desc_setbpcalibration), isSupported = sdk.funcTable.getSupportBpSetOrMeasurementV2))
            mutableListOf.add(SetFuncData(CustomEvtType.SETBPMEASUREMENT, "setBpMeasurement", context.getString(R.string.desc_setbpmeasurement), isSupported = sdk.funcTable.getSupportBpSetOrMeasurementV2))
            
            mutableListOf.add(SetFuncData(CustomEvtType.SETSENDRUNPLAN, "setSendRunPlan", context.getString(R.string.desc_setsendrunplan), isSupported = sdk.funcTable.setSupportSportPlan))
            mutableListOf.add(SetFuncData(CustomEvtType.SETMUSICOPERATE, "setMusicOperate", context.getString(R.string.desc_setmusicoperate), isSupported = sdk.funcTable.setTransferMusicFile))
            mutableListOf.add(SetFuncData(CustomEvtType.MUSICCONTROL, "musicControl", context.getString(R.string.desc_musiccontrol), isSupported = sdk.funcTable.setBleControlMusic))
            mutableListOf.add(SetFuncData(CustomEvtType.SETBLEVOICE, "setBleVoice", context.getString(R.string.desc_setblevoice), isSupported = sdk.funcTable.setSetPhoneVoice))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSCIENTIFICSLEEPSWITCH, "setScientificSleepSwitch", context.getString(R.string.desc_setscientificsleepswitch), isSupported = sdk.funcTable.setScientificSleepSwitch))
            mutableListOf.add(SetFuncData(CustomEvtType.SETUNREADAPPREMINDER, "setUnreadAppReminder", context.getString(R.string.desc_setunreadappreminder), isSupported = sdk.funcTable.setSetUnreadAppReminder))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSYNCCONTACT, "setSyncContact", context.getString(R.string.desc_setsynccontact), isSupported = sdk.funcTable.setSyncContact))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSTRESSCALIBRATION, "setStressCalibration", context.getString(R.string.desc_setstresscalibration), isSupported = sdk.funcTable.setSetStressCalibration))
            mutableListOf.add(SetFuncData(CustomEvtType.SETHEARTRATEINTERVAL, "setHeartRateInterval", context.getString(R.string.desc_setheartrateinterval), isSupported = sdk.funcTable.supportSimpleHrZoneSetting))
            
            // Menu list logic
            if (sdk.funcTable.supportProtocolV3MenuList) {
                mutableListOf.add(SetFuncData(CustomEvtType.SETMENULISTV3, "setMenuListV3", context.getString(R.string.desc_setmenulistv3), isSupported = true))
            } else if (sdk.funcTable.setMenuListMain7) {
                mutableListOf.add(SetFuncData(CustomEvtType.SETMENULIST, "setMenuList", context.getString(R.string.desc_setmenulist), isSupported = true))
            } else {
                mutableListOf.add(SetFuncData(CustomEvtType.SETMENULISTV3, "setMenuListV3", context.getString(R.string.desc_setmenulistv3), isSupported = false))
            }

            mutableListOf.add(SetFuncData(CustomEvtType.SETBPCALCONTROLV3, "setBpCalControlV3", context.getString(R.string.desc_setbpcalcontrolv3), isSupported = sdk.funcTable.setSupportV3Bp))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSPORTSTYPEV3, "setSportsTypeV3", context.getString(R.string.desc_setsportstypev3), isSupported = sdk.funcTable.getSportsTypeV3))
            mutableListOf.add(SetFuncData(CustomEvtType.SETWORLDTIMEV3, "setWorldTimeV3", context.getString(R.string.desc_setworldtimev3), isSupported = sdk.funcTable.setSetV3WorldTime))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSPORTPARAMSORT, "setSportParamSort", context.getString(R.string.desc_setsportparamsort), isSupported = sdk.funcTable.setSet20SportParamSort))
            mutableListOf.add(SetFuncData(CustomEvtType.SETWEATHERCITYNAME, "setWeatherCityName", context.getString(R.string.desc_setweathercityname), isSupported = sdk.funcTable.setWeatherCity))
            mutableListOf.add(SetFuncData(CustomEvtType.SETMAINUISORTV3, "setMainUISortV3", context.getString(R.string.desc_setmainuisortv3), isSupported = sdk.funcTable.setSetMainUiSort))
            mutableListOf.add(SetFuncData(CustomEvtType.SETFITNESSGUIDANCE, "setFitnessGuidance", context.getString(R.string.desc_setfitnessguidance), isSupported = sdk.funcTable.setSetFitnessGuidance))
            mutableListOf.add(SetFuncData(CustomEvtType.SETCALLQUICKREPLYONOFF, "setCallQuickReplyOnOff", context.getString(R.string.desc_setcallquickreplyonoff), isSupported = sdk.funcTable.setSupportSetCallQuickReplyOnOff))
            mutableListOf.add(SetFuncData(CustomEvtType.SETHISTORICALMENSTRUATION, "setHistoricalMenstruation", context.getString(R.string.desc_sethistoricalmenstruation), isSupported = sdk.funcTable.supportHistoricalMenstruationExchange))
            mutableListOf.add(SetFuncData(CustomEvtType.SETTEMPERATURESWITCH, "setTemperatureSwitch", context.getString(R.string.desc_settemperatureswitch), isSupported = sdk.funcTable.setTemperatureSwitchSupport))
            mutableListOf.add(SetFuncData(CustomEvtType.SETAPPLETCONTROL, "setAppletControl", context.getString(R.string.desc_setappletcontrol), isSupported = sdk.funcTable.setSupportControlMiniProgram))
            mutableListOf.add(SetFuncData(CustomEvtType.SETV3NOISE, "setV3Noise", context.getString(R.string.desc_setv3noise), isSupported = sdk.funcTable.syncV3Noise))
            mutableListOf.add(SetFuncData(CustomEvtType.SETCALORIEDISTANCEGOAL, "setCalorieDistanceGoal", context.getString(R.string.desc_setcaloriedistancegoal), isSupported = sdk.funcTable.setGetCalorieDistanceGoal))
            mutableListOf.add(SetFuncData(CustomEvtType.SETSPORT100SORT, "setSport100Sort", context.getString(R.string.desc_setsport100sort), isSupported = sdk.funcTable.setSet100SportSort))
            mutableListOf.add(SetFuncData(CustomEvtType.SETDEFAULTMSGLIST, "setDefaultMsgList", context.getString(R.string.desc_setdefaultmsglist), isSupported = sdk.funcTable.setMsgAllSwitch))
            mutableListOf.add(SetFuncData(CustomEvtType.SETVOICEASSISTANTONOFF, "setVoiceAssistantOnOff", context.getString(R.string.desc_setvoiceassistantonoff), isSupported = sdk.funcTable.getSupportSetVoiceAssistantStatus))
            mutableListOf.add(SetFuncData(CustomEvtType.SETRRESPIRATETURN, "setRRespiRateTurn", context.getString(R.string.desc_setrrespirateturn), isSupported = sdk.funcTable.setRespirationRate))
            mutableListOf.add(SetFuncData(CustomEvtType.SETBODYPOWERTURN, "setBodyPowerTurn", context.getString(R.string.desc_setbodypowerturn), isSupported = sdk.funcTable.syncV3BodyPower))
            mutableListOf.add(SetFuncData(CustomEvtType.SETBIKELOCKLIST, "setBikeLockList", context.getString(R.string.desc_setbikelocklist), isSupported = sdk.funcTable.supportBikeLockManager))
            mutableListOf.add(SetFuncData(CustomEvtType.SETCGMKEYANDDEVICE, "setCgmKeyAndDevice", context.getString(R.string.desc_setcgmkeyanddevice), isSupported = sdk.funcTable.supportCgmPhoneCommand))
            mutableListOf.add(SetFuncData(CustomEvtType.DELETECGMKEYANDDEVICE, "deleteCgmKeyAndDevice", context.getString(R.string.desc_deletecgmkeyanddevice), isSupported = sdk.funcTable.supportCgmPhoneCommand))
            mutableListOf.add(SetFuncData(CustomEvtType.CONNECTCGM, "connectCgm", context.getString(R.string.desc_connectcgm), isSupported = sdk.funcTable.supportCgmPhoneCommand))
            mutableListOf.add(SetFuncData(CustomEvtType.DISCONNECTCGM, "disconnectCgm", context.getString(R.string.desc_disconnectcgm), isSupported = sdk.funcTable.supportCgmPhoneCommand))
            mutableListOf.add(SetFuncData(CustomEvtType.SETBLOODGLUCOSEDATAV01, "setBloodGlucoseDataV01", context.getString(R.string.desc_setbloodglucosedatav01), isSupported = sdk.funcTable.supportBloodGlucoseV01))

            mutableListOf.add(SetFuncData(CustomEvtType.FACTORYRESET, "factoryReset", context.getString(R.string.desc_factoryreset), isSupported = true))
            mutableListOf.add(SetFuncData(CustomEvtType.REBOOT, "reboot", context.getString(R.string.desc_reboot), isSupported = true))
            mutableListOf.add(SetFuncData(CustomEvtType.FINDDEVICESTART, "findDeviceStart", context.getString(R.string.desc_finddevicestart), isSupported = true))
            mutableListOf.add(SetFuncData(CustomEvtType.FINDDEVICESTOP, "findDeviceStop", context.getString(R.string.desc_finddevicestop), isSupported = true))

            mutableListOf.add(SetFuncData(CustomEvtType.SETUSERINFO, "setUserInfo", context.getString(R.string.desc_setuserinfo), isSupported = true))

            mutableListOf.sortBy { it.title?.lowercase() }
            return mutableListOf
        }
    }
}
