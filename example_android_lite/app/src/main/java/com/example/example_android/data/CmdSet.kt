package com.example.example_android.data

import android.util.Log
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDOBpCalControlModel
import com.idosmart.model.IDOBpCalibrationParamModel
import com.idosmart.model.IDOBpMeasurementParamModel
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.model.IDODisplayModeParamModel
import com.idosmart.model.IDOFitnessGuidanceParamModel
import com.idosmart.model.IDOGpsControlParamModel
import com.idosmart.model.IDOHandWashingReminderParamModel
import com.idosmart.model.IDOHeartModeParamModel
import com.idosmart.model.IDOHeartRateModeSmartParamModel
import com.idosmart.model.IDOLongSitParamModel
import com.idosmart.model.IDOLostFindParamModel
import com.idosmart.model.IDOMainUISortParamModel
import com.idosmart.model.IDOMusicControlParamModel
import com.idosmart.model.IDOMusicOnOffParamModel
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageParamModel
import com.idosmart.model.IDONoticeMessageStateParamModel
import com.idosmart.model.IDONotificationCenterParamModel
import com.idosmart.model.IDONotificationStatusParamModel
import com.idosmart.model.IDORunPlanParamModel
import com.idosmart.model.IDOSchedulerReminderParamModel
import com.idosmart.model.IDOScientificSleepSwitchParamModel
import com.idosmart.model.IDOShortcutParamModel
import com.idosmart.model.IDOSleepPeriodParamModel
import com.idosmart.model.IDOSpo2SwitchParamModel
import com.idosmart.model.IDOSport100SortParamModel
import com.idosmart.model.IDOSportGoalParamModel
import com.idosmart.model.IDOSportModeSelectParamModel
import com.idosmart.model.IDOSportModeSortParamModel
import com.idosmart.model.IDOSportSortParamModel
import com.idosmart.model.IDOSportType
import com.idosmart.model.IDOStressCalibrationParamModel
import com.idosmart.model.IDOSyncContactParamModel
import com.idosmart.model.IDOTakingMedicineReminderParamModel
import com.idosmart.model.IDOTemperatureSwitchParamModel
import com.idosmart.model.IDOUnitParamModel
import com.idosmart.model.IDOUpHandGestureParamModel
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
import com.idosmart.pigeon_implement.IDOCmdSetResponseModel
import com.idosmart.pigeongen.api_evt_type.ApiEvtType

