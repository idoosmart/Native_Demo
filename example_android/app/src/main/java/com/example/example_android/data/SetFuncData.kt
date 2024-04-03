package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.IDOActivitySwitchParamModel
import com.idosmart.model.IDOAlarmItem
import com.idosmart.model.IDOAlarmModel
import com.idosmart.model.IDOAlarmStatus
import com.idosmart.model.IDOAlarmType
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDOBpCalControlModel
import com.idosmart.model.IDOBpCalibrationParamModel
import com.idosmart.model.IDOBpMeasurementParamModel
import com.idosmart.model.IDOContactItem
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.model.IDODisplayModeParamModel
import com.idosmart.model.IDODrinkWaterRemindModel
import com.idosmart.model.IDOFitnessGuidanceParamModel
import com.idosmart.model.IDOFutureItem
import com.idosmart.model.IDOGpsInfoModelItem
import com.idosmart.model.IDOHandWashingReminderParamModel
import com.idosmart.model.IDOHeartRateIntervalModel
import com.idosmart.model.IDOHeartRateModeSmartParamModel
import com.idosmart.model.IDOHistoricalMenstruationParamItem
import com.idosmart.model.IDOHistoricalMenstruationParamModel
import com.idosmart.model.IDOHoursWeatherItem
import com.idosmart.model.IDOItemItem
import com.idosmart.model.IDOLongSitParamModel
import com.idosmart.model.IDOLostFindParamModel
import com.idosmart.model.IDOMainSportGoalModel
import com.idosmart.model.IDOMainUISortParamModel
import com.idosmart.model.IDOMenstruationModel
import com.idosmart.model.IDOMenstruationRemindParamModel
import com.idosmart.model.IDOMenuListParamModel
import com.idosmart.model.IDOMusicControlParamModel
import com.idosmart.model.IDOMusicFolderItem
import com.idosmart.model.IDOMusicOnOffParamModel
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDONotDisturbParamModel
import com.idosmart.model.IDONoticeMesaageParamItem
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageStateItemItem
import com.idosmart.model.IDONoticeMessageStateParamModel
import com.idosmart.model.IDONotificationCenterParamModel
import com.idosmart.model.IDONotificationStatusParamModel
import com.idosmart.model.IDORunPlanParamModel
import com.idosmart.model.IDOSchedulerReminderItem
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
import com.idosmart.model.IDOSunriseItem
import com.idosmart.model.IDOSyncContactParamModel
import com.idosmart.model.IDOTemperatureSwitchParamModel
import com.idosmart.model.IDOUnitParamModel
import com.idosmart.model.IDOUpHandGestureParamModel
import com.idosmart.model.IDOUserInfoPramModel
import com.idosmart.model.IDOV3NoiseParamModel
import com.idosmart.model.IDOVoiceReplyParamModel
import com.idosmart.model.IDOWalkRemindModel
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
import com.idosmart.protocol_channel.sdk

