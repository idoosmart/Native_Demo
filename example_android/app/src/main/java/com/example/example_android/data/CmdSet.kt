package com.example.example_android.data

import android.util.Log
import com.idosmart.model.IDOActivitySwitchParamModel
import com.idosmart.model.IDOAlarmModel
import com.idosmart.model.IDOAppletControlModel
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDOBpCalControlModel
import com.idosmart.model.IDOBpCalibrationParamModel
import com.idosmart.model.IDOBpMeasurementParamModel
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.model.IDODisplayModeParamModel
import com.idosmart.model.IDODrinkWaterRemindModel
import com.idosmart.model.IDOFastMsgSettingModel
import com.idosmart.model.IDOFastMsgUpdateParamModel
import com.idosmart.model.IDOFitnessGuidanceParamModel
import com.idosmart.model.IDOGpsControlParamModel
import com.idosmart.model.IDOHandWashingReminderParamModel
import com.idosmart.model.IDOHeartModeParamModel
import com.idosmart.model.IDOHeartRateIntervalModel
import com.idosmart.model.IDOHeartRateModeSmartParamModel
import com.idosmart.model.IDOHistoricalMenstruationParamModel
import com.idosmart.model.IDOLongSitParamModel
import com.idosmart.model.IDOLostFindParamModel
import com.idosmart.model.IDOMainSportGoalModel
import com.idosmart.model.IDOMainUISortParamModel
import com.idosmart.model.IDOMenstruationModel
import com.idosmart.model.IDOMenstruationRemindParamModel
import com.idosmart.model.IDOMenuListParamModel
import com.idosmart.model.IDOMusicControlParamModel
import com.idosmart.model.IDOMusicOnOffParamModel
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDONotDisturbParamModel
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageParamModel
import com.idosmart.model.IDONoticeMessageStateParamModel
import com.idosmart.model.IDONotificationCenterParamModel
import com.idosmart.model.IDONotificationStatusParamModel
import com.idosmart.model.IDORunPlanParamModel
import com.idosmart.model.IDOSchedulerReminderParamModel
import com.idosmart.model.IDOScientificSleepSwitchParamModel
import com.idosmart.model.IDOScreenBrightnessModel
import com.idosmart.model.IDOShortcutParamModel
import com.idosmart.model.IDOSleepPeriodParamModel
import com.idosmart.model.IDOSpo2SwitchParamModel
import com.idosmart.model.IDOSport100SortParamModel
import com.idosmart.model.IDOSportGoalParamModel
import com.idosmart.model.IDOSportModeSelectParamModel
import com.idosmart.model.IDOSportModeSortParamModel
import com.idosmart.model.IDOSportParamModel
import com.idosmart.model.IDOSportSortParamModel
import com.idosmart.model.IDOSportType
import com.idosmart.model.IDOStressCalibrationParamModel
import com.idosmart.model.IDOStressSwitchParamModel
import com.idosmart.model.IDOSyncContactParamModel
import com.idosmart.model.IDOTakingMedicineReminderParamModel
import com.idosmart.model.IDOTemperatureSwitchParamModel
import com.idosmart.model.IDOUnitParamModel
import com.idosmart.model.IDOUpHandGestureParamModel
import com.idosmart.model.IDOUserInfoPramModel
import com.idosmart.model.IDOV3NoiseParamModel
import com.idosmart.model.IDOVoiceReplyParamModel
import com.idosmart.model.IDOWalkRemindModel
import com.idosmart.model.IDOWalkRemindTimesParamModel
import com.idosmart.model.IDOWallpaperDialReplyV3ParamModel
import com.idosmart.model.IDOWatchDialParamModel
import com.idosmart.model.IDOWatchDialSortParamModel
import com.idosmart.model.IDOWatchFaceParamModel
import com.idosmart.model.IDOWeatherDataParamModel
import com.idosmart.model.IDOWeatherSunTimeParamModel
import com.idosmart.model.IDOWeatherV3ParamModel
import com.idosmart.model.IDOWorldTimeParamModel
import com.idosmart.pigeon_implement.Cmds