object CmdSet {
    fun set(evtType: ApiEvtType?, idoBaseModel: IDOBaseModel?, request: (String) -> Unit, result: (String) -> Unit) {
        val cmd = when (evtType) {
            ApiEvtType.SETSENDRUNPLAN -> Cmds.setSendRunPlan(idoBaseModel as IDORunPlanParamModel)
            ApiEvtType.SETWALKREMIND -> Cmds.setWalkReminder(idoBaseModel as IDOWalkRemindModel)
            ApiEvtType.SETWATCHDIALSORT -> Cmds.setWatchDialSort(idoBaseModel as IDOWatchDialSortParamModel)
            ApiEvtType.SETWALKREMINDTIMES -> Cmds.setWalkRemindTimes(idoBaseModel as IDOWalkRemindTimesParamModel)
            ApiEvtType.SETWEATHERV3 -> Cmds.setWeatherV3(idoBaseModel as IDOWeatherV3ParamModel)
            ApiEvtType.SETNOTICEMESSAGESTATE -> Cmds.setNoticeMessageState(idoBaseModel as IDONoticeMessageStateParamModel)
            ApiEvtType.SETMAINUISORTV3 -> Cmds.setMainUISortV3(idoBaseModel as IDOMainUISortParamModel)
            ApiEvtType.SETWATCHFACEDATA -> Cmds.setWatchFaceData(idoBaseModel as IDOWatchFaceParamModel)
            ApiEvtType.SETMUSICOPERATE -> Cmds.setMusicOperate(idoBaseModel as IDOMusicOpearteParamModel)
            ApiEvtType.SETNOTIFICATIONSTATUS -> Cmds.setNotificationStatus(idoBaseModel as IDONotificationStatusParamModel)
            ApiEvtType.SETFITNESSGUIDANCE -> Cmds.setFitnessGuidance(idoBaseModel as IDOFitnessGuidanceParamModel)
            ApiEvtType.SETSCIENTIFICSLEEPSWITCH -> Cmds.setScientificSleepSwitch(idoBaseModel as IDOScientificSleepSwitchParamModel)
            ApiEvtType.SETTEMPERATURESWITCH -> Cmds.setTemperatureSwitch(idoBaseModel as IDOTemperatureSwitchParamModel)
            ApiEvtType.SETV3NOISE -> Cmds.setV3Noise(idoBaseModel as IDOV3NoiseParamModel)
            ApiEvtType.SETHEARTMODE -> Cmds.setHeartMode(idoBaseModel as IDOHeartModeParamModel)
            ApiEvtType.SETHEARTRATEMODESMART -> Cmds.setHeartRateModeSmart(idoBaseModel as IDOHeartRateModeSmartParamModel)
            ApiEvtType.SETTAKINGMEDICINEREMINDER -> Cmds.setTakingMedicineReminder(idoBaseModel as IDOTakingMedicineReminderParamModel)
            ApiEvtType.SETBLEVOICE -> Cmds.setBleVoice(idoBaseModel as IDOBleVoiceParamModel)
            ApiEvtType.SETLONGSIT -> Cmds.setLongSit(idoBaseModel as IDOLongSitParamModel)
            ApiEvtType.SETLOSTFIND -> Cmds.setLostFind(idoBaseModel as IDOLostFindParamModel)
            ApiEvtType.SETSPORTGOAL -> Cmds.setSportGoal(idoBaseModel as IDOSportGoalParamModel)
            ApiEvtType.SETUNIT -> Cmds.setUnit(idoBaseModel as IDOUnitParamModel)
            ApiEvtType.SETNOTIFICATIONCENTER -> Cmds.setNotificationCenter(idoBaseModel as IDONotificationCenterParamModel)
            ApiEvtType.SETUPHANDGESTURE -> Cmds.setUpHandGesture(idoBaseModel as IDOUpHandGestureParamModel)
            ApiEvtType.SETMUSICONOFF -> Cmds.setMusicOnOff(idoBaseModel as IDOMusicOnOffParamModel)
            ApiEvtType.SETDISPLAYMODE -> Cmds.setDisplayMode(idoBaseModel as IDODisplayModeParamModel)
            ApiEvtType.SETSPORTMODESELECT -> Cmds.setSportModeSelect(idoBaseModel as IDOSportModeSelectParamModel)
            ApiEvtType.SETSLEEPPERIOD -> Cmds.setSleepPeriod(idoBaseModel as IDOSleepPeriodParamModel)
            ApiEvtType.SETWEATHERDATA -> Cmds.setWeatherData(idoBaseModel as IDOWeatherDataParamModel)
            ApiEvtType.SETWEATHERSUNTIME -> Cmds.setWeatherSunTime(idoBaseModel as IDOWeatherSunTimeParamModel)
            ApiEvtType.SETWATCHDIAL -> Cmds.setWatchDial(idoBaseModel as IDOWatchDialParamModel)
            ApiEvtType.SETSHORTCUT -> Cmds.setShortcut(idoBaseModel as IDOShortcutParamModel)
            ApiEvtType.SETBPCALIBRATION -> Cmds.setBpCalibration(idoBaseModel as IDOBpCalibrationParamModel)
            ApiEvtType.SETBPMEASUREMENT -> Cmds.setBpMeasurement(idoBaseModel as IDOBpMeasurementParamModel)
            ApiEvtType.SETSTRESSCALIBRATION -> Cmds.setStressCalibration(idoBaseModel as IDOStressCalibrationParamModel)
            ApiEvtType.SETGPSCONTROL -> Cmds.setGpsControl(idoBaseModel as IDOGpsControlParamModel)
            ApiEvtType.SETSPO2SWITCH -> Cmds.setSpo2Switch(idoBaseModel as IDOSpo2SwitchParamModel)
            ApiEvtType.SETHANDWASHINGREMINDER -> Cmds.setHandWashingReminder(idoBaseModel as IDOHandWashingReminderParamModel)
            ApiEvtType.SETNOTICEAPPNAME -> Cmds.setNoticeAppName(idoBaseModel as IDONoticeMesaageParamModel)
            ApiEvtType.SETSYNCCONTACT -> Cmds.setSyncContact(idoBaseModel as IDOSyncContactParamModel)
            ApiEvtType.MUSICCONTROL -> Cmds.musicControl(idoBaseModel as IDOMusicControlParamModel)
            ApiEvtType.NOTICEMESSAGEV3 -> Cmds.noticeMessageV3(idoBaseModel as IDONoticeMessageParamModel)
            ApiEvtType.SETBPCALCONTROLV3 -> Cmds.setBpCalControlV3(idoBaseModel as IDOBpCalControlModel)
            ApiEvtType.SETBASESPORTPARAMSORTV3 -> Cmds.setSportParamSort(
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

            ApiEvtType.SETSCHEDULERREMINDERV3 -> Cmds.setSchedulerReminder(idoBaseModel as IDOSchedulerReminderParamModel)
            ApiEvtType.SET100SPORTSORTV3 -> Cmds.setSport100Sort(idoBaseModel as IDOSport100SortParamModel)
            ApiEvtType.SETWALLPAPERDIALREPLYV3 -> Cmds.setWallpaperDialReply(idoBaseModel as IDOWallpaperDialReplyV3ParamModel)
            ApiEvtType.SETVOICEREPLYTXTV3 -> Cmds.setVoiceReplyText(idoBaseModel as IDOVoiceReplyParamModel)
            ApiEvtType.SETTIME -> Cmds.setDateTime(idoBaseModel as IDODateTimeParamModel)
            ApiEvtType.SETFINDPHONE -> Cmds.setFindPhone(true)
            ApiEvtType.SETWEATHERSWITCH -> Cmds.setWeatherSwitch(true)
            ApiEvtType.SETONEKEYSOS -> Cmds.setOnekeySOS(false, 0)
            ApiEvtType.SETUNREADAPPREMINDER -> Cmds.setUnreadAppReminder(true)
            ApiEvtType.SETWEATHERCITYNAME -> Cmds.setWeatherCityName("dsdgf")
            ApiEvtType.SETRRESPIRATETURN -> Cmds.setRRespiRateTurn(false)
            ApiEvtType.SETBODYPOWERTURN -> Cmds.setBodyPowerTurn(false)
            ApiEvtType.SETWORLDTIMEV3 -> Cmds.setWorldTimeV3(
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

            ApiEvtType.SETSPORTMODESORT -> Cmds.setSportModeSort(
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
            result(it.error.message ?: "")
        }
        result("")
    }
}