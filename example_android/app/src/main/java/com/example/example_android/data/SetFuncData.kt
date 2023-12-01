package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDOBpCalControlModel
import com.idosmart.model.IDOBpCalibrationParamModel
import com.idosmart.model.IDOBpMeasurementParamModel
import com.idosmart.model.IDOContactItem
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.model.IDODisplayModeParamModel
import com.idosmart.model.IDOFitnessGuidanceParamModel
import com.idosmart.model.IDOFutureItem
import com.idosmart.model.IDOGpsControlParamModel
import com.idosmart.model.IDOGpsInfoModelItem
import com.idosmart.model.IDOHandWashingReminderParamModel
import com.idosmart.model.IDOHeartModeParamModel
import com.idosmart.model.IDOHeartRateModeSmartParamModel
import com.idosmart.model.IDOHoursWeatherItem
import com.idosmart.model.IDOItemItem
import com.idosmart.model.IDOLongSitParamModel
import com.idosmart.model.IDOLostFindParamModel
import com.idosmart.model.IDOMainUISortParamModel
import com.idosmart.model.IDOMusicControlParamModel
import com.idosmart.model.IDOMusicFolderItem
import com.idosmart.model.IDOMusicItem
import com.idosmart.model.IDOMusicOnOffParamModel
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDONoticeMesaageParamItem
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageParamModel
import com.idosmart.model.IDONoticeMessageStateItemItem
import com.idosmart.model.IDONoticeMessageStateParamModel
import com.idosmart.model.IDONotificationCenterParamModel
import com.idosmart.model.IDONotificationStatusParamModel
import com.idosmart.model.IDORunPlanParamModel
import com.idosmart.model.IDOSchedulerReminderItem
import com.idosmart.model.IDOSchedulerReminderModel
import com.idosmart.model.IDOSchedulerReminderParamModel
import com.idosmart.model.IDOScientificSleepSwitchParamModel
import com.idosmart.model.IDOShortcutParamModel
import com.idosmart.model.IDOSleepPeriodParamModel
import com.idosmart.model.IDOSpo2SwitchParamModel
import com.idosmart.model.IDOSport100SortItem
import com.idosmart.model.IDOSport100SortModel
import com.idosmart.model.IDOSport100SortParamModel
import com.idosmart.model.IDOSportGoalParamModel
import com.idosmart.model.IDOSportModeSelectParamModel
import com.idosmart.model.IDOSportSortModel
import com.idosmart.model.IDOSportSortParamModel
import com.idosmart.model.IDOSportType
import com.idosmart.model.IDOStressCalibrationParamModel
import com.idosmart.model.IDOSunriseItem
import com.idosmart.model.IDOSyncContactParamModel
import com.idosmart.model.IDOTakingMedicineReminderParamModel
import com.idosmart.model.IDOTemperatureSwitchParamModel
import com.idosmart.model.IDOUnitParamModel
import com.idosmart.model.IDOUpHandGestureParamModel
import com.idosmart.model.IDOV3NoiseParamModel
import com.idosmart.model.IDOVoiceReplyParamModel
import com.idosmart.model.IDOWalkRemindModel
import com.idosmart.model.IDOWalkRemindTimesItem
import com.idosmart.model.IDOWalkRemindTimesParamModel
import com.idosmart.model.IDOWallpaperDialReplyV3Model
import com.idosmart.model.IDOWallpaperDialReplyV3ParamModel
import com.idosmart.model.IDOWatchDialParamModel
import com.idosmart.model.IDOWatchDialSortItem
import com.idosmart.model.IDOWatchDialSortParamModel
import com.idosmart.model.IDOWatchFaceParamModel
import com.idosmart.model.IDOWeatherDataFuture
import com.idosmart.model.IDOWeatherDataParamModel
import com.idosmart.model.IDOWeatherSunTimeParamModel
import com.idosmart.model.IDOWeatherV3ParamModel
import com.idosmart.model.IDOWeek
import com.idosmart.model.IDOWorldTimeParamModel
import com.idosmart.pigeon_implement.IDOCmdSetResponseModel
import com.idosmart.pigeongen.api_evt_type.ApiEvtType
import java.io.Serializable