class SetFuncData(
    type: CustomEvtType = CustomEvtType.GETACTIVITYSWITCH,
    title: String? = null,
    var idoBaseModel: IDOBaseModel
) : IDoDataBean(type, title) {
    companion object {
        fun getFunctions(context: Context): MutableList<SetFuncData> {
            var mutableListOf = mutableListOf<SetFuncData>(
                SetFuncData(
                    CustomEvtType.SETACTIVITYSWITCH,
                    context.getString(R.string.set_activity_switch),
                    IDOActivitySwitchParamModel(
                        1,
                        2, 10,
                        9, 7,
                        9, 7,
                        5,
                        4
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETALARMV3, context.getString(R.string.set_alarm), IDOAlarmModel(
                        listOf(
                            IDOAlarmItem(
                                14,
                                5,
                                12,
                                54,
                                "dsdgf",
                                false,
                                hashSetOf(
                                    IDOWeek.FRIDAY,
                                    IDOWeek.FRIDAY,
                                    IDOWeek.FRIDAY,
                                    IDOWeek.FRIDAY,
                                ),
                                3,
                                10,
                                IDOAlarmStatus.DISPLAYED,
                                10,
                                IDOAlarmType.DATE
                            )
                        )
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETHEARTRATEINTERVAL,
                    context.getString(R.string.set_heart_rate_interval),
                    IDOHeartRateIntervalModel(
                        1,
                        2,
                        4,
                        5,
                        6,
                        8,
                        9,
                        10,
                        7,
                        6,
                        5, 5,
                        5, 5, 5,
                        5
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSCREENBRIGHTNESS,
                    context.getString(R.string.set_screen_brightness),
                    IDOScreenBrightnessModel(
                        1,
                        2,
                        4,
                        5,
                        6,
                        8,
                        9,
                        10,
                        7,
                        6,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETMENSTRUATION, context.getString(R.string.set_menstrual_period),
                    IDOMenstruationModel(
                        66, 4, 15, 89, 90, 90, 90,
                        80, 70, 76, 6
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETCALORIEDISTANCEGOAL,
                    context.getString(R.string.calories_and_distance_targets),
                    IDOMainSportGoalModel(
                        66, 4, 15, 89, 90, 90, 90,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSENDRUNPLAN,
                    context.getString(R.string.set_send_run_plan),
                    IDORunPlanParamModel(
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
                    CustomEvtType.SETWALKREMIND,
                    context.getString(R.string.setwalkreminder),
                    IDOWalkRemindModel(
                        1,
                        100,
                        9,
                        0,
                        18,
                        0,
                        hashSetOf(IDOWeek.MONDAY, IDOWeek.SUNDAY),
                        0,
                        1,
                        0,
                        14,
                        0,
                        15,
                        0
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETWATCHDIALSORT,
                    context.getString(R.string.set_dial_order),
                    IDOWatchDialSortParamModel(
                        sortItemNumb = 2, pSortItem = listOf(
                            IDOWatchDialSortItem(
                                type = 1, sortNumber = 0, name = "w6.iwf"
                            ),
                            IDOWatchDialSortItem(
                                type = 1, sortNumber = 1, name = "w96.iwf"
                            )
                        )
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETWEATHERV3,
                    context.getString(R.string.set_weather_v3),
                    IDOWeatherV3ParamModel(
                        11,
                        29,
                        16,
                        2,
                        2,
                        1,
                        7,
                        9,
                        33,
                        3,
                        "shenzhen",
                        7,
                        40,
                        32,
                        10,
                        5,
                        5,
                        37,
                        18,
                        49,
                        3,
                        "big",
                        listOf(
                            IDOHoursWeatherItem(
                                weatherType = 7, temperature = 8, probability = 40
                            )
                        ),
                        listOf(
                            IDOFutureItem(
                                weatherType = 6, maxTemp = 33, minTemp = 8
                            )
                        ),
                        listOf(
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
                    CustomEvtType.SETNOTICEMESSAGESTATE,
                    context.getString(R.string.v3_set_message_notification_status),
                    IDONoticeMessageStateParamModel(
                        1, 1, 3, 1, 1, listOf(
                            IDONoticeMessageStateItemItem(
                                evtType = 1, notifyState = 1, picFlag = 1
                            )
                        )
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETNOTICEMESSAGESTATE,
                    context.getString(R.string.v3_get_message_notification_status),
                    IDONoticeMessageStateParamModel(
                        1, 3, 1, 1, 1, listOf(
                            IDONoticeMessageStateItemItem(
                                evtType = 1, notifyState = 1, picFlag = 1
                            )
                        )
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETNOTICEMESSAGESTATE,
                    context.getString(R.string.v3_updata_message_notification_status),
                    IDONoticeMessageStateParamModel(
                        1, 2, 1, 1, 1, listOf(
                            IDONoticeMessageStateItemItem(
                                evtType = 1, notifyState = 1, picFlag = 1
                            )
                        )
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETWATCHFACEDATA,
                    context.getString(R.string.setwatchfacedata),
                    IDOWatchFaceParamModel(
                        1, "w63.iwf", 2024
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETNOTIFICATIONSTATUS,
                    context.getString(R.string.setnotificationstatus),
                    IDONotificationStatusParamModel(1)
                ),
                SetFuncData(
                    CustomEvtType.SETFITNESSGUIDANCE,
                    context.getString(R.string.setfitnessguidance),
                    IDOFitnessGuidanceParamModel(
                        1, 2, 4, 5, 6, 7, 8, hashSetOf(
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
                    CustomEvtType.SETSCIENTIFICSLEEPSWITCH,
                    context.getString(R.string.setscientificsleepswitch),
                    IDOScientificSleepSwitchParamModel(
                        1, 1, 2, 3, 4
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETTEMPERATURESWITCH,
                    context.getString(R.string.settemperatureswitch),
                    IDOTemperatureSwitchParamModel(
                        1, 1, 2, 3, 4, 6
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETV3NOISE,
                    context.resources.getString(R.string.setv3noise),
                    IDOV3NoiseParamModel(
                        3, 0, 0, 23, 59, 1, 5
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETHEARTRATEMODESMART,
                    context.getString(R.string.setheartratemodesmart),
                    IDOHeartRateModeSmartParamModel(
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
//                SetFuncData(
//                    CustomEvtType.SETTAKINGMEDICINEREMINDER,
//                    context.getString(R.string.settakingmedicinereminder),
//                    IDOTakingMedicineReminderParamModel(
//                        1, 0, 0, 23, 59, 1, hashSetOf(
//                            IDOWeek.MONDAY,
//                            IDOWeek.TUESDAY,
//                            IDOWeek.WEDNESDAY,
//                            IDOWeek.THURSDAY,
//                            IDOWeek.FRIDAY,
//                            IDOWeek.SATURDAY,
//                            IDOWeek.SUNDAY
//                        ), 49, 98, 99, 100, 101, 9
//                    )
//                ),
                SetFuncData(
                    CustomEvtType.SETBLEVOICE,
                    context.getString(R.string.setblevoiceble),
                    IDOBleVoiceParamModel(5, 6)
                ),
                SetFuncData(
                    CustomEvtType.SETLONGSIT,
                    context.getString(R.string.setlongsit),
                    IDOLongSitParamModel(
                        10, 4, 10, 19, 10, 39
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETLOSTFIND,
                    context.getString(R.string.setlostfind),
                    IDOLostFindParamModel(8)
                ),
                SetFuncData(
                    CustomEvtType.SETSPORTGOAL,
                    context.getString(R.string.setsportgoal),
                    IDOSportGoalParamModel(
                        10,
                        4,
                        10,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETUNIT, context.getString(R.string.setunit), IDOUnitParamModel(
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
                    CustomEvtType.SETUPHANDGESTURE,
                    context.getString(R.string.setuphandgesture),
                    IDOUpHandGestureParamModel(
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
                    CustomEvtType.SETMUSICONOFF,
                    context.getString(R.string.setmusiconoff),
                    IDOMusicOnOffParamModel(
                        10,
                        4,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETDISPLAYMODE,
                    context.getString(R.string.setdisplaymode),
                    IDODisplayModeParamModel(
                        10,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSPORTMODESELECT,
                    context.getString(R.string.setsportmodeselect),
                    IDOSportModeSelectParamModel(
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
                    CustomEvtType.SETSLEEPPERIOD,
                    context.getString(R.string.setsleepperiod),
                    IDOSleepPeriodParamModel(
                        10,
                        4,
                        10,
                        19,
                        10,
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETWEATHERSUNTIME,
                    context.getString(R.string.setweathersuntime),
                    IDOWeatherSunTimeParamModel(
                        10,
                        4,
                        10,
                        19,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETWATCHDIAL,
                    context.getString(R.string.setwatchdial),
                    IDOWatchDialParamModel(
                        10,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSHORTCUT,
                    context.getString(R.string.setshortcut),
                    IDOShortcutParamModel(
                        1
                    )
                ),


//                SetFuncData(
//                    CustomEvtType.SETGPSCONTROL,
//                    context.getString(R.string.setgpscontrol),
//                    IDOGpsControlParamModel(1, 1)
//                ),
                SetFuncData(
                    CustomEvtType.SETSPO2SWITCH,
                    context.getString(R.string.setspo2switch),
                    IDOSpo2SwitchParamModel(
                        1, 14, 0, 20, 0, 1, 20, 1
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETNOTICEAPPNAME,
                    context.getString(R.string.setnoticeappname),
                    IDONoticeMesaageParamModel(
                        4, 10, 19, 10, 39, "ido", "ido_demo", "ido_demo", listOf(
                            IDONoticeMesaageParamItem(
                                0, "ido"
                            )
                        )
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSYNCCONTACT,
                    context.getString(R.string.setsynccontact),
                    IDOSyncContactParamModel(
                        1, listOf(
                            IDOContactItem(
                                "18888888888", "ido"
                            )
                        )
                    )
                ),
                SetFuncData(
                    CustomEvtType.MUSICCONTROL,
                    context.getString(R.string.musiccontrol),
                    IDOMusicControlParamModel(
                        1, 5, 2, "ido", "ido"

                    )
                ),
//                SetFuncData(
//                    CustomEvtType.NOTICEMESSAGEV3,
//                    context.getString(R.string.noticemessagev3),
//                    IDONoticeMessageParamModel(
//                        2, 4, 10, false, false, false, "xmm", "ddd", "13340216580", "xiao"
//                    )
//                ),


                SetFuncData(
                    CustomEvtType.SETSCHEDULERREMINDERV3,
                    context.getString(R.string.setschedulerreminderv3),
                    IDOSchedulerReminderParamModel(
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
                    CustomEvtType.SET100SPORTSORTV3,
                    context.getString(R.string.set100sportsortv3),
                    IDOSport100SortParamModel(
                        1, 2, listOf(
                            1, 2
                        )
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETVOICEREPLYTXTV3,
                    context.getString(R.string.setvoicereplytxtv3),
                    IDOVoiceReplyParamModel(
                        1, "dsdf", "sdf"
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETTIME,
                    context.getString(R.string.settime),
                    IDODateTimeParamModel(
                        2022, 10, 3, 5, 19, 16, 10, 29
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETFINDPHONE,
                    context.getString(R.string.setfindphone),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETONEKEYSOS,
                    context.getString(R.string.setonekeysos),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETWEATHERSWITCH,
                    context.getString(R.string.setweatherswitch),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETUNREADAPPREMINDER,
                    context.getString(R.string.setunreadappreminder),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETWEATHERCITYNAME,
                    context.getString(R.string.setweathercityname),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETSPORTMODESORT,
                    context.getString(R.string.setsportmodesort),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETRRESPIRATETURN,
                    context.getString(R.string.setrrespirateturn),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETBODYPOWERTURN,
                    context.getString(R.string.setbodypowerturn),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETWORLDTIMEV3,
                    context.resources.getString(R.string.setworldtimev3),
                    IDOCmdSetResponseModel(
                        1,
                    )
                ),
//                SetFuncData(
//                    CustomEvtType.SETLONGCITYNAMEV3,
//                    context.resources.getString(R.string.set_long_city_name_v3),
//                    IDOCmdSetResponseModel(1)
//                ),
                SetFuncData(
                    CustomEvtType.GETHISTORICALMENSTRUATION,
                    context.resources.getString(R.string.set_historical_menstruation),
                    IDOHistoricalMenstruationParamModel(
                        7, 29, listOf(
                            IDOHistoricalMenstruationParamItem(2023, 8, 1, 7, 30, 14, 5, 5)
                        )
                    )
                ),

                SetFuncData(
                    CustomEvtType.SETUSERINFO, context.resources.getString(R.string.set_user_info),
                    IDOUserInfoPramModel(2022, 12, 16, 173, 7400, 0)
                ),
                SetFuncData(
                    CustomEvtType.SETNOTDISTURB,
                    context.resources.getString(R.string.set_notDisturb),
                    IDONotDisturbParamModel(1, 15, 23, 30, 2, 127, 1, 9, 0, 12, 0, 0, 0)
                ),
                SetFuncData(
                    CustomEvtType.SETMENSTRUATIONREMIND,
                    context.resources.getString(R.string.set_menstrual_period),
                    IDOMenstruationRemindParamModel(8, 8, 21, 0, 5, 5, 1)
                ),

                SetFuncData(
                    CustomEvtType.SETSTRESSSWITCH,
                    context.resources.getString(R.string.set_stress_switch),
                    IDOStressSwitchParamModel(1, 14, 3, 20, 5, 1, 60, 170, 80, 1, hashSetOf(
                        IDOWeek.MONDAY,
                        IDOWeek.TUESDAY,
                        IDOWeek.WEDNESDAY,
                        IDOWeek.THURSDAY,
                        IDOWeek.FRIDAY,
                        IDOWeek.SATURDAY,
                        IDOWeek.SUNDAY
                    ))
                ),

                SetFuncData(
                    CustomEvtType.SETDRINKWATERREMIND,
                    context.resources.getString(R.string.set_drinkwater_remind),
                    IDODrinkWaterRemindModel(
                        1, 18, 7, 23, 12, hashSetOf(
                            IDOWeek.MONDAY,
                            IDOWeek.TUESDAY,
                            IDOWeek.WEDNESDAY,
                            IDOWeek.THURSDAY,
                            IDOWeek.FRIDAY,
                            IDOWeek.SATURDAY,
                        ), 1, 1, 9, 0, 12, 0, 0
                    )
                ),
                SetFuncData(
                    CustomEvtType.SETOVERFINDPHONE,
                    context.resources.getString(R.string.set_over_find_phone),
                    IDOCmdSetResponseModel(1)
                ),

                SetFuncData(
                    CustomEvtType.SETMENULIST, context.resources.getString(R.string.set_menu_list),
                    IDOMenuListParamModel(listOf(1, 2, 3, 4, 5, 6, 7))
                ),
                SetFuncData(
                    CustomEvtType.MUSICSTART,
                    context.resources.getString(R.string.music_start),
                    IDOCmdSetResponseModel(1)
                ),
                SetFuncData(
                    CustomEvtType.MUSICSTOP,
                    context.resources.getString(R.string.music_stop),
                    IDOCmdSetResponseModel(1)
                ),


                )


//            if (sdk.funcTable.setWalkReminderTimeGoal) {
//                mutableListOf.add(
//                    SetFuncData(
//                        CustomEvtType.SETWALKREMINDTIMES,
//                        context.getString(R.string.set_walk_remiders_time),
//                        IDOWalkRemindTimesParamModel(
//                            onOff = 0, items = listOf(
//                                IDOWalkRemindTimesItem(
//                                    hour = 0, min = 0
//                                )
//                            )
//                        )
//                    )
//                )
//            }
            if (sdk.funcTable.setSetMainUiSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMAINUISORTV3,
                        context.getString(R.string.setmainuisortv3),
                        IDOMainUISortParamModel(
                            2, listOf(1, 2, 3), 1, 1, 2, 1
                        )
                    )
                )
            }
            if (sdk.funcTable.getSupportV3BleMusic) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMUSICOPERATE,
                        context.getString(R.string.setmusicoperate),
                        IDOMusicOpearteParamModel(
                            0, 2,
                            IDOMusicFolderItem(
                                folderId = 1, musicNum = 0, folderName = "kd", musicIndex = listOf()
                            ), null


                        )

                    )
                )
            }
            //----------------------------
//            if (sdk.funcTable.syncHeartRateMonitor) {
//                mutableListOf.add(   SetFuncData(
//                    CustomEvtType.SETHEARTMODE,
//                    context.getString(R.string.setheartmode),
//                    IDOHeartModeParamModel(
//                        8, 0, 0, 23, 59, 1, 4, 4, 49, 98, 99, 100, 101
//
//                    )
//                ))
//            }
            if (sdk.funcTable.setMsgAllSwitch) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETNOTIFICATIONCENTER,
                        context.getString(R.string.setnotificationcenter),
                        IDONotificationCenterParamModel(
                            1,
                            1,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                            0,
                        )
                    )
                )
            }
            if (sdk.funcTable.supportSetWeatherDataV2) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWEATHERDATA,
                        context.getString(R.string.setweatherdata),
                        IDOWeatherDataParamModel(
                            10, 4, 10, 19, 10, 4, 5, listOf(
                                IDOWeatherDataFuture(
                                    0, 0, 0
                                )
                            )
                        )
                    )
                )
            }
            if (sdk.funcTable.getSupportBpSetOrMeasurementV2) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPMEASUREMENT,
                        context.getString(R.string.setbpmeasurement),
                        IDOBpMeasurementParamModel(
                            1,
                        )
                    ),
                )
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPCALIBRATION,
                        context.getString(R.string.setbpcalibration),
                        IDOBpCalibrationParamModel(
                            1, 0, 0
                        )
                    )
                )
            }
            if (sdk.funcTable.setHandWashReminder) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETHANDWASHINGREMINDER,
                        context.getString(R.string.sethandwashingreminder),
                        IDOHandWashingReminderParamModel(
                            0, 0, 0, 23, 59, hashSetOf(
                                IDOWeek.MONDAY,
                                IDOWeek.TUESDAY,
                                IDOWeek.WEDNESDAY,
                                IDOWeek.THURSDAY,
                                IDOWeek.FRIDAY,
                                IDOWeek.SATURDAY,
                            ), 2
                        )
                    )
                )
            }
            if (sdk.funcTable.setSupportV3Bp) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPCALCONTROLV3,
                        context.getString(R.string.setbpcalcontrolv3),
                        IDOBpCalControlModel(
                            1, 0, 0, 23, listOf(
                                0, 0, 1
                            ), listOf(
                                0, 0, 1
                            )
                        )
                    )
                )
            }
            if (sdk.funcTable.setSet20SportParamSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBASESPORTPARAMSORTV3,
                        context.getString(R.string.setbasesportparamsortv3),
                        IDOSportSortParamModel(
                            1, IDOSportType.SPORTTYPEAEROBICS, 1, listOf(
                                1,
                                2,
                            )
                        )
                    )
                )
            }
//            if (sdk.funcTable.setWatchPhotoPositionMove) {
//                mutableListOf.add(   SetFuncData(
//                    CustomEvtType.SETWALLPAPERDIALREPLYV3,
//                    context.getString(R.string.setwallpaperdialreplyv3),
//                    IDOWallpaperDialReplyV3ParamModel(
//                        1,
//                        2,
//                        3,
//                        4,
//                        5,
//                        6,
//                        7,
//                    )
//                ))
//            }
            if (sdk.funcTable.setSupportSetCallQuickReplyOnOff) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETCALLQUICKREPLYONOFF,
                        context.resources.getString(R.string.set_call_quick_reply_on_off),
                        IDOCmdSetResponseModel(1)
                    ),
                )
            }
            if (sdk.funcTable.getSupportSetVoiceAssistantStatus) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETVOICEASSISTANTONOFF,
                        context.resources.getString(R.string.set_voice_assistant_on_off),
                        IDOCmdSetResponseModel(1)
                    )
                )
            }

            if (sdk.funcTable.getSportsTypeV3) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSPORTSORTV3,
                        context.resources.getString(R.string.set_sport_sortV3),
                        IDOSportParamModel(
                            1,
                            listOf(IDOSportModeSortParamModel(1, IDOSportType.SPORTTYPEBURPEE))
                        )
                    )
                )
            }

            if (sdk.funcTable.setSetStressCalibration) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSTRESSCALIBRATION,
                        context.getString(R.string.setstresscalibration),
                        IDOStressCalibrationParamModel(
                            1,
                            0,
                        )
                    )
                )
            }
            return mutableListOf

        }
    }
}