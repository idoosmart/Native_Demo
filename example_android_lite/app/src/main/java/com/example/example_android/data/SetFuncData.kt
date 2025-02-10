package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.IDOActivitySwitchParamModel
import com.idosmart.model.IDOAlarmItem
import com.idosmart.model.IDOAlarmModel
import com.idosmart.model.IDOAlarmStatus
import com.idosmart.model.IDOAlarmType
import com.idosmart.model.IDOAppletControlModel
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDOBpCalControlModel
import com.idosmart.model.IDOBpCalibrationParamModel
import com.idosmart.model.IDOBpMeasurementParamModel
import com.idosmart.model.IDOContactItem
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.model.IDODisplayModeParamModel
import com.idosmart.model.IDODrinkWaterRemindModel
import com.idosmart.model.IDOFastMsgItem
import com.idosmart.model.IDOFastMsgSettingModel
import com.idosmart.model.IDOFastMsgUpdateParamModel
import com.idosmart.model.IDOFitnessGuidanceParamModel
import com.idosmart.model.IDOFutureItem
import com.idosmart.model.IDOGpsInfoModelItem
import com.idosmart.model.IDOHandWashingReminderParamModel
import com.idosmart.model.IDOHeartModeParamModel
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
import com.idosmart.model.IDOTakingMedicineReminderParamModel
import com.idosmart.model.IDOTemperatureSwitchParamModel
import com.idosmart.model.IDOUnitParamModel
import com.idosmart.model.IDOUpHandGestureParamModel
import com.idosmart.model.IDOUserInfoPramModel
import com.idosmart.model.IDOV3NoiseParamModel
import com.idosmart.model.IDOVoiceReplyParamModel
import com.idosmart.model.IDOWalkRemindModel
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
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDOCmdSetResponseModel
import com.idosmart.protocol_channel.sdk