class SetFuncData(
    type: ApiEvtType = ApiEvtType.GETACTIVITYSWITCH, title: String? = null, var idoBaseModel: IDOBaseModel
) : IDoDataBean(type, title) {
    companion object {
        fun getFunctions(context: Context): MutableList<SetFuncData> {
            return mutableListOf<SetFuncData>(
                SetFuncData(
                    ApiEvtType.SETSENDRUNPLAN, context.getString(R.string.set_send_run_plan), IDORunPlanParamModel(
                        verison = 1,
                        operate = 1,
                        type = 1,
                        year = 2020,
                        month = 1,
                        day = 1,
                        hour = 0,
                        min = 0,
                        sec = 0,
                        dayNum = 0,
                        items = listOf(
                            IDOGpsInfoModelItem(
                                type = 186, num = 0, items = listOf(
                                    IDOItemItem(
                                        type = 1, time = 0, heightHeart = 0, lowHeart = 0
                                    )
                                )
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWALKREMIND, context.getString(R.string.setwalkreminder), IDOWalkRemindModel(
                        1, 100, 9, 0, 18, 0, true, hashSetOf(IDOWeek.MONDAY, IDOWeek.SUNDAY), 0, 1, 0, 14, 0, 15, 0
                    )
                ),

                SetFuncData(
                    ApiEvtType.SETWATCHDIALSORT, context.getString(R.string.set_dial_order), IDOWatchDialSortParamModel(
                        sortItemNumb = 0, pSortItem = listOf(
                            IDOWatchDialSortItem(
                                type = 1, sortNumber = 0, name = ""
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWALKREMINDTIMES, context.getString(R.string.set_walk_remiders_time), IDOWalkRemindTimesParamModel(
                        onOff = 0, items = listOf(
                            IDOWalkRemindTimesItem(
                                hour = 0, min = 0
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWEATHERV3, context.getString(R.string.set_weather_v3), IDOWeatherV3ParamModel(
                        11, 29, 16, 2, 2, 1, 7, 9, 33, 3, "shenzhen", 7, 40, 32, 10, 5, 5, 37, 18, 49, 3, "big", listOf(
                            IDOHoursWeatherItem(
                                weatherType = 7, temperature = 8, probability = 40
                            )
                        ), listOf(
                            IDOFutureItem(
                                weatherType = 6, maxTemp = 33, minTemp =8
                            )
                        ), listOf(
                            IDOSunriseItem(
                                sunriseHour = 5, sunriseMin = 35, sunsetHour = 15, sunsetMin = 35
                            ), IDOSunriseItem(
                                sunriseHour = 6, sunriseMin = 36, sunsetHour = 16, sunsetMin = 36
                            ), IDOSunriseItem(
                                sunriseHour = 7, sunriseMin = 37, sunsetHour = 17, sunsetMin = 37
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETNOTICEMESSAGESTATE,
                    context.getString(R.string.v3_set_message_notification_status),
                    IDONoticeMessageStateParamModel(
                        1, 1, 0, 0, 0, 2, listOf(
                            IDONoticeMessageStateItemItem(
                                evtType = 0, notifyState = 0, picFlag = 0
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETMAINUISORTV3, context.getString(R.string.setmainuisortv3), IDOMainUISortParamModel(
                        1, listOf(1, 45, 23), 2, 4, 6, 54
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWATCHFACEDATA, context.getString(R.string.setwatchfacedata), IDOWatchFaceParamModel(
                        1, "w97.iwf", 2097152
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETMUSICOPERATE, context.getString(R.string.setmusicoperate), IDOMusicOpearteParamModel(
                        1, 1, listOf(
                            IDOMusicFolderItem(
                                folderId = 1, musicNum = 0, folderName = "kd", musicIndex = listOf()
                            )
                        ), listOf(
                            IDOMusicItem(
                                musicId = 1, musicMemory = 0, musicName = "", singerName = ""
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETNOTIFICATIONSTATUS, context.getString(R.string.setnotificationstatus), IDONotificationStatusParamModel(1)
                ),
                SetFuncData(
                    ApiEvtType.SETFITNESSGUIDANCE, context.getString(R.string.setfitnessguidance), IDOFitnessGuidanceParamModel(
                        1, 2, 4, 5, 6, 7, 8, false, hashSetOf(
                            IDOWeek.MONDAY,
                            IDOWeek.TUESDAY,
                            IDOWeek.WEDNESDAY,
                            IDOWeek.THURSDAY,
                            IDOWeek.FRIDAY,
                            IDOWeek.SATURDAY,
                            IDOWeek.SUNDAY
                        ), 10
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSCIENTIFICSLEEPSWITCH,
                    context.getString(R.string.setscientificsleepswitch),
                    IDOScientificSleepSwitchParamModel(
                        1, 1, 2, 3, 4
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETTEMPERATURESWITCH, context.getString(R.string.settemperatureswitch), IDOTemperatureSwitchParamModel(
                        1, 1, 2, 3, 4, 6
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETV3NOISE, context.resources.getString(R.string.setv3noise), IDOV3NoiseParamModel(
                        3, 0, 0, 23, 59, 1, 5
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETHEARTMODE, context.getString(R.string.setheartmode), IDOHeartModeParamModel(
                        8, 0, 0, 23, 59, 1, 4, 4, 49, 98, 99, 100, 101

                    )
                ),
                SetFuncData(
                    ApiEvtType.SETHEARTRATEMODESMART, context.getString(R.string.setheartratemodesmart), IDOHeartRateModeSmartParamModel(
                        1,
                        0,
                        0,
                        23,
                        59,
                        1,
                        4,
                        4,
                        49,
                        98,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETTAKINGMEDICINEREMINDER,
                    context.getString(R.string.settakingmedicinereminder),
                    IDOTakingMedicineReminderParamModel(
                        1, 0, 0, 23, 59, 1, false, hashSetOf(
                            IDOWeek.MONDAY,
                            IDOWeek.TUESDAY,
                            IDOWeek.WEDNESDAY,
                            IDOWeek.THURSDAY,
                            IDOWeek.FRIDAY,
                            IDOWeek.SATURDAY,
                            IDOWeek.SUNDAY
                        ), 49, 98, 99, 100, 101, 9
                    )
                ),
                SetFuncData(ApiEvtType.SETBLEVOICE, context.getString(R.string.setblevoiceble), IDOBleVoiceParamModel(5, 6)),
                SetFuncData(
                    ApiEvtType.SETLONGSIT, context.getString(R.string.setlongsit), IDOLongSitParamModel(
                        10, 4, 10, 19, 10, 39
                    )
                ),
                SetFuncData(ApiEvtType.SETLOSTFIND, context.getString(R.string.setlostfind), IDOLostFindParamModel(8)),
                SetFuncData(
                    ApiEvtType.SETSPORTGOAL, context.getString(R.string.setsportgoal), IDOSportGoalParamModel(
                        10,
                        4,
                        10,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETUNIT, context.getString(R.string.setunit), IDOUnitParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                        39,
                        49,
                        98,
                        99,
                        100,
                        101,
                        6,
                        7,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETNOTIFICATIONCENTER, context.getString(R.string.setnotificationcenter), IDONotificationCenterParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                        39,
                        10,
                        4,
                        10,
                        19,
                        10,
                        39,
                        10,
                        4,
                        10,
                        19,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETUPHANDGESTURE, context.getString(R.string.setuphandgesture), IDOUpHandGestureParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                        39,
                        10,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETMUSICONOFF, context.getString(R.string.setmusiconoff), IDOMusicOnOffParamModel(
                        10,
                        4,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETDISPLAYMODE, context.getString(R.string.setdisplaymode), IDODisplayModeParamModel(
                        10,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSPORTMODESELECT, context.getString(R.string.setsportmodeselect), IDOSportModeSelectParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                        false,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSLEEPPERIOD, context.getString(R.string.setsleepperiod), IDOSleepPeriodParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWEATHERDATA, context.getString(R.string.setweatherdata), IDOWeatherDataParamModel(
                        10, 4, 10, 19, 10, 4, 5, listOf(
                            IDOWeatherDataFuture(
                                0, 0, 0
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWEATHERSUNTIME, context.getString(R.string.setweathersuntime), IDOWeatherSunTimeParamModel(
                        10,
                        4,
                        10,
                        19,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWATCHDIAL, context.getString(R.string.setwatchdial), IDOWatchDialParamModel(
                        10,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSHORTCUT, context.getString(R.string.setshortcut), IDOShortcutParamModel(
                        1
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETBPCALIBRATION, context.getString(R.string.setbpcalibration), IDOBpCalibrationParamModel(
                        1, 0, 0
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETBPMEASUREMENT, context.getString(R.string.setbpmeasurement), IDOBpMeasurementParamModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSTRESSCALIBRATION, context.getString(R.string.setstresscalibration), IDOStressCalibrationParamModel(
                        1,
                        0,
                    )
                ),
                SetFuncData(ApiEvtType.SETGPSCONTROL, context.getString(R.string.setgpscontrol), IDOGpsControlParamModel(8, 9)),
                SetFuncData(
                    ApiEvtType.SETSPO2SWITCH, context.getString(R.string.setspo2switch), IDOSpo2SwitchParamModel(
                        10, 4, 10, 19, 10, 39, 3, 6
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETHANDWASHINGREMINDER, context.getString(R.string.sethandwashingreminder), IDOHandWashingReminderParamModel(
                        3, 0, 0, 23, 59, false, hashSetOf(
                            IDOWeek.MONDAY,
                            IDOWeek.TUESDAY,
                            IDOWeek.WEDNESDAY,
                            IDOWeek.THURSDAY,
                            IDOWeek.FRIDAY,
                            IDOWeek.SATURDAY,
                        ), 2
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETNOTICEAPPNAME, context.getString(R.string.setnoticeappname), IDONoticeMesaageParamModel(
                        10, 4, 10, 19, 10, 39, "ido", "ido_demo", "ido_demo", listOf(
                            IDONoticeMesaageParamItem(
                                0, "ido"
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSYNCCONTACT, context.getString(R.string.setsynccontact), IDOSyncContactParamModel(
                        5, listOf(
                            IDOContactItem(
                                "18888888888", "ido"
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.MUSICCONTROL, context.getString(R.string.musiccontrol), IDOMusicControlParamModel(
                        1, 5, 2, "ido", "ido"

                    )
                ),
                SetFuncData(
                    ApiEvtType.NOTICEMESSAGEV3, context.getString(R.string.noticemessagev3), IDONoticeMessageParamModel(
                        8, 4, 10, false, false, false, "xmm", "ddd", "dsdf", "xiao"
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETBPCALCONTROLV3, context.getString(R.string.setbpcalcontrolv3), IDOBpCalControlModel(
                        1, 0, 0, 23, listOf(
                            0, 0, 1
                        ), listOf(
                            0, 0, 1
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETBASESPORTPARAMSORTV3, context.getString(R.string.setbasesportparamsortv3), IDOSportSortParamModel(
                        1, IDOSportType.SPORTTYPEAEROBICS, 1, listOf(
                            1,
                            2,
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSCHEDULERREMINDERV3, context.getString(R.string.setschedulerreminderv3), IDOSchedulerReminderParamModel(
                        1, listOf(
                            IDOSchedulerReminderItem(
                                0,
                                2020,
                                1,
                                1,
                                0,
                                1,
                                2,
                                0,
                                0,
                                1,
                                "ddd",
                                "ddd",
                            )
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SET100SPORTSORTV3, context.getString(R.string.set100sportsortv3), IDOSport100SortParamModel(
                        1, 2, listOf(
                            1, 2
                        )
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWALLPAPERDIALREPLYV3,
                    context.getString(R.string.setwallpaperdialreplyv3),
                    IDOWallpaperDialReplyV3ParamModel(
                        1,
                        2,
                        3,
                        4,
                        5,
                        6,
                        7,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETVOICEREPLYTXTV3, context.getString(R.string.setvoicereplytxtv3), IDOVoiceReplyParamModel(
                        1, "dsdf", "sdf"
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETTIME, context.getString(R.string.settime), IDODateTimeParamModel(
                        2022, 10, 3, 5, 19, 16, 10, 29
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETFINDPHONE, context.getString(R.string.setfindphone), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETONEKEYSOS, context.getString(R.string.setonekeysos), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWEATHERSWITCH, context.getString(R.string.setweatherswitch), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETUNREADAPPREMINDER, context.getString(R.string.setunreadappreminder), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWEATHERCITYNAME, context.getString(R.string.setweathercityname), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETSPORTMODESORT, context.getString(R.string.setsportmodesort), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETRRESPIRATETURN, context.getString(R.string.setrrespirateturn), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETBODYPOWERTURN, context.getString(R.string.setbodypowerturn), IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    ApiEvtType.SETWORLDTIMEV3, context.resources.getString(R.string.setworldtimev3), IDOWorldTimeParamModel(
                        1,
                        0,
                        "北京",
                        0,
                        0,
                        0,
                        9,
                        0,
                        0,
                        9,
                        9,
                    )
                ),
            )

        }
    }
}