object CmdSet {
    fun set(evtType: CustomEvtType?, idoBaseModel: IDOBaseModel?, request: (String) -> Unit, result: (String) -> Unit) {
        val cmd = when (evtType) {
            CustomEvtType.SETSENDRUNPLAN -> Cmds.setSendRunPlan(idoBaseModel as IDORunPlanParamModel)
            CustomEvtType.SETWALKREMIND -> Cmds.setWalkReminder(idoBaseModel as IDOWalkRemindModel)
            CustomEvtType.SETWATCHDIALSORT -> Cmds.setWatchDialSort(idoBaseModel as IDOWatchDialSortParamModel)
            CustomEvtType.SETWALKREMINDTIMES -> Cmds.setWalkRemindTimes(idoBaseModel as IDOWalkRemindTimesParamModel)
            CustomEvtType.SETWEATHERV3 -> Cmds.setWeatherV3(idoBaseModel as IDOWeatherV3ParamModel)
            CustomEvtType.SETNOTICEMESSAGESTATE -> Cmds.setNoticeMessageState(idoBaseModel as IDONoticeMessageStateParamModel)
            CustomEvtType.SETMAINUISORTV3 -> Cmds.setMainUISortV3(idoBaseModel as IDOMainUISortParamModel)
            CustomEvtType.SETWATCHFACEDATA -> Cmds.setWatchFaceData(idoBaseModel as IDOWatchFaceParamModel)
            CustomEvtType.SETMUSICOPERATE -> Cmds.setMusicOperate(idoBaseModel as IDOMusicOpearteParamModel)
            CustomEvtType.SETNOTIFICATIONSTATUS -> Cmds.setNotificationStatus(idoBaseModel as IDONotificationStatusParamModel)
            CustomEvtType.SETFITNESSGUIDANCE -> Cmds.setFitnessGuidance(idoBaseModel as IDOFitnessGuidanceParamModel)
            CustomEvtType.SETSCIENTIFICSLEEPSWITCH -> Cmds.setScientificSleepSwitch(idoBaseModel as IDOScientificSleepSwitchParamModel)
            CustomEvtType.SETTEMPERATURESWITCH -> Cmds.setTemperatureSwitch(idoBaseModel as IDOTemperatureSwitchParamModel)
            CustomEvtType.SETV3NOISE -> Cmds.setV3Noise(idoBaseModel as IDOV3NoiseParamModel)
            CustomEvtType.SETHEARTMODE -> Cmds.setHeartMode(idoBaseModel as IDOHeartModeParamModel)
            CustomEvtType.SETHEARTRATEMODESMART -> Cmds.setHeartRateModeSmart(idoBaseModel as IDOHeartRateModeSmartParamModel)
            CustomEvtType.SETTAKINGMEDICINEREMINDER -> Cmds.setTakingMedicineReminder(idoBaseModel as IDOTakingMedicineReminderParamModel)
            CustomEvtType.SETBLEVOICE -> Cmds.setBleVoice(idoBaseModel as IDOBleVoiceParamModel)
            CustomEvtType.SETLONGSIT -> Cmds.setLongSit(idoBaseModel as IDOLongSitParamModel)
            CustomEvtType.SETLOSTFIND -> Cmds.setLostFind(idoBaseModel as IDOLostFindParamModel)
            CustomEvtType.SETSPORTGOAL -> Cmds.setSportGoal(idoBaseModel as IDOSportGoalParamModel)
            CustomEvtType.SETUNIT -> Cmds.setUnit(idoBaseModel as IDOUnitParamModel)
//            CustomEvtType.SETNOTIFICATIONCENTER -> Cmds.setNotificationCenter(idoBaseModel as IDONotificationCenterParamModel)
            CustomEvtType.SETUPHANDGESTURE -> Cmds.setUpHandGesture(idoBaseModel as IDOUpHandGestureParamModel)
            CustomEvtType.SETMUSICONOFF -> Cmds.setMusicOnOff(idoBaseModel as IDOMusicOnOffParamModel)
            CustomEvtType.SETDISPLAYMODE -> Cmds.setDisplayMode(idoBaseModel as IDODisplayModeParamModel)
            CustomEvtType.SETSPORTMODESELECT -> Cmds.setSportModeSelect(idoBaseModel as IDOSportModeSelectParamModel)
            CustomEvtType.SETSLEEPPERIOD -> Cmds.setSleepPeriod(idoBaseModel as IDOSleepPeriodParamModel)
            CustomEvtType.SETWEATHERDATA -> Cmds.setWeatherData(idoBaseModel as IDOWeatherDataParamModel)
            CustomEvtType.SETWEATHERSUNTIME -> Cmds.setWeatherSunTime(idoBaseModel as IDOWeatherSunTimeParamModel)
            CustomEvtType.SETWATCHDIAL -> Cmds.setWatchDial(idoBaseModel as IDOWatchDialParamModel)
            CustomEvtType.SETSHORTCUT -> Cmds.setShortcut(idoBaseModel as IDOShortcutParamModel)
            CustomEvtType.SETBPCALIBRATION -> Cmds.setBpCalibration(idoBaseModel as IDOBpCalibrationParamModel)
            CustomEvtType.SETBPMEASUREMENT -> Cmds.setBpMeasurement(idoBaseModel as IDOBpMeasurementParamModel)
            CustomEvtType.SETSTRESSCALIBRATION -> Cmds.setStressCalibration(idoBaseModel as IDOStressCalibrationParamModel)
            CustomEvtType.SETGPSCONTROL -> Cmds.setGpsControl(idoBaseModel as IDOGpsControlParamModel)
            CustomEvtType.SETSPO2SWITCH -> Cmds.setSpo2Switch(idoBaseModel as IDOSpo2SwitchParamModel)
            CustomEvtType.SETHANDWASHINGREMINDER -> Cmds.setHandWashingReminder(idoBaseModel as IDOHandWashingReminderParamModel)
            CustomEvtType.SETNOTICEAPPNAME -> Cmds.setNoticeAppName(idoBaseModel as IDONoticeMesaageParamModel)
            CustomEvtType.SETSYNCCONTACT -> Cmds.setSyncContact(idoBaseModel as IDOSyncContactParamModel)
            CustomEvtType.MUSICCONTROL -> Cmds.musicControl(idoBaseModel as IDOMusicControlParamModel)
            CustomEvtType.NOTICEMESSAGEV3 -> Cmds.noticeMessageV3(idoBaseModel as IDONoticeMessageParamModel)
            CustomEvtType.SETBPCALCONTROLV3 -> Cmds.setBpCalControlV3(idoBaseModel as IDOBpCalControlModel)
            CustomEvtType.SETAPPLETCONTROL ->Cmds.setAppletControl(idoBaseModel as IDOAppletControlModel)
            CustomEvtType.SETBASESPORTPARAMSORTV3 -> Cmds.setSportParamSort(
                IDOSportSortParamModel(
                    1,
                    IDOSportType.SPORTTYPEAEROBICS,
                    1,
                    listOf(
                        1,
                        2,
                    )
                )
            )
            CustomEvtType.SETSCHEDULERREMINDERV3 -> Cmds.setSchedulerReminder(idoBaseModel as IDOSchedulerReminderParamModel)
            CustomEvtType.SET100SPORTSORTV3 -> Cmds.setSport100Sort(idoBaseModel as IDOSport100SortParamModel)
            CustomEvtType.SETWALLPAPERDIALREPLYV3 -> Cmds.setWallpaperDialReply(idoBaseModel as IDOWallpaperDialReplyV3ParamModel)
            CustomEvtType.SETVOICEREPLYTXTV3 -> Cmds.setVoiceReplyText(idoBaseModel as IDOVoiceReplyParamModel)
            CustomEvtType.SETTIME -> Cmds.setDateTime() // Cmds.setDateTime(idoBaseModel as IDODateTimeParamModel)
            CustomEvtType.SETFINDPHONE -> Cmds.setFindPhone(true)
            CustomEvtType.SETWEATHERSWITCH -> Cmds.setWeatherSwitch(true)
            CustomEvtType.SETONEKEYSOS -> Cmds.setOnekeySOS(false, 0)
            CustomEvtType.SETUNREADAPPREMINDER -> Cmds.setUnreadAppReminder(true)
            CustomEvtType.SETWEATHERCITYNAME -> Cmds.setWeatherCityName("dsdgf")
            CustomEvtType.SETRRESPIRATETURN -> Cmds.setRRespiRateTurn(false)
            CustomEvtType.SETBODYPOWERTURN -> Cmds.setBodyPowerTurn(false)
            CustomEvtType.SETSCREENBRIGHTNESS -> Cmds.setScreenBrightness(idoBaseModel as IDOScreenBrightnessModel)
            CustomEvtType.SETACTIVITYSWITCH -> Cmds.setActivitySwitch(idoBaseModel as IDOActivitySwitchParamModel)
            CustomEvtType.SETALARMV3 -> Cmds.setAlarmV3(idoBaseModel as IDOAlarmModel)
            CustomEvtType.SETHEARTRATEINTERVAL -> Cmds.setHeartRateInterval(idoBaseModel as IDOHeartRateIntervalModel)
            CustomEvtType.SETMENSTRUATION -> Cmds.setMenstruation(idoBaseModel as IDOMenstruationModel)
            CustomEvtType.SETCALORIEDISTANCEGOAL -> Cmds.setCalorieDistanceGoal(idoBaseModel as IDOMainSportGoalModel)
            CustomEvtType.SETWORLDTIMEV3 -> Cmds.setWorldTimeV3(
                listOf(
                    IDOWorldTimeParamModel(
                        1,
                        2,
                        "东京",
                        3,
                        4,
                        5,
                        6,
                        7,
                        2,
                        3,
                        4
                    )
                )
            )
            CustomEvtType.SETHAND -> Cmds.setHand(false)
            CustomEvtType.SETLONGCITYNAMEV3 -> Cmds.setLongCityNameV3("深圳")
            CustomEvtType.GETHISTORICALMENSTRUATION -> Cmds.setHistoricalMenstruation(idoBaseModel as IDOHistoricalMenstruationParamModel)
            CustomEvtType.SETSPORTSORTV3 -> Cmds.setSportSortV3(idoBaseModel as IDOSportParamModel)
            CustomEvtType.SETUSERINFO -> Cmds.setUserInfo(idoBaseModel as IDOUserInfoPramModel)
            CustomEvtType.SETNOTDISTURB -> Cmds.setNotDisturb(idoBaseModel as IDONotDisturbParamModel)
            CustomEvtType.SETMENSTRUATIONREMIND -> Cmds.setMenstruationRemind(idoBaseModel as IDOMenstruationRemindParamModel)
            CustomEvtType.SETSTRESSSWITCH -> Cmds.setStressSwitch(idoBaseModel as IDOStressSwitchParamModel)
            CustomEvtType.SETDRINKWATERREMIND -> Cmds.setDrinkWaterRemind(idoBaseModel as IDODrinkWaterRemindModel)
            CustomEvtType.SETOVERFINDPHONE -> Cmds.setOverFindPhone()
            CustomEvtType.SETMENULIST -> Cmds.setMenuList(idoBaseModel as IDOMenuListParamModel)
            CustomEvtType.SETALARM -> Cmds.setAlarmV3(idoBaseModel as IDOAlarmModel)
            CustomEvtType.MUSICSTART -> Cmds.musicStart()
            CustomEvtType.MUSICSTOP -> Cmds.musicStop()
            CustomEvtType.SETCALLQUICKREPLYONOFF -> Cmds.setCallQuickReplyOnOff(true)
            CustomEvtType.SETVOICEASSISTANTONOFF -> Cmds.setVoiceAssistantOnOff(true)
            CustomEvtType.SETFASTMSGUPDATE -> Cmds.setFastMsgUpdate(idoBaseModel as IDOFastMsgUpdateParamModel)
            CustomEvtType.SETFASTMSGV3 -> Cmds.setDefaultQuickMsgReplyList(idoBaseModel as IDOFastMsgSettingModel)
            CustomEvtType.SETSPORTMODESORT -> Cmds.setSportModeSort(
                listOf(
                    IDOSportModeSortParamModel(
                        1,
                        IDOSportType.SPORTTYPEAEROBICS
                    )
                )
            )
            else -> {
                null
            }
        }
        request(cmd?.json ?: "")
        cmd?.send {
            if (it.error.code == 0) {
                val res = it.res?.toJsonString() ?: "{}"
                result("${it.error.message}\n\n$res")
            } else {
                val res = it.res?.toJsonString() ?: "{}"
                result("${it.error.message}\n\n$res")
            }
        }
        result("")
    }
}