class SetFuncData(
    type: CustomEvtType = CustomEvtType.GETACTIVITYSWITCH,
    title: String? = null,
) : IDoDataBean(type, title) {
    companion object {
        fun getFunctions(context: Context): MutableList<SetFuncData> {
            var mutableListOf = mutableListOf<SetFuncData>(
                SetFuncData(
                    CustomEvtType.SETHEARTRATEINTERVAL,
                    context.getString(R.string.set_heart_rate_interval)
                ),


                SetFuncData(
                    CustomEvtType.SETCALORIEDISTANCEGOAL,
                    context.getString(R.string.calories_and_distance_targets)
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
                    CustomEvtType.SETSPORTGOAL,
                    context.getString(R.string.setsportgoal)
                ),
                SetFuncData(
                    CustomEvtType.SETUNIT, context.getString(R.string.setunit),
                ),

                SetFuncData(
                    CustomEvtType.SETUPHANDGESTURE,
                    context.getString(R.string.setuphandgesture),

                    ),
                SetFuncData(
                    CustomEvtType.SETMUSICONOFF,
                    context.getString(R.string.setmusiconoff),

                    ),
                SetFuncData(
                    CustomEvtType.SETDISPLAYMODE,
                    context.getString(R.string.setdisplaymode),

                    ),

                SetFuncData(
                    CustomEvtType.SETSLEEPPERIOD,
                    context.getString(R.string.setsleepperiod),

                    ),

                SetFuncData(
                    CustomEvtType.SETWEATHERSUNTIME,
                    context.getString(R.string.setweathersuntime),

                    ),
                SetFuncData(
                    CustomEvtType.SETWATCHDIAL,
                    context.getString(R.string.setwatchdial),

                    ),
                SetFuncData(
                    CustomEvtType.SETSHORTCUT,
                    context.getString(R.string.setshortcut),

                    ),


//                SetFuncData(
//                    CustomEvtType.SETGPSCONTROL,
//                    context.getString(R.string.setgpscontrol),
//                    IDOGpsControlParamModel(1, 1)
//                ),


                SetFuncData(
                    CustomEvtType.SETNOTICEAPPNAME,
                    context.getString(R.string.setnoticeappname)

                ),


                SetFuncData(
                    CustomEvtType.SETTIME,
                    context.getString(R.string.settime)
                ),


//                SetFuncData(
//                    CustomEvtType.SETLONGCITYNAMEV3,
//                    context.resources.getString(R.string.set_long_city_name_v3),
//                    IDOCmdSetResponseModel(1)
//                ),


                SetFuncData(
                    CustomEvtType.SETUSERINFO, context.resources.getString(R.string.set_user_info),
                ),


                SetFuncData(
                    CustomEvtType.SETOVERFINDPHONE,
                    context.resources.getString(R.string.set_over_find_phone),
                ),

                )


            if (sdk.funcTable.getNotifyMsgV3) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.NOTICEMESSAGEV3,
                        context.getString(R.string.setv3noise)
                    )
                )
            }




            if (sdk.funcTable.setTemperatureSwitchSupport) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETTEMPERATURESWITCH,
                        context.getString(R.string.settemperatureswitch)
                    ),
                )
            }

            if (sdk.funcTable.syncV3SyncAlarm) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETALARMV3,
                        context.getString(R.string.set_alarm),

                        )
                )
            }


            if (sdk.funcTable.setScreenBrightness) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSCREENBRIGHTNESS,
                        context.getString(R.string.set_screen_brightness),

                        )
                )
            }

            if (sdk.funcTable.setMenstruation) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMENSTRUATION,
                        context.getString(R.string.set_menstrual_period),

                        )
                )
            }

            if (sdk.funcTable.setSupportSportPlan) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSENDRUNPLAN,
                        context.getString(R.string.set_send_run_plan),

                        )
                )
            }


            if (sdk.funcTable.setWalkReminder) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWALKREMIND,
                        context.getString(R.string.setwalkreminder),

                        )
                )
            }

            if (sdk.funcTable.setWatchDialSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWATCHDIALSORT,
                        context.getString(R.string.set_dial_order),

                        )
                )
            }

            if (sdk.funcTable.setSetV3Weather) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWEATHERV3,
                        context.getString(R.string.set_weather_v3)
                    )
                )
            }



            if (sdk.funcTable.getMultiDial) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWATCHFACEDATA,
                        context.getString(R.string.setwatchfacedata)
                    )
                )
            }

            if (sdk.funcTable.setSetNotificationStatus) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETNOTIFICATIONSTATUS,
                        context.getString(R.string.setnotificationstatus)
                    )
                )
            }

            if (sdk.funcTable.setSetFitnessGuidance) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETFITNESSGUIDANCE,
                        context.getString(R.string.setfitnessguidance)
                    )
                )
            }

            if (sdk.funcTable.setScientificSleepSwitch) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSCIENTIFICSLEEPSWITCH,
                        context.getString(R.string.setscientificsleepswitch),
                    )
                )
            }

            if (sdk.funcTable.syncV3Noise) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETV3NOISE,
                        context.resources.getString(R.string.setv3noise)
                    )
                )
            }

            if (sdk.funcTable.setSmartHeartRate) {

                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETHEARTRATEMODESMART,
                        context.getString(R.string.setheartratemodesmart)
                    )
                )
            }

            if (sdk.funcTable.setSetPhoneVoice) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBLEVOICE,
                        context.getString(R.string.setblevoiceble)
                    )
                )
            }

            if (sdk.funcTable.setSedentariness) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETLONGSIT,
                        context.getString(R.string.setlongsit)
                    )
                )
            }

            if (sdk.funcTable.supportSetAntilost) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETLOSTFIND,
                        context.getString(R.string.setlostfind)
                    )
                )
            }


            if (sdk.funcTable.syncTimeLine) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSPORTMODESELECT,
                        context.getString(R.string.setsportmodeselect)
                    )
                )
            }

            if (sdk.funcTable.setSpo2Data) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSPO2SWITCH,
                        context.getString(R.string.setspo2switch)
                    )
                )
            }


            if (sdk.funcTable.setSyncContact && sdk.funcTable.reminderCallContact) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSYNCCONTACT,
                        context.getString(R.string.setsynccontact)
                    )
                )
            }


            if (sdk.funcTable.setBleControlMusic) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.MUSICCONTROL,
                        context.getString(R.string.musiccontrol)
                    )
                )

                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.MUSICSTART,
                        context.resources.getString(R.string.music_start)
                    )
                )

                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.MUSICSTOP,
                        context.resources.getString(R.string.music_stop)
                    )
                )
            }


            if (sdk.funcTable.setScheduleReminder) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSCHEDULERREMINDERV3,
                        context.getString(R.string.setschedulerreminderv3)
                    )
                )
            }

            if (sdk.funcTable.getSportsTypeV3) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SET100SPORTSORTV3,
                        context.getString(R.string.set100sportsortv3)
                    )
                )
            }

            if (sdk.funcTable.getSportsTypeV3) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETVOICEREPLYTXTV3,
                        context.getString(R.string.setvoicereplytxtv3)
                    )
                )
            }

            if (sdk.funcTable.getFindPhone) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETFINDPHONE,
                        context.getString(R.string.setfindphone)
                    )
                )
            }
            if (sdk.funcTable.supportSetOnetouchCalling) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETONEKEYSOS,
                        context.getString(R.string.setonekeysos)
                    )
                )
            }

            if (sdk.funcTable.setSetV3Weather) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWEATHERSWITCH,
                        context.getString(R.string.setweatherswitch)
                    )
                )
            }

            if (sdk.funcTable.setSetUnreadAppReminder) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETUNREADAPPREMINDER,
                        context.getString(R.string.setunreadappreminder)
                    )
                )
            }

            if (sdk.funcTable.setWeatherCity) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWEATHERCITYNAME,
                        context.getString(R.string.setweathercityname)
                    )
                )
            }

            if (sdk.funcTable.setSportModeSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSPORTMODESORT,
                        context.getString(R.string.setsportmodesort)
                    )
                )
            }

            if (sdk.funcTable.setRespirationRate) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETRRESPIRATETURN,
                        context.getString(R.string.setrrespirateturn)
                    )
                )
            }
            if (sdk.funcTable.syncV3BodyPower) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBODYPOWERTURN,
                        context.getString(R.string.setbodypowerturn)
                    )
                )
            }

            if (sdk.funcTable.setSetV3WorldTime) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWORLDTIMEV3,
                        context.resources.getString(R.string.setworldtimev3)
                    )
                )
            }

            if (sdk.funcTable.setHistoryMenstrual) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.GETHISTORICALMENSTRUATION,
                        context.resources.getString(R.string.set_historical_menstruation)
                    )
                )

            }

            if (sdk.funcTable.setDoNotDisturb) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETNOTDISTURB,
                        context.resources.getString(R.string.set_notDisturb)
                    )
                )
            }

            if (sdk.funcTable.setMenuListMain7) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMENULIST,
                        context.resources.getString(R.string.set_menu_list)
                    )
                )
            }


            if (sdk.funcTable.setNoReminderOnDrinkReminder && sdk.funcTable.setDrinkWaterAddNotifyFlag) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETDRINKWATERREMIND,
                        context.resources.getString(R.string.set_drinkwater_remind)
                    )
                )
            }
            if (sdk.funcTable.setPressureData) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSTRESSSWITCH,
                        context.resources.getString(R.string.set_stress_switch)
                    )
                )
            }

            if (sdk.funcTable.setMenstruation) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMENSTRUATIONREMIND,
                        context.resources.getString(R.string.set_menstrual_period)
                    )
                )
            }
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


            if (sdk.funcTable.setActivitySwitch) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETACTIVITYSWITCH,
                        context.getString(R.string.set_activity_switch)
                    )
                )
            }

            if (sdk.funcTable.setSetMainUiSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMAINUISORTV3,
                        context.getString(R.string.setmainuisortv3)
                    )
                )
            }
            if (sdk.funcTable.getSupportV3BleMusic) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETMUSICOPERATE,
                        context.getString(R.string.setmusicoperate)

                    )
                )
            }
            //----------------------------
            if (sdk.funcTable.syncHeartRateMonitor) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETHEARTMODE,
                        context.getString(R.string.setheartmode)
                    )
                )
            }
            if (sdk.funcTable.setMsgAllSwitch) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETNOTIFICATIONCENTER,
                        context.getString(R.string.setnotificationcenter)
                    )
                )
            }
            if (sdk.funcTable.supportSetWeatherDataV2) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWEATHERDATA,
                        context.getString(R.string.setweatherdata)
                    )
                )
            }
            if (sdk.funcTable.getSupportBpSetOrMeasurementV2) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPMEASUREMENT,
                        context.getString(R.string.setbpmeasurement)
                    ),
                )
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPCALIBRATION,
                        context.getString(R.string.setbpcalibration)
                    )
                )
            }
            if (sdk.funcTable.setHandWashReminder) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETHANDWASHINGREMINDER,
                        context.getString(R.string.sethandwashingreminder)
                    )
                )
            }
            if (sdk.funcTable.setSupportV3Bp) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBPCALCONTROLV3,
                        context.getString(R.string.setbpcalcontrolv3)
                    )
                )
            }
            if (sdk.funcTable.setSet20SportParamSort) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETBASESPORTPARAMSORTV3,
                        context.getString(R.string.setbasesportparamsortv3)
                    )
                )
            }
            if (sdk.funcTable.setWatchPhotoPositionMove) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETWALLPAPERDIALREPLYV3,
                        context.getString(R.string.setwallpaperdialreplyv3)
                    )
                )
            }
            if (sdk.funcTable.setSupportSetCallQuickReplyOnOff) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETCALLQUICKREPLYONOFF,
                        context.resources.getString(R.string.set_call_quick_reply_on_off)
                    ),
                )
            }
            if (sdk.funcTable.getSupportSetVoiceAssistantStatus) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETVOICEASSISTANTONOFF,
                        context.resources.getString(R.string.set_voice_assistant_on_off)
                    )
                )
            }

            if (sdk.funcTable.getSportsTypeV3) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSPORTSORTV3,
                        context.resources.getString(R.string.set_sport_sortV3)
                    )
                )
            }

            if (sdk.funcTable.setSetStressCalibration) {
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETSTRESSCALIBRATION,
                        context.getString(R.string.setstresscalibration)
                    )
                )
            }

            if (sdk.funcTable.setSupportControlMiniProgram) {
                //获取小程序列表
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETAPPLETCONTROL,
                        context.getString(R.string.getapplet)
                    )
                )
                //设置之前需要先获取小程序列表，然后根据获取的小程序列表名称进行设置操作
                mutableListOf.add(
                    SetFuncData(
                        CustomEvtType.SETAPPLETCONTROL,
                        context.getString(R.string.setapplet)
                    )
                )
            }

            return mutableListOf

        }
    }
}

