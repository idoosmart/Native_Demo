package com.example.example_android.activity

import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.CmdSet
import com.example.example_android.data.CustomEvtType
import com.example.example_android.data.SetFuncData
import com.google.gson.GsonBuilder
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
import com.idosmart.model.IDOGpsControlParamModel
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
import com.idosmart.model.IDONoticeMessageParamModel
import com.idosmart.model.IDONoticeMessageStateParamModel
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
import com.idosmart.model.IDOWalkRemindTimesParamModel
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
import kotlinx.android.synthetic.main.layout_comme_send_data.*
import kotlinx.android.synthetic.main.layout_comme_send_data.view.*
import java.time.LocalDateTime

class SetFunctionDetailActivity : BaseActivity() {
    private var type: Int = SetFuntionActivity.setDateTime
    private var setFuncData: SetFuncData? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_send_data
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun initView() {
        super.initView()
        setFuncData =
            intent.getSerializableExtra(SetFuntionActivity.SET_FUNCTION_DATA) as SetFuncData
        supportActionBar?.setTitle(setFuncData?.title)
        val myType = setFuncData?.type

        send_btn.setOnClickListener {
            when (myType) {
                CustomEvtType.SETALARMV3 -> setAlarmV3()
                CustomEvtType.SETWATCHDIALSORT -> setWatchDialSort()
                CustomEvtType.SETSENDRUNPLAN -> setSendRunPlan()
                CustomEvtType.SETWALKREMIND -> setWalkReminder()
//                CustomEvtType.SETWALKREMINDTIMES -> Cmds.setWalkRemindTimes(idoBaseModel as IDOWalkRemindTimesParamModel)
                CustomEvtType.SETWEATHERV3 -> setWeatherV3()
//                CustomEvtType.SETNOTICEMESSAGESTATE -> Cmds.setNoticeMessageState(idoBaseModel as IDONoticeMessageStateParamModel)
                CustomEvtType.SETMAINUISORTV3 -> setMainUISortV3()
                CustomEvtType.SETWATCHFACEDATA -> setWatchFaceData()
                CustomEvtType.SETMUSICOPERATE -> setMusicOperate()
                CustomEvtType.SETNOTIFICATIONSTATUS -> setNotificationStatus()
                CustomEvtType.SETFITNESSGUIDANCE -> setFitnessGuidance()
                CustomEvtType.SETSCIENTIFICSLEEPSWITCH -> setScientificSleepSwitch()
                CustomEvtType.SETTEMPERATURESWITCH -> setTemperatureSwitch()
                CustomEvtType.SETV3NOISE -> setV3Noise()
                CustomEvtType.SETHEARTMODE -> setHeartMode()
                CustomEvtType.SETHEARTRATEMODESMART -> setHeartRateModeSmart()
                CustomEvtType.SETTAKINGMEDICINEREMINDER -> setTakingMedicineReminder()
                CustomEvtType.SETBLEVOICE -> setBleVoice()
                CustomEvtType.SETLONGSIT -> setLongSit()
                CustomEvtType.SETLOSTFIND -> setLostFind()
                CustomEvtType.SETSPORTGOAL -> setSportGoal()
                CustomEvtType.SETUNIT -> setUnit()
//            CustomEvtType.SETNOTIFICATIONCENTER -> Cmds.setNotificationCenter(idoBaseModel as IDONotificationCenterParamModel)
                CustomEvtType.SETUPHANDGESTURE -> setUpHandGesture()
                CustomEvtType.SETMUSICONOFF -> setMusicOnOff()
                CustomEvtType.SETDISPLAYMODE -> setDisplayMode()
                CustomEvtType.SETSPORTMODESELECT -> setSportModeSelect()
                CustomEvtType.SETSLEEPPERIOD -> setSleepPeriod()
                CustomEvtType.SETWEATHERDATA -> setWeatherData()
                CustomEvtType.SETWEATHERSUNTIME -> setWeatherSunTime()
                CustomEvtType.SETWATCHDIAL -> setWatchDial()
                CustomEvtType.SETSHORTCUT -> setShortcut()
                CustomEvtType.SETBPCALIBRATION -> setBpCalibration()
                CustomEvtType.SETBPMEASUREMENT -> setBpMeasurement()
                CustomEvtType.SETSTRESSCALIBRATION -> setStressCalibration()
                CustomEvtType.SETSPO2SWITCH -> setSpo2Switch()
                CustomEvtType.SETHANDWASHINGREMINDER -> setHandWashingReminder()
                CustomEvtType.SETNOTICEAPPNAME -> setNoticeAppName()
                CustomEvtType.SETSYNCCONTACT -> setSyncContact()
                CustomEvtType.MUSICCONTROL -> musicControl()
                CustomEvtType.SETBPCALCONTROLV3 -> setBpCalControlV3()
                CustomEvtType.SETAPPLETCONTROL -> setAppletControl()
                CustomEvtType.SETBASESPORTPARAMSORTV3 -> setSportParamSort()
                CustomEvtType.SETSCHEDULERREMINDERV3 -> setSchedulerReminder()
                CustomEvtType.SET100SPORTSORTV3 -> setSport100Sort()
                CustomEvtType.SETWALLPAPERDIALREPLYV3 -> setWallpaperDialReply()
                CustomEvtType.SETVOICEREPLYTXTV3 -> setVoiceReplyText()
                CustomEvtType.SETTIME -> setDateTime()
                CustomEvtType.SETFINDPHONE -> Cmds.setFindPhone(true)
                CustomEvtType.SETWEATHERSWITCH -> {
                    Cmds.setWeatherSwitch(true).apply {
                        paramter_tv.text=json
                    }.send {
                        if (it.error.code == 0) {
                            tv_response.text = it.res?.toJsonString()
                        } else {
                            tv_response.text = "设置失败 / Setup failure"
                        }
                    }
                }
                CustomEvtType.SETONEKEYSOS -> Cmds.setOnekeySOS(false, 0)
                CustomEvtType.SETUNREADAPPREMINDER -> Cmds.setUnreadAppReminder(true)
                CustomEvtType.SETWEATHERCITYNAME -> Cmds.setWeatherCityName("dsdgf")
                CustomEvtType.SETRRESPIRATETURN -> Cmds.setRRespiRateTurn(false)
                CustomEvtType.SETBODYPOWERTURN -> Cmds.setBodyPowerTurn(false)
                CustomEvtType.SETSCREENBRIGHTNESS -> setScreenBrightness()
                CustomEvtType.SETACTIVITYSWITCH -> setActivitySwitch()
                CustomEvtType.SETHEARTRATEINTERVAL -> setHeartRateInterval()
                CustomEvtType.SETMENSTRUATION -> setMenstruation()
                CustomEvtType.SETCALORIEDISTANCEGOAL -> setCalorieDistanceGoal()
                CustomEvtType.SETWORLDTIMEV3 -> setWorldTimeV3()
                CustomEvtType.SETHAND -> Cmds.setHand(false)
                CustomEvtType.SETLONGCITYNAMEV3 -> setLongCityNameV3()
                CustomEvtType.GETHISTORICALMENSTRUATION -> setHistoricalMenstruation()
                CustomEvtType.SETSPORTSORTV3 -> setSportSortV3()
                CustomEvtType.SETUSERINFO -> setUserInfo()
                CustomEvtType.SETNOTDISTURB -> setNotDisturb()
                CustomEvtType.SETMENSTRUATIONREMIND -> setMenstruationRemind()
                CustomEvtType.SETSTRESSSWITCH -> setStressSwitch()
                CustomEvtType.SETDRINKWATERREMIND -> setDrinkWaterRemind()
                CustomEvtType.SETOVERFINDPHONE -> Cmds.setOverFindPhone()
                CustomEvtType.SETMENULIST -> setMenuList()
                CustomEvtType.SETALARM -> setAlarmV3()
                CustomEvtType.MUSICSTART -> Cmds.musicStart()
                CustomEvtType.MUSICSTOP -> Cmds.musicStop()
                CustomEvtType.SETCALLQUICKREPLYONOFF -> setCallQuickReplyOnOff()
                CustomEvtType.SETVOICEASSISTANTONOFF -> setVoiceAssistantOnOff()
                CustomEvtType.SETFASTMSGUPDATE -> setFastMsgUpdate()
                CustomEvtType.SETFASTMSGV3 -> setDefaultQuickMsgReplyList()
                CustomEvtType.SETSPORTMODESORT -> setSportModeSort()
                CustomEvtType.NOTICEMESSAGEV3 -> noticeMessageV3()

                else -> {
                    null
                }
            }
        }
    }

    /**
     *IDONoticeMessageParamModel
     * Attribute type declaration
     * evtType Int Indicates the message application type
     * msgID Int Message ID, which is used for quick reply. 0 indicates that quick reply is not supported
     * supportAnswering Bool Answering Answering: 1
     * Answer not supported: 0
     * supportMute Bool Mute support: 1
     * Mute: 0 is not supported
     * supportHangUp Bool HangUp support: 1
     * Hang-up: 0 is not supported
     * contact String Contact name (maximum 63 bytes)
     * phoneNumber String Phone number (maximum 31 bytes)
     * dataText String Message content (Max. 249 bytes)
     *
     * */
    private fun noticeMessageV3() {
        var param =
            IDONoticeMessageParamModel(0x01, 0,
                true, true, true,
                "Jeffry", "13200000000", "hello")


        var noticeMessageV3 = Cmds.noticeMessageV3(param)
        noticeMessageV3.send {

            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = noticeMessageV3.json
    }

    /**
     *  app下发跑步计划(运动计划)
     * [IDORunPlanParamModel]
     * 属性	类型	说明
     * verison	Int	协议库版本号
     * operate	Int	操作
     * 1：启动计划
     * 2：发送计划数据
     * 3：结束计划
     * 4：查询运行计划
     * type	Int	计划类型
     * 1：3公里跑步计划
     * 2：5公里跑步计划
     * 3：10公里跑步计划
     * 4：半程马拉松训练（第二阶段）
     * 5：马拉松训练（阶段2）
     * dayNum	Int	计划天数
     * 运行2天时适用
     * year	Int	运动计划开始时间
     * month	Int	运动计划开始时间
     * day	Int	运动计划开始时间
     * hour	Int	运动计划开始时间
     * min	Int	运动计划开始时间
     * sec	Int	运动计划开始时间
     * items	List    [IDOGpsInfoModelItem] 集合
     *
     * [IDOGpsInfoModelItem]
     * 属性	类型	说明
     * type	Int	训练类型
     * 186：休息计划
     * 187：户外跑步计划
     * 188：室内跑步计划
     * 189：室内健身计划
     * num	Int	动作次数
     * 注意：休息时动作次数为零，其他动作时动作次数非零
     * items	List    [IDOItemItem]集合
     * IDOItemItem
     * 属性	类型	说明
     * type	Int	动作类型
     * 1：快走
     * 2：慢跑
     * 3：中速跑
     * 4：快跑
     * time	Int	目标时间 单位：秒
     * heightHeart	Int	低心率范围
     * lowHeart	Int	高心率范围
     *
     *Running plan issued by app (Exercise plan)
     * [IDORunPlanParamModel]
     * Attribute type declaration
     * verison Int Version number of the protocol library
     * operate Int Operate int
     * 1: Start the plan
     * 2: Send schedule data
     * 3: End the plan
     * 4: Query the running plan
     * type Int Type of the plan
     * 1:3km run program
     * 2:5km run program
     * 3:10km run program
     * 4: Half Marathon Training (Stage 2)
     * 5: Marathon Training (Stage 2)
     * dayNum Int Number of scheduled days
     * Applicable for 2 days of operation
     * year Int Start time of the exercise plan
     * month Int Start time of an exercise plan
     * day Int Start time of the exercise schedule
     * hour Int Indicates the start time of the exercise plan
     * min Int Start time of the exercise schedule
     * sec Int Start time of the exercise program
     * items	List    [IDOGpsInfoModelItem]
     * [IDOGpsInfoModelItem]
     * Attribute type declaration
     * type Int Training type
     * 186: Rest plan
     * 187: Outdoor running program
     * 188: Indoor running program
     * 189: Indoor fitness program
     * num Int Number of actions
     * Note: The number of movements at rest is zero, and the number of movements at other movements is non-zero
     * items List IDOItemItem collection
     * [IDOItemItem]
     * Attribute type declaration
     * type Int Action type
     * 1: Let's go
     * 2: Jogging
     * 3: Run at a moderate pace
     * 4: Run fast
     * time Int Time unit: second
     * heightHeart Int Heightheart int Low heart rate range
     * lowHeart Int High heart rate range
     *
     * */

    private fun setSendRunPlan() {
        var sendRunPlan = Cmds.setSendRunPlan(
            IDORunPlanParamModel(
                operate = 1,
                type = 1,
                year = 2020,
                month = 12,
                day = 26,
                hour = 17,
                min = 36,
                sec = 0,
                dayNum = 1,
                items = listOf(
                    IDOGpsInfoModelItem(
                        type = 186, num = 1, items = listOf(
                            IDOItemItem(
                                type = 1, time = 200, heightHeart = 110, lowHeart = 80
                            )
                        )
                    )
                )
            )
        )
        sendRunPlan.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sendRunPlan.json

    }

    /**
     * 设置走动提醒
     * [IDOWalkRemindModel]
     * 属性	类型	说明
     * onOff	Int	0 关，1 开
     * goalStep	Int	每小时标步数（废弃）
     * startHour	Int	开始时间（小时）
     * startMinute	Int	开始时间（分钟）
     * endHour	Int	结束时间（小时）
     * endMinute	Int	结束时间（分钟）
     * repeats	Set	重复IDOWeek
     * isOpen	Bool	重复开关
     * goalTime	Int	目标时间（小时）（废弃）
     * notifyFlag	Int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：关闭通知
     * 需要固件启用setWalkReminderAddNotify
     * doNotDisturbOnOff	Int	请勿打扰开关
     * 0 关闭
     * 1 开启
     * 需要固件启用 getSupportSetGetNoReminderOnWalkReminderV2
     * noDisturbStartHour	Int	请勿打扰开始时间（小时）
     * 需要固件启用 getSupportSetGetNoReminderOnWalkReminderV2
     * noDisturbStartMinute	Int	请勿打扰开始时间（分钟）
     * 需要固件启用 getSupportSetGetNoReminderOnWalkReminderV2
     * noDisturbEndHour	Int	请勿打扰结束时间（小时）
     * 需要固件启用 getSupportSetGetNoReminderOnWalkReminderV2
     * noDisturbEndMinute	Int	请勿打扰结束时间（分钟）
     * 需要固件启用 getSupportSetGetNoReminderOnWalkReminderV2
     *
     *
     * Set a walk alert
     * [IDOWalkRemindModel]
     * Attribute type declaration
     * onOff Int 0 off, 1 on
     * goalStep Int Number of steps per hour (deprecated)
     * startHour Int Start time (hours)
     * startMinute Int Start time (minutes)
     * endHour Int End time (hour)
     * endMinute Int End time (minutes)
     * repeats Set IDOWeek
     * isOpen Bool Repeat switch
     * goalTime Int Goal time (hours) (deprecated)
     * notifyFlag Int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * setWalkReminderAddNotify needs to be enabled in the firmware
     * doNotDisturbOnOff Int Do NotDisturb switch
     * 0 off
     * 1 Turn on
     * Need to enable getSupportSetGetNoReminderOnWalkReminderV2 firmware
     * noDisturbStartHour Int Do Not DisturbStart Time (hour)
     * Need to enable getSupportSetGetNoReminderOnWalkReminderV2 firmware
     * noDisturbStartMinute Int Do Not DisturbStart Time (minute)
     * Need to enable getSupportSetGetNoReminderOnWalkReminderV2 firmware
     * noDisturbEndHour Int Do Not DisturbEnd Time (hour)
     * Need to enable getSupportSetGetNoReminderOnWalkReminderV2 firmware
     * noDisturbEndMinute Int Do Not DisturbEnd Time (minute)
     * Need to enable getSupportSetGetNoReminderOnWalkReminderV2 firmware
     * */

    private fun setWalkReminder() {
        var walkReminder = Cmds.setWalkReminder(
            IDOWalkRemindModel(
                1,
                2000,
                14,
                0,
                20,
                0,
                hashSetOf(IDOWeek.MONDAY, IDOWeek.SUNDAY),
                60,
                1,
                0,
                0,
                0,
                0,
                0
            )
        )
        walkReminder.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = walkReminder.json


    }

    /**
     * 设置表盘顺序
     * [IDOWatchDialSortParamModel]
     * 属性	类型	说明
     * sortItemNumb	Int	表盘排序列表中的项目数
     * pSortItem    [IDOWatchDialSortItem]	表盘排序列表内容
     *
     * [IDOWatchDialSortItem]
     * 属性	类型	说明
     * type	Int	手表表盘类型 1：普通表盘，2：壁纸表盘，3：云表盘
     * sortNumber	Int	序列号，从0开始，不超过支持的手表表盘总数
     * name	String	表盘 ID，最大 29 字节
     *
     * Set the dial order
     * [IDOWatchDialSortParamModel]
     * Attribute type declaration
     * sortItemNumb Int Number of items in the dial sorting list
     * pSortItem [IDOWatchDialSortItem] Dial sorting list content
     * [IDOWatchDialSortItem]
     * Attribute type declaration
     * type Int Type 1: common dial, 2: wallpaper dial, 3: cloud dial
     * sortNumber Int Indicates the serial number starting from 0 and cannot exceed the total number of supported watch dials
     * name String Dial ID. The value is a maximum of 29 bytes
     *
     * */

    private fun setWatchDialSort() {

        Cmds.getWatchListV2().send { it ->
            var size = it.res?.items?.size
            var list = mutableListOf<IDOWatchDialSortItem>()
            var i = 0
            it.res?.items?.forEach {
                list.add(IDOWatchDialSortItem(1, i++, it.fileName))
            }
            var watchDialSort = Cmds.setWatchDialSort(
                IDOWatchDialSortParamModel(size!!, list)
            )
            watchDialSort.send {
                if (it.error.code == 0) {
                    tv_response.text = it.res?.toJsonString()
                } else {
                    tv_response.text = "设置失败 / Setup failure"
                }
            }
            paramter_tv.text = watchDialSort.json
        }


    }

    /**
     * v3 下发v3天气协议
     *
     * [IDOWeatherV3ParamModel]
     * 属性	类型	说明
     * month	int	服务器最新一次同步的月
     * day	int	服务器最后一次同步的日
     * hour	int	服务器最后一次同步的时
     * min	int	服务器最后一次同步的分
     * sec	int	服务器最后一次同步的秒
     * week	Int	星期几
     * bit0：星期一
     * bit1：星期二，依此类推直到星期日
     * weatherType	Int	天气类型
     * 0：其他
     * 1：晴
     * 2：多云
     * 3：阴
     * 4：雨
     * 5：大雨
     * 6 ：雷暴
     * 7：雪
     * 8：雨夹雪
     * 9：台风
     * 10：沙尘暴
     * 11：夜间晴
     * 12：夜间多云
     * 13：热
     * 14：冷
     * 15：微风
     * 16：大风
     * 17：阴霾
     * 18：阵雨
     * 19：阴转晴< br/>48：雷声
     * 49：冰雹
     * 50：风沙
     * 51：龙卷风（realme自定义天气类型idw02）
     * todayTmp	Int	当前温度（摄氏度）
     * 对于负温度，将温度加 100 并传输
     * todayMaxTemp	Int	最高温度（摄氏度）
     * 对于负温度，将温度加 100 并传输
     * todayMinTemp	Int	最低温度（摄氏度）
     * 对于负温度，将温度加 100 并传输
     * cityName	String	城市名称
     * 最多 74 字节
     * airQuality	Int	空气质量
     * 乘以10进行传输
     * precipitationProbability	Int	降水概率
     * 0-100%
     * humidity	int	湿度
     * todayUvIntensity	int	紫外线强度
     * 扩大10倍传输
     * windSpeed	int	风速
     * windSpeed	int	风力
     * sunriseHour	int	日出时间 时
     * sunriseMin	int	日出时间 分
     * sunsetHour	int	日出时间 时
     * sunsetMin	int	日出时间 分
     * sunriseItemNum	Int	日出日落时间详情数
     * 目前最大天数设置为7
     * airGradeItem	String	空气质量等级内容
     * hoursWeatherItems	集合	未来48小时的天气数据集合（可选）
     * [IDOHoursWeatherItem]
     * futureItems	集合	未来七天的天气数据（可选），不需要包含当天数据
     * [IDOFutureItem]
     * sunriseItem	集合	日出日落时间详情（可选），需要包含当天数据
     * [IDOSunriseItem]
     * [IDOHoursWeatherItem]
     * 属性	类型	说明
     * weatherType	int	天气类型
     * temperature	int	温度
     * 温度加100传输
     * probability	int	降水出现的概率
     * 0-100 百分比
     * [IDOFutureItem]
     * 属性	类型	说明
     * weatherType	int	天气类型
     * maxTemp	int	最大温度
     * 温度加100传输
     * minTemp	int	最小温度
     * 温度加100传输
     * [IDOSunriseItem]
     * 属性	类型	说明
     * sunriseHour	int	日出时间 时
     * version为1无效
     * sunriseMin	int	日出时间 分
     * version为1无效
     * sunsetHour	int	日落时间 时
     * version为1无效
     * sunsetMin	int	日落时间 分
     * version为1无效
     *
     *
     * v3 Delivers the v3 weather protocol
     * [IDOWeatherV3ParamModel]
     * Attribute type declaration
     * month int Month of the latest synchronization on the server
     * day int Day of the last synchronization on the server
     * hour int Indicates the last synchronization time on the server
     * min int Minutes of the last synchronization on the server
     * sec int Seconds of the last synchronization on the server
     * week Int Day of the week
     * bit0: Monday
     * bit1: Tuesday, and so on until Sunday
     * weatherType Int Weather type
     * 0: other
     * 1: Clear
     * 2: Cloudy
     * 3: Yin
     * 4: Rain
     * 5: Heavy rain
     * 6: Thunderstorms
     * 7: Snow
     * 8: Sleet
     * 9: Typhoon
     * 10: Dust storm
     * 11: Clear at night
     * 12: Cloudy at night
     * 13: Hot
     * 14: Cold
     * 15: Light breeze
     * 16: Strong Wind
     * 17: Haze
     * 18: Shower
     * 19: Cloudy to sunny < br/>48: thunder
     * 49: Hail
     * 50: Wind and sand
     * 51: Tornado (realme Custom Weather Type idw02)
     * todayTmp Int Current temperature (degrees Celsius)
     * For negative temperatures, add 100 to the temperature and transmit
     * todayMaxTemp Int Maximum temperature (Celsius)
     * For negative temperatures, add 100 to the temperature and transmit
     * todayMinTemp Int Minimum Temperature (Celsius)
     * For negative temperatures, add 100 to the temperature and transmit
     * cityName String City name
     * Up to 74 bytes
     * airQuality Int Air quality
     * Multiply by 10 for transmission
     * precipitationProbability Int Precipitation probability
     * 0-100%
     * humidity int Humidity int
     * todayUvIntensity int UV intensity
     * Expand transmission by a factor of 10
     * windSpeed int Wind speed
     * sunriseHour int Sunrise time
     * sunriseMin int Sunrise time
     * sunsetHour int Sunrise time
     * sunsetMin int Sunrise time
     * sunriseItemNum Int Detailed number of sunrise and sunset times
     * The current maximum number of days is set to 7
     * airGradeItem String Air quality level content
     * hoursWeatherItems Collection A collection of weather data for the next 48 hours (optional)
     * [IDOHoursWeatherItem]
     * futureItems Collects weather data for the next seven days (optional). It is not necessary to include the current day's data
     * [IDOFutureItem]
     * sunriseItem Collection sunrise and sunset time details (optional), which must contain the current day data
     * [IDOSunriseItem]
     * [IDOHoursWeatherItem]
     * Attribute type declaration
     * weatherType int Weather type
     * temperature int Temperature
     * Temperature plus 100 transmission
     * probability int The probability that the temperature occurs
     * 0-100 percent
     * [IDOFutureItem]
     * Attribute type declaration
     * weatherType int Weather type
     * maxTemp int Maximum temperature
     * Temperature plus 100 transmission
     * minTemp int Minimum temperature
     * Temperature plus 100 transmission
     * [IDOSunriseItem]
     * Attribute type declaration
     * sunriseHour int Sunrise time
     * version 1 is invalid
     * sunriseMin int Sunrise time
     * version 1 is invalid
     * sunsetHour int Indicates the sunset time
     * version 1 is invalid
     * sunsetMin int Sunset time
     * version 1 is invalid
     */

    private fun setWeatherV3() {
        // 获取当前时间
        val now = LocalDateTime.now()
        val weatherV3 = Cmds.setWeatherV3(
            IDOWeatherV3ParamModel(
                now.monthValue,
                now.dayOfMonth,
                now.hour,
                now.minute,
                now.second,
                now.dayOfWeek.value,
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
                10,
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
                        sunriseHour = 5,
                        sunriseMin = 35,
                        sunsetHour = 15,
                        sunsetMin = 35
                    ), IDOSunriseItem(
                        sunriseHour = 6,
                        sunriseMin = 36,
                        sunsetHour = 16,
                        sunsetMin = 36
                    ), IDOSunriseItem(
                        sunriseHour = 7,
                        sunriseMin = 37,
                        sunsetHour = 17,
                        sunsetMin = 37
                    )
                ),
                listOf(23,24,25,26,27,28,29),
                listOf(51,52,53,54,55,56,57)
            )
        )
        weatherV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = weatherV3.json

    }


    /**
     * v3 设置主界面控件排序
     * [IDOMainUISortParamModel]
     * 属性	类型	说明
     * operate	Int	操作
     * 0：无效 1：查询 2：设置
     * locationX	Int	坐标x轴，从1开始
     * locationY	Int	坐标y轴，从1开始
     * 一个y轴代表一个水平网格
     * sizeType	Int	0：无效 1：大图标 2：小图标
     * widgetsType	Int	控制类型
     * 0：无效
     * 1：周/日期
     * 2：步数
     * 3：距离
     * 4：卡路里
     * 5：心率
     * 6：电池
     * items	List	int 集合
     *
     * v3 Sets the home screen control sort
     * [IDOMainUISortParamModel]
     * Attribute type declaration
     * operate Int Operate int
     * 0: invalid 1: query 2: set
     * locationX Int The X-axis, starting at 1
     * locationY Int coordinates on the Y-axis, starting at 1
     * A y axis represents a horizontal grid
     * sizeType Int 0: invalid 1: large icon 2: small icon
     * widgetsType Int Control type
     * 0: invalid
     * 1: Week/date
     * 2: number of steps
     * 3: Distance
     * 4: Calories
     * 5: Heart rate
     * 6: Battery
     * items List int collection
     * */
    private fun setMainUISortV3() {
        var mainUISortV3 = Cmds.setMainUISortV3(
            IDOMainUISortParamModel(
                2, listOf(1, 2, 3), 1, 1, 2, 1
            )
        )
        mainUISortV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = mainUISortV3.json

    }

    /**
     * 设置表盘
     * [IDOWatchFaceParamModel]
     * 属性	类型	说明
     * operate	Int	操作：
     * 0 - 查询当前使用的表盘
     * 1 - 设置表盘
     * 2 - 删除表盘
     * 3 - 动态请求空间设置对应的空间大小
     * fileName	String	表盘名称，最大29字节
     * watchFileSize	Int	未压缩的文件长度
     * 固件打开功能表getWatchDailSetAddSize后，应用程序需要发送该字段
     * 在表盘传输之前，固件需要分配相应的空间来保存，未压缩的文件长度需要传输的文件长度
     *
     * Dial setting
     * [IDOWatchFaceParamModel]
     * Attribute type declaration
     * operate Int Operation:
     * 0 - Queries the dial currently in use
     * 1 - Set the dial
     * 2 - Remove the dial
     * 3 - Dynamic Request Space Sets the corresponding space size
     * fileName String Dial name. The value is a maximum of 29 bytes
     * watchFileSize Int Uncompressed file length
     * After the firmware opens the menu getWatchDailSetAddSize, the application needs to send this field
     * Before the dial is transferred, the firmware needs to allocate the corresponding space to save, and the uncompressed file length needs to be the file length of the transfer
     * */
    private fun setWatchFaceData() {
        var watchFaceData = Cmds.setWatchFaceData(
            IDOWatchFaceParamModel(
                1, "w63.iwf", 2024
            )
        )
        watchFaceData.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = watchFaceData.json

    }

    /**
     * 手机app通过这个命令开关，实现通知应用状态设置
     * [IDONotificationStatusParamModel]
     * 属性	类型	说明
     * notifyFlag	Int	通知类型：
     * 1：允许通知
     * 2：静默通知
     * 3：禁用通知
     *
     * Mobile app through this command switch to achieve notification application status Settings
     * [IDONotificationStatusParamModel]
     * Attribute type declaration
     * notifyFlag Int Notification type:
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * */
    private fun setNotificationStatus() {
        var notificationStatus = Cmds.setNotificationStatus(IDONotificationStatusParamModel(1))
        notificationStatus.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = notificationStatus.json

    }

    /**
     * 健身指导
     * [IDOFitnessGuidanceParamModel]
     * 属性	类型	说明
     * mode	Int	健身指导模式开关
     * 1：开
     * 0：关
     * startHour	Int	开始时间
     * startMinute	Int	开始分钟
     * endHour	Int	结束时间
     * endMinute	Int	结束分钟
     * notifyFlag	Int	通知类型
     * 0：无效
     * 1：允许
     * 2：静默
     * 3：禁用
     * goMode	Int	移动开关提醒
     * 1：开
     * 0：关
     * repeats	Set	重复IDOWeek 集合
     * isOpen	Bool	总开关
     * targetSteps	Int	目标步数
     *
     * Fitness instruction
     * [IDOFitnessGuidanceParamModel]
     * Attribute type declaration
     * mode Int Fitness instruction mode switch
     * 1: On
     * 0: Off
     * startHour Int Start time
     * startMinute Int Start minute
     * endHour Int End time
     * endMinute Int Indicates the end minute
     * notifyFlag Int Indicates the notification type
     * 0: invalid
     * 1: Allow
     * 2: Silence
     * 3: Disable
     * goMode Int Mobile switch reminder
     * 1: On
     * 0: Off
     * repeats Set IDOWeek sets
     * isOpen Bool Main switch
     * targetSteps Int Number of target steps
     * */
    private fun setFitnessGuidance() {
        var fitnessGuidance = Cmds.setFitnessGuidance(
            IDOFitnessGuidanceParamModel(
                1, 9, 0, 18, 0, 1, 0, hashSetOf(
                    IDOWeek.MONDAY,
                    IDOWeek.TUESDAY,
                    IDOWeek.WEDNESDAY,
                    IDOWeek.THURSDAY,
                    IDOWeek.FRIDAY,
                    IDOWeek.SATURDAY,
                    IDOWeek.SUNDAY
                ), 2000
            )
        )
        fitnessGuidance.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }

        }
        paramter_tv.text = fitnessGuidance.json

    }

    /**
     *
     * 设置科学睡眠开关
     * [IDOScientificSleepSwitchParamModel]
     * 属性	类型	说明
     * mode	Int	模式
     * 2：科学睡眠
     * 1：正常睡眠
     * startHour	Int	开始时间 - 小时
     * startMinute	Int	开始时间 - 分钟
     * endHour	Int	结束时间 - 小时
     * endMinute	Int	结束时间-分钟
     *
     * Set the scientific sleep switch
     * [IDOScientificSleepSwitchParamModel]
     * Attribute type declaration
     * mode Int mode
     * 2: Scientific sleep
     * 1: Normal sleep
     * startHour Int Start time - hour
     * startMinute Int Start time - minutes
     * endHour Int End time - hour
     * endMinute Int End time - minute
     * */
    private fun setScientificSleepSwitch() {
        var scientificSleepSwitch = Cmds.setScientificSleepSwitch(
            IDOScientificSleepSwitchParamModel(
                1, 23, 23, 9, 0
            )
        )
        scientificSleepSwitch.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = scientificSleepSwitch.json

    }

    /**
     * 设置夜间体温开关
     * [IDOTemperatureSwitchParamModel]
     * 属性	类型	说明
     * mode	Int	模式：
     * 1：开
     * 0：关
     * startHour	Int	开始时间、小时
     * startMinute	Int	开始时间，分钟
     * endHour	Int	结束时间，小时
     * endMinute	Int	结束时间，分钟
     * unit	Int	温度单位设置：
     * 1：摄氏度
     * 2：华氏度
     *
     * Set the night temperature switch
     * [IDOTemperatureSwitchParamModel]
     * Attribute type declaration
     * mode Int mode:
     * 1: On
     * 0: Off
     * startHour Int Start time and hour
     * startMinute Int Start time (minutes)
     * endHour Int End time, hour
     * endMinute Int End time (minutes)
     * unit Int Temperature unit setting:
     * 1: Degree Celsius
     * 2: Degrees Fahrenheit
     * */
    private fun setTemperatureSwitch() {
        var temperatureSwitch = Cmds.setTemperatureSwitch(
            IDOTemperatureSwitchParamModel(
                1, 19, 0, 23, 0, 1
            )
        )
        temperatureSwitch.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = temperatureSwitch.json

    }

    /**
     * 环境音量的开关和阀值
     * [IDOV3NoiseParamModel]
     * 属性	类型	说明
     * mode	Int	全天环境噪音音量开关
     * 1：开
     * 0：关
     * startHour	Int	开始时间（小时）
     * startMinute	Int	开始时间（分钟）
     * endHour	Int	结束时间（小时）
     * endMinute	Int	结束时间（分钟）
     * highNoiseOnOff	Int	阈值开关
     * 1：开
     * 0：关
     * highNoiseValue	Int	阈值
     *
     * Ambient volume switch and threshold
     * [IDOV3NoiseParamModel]
     * Attribute type declaration
     * mode Int All-day ambient noise volume switch
     * 1: On
     * 0: Off
     * startHour Int Start time (hours)
     * startMinute Int Start time (minutes)
     * endHour Int End time (hour)
     * endMinute Int End time (minutes)
     * highNoiseOnOff Int Threshold switch
     * 1: On
     * 0: Off
     * highNoiseValue Int Threshold
     * */
    private fun setV3Noise() {
        var v3Noise = Cmds.setV3Noise(
            IDOV3NoiseParamModel(
                1, 15, 0, 20, 0, 1, 100
            )
        )
        v3Noise.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = v3Noise.json

    }

    /**
     * 设置心率模式
     * [IDOHeartModeParamModel]
     * 属性	类型	说明
     * updateTime	Int	更新时间为 Unix 时间戳（以秒为单位）。如果等于0，表示获取当前UTC时间戳。
     * mode	Int	模式
     * 0：关闭
     * 1：自动（5 分钟）
     * 2：连续监控（5 秒）
     * 3：手动模式（禁用自动）
     * 4：默认类型，设置后固件自动设置为默认模式
     * 5：设置相应的测量间隔
     * 6：智能心率模式（ID206）
     * 注意：
     * 1.如果配置了setSetV3HeartInterval函数，则模式0、模式1、模式2无效。
     * 2．使用快速设置进行配置时，设置 setSetV3HeartInterval 将激活模式 5
     * 3。设置连续心率时，如果配置了setSetV3HeartInterval函数，则对应的模式为模式5。
     * hasTimeRange	Int	是否有时间范围。 0：否，1：是
     * measurementInterval	Int	测量间隔（以秒为单位）
     * startHour	Int	开始时间，时
     * startMinute	Int	开始时间，分
     * endHour	Int	结束时间，时
     * endMinute	Int	结束时间，分
     * notifyFlag	Int	通知类型：
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：关闭通知
     * 注意：如果固件未启用v3HeartSetRateModeCustom，则此功能无效
     * highHeartMode	Int	1：开启智能高心率提醒
     * 0：关闭
     * 注：如果固件没有开启v3HeartSetRateModeCustom则此功能无效
     * lowHeartMode	Int	1：开启智能低心率提醒
     * 0：关闭
     * 注：如果固件没有开启v3HeartSetRateModeCustom则此功能无效
     * highHeartValue	Int	智能高心率提醒阈值
     * 注意：如果固件没有启用v3HeartSetRateModeCustom，则此功能无效
     * lowHeartValue	Int	智能低心率提醒阈值
     * 注意：如果固件没有启用v3HeartSetRateModeCustom，则此功能无效
     *
     * Set heart rate mode
     * [IDOHeartModeParamModel]
     * Attribute type declaration
     * updateTime Int The update time is the Unix timestamp in seconds. If the value is 0, the current UTC timestamp is obtained.
     * mode Int mode
     * 0: Off
     * 1: Automatic (5 minutes)
     * 2: Continuous monitoring (5 seconds)
     * 3: Manual mode (auto disabled)
     * 4: Default mode, which is automatically set to the default mode
     * 5: Set the corresponding measurement interval
     * 6: Intelligent Heart Rate Mode (ID206)
     * Attention:
     * 1. If the setSetV3HeartInterval function is configured, modes 0, 1, and 2 are invalid.
     * 2. When configuring with Quick Settings, setting setSetV3HeartInterval activates mode 5
     * 3. If the setSetV3HeartInterval function is configured when setting the continuous heart rate, the corresponding mode is mode 5.
     * hasTimeRange Int Specifies whether a time range exists. 0: no, 1: yes
     * measurementInterval Int Measurement interval in seconds
     * startHour Int Start time, when
     * startMinute Int Start time (minutes)
     * endHour Int End time, when
     * endMinute Int End time
     * notifyFlag Int Notification type:
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * Note: If the firmware does not have v3HeartSetRateModeCustom enabled, this feature is invalid
     * highHeartMode Int 1: Enables the intelligent high heart rate notification
     * 0: Off
     * Note: This feature is invalid if the firmware does not have v3HeartSetRateModeCustom enabled
     * lowHeartMode Int 1: Enables the smart low heart rate alert
     * 0: Off
     * Note: This feature is invalid if the firmware does not have v3HeartSetRateModeCustom enabled
     * highHeartValue Int Intelligent high heart rate alert threshold
     * Note: If the firmware does not have v3HeartSetRateModeCustom enabled, this feature is invalid
     * lowHeartValue Int Intelligent low heart rate alert threshold
     * Note: If the firmware does not have v3HeartSetRateModeCustom enabled, this feature is invalid
     * */
    private fun setHeartMode() {
        var heartMode = Cmds.setHeartMode(
            IDOHeartModeParamModel(
                8, 0, 0, 23, 59, 1, 4, 4, 49, 98, 99, 100, 101
            )
        )
        heartMode.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = heartMode.json


    }

    /**
     * 智能心率模式设置
     * [IDOHeartRateModeSmartParamModel]
     * 属性	类型	说明
     * mode	Int	开关
     * 0：关
     * 1：开
     * notifyFlag	Int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：禁用通知
     * highHeartMode	Int	1：启用智能高心率警报
     * 0：禁用
     * lowHeartMode	Int	1：启用智能低心率警报
     * 0：禁用
     * highHeartValue	Int	智能高心率警报阈值
     * lowHeartValue	Int	智能低心率警报阈值
     * startHour	Int	心率监测开始时间（小时）
     * startMinute	Int	心率监测开始时间（分钟）
     * endHour	Int	心率监测结束时间（小时）
     * endMinute	Int	心率监测结束时间（分钟）
     *
     * Smart heart rate mode setting
     * [IDOHeartRateModeSmartParamModel]
     * Attribute type declaration
     * mode Int switch
     * 0: Off
     * 1: On
     * notifyFlag Int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * highHeartMode Int 1: Enables intelligent high heart rate alert
     * 0: disable
     * lowHeartMode Int 1: Enables intelligent low heart rate alert
     * 0: disable
     * highHeartValue Int Intelligent high heart rate alarm threshold
     * lowHeartValue Int Intelligent low heart rate alarm threshold
     * startHour Int Heart Rate monitoring start time (hours)
     * startMinute Int Start time of heart rate monitoring (minutes)
     * endHour Int Heart rate monitoring end time (hour)
     * endMinute Int End time of Heart rate monitoring (minutes)
     * */
    private fun setHeartRateModeSmart() {
        var heartRateModeSmart = Cmds.setHeartRateModeSmart(
            IDOHeartRateModeSmartParamModel(
                1,
                1,
                1,
                0,
                120,
                50,
                0,
                0,
                23,
                59,
            )
        )
        runOnUiThread(Runnable {
            heartRateModeSmart.send {
                if (it.error.code == 0) {
                    tv_response.text = it.res?.toJsonString()
                } else {
                    tv_response.text = "设置失败 / Setup failure"
                }
            }
        })
        paramter_tv.text = heartRateModeSmart.json

    }

    /**
     * 设置吃药提醒
     * [IDOTakingMedicineReminderParamModel]
     * 属性	类型	说明
     * takingMedicineId	Int	ID范围为1到5
     * onOff	Int	0 表示关闭
     * 1 表示开启
     * startHour	Int	提醒的开始时间
     * startMinute	Int	提醒的起始分钟
     * endHour	Int	提醒结束时间
     * endMinute	Int	提醒的结束分钟
     * repeats	Set	重复IDOWeek
     * interval	Int	提醒间隔（分钟）
     * 默认为 60 分钟
     * doNotDisturbOnOff	Int	请勿打扰时间段开关
     * 0为关
     * 1为开
     * 默认为关
     * doNotDisturbStartHour	Int	请勿打扰开始时间
     * doNotDisturbStartMinute	Int	请勿打扰开始分钟
     * doNotDisturbEndHour	Int	请勿打扰结束时间
     * doNotDisturbEndMinute	Int	请勿打扰结束分钟
     *
     * Set a pill reminder
     * [IDOTakingMedicineReminderParamModel]
     * Attribute type declaration
     * takingMedicineId Int The ID ranges from 1 to 5
     * onOff Int 0 Indicates off
     * 1 indicates enable.
     * startHour Int Indicates the start time of the reminder
     * startMinute Int Indicates the start minute of the reminder
     * endHour Int Indicates the end time of reminding
     * endMinute Int Indicates the end minute of the reminder
     * repeats Set IDOWeek
     * interval Int Reminder interval (minutes)
     * The default value is 60 minutes
     * doNotDisturbOnOff Int Do not Disturb Time range switch
     * 0 is Off
     * 1 is on
     * Default to off
     * Donotdisturb starthour Int Do not disturb the start time
     * Donotdisturb startminute Int Do not disturb the start minute
     * Donotdisturb Endhour Int Do not disturb the end time
     * Donotdisturb endminute Int doNotDisturbEndMinute Int
     * */
    private fun setTakingMedicineReminder() {
        var takingMedicineReminder = Cmds.setTakingMedicineReminder(
            IDOTakingMedicineReminderParamModel(
                1, 0, 0, 23, 59, 1, hashSetOf(
                    IDOWeek.MONDAY,
                    IDOWeek.TUESDAY,
                    IDOWeek.WEDNESDAY,
                    IDOWeek.THURSDAY,
                    IDOWeek.FRIDAY,
                    IDOWeek.SATURDAY,
                    IDOWeek.SUNDAY
                ), 49, 98, 99, 100, 101, 9
            )
        )
        takingMedicineReminder.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = takingMedicineReminder.json

    }

    /**
     * 手机音量下发给ble
     * [IDOBleVoiceParamModel]
     * 属性	类型	说明
     * totalVolume	Int	总容积
     * currentVolume	Int	当前音量
     *
     * Send ble at phone volume
     * [IDOBleVoiceParamModel]
     * Attribute type declaration
     * totalVolume Int Total volume
     * currentVolume Int Current volume
     * */
    private fun setBleVoice() {
        var bleVoice = Cmds.setBleVoice(IDOBleVoiceParamModel(100, 85))
        bleVoice.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = bleVoice.json


    }

    /**
     * 设置久坐
     * [IDOLongSitParamModel]
     * 属性	类型	说明
     * startHour	Int	久坐提醒开始时间（小时）
     * startMinute	Int	久坐提醒开始时间（分钟）
     * endHour	Int	久坐提醒结束时间（小时）
     * endMinute	Int	久坐提醒结束时间（分钟）
     * interval	Int	间隔（以分钟为单位）
     * 值应大于 15 分钟
     * repetitions	Int	重复与开关
     * bit0：0表示关闭，1表示打开
     * bit1-7：0表示不重复，1表示重复
     *
     * sedentary
     * [IDOLongSitParamModel]
     * Attribute type declaration
     * startHour Int Sitting Reminder Start time (hours)
     * startMinute Int Sitting Reminder start time (minutes)
     * endHour Int Sitting Reminder End time (hours)
     * endMinute Int End time of Sitting reminder (minutes)
     * interval Int Interval in minutes
     * The value should be greater than 15 minutes
     * repetitions Int Repetitions and switches
     * bit0:0 indicates off, 1 indicates on
     * bit1-7:0 means no repetition, and 1 means repetition
     * */
    private fun setLongSit() {
        var longSit = Cmds.setLongSit(
            IDOLongSitParamModel(
                15, 40, 23, 26, 15, 254
            )
        )
        longSit.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = longSit.json

    }

    /**
     * 设置防丢
     * [IDOLostFindParamModel]
     * 属性	类型	说明
     * mode	Int	模式
     * 0：无防丢
     * 1：近距离防丢
     * 2：中距离防丢
     * 3：远距离防丢
     *
     * Set up anti-lose
     * [IDOLostFindParamModel]
     * Attribute type declaration
     * mode Int mode
     * 0: no loss prevention
     * 1: Close to prevent loss
     * 2: Medium-distance anti-loss
     * 3: Long distance to prevent loss
     * */
    private fun setLostFind() {
        var lostFind = Cmds.setLostFind(IDOLostFindParamModel(0))
        lostFind.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = lostFind.json

    }

    /**
     * 设置运动目标
     * [IDOSportGoalParamModel]
     * 属性	类型	说明
     * sportStep	Int	锻炼目标的步数
     * walkGoalSteps	Int	每小时步行目标步数设置
     * targetType	Int	目标类型设置
     * 0：无效
     * 1：每日目标
     * 2：每周目标
     * 需要菜单getStepDataTypeV2支持
     *
     * Set moving goals
     * [IDOSportGoalParamModel]
     * Attribute type declaration
     * sportStep Int The number of steps for the exercise goal
     * walkGoalSteps Int Set the target number of steps per hour
     * targetType Int Set the target type
     * 0: invalid
     * 1: Daily goals
     * 2: Weekly goals
     * This parameter is supported by getStepDataTypeV2
     * */
    private fun setSportGoal() {
        var sportGoal = Cmds.setSportGoal(
            IDOSportGoalParamModel(
                2000,
                15,
                1,
            )
        )
        sportGoal.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sportGoal.json

    }

    /**
     * 设置单位
     * [IDOUnitParamModel]
     * 属性	类型	说明
     * distUnit	Int	距离单位：
     * 0：无效
     * 1：公里（公制）
     * 2：英里（英制）
     * weightUnit	Int	重量单位：
     * 0：无效
     * 1：kg
     * 2：lb
     * temp	Int	温度单位：
     * 0：无效
     * 1：℃
     * 2：℉
     * stride	Int	步行步幅：
     * 0：无效
     * 0：厘米
     * language	Int	语言
     * is12HourFormat	Int	时间格式：
     * 0：无效
     * 1：24小时格式
     * 2：12小时格式
     * strideRun	Int	跑步步幅：
     * 0：无效
     * 1：cm
     * 男性默认值：90cm
     * strideGpsCal	Int	通过 GPS 步幅校准开/关：
     * 0：无效
     * 1：开
     * 2：关
     * weekStartDate	Int	一周的开始日期：
     * 0：星期一
     * 1：星期日
     * 3：星期六
     * calorieUnit	Int	卡路里单位设置：
     * 0：无效
     * 1：默认kCal
     * 2：Cal
     * 3：kJ
     * swimPoolUnit	Int	泳池单位设置：
     * 0：无效
     * 1：默认米
     * 2：码
     * cyclingUnit	Int	骑行单位：
     * 0：无效
     * 1：公里
     * 2：英里
     * walkingRunningUnit	Int	步行或跑步单位（公里/英里）设置：
     * 0：无效
     * 1：公里
     * 2：英里
     * 需要设备固件 setSupportWalkRunUnit 支持
     *
     *
     * Set unit
     * [IDOUnitParamModel]
     * Attribute type declaration
     * distUnit Int Distance unit:
     * 0: invalid
     * 1: km (metric)
     * 2: miles (imperial)
     * weightUnit Int A unit of weight:
     * 0: invalid
     * 1: kg
     * 2: lb
     * temp Int Temperature unit:
     * 0: invalid
     * 1: ° C
     * 2: ℉
     * stride Int: Stride int:
     * 0: invalid
     * 0: cm
     * language Int Language
     * is12HourFormat Int Time format:
     * 0: invalid
     * 1:24 hour format
     * 2:12 hour format
     * strideRun Int Running stride:
     * 0: invalid
     * 1: cm
     * Default value for males: 90cm
     * strideGpsCal Int Calibrates on/off via GPS stride length:
     * 0: invalid
     * 1: On
     * 2: Off
     * weekStartDate Int Start date of a week:
     * 0: Monday
     * 1: Sunday
     * 3: Saturday
     * calorieUnit Int Calorieunit setting:
     * 0: invalid
     * 1: indicates the default kCal
     * 2: Cal
     * 3: kJ
     * swimPoolUnit Int PoolUnit Settings:
     * 0: invalid
     * 1: default meter
     * 2: code
     * cyclingUnit Int Cycling unit:
     * 0: invalid
     * 1: km
     * 2: miles
     * walkingRunningUnit Int Walking or running unit (km/mile) setting:
     * 0: invalid
     * 1: km
     * 2: miles
     * The device firmware setSupportWalkRunUnit support is required
     * */
    private fun setUnit() {
        var unit = Cmds.setUnit(
            IDOUnitParamModel(
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
            )
        )
        unit.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = unit.json

    }

    /**
     * 抬手亮屏
     * [IDOUpHandGestureParamModel]
     * 属性	类型	说明
     * onOff	Int	开关
     * 1：开
     * 0：关
     * showSecond	Int	屏幕保持开启的持续时间（以秒为单位）
     * hasTimeRange	Int	是否有时间范围
     * 1：有
     * 0：无
     * startHour	Int	时间范围的开始时间
     * startMinute	Int	时间范围的起始分钟
     * endHour	Int	时间范围的结束小时
     * endMinute	Int	时间范围的结束分钟
     *
     * Raise your hand to light the screen
     * [IDOUpHandGestureParamModel]
     * Attribute type declaration
     * onOff Int Switch
     * 1: On
     * 0: Off
     * showSecond Int Duration for which the screen remains on (in seconds)
     * hasTimeRange Int Specifies whether a time range exists
     * 1: Yes
     * 0: None
     * startHour Int Specifies the start time of the time range
     * startMinute Int Specifies the start minute of the time range
     * endHour Int End hour of the time range
     * endMinute Int Indicates the end minute of the time range
     * */
    private fun setUpHandGesture() {
        var upHandGesture = Cmds.setUpHandGesture(
            IDOUpHandGestureParamModel(
                1,
                10,
                1,
                8,
                0,
                18,
                0,
            )
        )
        upHandGesture.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = upHandGesture.json

    }

    /**
     * 音乐开关
     * [IDOMusicOnOffParamModel]
     * 属性	类型	说明
     * onOff	Int	1：开
     * 0：关
     * showInfoStatus	Int	显示歌曲信息开关
     * 1：开
     * 0：关
     * 需要固件支持菜单：supportV2SetShowMusicInfoSwitch
     *
     * Music switch
     * [IDOMusicOnOffParamModel]
     * Attribute type declaration
     * onOff Int 1: On
     * 0: Off
     * showInfoStatus Int Switch of displaying song information
     * 1: On
     * 0: Off
     * Need firmware support menu: supportV2SetShowMusicInfoSwitch
     * */
    private fun setMusicOnOff() {
        var musicOnOff = Cmds.setMusicOnOff(
            IDOMusicOnOffParamModel(
                10,
                4,
            )
        )
        musicOnOff.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = musicOnOff.json

    }

    /**
     * 显示模式
     * [IDODisplayModeParamModel]
     * 属性	类型	说明
     * mode	Int	模式
     * 0：默认
     * 1：横向
     * 2：纵向
     * 3：翻转（180度）
     *
     * Display mode
     * [IDODisplayModeParamModel]
     * Attribute type declaration
     * mode Int mode
     * 0: default
     * 1: Horizontal
     * 2: Vertical
     * 3: Flip (180 degrees)
     * */
    private fun setDisplayMode() {
        var displayMode = Cmds.setDisplayMode(
            IDODisplayModeParamModel(
                10,
            )
        )
        displayMode.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = displayMode.json

    }

    /**
     * 设置运动模式选择
     * [IDOSportModeSelectParamModel]
     * 属性	类型	说明
     * flag	Int	0：无效
     * 1：设置快速运动类型 - sport_type1 & sport_type2 & sport_type3 & sport_type4
     * 2：设置具体运动类型
     * sportType1	Int	快速运动类型1
     * 标志：1有效
     * sportType2	Int	快速运动类型2
     * 标志：1有效
     * sportType3	Int	快速运动类型3
     * 标志：1有效
     * sportType4	Int	快速运动类型4
     * 标志：1有效
     * sportType0Walk	Bool	类型：步行，0不支持，1支持
     * 标志：2有效
     * sportType0Run	Bool	类型：正在运行，0不支持，1支持
     * 标志：2有效
     * sportType0ByBike	Bool	类型：骑行，0不支持，1支持
     * 标志：2有效
     * sportType0OnFoot	Bool	类型：步行（步行），0不支持，1支持
     * 标志：2有效
     * sportType0Swim	Bool	类型：游泳，0不支持，1支持
     * 标志：2有效
     * sportType0MountainClimbing	Bool	类型：登山，0不支持，1支持
     * flag：2有效
     * sportType0Badminton	Bool	类型：羽毛球，0不支持，1支持
     * 标志：2有效
     * sportType0Other	Bool	类型：其他，0不支持，1支持
     * 标志：2有效
     * sportType1Fitness	Bool	类型：健身，0不支持，1支持
     * 标志：2有效
     * sportType1Spinning	Bool	类型：旋转，0不支持，1支持
     * 标志：2有效
     * sportType1Ellipsoid	Bool	类型：椭球体，0不支持，1支持
     * 标志：2有效
     * sportType1Treadmill	Bool	类型：跑步机，0 不支持，1 支持
     * 标志：2 有效
     * sportType1SitUp	Bool	类型：仰卧起坐，0 不支持，1 支持
     * 标志：2 有效
     * sportType1PushUp	Bool	类型：俯卧撑，0不支持，1支持
     * 标志：2有效
     * sportType1Dumbbell	Bool	类型：哑铃，0不支持，1支持
     * 标志：2有效
     * sportType1Weightlifting	Bool	类型：举重，0 不支持，1 支持
     * 标志：2 有效
     * sportType2BodybuildingExercise	Bool	类型：健身运动，0不支持，1支持
     * 标志：2有效
     * sportType2Yoga	Bool	类型：瑜伽，0 不支持，1 支持
     * 标志：2 有效
     * sportType2RopeSkipping	Bool	类型：跳绳，0不支持，1支持
     * 标志：2有效
     * sportType2TableTennis	Bool	类型：乒乓球，0不支持，1支持
     * 标志：2有效
     * sportType2Basketball	Bool	类型：篮球，0不支持，1支持
     * 标志：2有效
     * sportType2Football	Bool	类型：足球，0不支持，1支持
     * 标志：2有效
     * sportType2Volleyball	Bool	类型：排球，0 不支持，1 支持
     * 标志：2 有效
     * sportType2Tennis	Bool	类型：网球，0 不支持，1 支持
     * 标志：2 有效
     * sportType3Golf	Bool	类型：高尔夫，0 不支持，1 支持
     * 标志：2 有效
     * sportType3Baseball	Bool	类型：棒球，0 不支持，1 支持
     * 标志：2 有效
     * sportType3Skiing	Bool	类型：滑雪，0 不支持，1 支持
     * 标志：2 有效
     * sportType3RollerSkating	Bool	类型：轮滑，0不支持，1支持
     * 标志：2有效
     * sportType3Dance	Bool	类型：舞蹈，0不支持，1支持
     * 标志：2有效
     * sportType3StrengthTraining	Bool	类型：力量训练，0不支持，1支持
     * 标志：2有效
     * sportType3CoreTraining	Bool	类型：核心训练，0不支持，1支持
     * 标志：2有效
     * sportType3TidyUpRelax	Bool	类型：整理放松，0 不支持，1 支持
     * 标志：2 有效
     *
     * Set motion mode selection
     * [IDOSportModeSelectParamModel]
     * Attribute type declaration
     * flag Int 0: invalid
     * 1: Set the fast sport type - sport_type1 & sport_type2 & sport_type3 & sport_type4
     * 2: Set the specific exercise type
     * sportType1 Int Fast sport type 1
     * Flag: 1 Valid
     * sportType2 Int Fast sport type 2
     * Flag: 1 Valid
     * sportType3 Int Fast sport type 3
     * Flag: 1 Valid
     * sportType4 Int Fast Sport type 4
     * Flag: 1 Valid
     * sportType0Walk Bool Type: walk. 0 is not supported and 1 is supported
     * Flag: 2 Valid
     * sportType0Run Bool Type: Running. 0 is not supported and 1 is supported
     * Flag: 2 Valid
     * sportType0ByBike Bool Type: ride, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType0OnFoot Bool Type: Walk (walk), 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType0Swim Bool Type: swim. 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * SportType0MountainClimbing Bool type: mountain, 0 does not support, 1 support
     * flag: 2 Valid
     * sportType0Badminton Bool Type: badminton, 0 not supported, 1 supported
     * Flag: 2 Valid
     * sportType0Other Bool Type: other. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * sportType1Fitness Bool Type: Fitness. 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType1Spinning Bool Type: spinning, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType1Ellipsoid Bool Type: ellipsoid. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * Sporttype1bool Treadmill type: treadmill, with 0 not supported and 1 supported
     * Flag: 2 Valid
     * sportType1SitUp Bool Type: sit-ups. 0 is not supported and 1 is supported
     * Flag: 2 Valid
     * sportType1PushUp Bool Type: push-up. 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType1Dumbbell Bool Type: dumbbell. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * sportType1Weightlifting Bool Type: weightlifting. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * SportType2BodybuildingExercise Bool types: exercise, 0 is not supported, 1 support
     * Flag: 2 Valid
     * sportType2Yoga Bool Type: yoga. 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType2RopeSkipping Bool Type: Skip rope. 0 is not supported and 1 is supported
     * Flag: 2 Valid
     * sportType2TableTennis Bool Type: table tennis. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * sportType2Basketball Bool Type: basketball, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType2Football Bool Type: football, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType2Volleyball Bool Type: volleyball, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType2Tennis Bool Type: tennis, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType3Golf Bool Type: golf, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType3Baseball Bool Type: baseball, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType3Skiing Bool Type: skiing, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType3RollerSkating Bool Type: Roller skating. 0 is not supported and 1 is supported
     * Flag: 2 Valid
     * sportType3Dance Bool Type: dance. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * SportType3StrengthTraining Bool types: strength training, 0 is not supported, 1 support
     * Flag: 2 Valid
     * sportType3CoreTraining Bool Type: core training, 0 is not supported, 1 is supported
     * Flag: 2 Valid
     * sportType3TidyUpRelax Bool Type: Collated relaxed. 0 is not supported, and 1 is supported
     * Flag: 2 Valid
     * */
    private fun setSportModeSelect() {
        var sportModeSelect = Cmds.setSportModeSelect(
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
        )
        sportModeSelect.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = sportModeSelect.json

    }

    /**
     * 设置睡眠时间段
     * [IDOSleepPeriodParamModel]
     * 属性	类型	说明
     * onOff	Int	开关
     * 1 开
     * 0 关
     * startHour	Int	开始时间（小时）
     * startMinute	Int	开始时间（分钟）
     * endHour	Int	结束时间（小时）
     * endMinute	Int	结束时间（分钟）
     *
     * Set a sleep schedule
     * [IDOSleepPeriodParamModel]
     * Attribute type declaration
     * onOff Int Switch
     * 1-mo
     * 0 stage
     * startHour Int Start time (hours)
     * startMinute Int Start time (minutes)
     * endHour Int End time (hour)
     * endMinute Int End time (minutes)
     * */
    private fun setSleepPeriod() {
        var sleepPeriod = Cmds.setSleepPeriod(
            IDOSleepPeriodParamModel(
                1,
                23,
                0,
                8,
                0,
            )
        )
        sleepPeriod.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sleepPeriod.json

    }

    /**
     * 设置日出日落时间
     * [IDOWeatherSunTimeParamModel]
     * 属性	类型	说明
     * sunriseHour	Int	日出时刻
     * sunriseMin	Int	日出时刻
     * sunsetHour	Int	日落时分
     * sunsetMin	Int	日落一分钟
     *
     * Set sunrise and sunset times
     * [IDOWeatherSunTimeParamModel]
     * Attribute type declaration
     * sunriseHour Int Sunrise time
     * sunriseMin Int Sunrise time
     * sunsetHour Int. Sunsethour int
     * sunsetMin Int One minute after sunset
     * */
    private fun setWeatherSunTime() {
        var weatherSunTime = Cmds.setWeatherSunTime(
            IDOWeatherSunTimeParamModel(
                6,
                12,
                18,
                30,
            )
        )
        weatherSunTime.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = weatherSunTime.json

    }

    /**
     * 设置表盘
     * [IDOWatchDialParamModel]
     * 属性	类型	说明
     * dialId	Int	需要设置的表盘ID
     * 拨号id
     * 0无效，目前支持1~4
     *
     * Dial setting
     * [IDOWatchDialParamModel]
     * Attribute type declaration
     * dialId Int Dial ID to be set
     * Dial id
     * 0 is invalid. Currently 1 to 4 is supported
     * */
    private fun setWatchDial() {
        var watchDial = Cmds.setWatchDial(
            IDOWatchDialParamModel(
                1,
            )
        )
        watchDial.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = watchDial.json

    }

    /**
     * 设置快捷方式
     * [IDOShortcutParamModel]
     * 属性	类型	说明
     * mode	Int	快捷键1功能
     * 0：无效
     * 1：快速进入摄像头控制
     * 2：快速进入运动模式
     * 3：快速进入请勿打扰
     *
     * Set a shortcut
     * [IDOShortcutParamModel]
     * Attribute type declaration
     * mode Int Function of shortcut key 1
     * 0: invalid
     * 1: Quickly enter the camera control
     * 2: Quickly enter the exercise mode
     * 3: Enter do not Disturb quickly
     * */
    private fun setShortcut() {
        var shortcut = Cmds.setShortcut(
            IDOShortcutParamModel(
                2
            )
        )
        shortcut.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = shortcut.json

    }


    /**
     * 设置血氧开关
     * [IDOSpo2SwitchParamModel]
     * 属性	类型	说明
     * onOff	Int	SpO2 全天开关
     * 1 开
     * 0 关
     * startHour	Int	开始时间（小时）
     * startMinute	Int	开始时间（分钟）
     * endHour	Int	结束时间（小时）
     * endMinute	Int	结束时间（分钟）
     * lowSpo2OnOff	Int	低 SpO2 开关
     * 1 开
     * 0 关
     * 需要菜单 setSpo2AllDayOnOff 的支持
     * lowSpo2Value	Int	低 SpO2 阈值
     * 需要菜单“v3SupportSetSpo2LowValueRemind”的支持
     * notifyFlag	Int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：禁用通知
     * 需要菜单“getSpo2NotifyFlag”的支持
     *
     * Set the blood oxygen switch
     * [IDOSpo2SwitchParamModel]
     * Attribute type declaration
     * onOff Int SpO2 all-day switch
     * 1-mo
     * 0 stage
     * startHour Int Start time (hours)
     * startMinute Int Start time (minutes)
     * endHour Int End time (hour)
     * endMinute Int End time (minutes)
     * lowSpo2OnOff Int Low SpO2 switch
     * 1-mo
     * 0 stage
     * Requires support for menu setSpo2AllDayOnOff
     * lowSpo2Value Int Low SpO2 threshold
     * Need the support of "v3SupportSetSpo2LowValueRemind" menu
     * notifyFlag Int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * The "getSpo2NotifyFlag" menu is required
     * */
    private fun setSpo2Switch() {
        var spo2Switch = Cmds.setSpo2Switch(
            IDOSpo2SwitchParamModel(
                1, 14, 0, 20, 0, 1, 20, 1
            )
        )
        spo2Switch.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = spo2Switch.json

    }

    /**
     * V3动态消息通知
     * [IDONoticeMesaageParamModel]
     * 属性	类型	说明
     * verison	Int	协议库版本号
     * osPlatform	Int	系统0：无效，1：Android，2：iOS
     * evtType	Int	当前模式 0：无效，1：消息提醒
     * notifyType	Int	消息枚举类型 最大值：20000
     * msgID	Int	消息ID 仅当evt_type为消息提醒且msg_ID不为0时有效
     * appItemsLen	Int	国家/地区数量和语言详细信息
     * contact	String	联系人姓名（最大 63 字节）
     * phoneNumber	String	电话号码（最大 31 字节）
     * msgData	String	消息内容（最大249字节）
     *
     * [IDONoticeMesaageParamItem]
     * 属性	类型	说明
     * language	Int	语言类型
     * name	String	国家对应的应用名称（最大49字节）
     *
     * V3 Dynamic message notification
     * [IDONoticeMesaageParamModel]
     * Attribute type declaration
     * verison Int Version number of the protocol library
     * osPlatform Int System 0: invalid, 1: Android, 2: iOS
     * evtType Int Indicates the current mode. 0: invalid, 1: message alert
     * notifyType Int Indicates the maximum message enumeration type: 20000
     * msgID Int Message ID This parameter is valid only when evt_type is message alert and msg_ID is not 0
     * appItemsLen Int Number of countries and language details
     * contact String Contact name (maximum 63 bytes)
     * phoneNumber String Phone number (maximum 31 bytes)
     * msgData String Message content (Max. 249 bytes)
     * [IDONoticeMesaageParamItem]
     * Attribute type declaration
     * language Int Indicates the language type
     * name String Application name corresponding to the country (maximum 49 bytes)
     * */
    private fun setNoticeAppName() {
        var noticeAppName = Cmds.setNoticeAppName(
            IDONoticeMesaageParamModel(
                1, 1, 19, 1, 7, "ido", "ido_demo", "ido_demo", listOf(
                    IDONoticeMesaageParamItem(
                        1, "china"
                    )
                )
            )
        )
        noticeAppName.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = noticeAppName.json

    }

    /**
     * 同步常用联系人
     * [IDOSyncContactParamModel]
     * 属性	类型	说明
     * operat	Int	操作
     * 0：无效
     * 1：设置联系人
     * 2：查询联系人
     * 3：设置紧急联系人（需要菜单中getSupportSetGetEmergencyContactV3支持）
     * 4：查询紧急联系人（需要菜单中支持getSupportSetGetEmergencyContactV3）
     * version	int	协议版本 （不需要赋值）
     * itemsNum	Int	item 个数 （不需要赋值）
     * items	List	IDOContactItem 集合
     *
     * Synchronize frequent contacts
     * [IDOSyncContactParamModel]
     * Attribute type declaration
     * operat Int Indicates the operation
     * 0: invalid
     * 1: Set a contact
     * 2: Query contacts
     * 3: set up an emergency contact getSupportSetGetEmergencyContactV3 support (menu)
     * 4: query emergency contact (need menu support getSupportSetGetEmergencyContactV3)
     * version int Protocol version (no assignment required)
     * itemsNum Int Number of items (no assignment required)
     * items List IDOContactItem collection
     * */
    private fun setSyncContact() {
        var syncContact = Cmds.setSyncContact(
            IDOSyncContactParamModel(
                1, listOf(
                    IDOContactItem(
                        "18888888888", "ido"
                    )
                )
            )
        )
        syncContact.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = syncContact.json

    }

    /**
     * 控制音乐 v3协议
     * [IDOMusicControlParamModel]
     * 类型	属性	说明
     * Int	status	状态： 0：无效 1：播放 2：暂停 3：停止
     * Int	curTimeSecond	当前播放时间 单位：秒
     * Int	totalTimeSecond	总播放时间 单位：秒
     * String	musicName	音乐名称（最大 63 字节）
     * String	singerName
     *
     * Control music v3 protocol
     * [IDOMusicControlParamModel]
     * Type attribute declaration
     * Int status Status: 0: invalid 1: play 2: pause 3: stopped
     * Int curTimeSecond Current playback time Unit: second
     * Int totalTimeSecond Total play time Unit: second
     * String musicName Music name (Max. 63 bytes)
     * String	singerName
     * */
    private fun musicControl() {
        var musicControl = Cmds.musicControl(
            IDOMusicControlParamModel(
                1, 5, 360, "ido.mp3", "ido"

            )
        )
        musicControl.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = musicControl.json

    }


    /**
     * v3 设置日程提醒
     * [IDOSchedulerReminderParamModel]
     * Attribute	Type	Description
     * operate	Int	Operation type
     * 0: Invalid
     * 1: Add
     * 2: Delete
     * 3: Query
     * 4: Modify
     * items    [IDOSchedulerReminderItem]	提醒事件详情
     * 最大设置1个数据
     *
     * [IDOSchedulerReminderItem]
     * 属性	类型	说明
     * id	Int	提醒事件 ID。应用程序发送的增量值，从0开始
     * repeatType	Int	重复时间
     * 如果使用
     * getSupportSetRepeatWeekTypeOnScheduleReminderV3启用，则设置基于周的重复的bit1-bit7（周一到周日，位0作为通用开关）
     * 设置重复类型（0：无效， 1：一次、2：每天、3：每周、4：每月、5：每年）（如果通过
     * getSupportSetRepeatTypeOnScheduleReminderV3启用）
     * remindOnOff	Int	每日提醒开关
     * 0：关，1：开
     * state	Int	状态码
     * 0：无效，1：已删除，2：启用
     * title	String	标题内容。最大 74 字节
     * note	String	提醒内容。最大 149 字节
     *
     * v3 Set schedule notification
     * [IDOSchedulerReminderParamModel]
     * Attribute	Type	Description
     * operate	Int	Operation type
     * 0: Invalid
     * 1: Add
     * 2: Delete
     * 3: Query
     * 4: Modify
     * items [IDOSchedulerReminderItem] Reminder event details
     * A maximum of one data can be set
     * [IDOSchedulerReminderItem]
     * Attribute type declaration
     * id Int ID of a reminder event. The incremental value sent by the application, starting from 0
     * repeatType Int Repeat time
     * If used
     * GetSupportSetRepeatWeekTypeOnScheduleReminderV3 is enabled, the repeated bit1 - bit7 set based on the week (Monday to Sunday, 0 as the general switch)
     * Set the type of repetition (0: invalid, 1: once, 2: daily, 3: weekly, 4: monthly, 5: annual) (if passed
     * GetSupportSetRepeatTypeOnScheduleReminderV3 enabled)
     * remindOnOff Int Daily reminder switch
     * 0: off, 1: on
     * state Int Status code
     * 0: invalid, 1: deleted, 2: enabled
     * title String Title content. Maximum 74 bytes
     * note String Reminder content. Up to 149 bytes
     * */
    private fun setSchedulerReminder() {
        var schedulerReminder = Cmds.setSchedulerReminder(
            IDOSchedulerReminderParamModel(
                1, listOf(
                    IDOSchedulerReminderItem(
                        0,
                        2022,
                        12,
                        26,
                        15,
                        51,
                        20,
                        255,
                        1,
                        2,
                        "提醒事项1",
                        "记得完成工作",
                    )
                )
            )
        )
        schedulerReminder.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = schedulerReminder.json

    }

    /**
     * v3 新的100种运动排序
     * [IDOSport100SortParamModel]
     * 属性	类型	说明
     * operate	Int	操作
     * 0：无效 1：查询 2：设置
     * nowUserLocation	Int	显示的添加运动的当前位置
     * items    [Int]	运动排序列表 最大值150个
     *
     * v3 new 100 sports sort
     * [IDOSport100SortParamModel]
     * Attribute type declaration
     * operate Int Operate int
     * 0: invalid 1: query 2: set
     * nowUserLocation Int Displays the current location of the add movement
     * items [Int] The maximum number of items in the motion sorting list is 150
     * */
    private fun setSport100Sort() {
        var sport100Sort = Cmds.setSport100Sort(
            IDOSport100SortParamModel(
                2, 2, listOf(
                    1, 2
                )
            )
        )
        sport100Sort.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sport100Sort.json

    }

    /**
     * v3 设置壁纸表盘列表
     * [IDOWallpaperDialReplyV3ParamModel]
     * 属性	类型	说明
     * operate	Int	操作：0为查询，1为设置，2为删除壁纸表盘
     * location	Int	设置位置信息，参考9格布局
     * hideType	Int	隐藏类型：0表示全部显示，1表示隐藏子控件（图标和数字）
     * timeColor	Int	时间控制颜色（保留1字节+R（1字节）+G（1字节）+B（1字节））
     * widgetType	Int	控制类型：1 表示周/日期、2 表示步数、3 表示距离、4 表示卡路里、5 表示心率、6 表示电池
     * widgetIconColor	Int	小部件图标的颜色（保留 1 个字节 + R（1 个字节）+ G（1 个字节）+ B（1 个字节））
     * widgetNumColor	Int	小部件编号的颜色（保留 1 个字节 + R（1 个字节）+ G（1 个字节）+ B（1 个字节））
     *
     * v3 Specifies the wallpaper dial list
     * [IDOWallpaperDialReplyV3ParamModel]
     * Attribute type declaration
     * operate Int Operation: 0 is used to query, 1 is used to set, and 2 is used to delete the wallpaper dial
     * location Int Sets the location information. For details, see the 9-space layout
     * hideType Int Hidden type: 0 indicates that all controls are displayed, 1 indicates that child controls (ICONS and numbers) are hidden.
     * timeColor Int Time control color (reserved 1 byte +R (1 byte) +G (1 byte) +B (1 byte))
     * widgetType Int Control type: 1 indicates week/day, 2 indicates steps, 3 indicates distance, 4 indicates calories, 5 indicates heart rate, and 6 indicates battery
     * widgetIconColor Int Widget icon color (reserved 1 byte + R (1 byte) + G (1 byte) + B (1 byte))
     * widgetNumColor Int Color of the widget number (Reserve 1 byte + R (1 byte) + G (1 byte) + B (1 byte))
     * */
    private fun setWallpaperDialReply() {
        var wallpaperDialReply = Cmds.setWallpaperDialReply(
            IDOWallpaperDialReplyV3ParamModel(
                1,
                2,
                3,
                4,
                5,
                6,
                7,
            )
        )
        wallpaperDialReply.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = wallpaperDialReply.json

    }

    /**
     * v3 语音回复文本
     * [IDOVoiceReplyParamModel]
     * 属性	类型	说明
     * flagIsContinue	Int	继续录音标志
     * 0：停止录音，1：继续录音
     * title	String	标题数据，最大 31 字节
     * textContent	String	内容数据，最大511字节
     *
     * v3 Voice reply text
     * [IDOVoiceReplyParamModel]
     * Attribute type declaration
     * flagIsContinue Int Indicates that recording continues
     * 0: stops recording. 1: continues recording
     * title String Title data. Maximum 31 bytes
     * textContent String Content data. The value is a maximum of 511 bytes
     * */
    private fun setVoiceReplyText() {
        var voiceReplyText = Cmds.setVoiceReplyText(
            IDOVoiceReplyParamModel(
                1, "test", "test"
            )
        )
        voiceReplyText.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = voiceReplyText.json

    }

    /**
     * 设置时间
     * [IDODateTimeParamModel]
     * 属性	类型	说明
     * year	Int	年
     * monuth	Int	月
     * day	Int	日
     * hour	Int	小时
     * minute	Int	分钟
     * second	Int	秒
     * week	Int	周：周一至周日 0-6
     * timeZone	Int	24 小时格式的时区：0-12 为东，13-24 为西 (未启用，赋值0)
     *
     * Set time
     * [IDODateTimeParamModel]
     * Attribute type declaration
     * year Int Year
     * monuth Int Month
     * day Int Day
     * hour Int Hour
     * minute Int Minute
     * second Int second
     * week Int Week: Monday to Sunday 0-6
     * timeZone Int Time zone in 24-hour format: 0-12 for east, 13-24 for west (not enabled, set to 0)
     * */
    private fun setDateTime() {
        var dateTime = Cmds.setDateTime(
            IDODateTimeParamModel(
                2022, 10, 3, 5, 19, 16, 10, 29
            )
        )
        dateTime.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = dateTime.json

    }

    /**
     *
     * 设置屏幕亮度
     * [IDOScreenBrightnessModel]
     * 属性	类型	说明
     * level	Int	亮度级别
     * (0-100)
     * opera	Int	0 自动
     * 1 手动
     * 如果是自动同步配置，请发送00；如果是用户调整，请发送01
     * mode	Int	0 指定级别
     * 1 使用环境光传感器
     * 2 级别无关紧要
     * autoAdjustNight	Int	夜间自动亮度调节
     * 0 无效，由固件定义
     * 1 关闭
     * 2 夜间自动亮度调节
     * 3 夜间亮度降低使用设定时间
     * startHour	Int	开始时间 小时
     * startMinute	Int	开始时间 分钟
     * endHour	Int	结束时间 小时
     * endMinute	Int	结束时间分钟
     * nightLevel	Int	夜间亮度
     * showInterval	Int	显示间隔
     *
     * Set screen brightness
     * [IDOScreenBrightnessModel]
     * Attribute type declaration
     * level Int Brightness level
     * (0-100)
     * opera Int 0 Automatic
     * 1 Manual
     * For automatic synchronization, send 00; If it is a user adjustment, send 01
     * mode Int 0 Specifies the level
     * 1 Use an ambient light sensor
     * Level 2 is irrelevant
     * autoAdjustNight Int Adjustnight int Automatic brightness adjustment
     * 0 Invalid, defined by firmware
     * 1 Close
     * 2 Automatic brightness adjustment at night
     * 3 Night brightness reduction using the set time
     * startHour Int Start time Hour
     * startMinute Int Start time minutes
     * endHour Int End time hour
     * endMinute Int End time minute
     * nightLevel Int Night brightness
     * showInterval Int Display interval
     * */
    private fun setScreenBrightness() {
        var screenBrightness = Cmds.setScreenBrightness(
            IDOScreenBrightnessModel(
                20,
                0,
                0,
                3,
                18,
                0,
                23,
                0,
                20,
                0,
            )
        )
        screenBrightness.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = screenBrightness.json

    }

    /**
     * 运动开关设置
     * [IDOActivitySwitchParamModel]
     * 属性	类型	说明
     * autoIdentifySportWalk	Int	自动识别走路开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportRun	Int	自动识别跑步开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportBicycle	Int	自动识别自行车开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoPauseOnOff	Int	运动自动暂停
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoEndRemindOnOffOnOff	Int	结束提醒
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportElliptical	Int	自动识别椭圆机开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportRowing	Int	自动识别划船机开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportSwim	Int	自动识别游泳开关
     * 0 关闭
     * 1 开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportSmartRope	Int	自动识别智能跳绳开关
     * 0关闭
     * 1开
     * 功能表getAutoActivitySetGetUseNewStructExchange
     *
     * Motion switch setting
     * [IDOActivitySwitchParamModel]
     * Attribute type declaration
     * autoIdentifySportWalk Int Automatic identification walk switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportRun Int Automatically identifies the run switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportBicycle Int Automatic bicycle identification switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * autoPauseOnOff Int Indicates the automatic suspension of the movement
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * Autoendremindonoffoff Int End reminder
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * Automatic identification of autoIdentifySportElliptical Int elliptical machine switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportRowing Int Automatic identification rowing machine switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * autoIdentifySportSwim Int Automatic identification of swim switch
     * 0 off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * Automatic identification of autoIdentifySportSmartRope Int intelligent jump rope switch
     * 0 Off
     * 1-mo
     * Menu getAutoActivitySetGetUseNewStructExchange
     * */
    private fun setActivitySwitch() {
        var activitySwitch = Cmds.setActivitySwitch(
            IDOActivitySwitchParamModel(
                0,
                0, 0,
                0, 0,
                0, 0,
                0,
                0
            )
        )
        activitySwitch.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = activitySwitch.json

    }


    /**
     * 设置心率区间
     * [IDOHeartRateIntervalModel]
     * 属性	类型	说明
     * burnFatThreshold	int	脂肪训练心率区间
     * 计算规则:最大心率的50%-69%
     * 单位:次/分钟
     * aerobicThreshold	int	心肺训练心率区间
     * 计算规则:最大心率的70%-84%
     * 单位:次/分钟
     * limitThreshold	int	峰值训练心率区间
     * 计算规则:最大心率的85%-100%
     * 单位:次/分钟
     * userMaxHr	int	心率上限,最大心率提醒
     * 单位:次/分钟
     * range1	int	热身运动心率区间
     * 计算规则：(200-年龄) * 50
     * 单位:次/分钟
     * range2	int	脂肪燃烧心率区间
     * 计算规则：(200-年龄) * 60
     * 单位:次/分钟
     * range3	int	有氧运动心率区间
     * 计算规则：(200-年龄) * 70
     * 单位:次/分钟
     * range4	int	无氧运动心率区间
     * 计算规则：(200-年龄) * 80
     * 单位:次/分钟
     * range5	int	极限锻炼心率区间
     * 计算规则：(200-年龄) * 90
     * 单位:次/分钟
     * minHr	int	心率最小值
     * 单位:次/分钟
     * maxHrRemind	int	最大心率提醒
     * 0 关闭,1 开启
     * minHrRemind	int	最小心率提醒
     * 0 关闭,1 开启
     * remindStartHour	int	提醒开始 时
     * remindStartMinute	int	提醒开始 分
     * remindStopHour	int	提醒结束 时
     * remindStopMinute	int	提醒结束 分
     *
     * Set heart rate interval
     * [IDOHeartRateIntervalModel]
     * Attribute type declaration
     * burnFatThreshold int Heart rate interval for fat training
     * Calculation rule: 50% to 69% of the maximum heart rate
     * Unit: times/minute
     * aerobicThreshold int Heart rate interval of aerobicthreshold int Cardiopulmonary training
     * Calculation rule: 70% to 84% of the maximum heart rate
     * Unit: times/minute
     * limitThreshold int Peak training heart rate interval
     * Calculation rule: 85-100% of the maximum heart rate
     * Unit: times/minute
     * userMaxHr int Heart rate upper limit, maximum heart rate alert
     * Unit: times/minute
     * range1 int Warm-up heart rate range
     * Calculation rules: (200- age) * 50
     * Unit: times/minute
     * range2 int Fat burning heart rate range
     * Calculation rules: (200- age) * 60
     * Unit: times/minute
     * range3 int Aerobic heart rate range
     * Calculation rules: (200- age) * 70
     * Unit: times/minute
     * range4 int Heart rate range of anaerobic exercise
     * Calculation rules: (200- age) * 80
     * Unit: times/minute
     * range5 int Extreme exercise heart rate range
     * Calculation rules: (200- age) * 90
     * Unit: times/minute
     * minHr int Minimum heart rate
     * Unit: times/minute
     * maxHrRemind int Max heart rate reminder
     * 0 is off,1 is on
     * minHrRemind int Minimum heart rate reminder
     * 0 is off,1 is on
     * remindStartHour int when the reminder starts
     * remindStartMinute int Indicates the remindstartminute
     * remindStopHour int End of remindstophour int
     * remindStopMinute int Remindstopminute of remindstopminute
     * */
    private fun setHeartRateInterval() {
        var heartRateInterval = Cmds.setHeartRateInterval(
            IDOHeartRateIntervalModel(
                113,
                132,
                170,
                220,
                94,
                113,
                132,
                151,
                170,
                20,
                1, 0,
                0, 0, 23,
                59
            )
        )
        heartRateInterval.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = heartRateInterval.json

    }

    /**
     * 设置经期
     * [IDOMenstruationModel]
     * 属性	类型	说明
     * onOff	int	经期开关 1开 0关闭
     * menstrualLength	int	经期长度
     * menstrualCycle	int	经期周期
     * lastMenstrualYear	int	最近一次经期开始时间 年
     * lastMenstrualMonth	int	最近一次经期开始时间 月
     * lastMenstrualDay	int	最近一次经期开始时间 日
     * ovulationIntervalDay	int	从下一个经期开始前到排卵日的间隔,一般为14天
     * ovulationBeforeDay	int	排卵日之前易孕期的天数,一般为5
     * ovulationAfterDay	int	排卵日之后易孕期的天数,一般为5
     * notifyFlag	int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：关闭通知 需要固件开启功能表支持 getMenstrualAddNotifyFlagV3
     * menstrualReminderOnOff	int	经期提醒开关开关
     * 1:开
     * 0:关闭
     * 需要固件开启功能表支持 getSupportSetMenstrualReminderOnOff 该开关无效时，功能开启就默认提醒。
     *
     * Set period
     * [IDOMenstruationModel]
     * Attribute type declaration
     * onOff int Period switch 1 On 0 Off
     * menstrualLength int Period length
     * menstrualCycle int Menstrual cycle
     * lastMenstrualYear int Last period start year
     * lastMenstrualMonth int Last period start month
     * lastMenstrualDay int Date when the last period started
     * ovulationIntervalDay int The interval between the start of the next period and the date of ovulation, usually 14 days
     * ovulationBeforeDay int Number of days before the ovulation date. The value is usually 5
     * ovulationAfterDay int The number of days after ovulation that the pregnancy is easy, usually 5
     * notifyFlag int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: close the notification needs to open firmware support getMenstrualAddNotifyFlagV3 table
     * menstrualReminderOnOff int Menstrual reminder switch Switch
     * 1: On
     * 0: Off
     * Need to open firmware table support getSupportSetMenstrualReminderOnOff when the switch was invalid, open will default to remind function.
     * */
    private fun setMenstruation() {
        var menstruation = Cmds.setMenstruation(
            IDOMenstruationModel(
                1, 7, 21, 2022, 12, 19, 15,
                5, 5, 1, 1
            )
        )
        menstruation.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = menstruation.json

    }


    /**
     * 卡路里和距离目标
     * [IDOMainSportGoalModel]
     * 属性	类型	说明
     * calorie	Int	活动卡路里目标（以千卡为单位）
     * 需要固件启用功能表“setCalorieGoal”
     * distance	Int	目标距离（米）
     * calorieMin	Int	最低活动热量值
     * calorieMax	Int	最大活动热量值
     * midHighTimeGoal	Int	中高运动时间目标（以秒为单位）
     * 需要固件启用功能表“setMidHighTimeGoal”
     * walkGoalTime	Int	目标时间（小时）
     * timeGoalType	Int	0：无效
     * 1：每日目标
     * 2：每周目标
     * 需要固件启用功能表getSupportSetGetTimeGoalTypeV2
     *
     * Calorie and distance goals
     * [IDOMainSportGoalModel]
     * Attribute type declaration
     * calorie Int Activity calorie target (in kilocalories)
     * Requires firmware to enable the "setCalorieGoal" function sheet
     * distance Int Target distance (m)
     * calorieMin Int Minimum active heat value
     * calorieMax Int Maximum active heat value
     * midHighTimeGoal Int Mid-high motion time goal (in seconds)
     * Requires firmware enable menu "setMidHighTimeGoal"
     * walkGoalTime Int Target Time (hours)
     * timeGoalType Int 0: invalid
     * 1: Daily goals
     * 2: Weekly goals
     * Need to enable menu getSupportSetGetTimeGoalTypeV2 firmware
     * */
    private fun setCalorieDistanceGoal() {
        var calorieDistanceGoal = Cmds.setCalorieDistanceGoal(
            IDOMainSportGoalModel(
                500, 200, 200, 666, 600, 600, 0,
            )
        )
        calorieDistanceGoal.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = calorieDistanceGoal.json

    }

    /**
     *  v3 下发v3世界时间
     *
     * [IDOWorldTimeParamModel]
     * 属性	类型	说明
     * id	Int	详细ID，唯一性
     * minOffset	Int	从当前时间到 UTC 0 的分钟偏移量
     * cityName	String	城市名称，最多 59 字节
     * longitudeFlag	Int	1：东经 2：西经
     * longitude	Int	经度，乘以 100，保留 2 位小数
     * latitudeFlag	Int	1：北纬 2：南纬
     * latitude	Int	纬度，乘以 100，保留 2 位小数
     *
     * [IDOWorldTimeParamModel]
     * Attribute type declaration
     * id Int Detailed ID, unique
     * minOffset Int Specifies the minute offset from the current time to UTC 0
     * cityName String City name. The value is a maximum of 59 bytes
     * longitudeFlag Int 1: East longitude 2: West longitude
     * longitude Int Longitude, multiplied by 100, keeping 2 decimal places
     * latitudeFlag Int 1: North latitude 2: south latitude
     * latitude Int Latitude, multiplied by 100, keeping 2 decimal places
     * */
    private fun setWorldTimeV3() {
        var worldTimeV3 = Cmds.setWorldTimeV3(
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
        worldTimeV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = worldTimeV3.json

    }

    /**
     * v3 设置运动城市名称
     * cityName String 城市名称
     *
     * v3 Specifies the sports city name
     * cityName String City name
     * */
    private fun setLongCityNameV3() {
        var longCityNameV3 = Cmds.setLongCityNameV3("深圳")
        longCityNameV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = longCityNameV3.json

    }

    /**
     * 经期的历史数据下发
     * [IDOHistoricalMenstruationParamModel]
     * 属性	类型	说明
     * avgMenstrualDay	Int	平均月经周期长度 单位：天
     * avgCycleDay	Int	平均月经周期长度 单位：天
     * items	List	IDOHistoricalMenstruationParamItem 集合
     *
     * [IDOHistoricalMenstruationParamItem]
     * 属性	类型	说明
     * year	Int	经期开始的年
     * mon	Int	经期开始的月
     * day	Int	经期开始的天
     * menstrualDay	Int	月经长度（天）
     * cycleDay	Int	周期长度(天)
     * ovulationIntervalDay	Int	从下次月经开始到排卵日的间隔通常为14天。
     * ovulationBeforeDay	Int	排卵日之前的受孕天数通常为5天，此时
     * ovulationAfterDay	Int	排卵日后的受孕天数通常为5天，此时
     *
     * Menstrual history data delivery
     * [IDOHistoricalMenstruationParamModel]
     * Attribute type declaration
     * avgMenstrualDay Int Average menstrual cycle length unit: day
     * avgCycleDay Int Average menstrual cycle length unit: day
     * The items List IDOHistoricalMenstruationParamItem collection
     * [IDOHistoricalMenstruationParamItem]
     * Attribute type declaration
     * year Int The year in which the period begins
     * mon Int The month in which your period begins
     * day Int Day when your period starts
     * menstrualDay Int Menstrual Length (days)
     * cycleDay Int Cycle length (days)
     * ovulationIntervalDay Int The interval between the start of the next period and the day of ovulation is usually 14 days.
     * ovulationBeforeDay Int The number of days before ovulation day is usually 5 days at this time
     * ovulationAfterDay Int The number of days of conception after ovulation is usually 5 days
     * */
    private fun setHistoricalMenstruation() {
        var historicalMenstruation = Cmds.setHistoricalMenstruation(
            IDOHistoricalMenstruationParamModel(
                7, 29, listOf(
                    IDOHistoricalMenstruationParamItem(2023, 8, 1, 7, 30, 14, 5, 5)
                )
            )
        )
        historicalMenstruation.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = historicalMenstruation.json

    }

    /**
     * 设置用户信息
     * [IDOUserInfoPramModel]
     * 属性	类型	说明
     * year	int	出生日期 年
     * month	int	出生日期 月
     * day	int	出生日期 日
     * height	int	身高 单位厘米
     * weight	int	体重 单位千克 值需要x100
     * gender	int	性别
     * 1：女
     * 0：男
     *
     * Set user information
     * [IDOUserInfoPramModel]
     * Attribute type declaration
     * year int Year of birth date
     * month int Date of birth month
     * day int Date of birth day
     * height int Height in centimeters
     * weight int Weight in kilograms requires x100
     * gender int Gender
     * 1: Female
     * 0: Male
     * */
    private fun setUserInfo() {
        var userInfo = Cmds.setUserInfo(IDOUserInfoPramModel(2022, 12, 16, 173, 7400, 0))
        userInfo.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = userInfo.json

    }

    /**
     * 勿扰模式
     * [IDONotDisturbParamModel]
     * Attribute	Type	Description
     * switchFlag	int	开关
     * 1 开启
     * 0 关闭
     * startHour	int	开始时间
     * 时
     * startMinute	int	开始时间
     * 分
     * endHour	int	结束时间
     * 时
     * endMinute	int	结束时间
     * 分
     * haveTimeRange	int	是否有时间范围
     * 0 无效
     * 1 表示无时间范围
     * 2 表示有时间范围
     * 功能表getSupportDisturbHaveRangRepeat开启有效
     * noontimeRESTOnOff	int	白天勿扰开关
     * 1 开启
     * 0 关闭
     * noontimeRESTStartHour	int	开始时间
     * 时
     * noontimeRESTStartMinute	int	开始时间
     * 分
     * noontimeRESTEndHour	int	结束时间
     * 时
     * noontimeRESTEndMinute	int	结束时间
     * 分
     * allDayOnOff	int	全天勿扰
     * 1 开启
     * 0 关闭
     * 功能表setOnlyNoDisturbAllDayOnOff开启有效
     * intelligentOnOff	int	智能勿扰开关
     * 1 开启
     * 0 关闭
     * 功能表setOnlyNoDisturbSmartOnOff开启有效
     *
     * Do not disturb mode
     * [IDONotDisturbParamModel]
     * Attribute	Type	Description
     * switchFlag int Switch
     * 1 Turn on
     * 0 off
     * startHour int Start time
     * when
     * startMinute int Start time
     * points
     * endHour int End time
     * when
     * endMinute int End time
     * points
     * haveTimeRange int Specifies whether a time range exists
     * 0 invalid
     * 1 indicates that there is no time range
     * 2 indicates a time range
     * Open menu getSupportDisturbHaveRangRepeat effectively
     * noontimeRESTOnOff int Do not disturb switch during the day
     * 1 Turn on
     * 0 off
     * noontimeRESTStartHour int Start time
     * when
     * noontimeRESTStartMinute int Start time
     * points
     * noontimeRESTEndHour int End time
     * when
     * noontimeRESTEndMinute int End time
     * points
     * allDayOnOff int All day
     * 1 Turn on
     * 0 off
     * Open menu setOnlyNoDisturbAllDayOnOff effectively
     * intelligentOnOff int Intelligent do not disturb switch
     * 1 Turn on
     * 0 off
     * Open menu setOnlyNoDisturbSmartOnOff effectively
     * */
    private fun setNotDisturb() {
        var notDisturb = Cmds.setNotDisturb(
            IDONotDisturbParamModel(1, 15, 23, 30, 2, 127, 1, 9, 0, 12, 0, 0, 0)
        )
        notDisturb.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = notDisturb.json

    }

    /**
     * 设置经期提醒
     * [IDOMenstruationRemindParamModel]
     * 属性	类型	说明
     * startDay	int	开始日提醒 提前天数
     * ovulationDay	int	排卵日提醒 提前天数
     * hour	int	提醒时间 时
     * minute	int	提醒时间 分
     * pregnancyDayBeforeRemind	int	易孕期 开始的时候 提前多少天提醒
     * pregnancyDayEndRemind	int	易孕期 结束的时候 提前多少天提醒
     * menstrualDayEndRemind	int	经期结束 提前多少天提醒
     *
     * Set period reminders
     * [IDOMenstruationRemindParamModel]
     * Attribute type declaration
     * startDay int Indicates the number of days before the start date
     * ovulationDay int Number of days before ovulation day
     * hour int Indicates the reminder time
     * minute int Indicates the reminding time
     * pregnancyDayBeforeRemind int Indicates how many days in advance of the start of pregnancy
     * pregnancyDayEndRemind int How many days in advance of the end of pregnancy
     * menstrualDayEndRemind int Reminder of how many days before your period ends
     * */
    private fun setMenstruationRemind() {
        var menstruationRemind = Cmds.setMenstruationRemind(
            IDOMenstruationRemindParamModel(8, 8, 21, 0, 5, 5, 1)
        )
        menstruationRemind.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = menstruationRemind.json

    }


    /**
     *
     * 设置压力开关
     * [IDOStressSwitchParamModel]
     * Attribute	Type	Description
     * onOff	int	总开关
     * 1开 0关闭
     * startHour	int	开始时间 时
     * startMinute	int	开始时间 分
     * endHour	int	结束时间 时
     * endMinute	int	结束时间 分
     * remindOnOff	int	压力提醒开关
     * 1开 0关
     * on_off为关则提醒不起作用
     * interval	int	提醒间隔,单位分钟 默认60分钟
     * highThreshold	int	压力过高阈值
     * stressThreshold	int	压力校准阈值，默认是80
     * 需要固件开启功能表支持 setSendCalibrationThreshold
     * notifyFlag	int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：关闭通知
     * 需要固件开启功能表支持 getPressureNotifyFlagMode
     * repeats	Set	重复IDOWeek
     *
     * Set pressure switch
     * [IDOStressSwitchParamModel]
     * Attribute	Type	Description
     * onOff int Main switch
     * 1 on 0 off
     * startHour int Indicates the start time
     * startMinute int Start time
     * endHour int Indicates the end time
     * endMinute int Indicates the end time
     * remindOnOff int Pressure reminder switch
     * 1 on, 0 off
     * If on_off is off, the notification does not take effect
     * interval int Alert interval. The unit minute is 60 minutes by default
     * highThreshold int High pressure threshold
     * stressThreshold int Pressure calibration threshold. The default value is 80
     * Need to open firmware support setSendCalibrationThreshold table
     * notifyFlag int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * Need to open firmware support getPressureNotifyFlagMode table
     * repeats Set IDOWeek
     * */
    private fun setStressSwitch() {
        var stressSwitch = Cmds.setStressSwitch(
            IDOStressSwitchParamModel(
                1, 14, 3, 20, 5, 1, 60, 170, 80, 1, hashSetOf(
                    IDOWeek.MONDAY,
                    IDOWeek.TUESDAY,
                    IDOWeek.WEDNESDAY,
                    IDOWeek.THURSDAY,
                    IDOWeek.FRIDAY,
                    IDOWeek.SATURDAY,
                    IDOWeek.SUNDAY
                )
            )
        )
        stressSwitch.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = stressSwitch.json

    }

    /**
     * 设置喝水提醒
     *
     * [IDODrinkWaterRemindModel]
     * Attribute	Type	Description
     * onOff	int	开关
     * 0 关
     * 1 开
     * startHour	int	开始时间 时
     * startMinute	int	开始时间 分
     * endHour	int	结束时间 时
     * endMinute	int	结束时间 分
     * repeats	Set	重复IDOWeek 集合
     * interval	int	提醒间隔
     * 单位分钟
     * notifyFlag	int	通知类型
     * 0：无效
     * 1：允许通知
     * 2：静默通知
     * 3：关闭通知
     * 需要固件开启功能表支持 setDrinkWaterAddNotifyFlag
     * doNotDisturbOnOff	int	免提醒开关 00关 01开
     * 需要固件开启功能表支持 setNoReminderOnDrinkReminder
     * noDisturbStartHour	int	免提醒开始时间 时
     * 需要固件开启功能表支持 setNoReminderOnDrinkReminder
     * noDisturbStartMinute	int	免提醒开始时间 分
     * 需要固件开启功能表支持 setNoReminderOnDrinkReminder
     * noDisturbEndHour	int	免提醒结束时间 时
     * 需要固件开启功能表支持 setNoReminderOnDrinkReminder
     * noDisturbEndMinute	int	免提醒结束时间 分
     * 需要固件开启功能表支持 setNoReminderOnDrinkReminder
     *
     * Set a drink reminder
     * [IDODrinkWaterRemindModel]
     * Attribute	Type	Description
     * onOff int Switch
     * 0 stage
     * 1-mo
     * startHour int Indicates the start time
     * startMinute int Start time
     * endHour int Indicates the end time
     * endMinute int Indicates the end time
     * repeats Set IDOWeek sets
     * interval int Alert interval
     * Unit minute
     * notifyFlag int Indicates the notification type
     * 0: invalid
     * 1: Allow notifications
     * 2: Silent notification
     * 3: Disable notification
     * Need to open firmware support setDrinkWaterAddNotifyFlag table
     * doNotDisturbOnOff int No-reminder switch 00 Off 01 On
     * Need to open firmware support setNoReminderOnDrinkReminder table
     * noDisturbStartHour int Do not disturb the start time
     * Need to open firmware support setNoReminderOnDrinkReminder table
     * noDisturbStartMinute int Indicates the start time of the Disturb start-Minute int
     * Need to open firmware support setNoReminderOnDrinkReminder table
     * Nodo not Disturb Endhour int Indicates the end time of the do not remind
     * Need to open firmware support setNoReminderOnDrinkReminder table
     * Nodo not Disturb endMinute int Indicates the end time of the alarm
     * Need to open firmware support setNoReminderOnDrinkReminder table
     * */
    private fun setDrinkWaterRemind() {
        var drinkWaterRemind = Cmds.setDrinkWaterRemind(
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
        )
        drinkWaterRemind.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = drinkWaterRemind.json

    }

    /**
     * 设置菜单列表
     * [IDOMenuListParamModel]
     * 属性	类型	说明
     * items    [int]	菜单列表且自带排序
     * 无排序情况,有值则显示,无值则不现实
     * 有排序情况,需要按照数组从0开始
     * 0 无效 1 步数 2 心率 3 睡眠 4 拍照5 闹钟 6 音乐 7 秒表 8 计时器 9 运动模式 10 天气
     * 11 呼吸锻炼 12 查找手机 13 压力 14 数据三 15 时间界面 16 最近一次活动 17 健康数据 18 血氧 19 菜单设置
     * 20 (20)alexa语音依次显示 21 X屏（gt01pro-X新增）22 卡路里 （Doro Watch新增）23 距离 （Doro Watch新增）
     * 24 一键测量 (IDW05新增) 25 renpho health(润丰健康)(IDW12新增) 26 指南针 (mp01新增) 27 气压高度计(mp01新增)
     *
     * Set menu list
     * [IDOMenuListParamModel]
     * Attribute type declaration
     * items [int] Menu list with its own sorting
     * No sorting case, if there is a value, it is displayed, and no value is unrealistic
     * In the case of sorting, you need to start from 0 in the array
     * 0 Invalid 1 steps 2 Heart rate 3 Sleep 4 Photos 5 Alarm clock 6 Music 7 stopwatch 8 timer 9 Exercise mode 10 Weather
     * 11 Breathing exercises 12 Find phone 13 Pressure 14 data 3 15 Time interface 16 Last activity 17 Health data 18 Blood oxygen 19 menu Settings
     * 20 (20)alexa Voice display in sequence 21 X screen (gt01pro-X added) 22 calories (Doro Watch added) 23 Distance (Doro Watch added)
     * 24 One-click Measurement (New IDW05) 25 renpho health(New IDW12) 26 Compass (New mp01) 27 Barometric altimeter (new mp01)
     * */
    private fun setMenuList() {
        var menuList = Cmds.setMenuList(IDOMenuListParamModel(listOf(1, 2, 3, 4, 5, 6, 7)))
        menuList.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = menuList.json

    }

    /**
     * 设置闹钟
     * [IDOAlarmModel]
     * 属性	类型	说明
     * items	List	IDOAlarmItem 集合
     *
     * [IDOAlarmItem]
     * 属性	类型	说明
     * alarmID	Int	报警ID，从1开始，1~支持的最大报警数
     * delayMin	Int	延迟几分钟
     * hour	Int	闹钟 时钟
     * minute	Int	闹钟 分钟
     * name	String	报警名称，最大23字节
     * isOpen	Bool	开关
     * repeats	HashSet
     * Set()	重复IDOWeek 集合
     * repeatTimes	Int	闹钟重复次数
     * 闹钟重复的次数，延时开关，设置为0则关闭，
     * 设置为某个数字则重复该次数
     * status	IDOAlarmStatus	0：隐藏（删除） 1：显示 -1：无效
     * type	IDOAlarmType	报警类型
     *
     * Set alarm
     * [IDOAlarmModel]
     * Attribute type declaration
     * items List IDOAlarmItem collection
     * [IDOAlarmItem]
     * Attribute type declaration
     * alarmID Int Alarm ID. The value starts from 1 and ranges from 1 to the maximum number of alarms supported
     * delayMin Int Delay a few minutes
     * hour Int Indicates the alarm clock
     * minute Int Indicates the minutes of the alarm clock
     * name String Alarm name. The value is a maximum of 23 bytes
     * isOpen Bool Switch
     * repeats	HashSet
     * Set() repeats the IDOWeek set
     * repeatTimes Int Specifies the number of times that the alarm clock repeats
     * The number of times the alarm clock is repeated, the delay switch, and the setting is 0.
     * Set to a certain number to repeat the number of times
     * status IDOAlarmStatus 0: hidden (deleted) 1: displayed -1: invalid
     * type IDOAlarmType Alarm type
     * */
    private fun setAlarmV3() {
        Cmds.getAlarm().send {
            var idoAlarmModel: IDOAlarmItem = it.res?.items?.get(0) as IDOAlarmItem
            idoAlarmModel.hour = 9
            idoAlarmModel.alarmId =1
            idoAlarmModel.minute = 10
            idoAlarmModel.name = "dddd"
            idoAlarmModel.repeatTimes = 1;
            idoAlarmModel.isOpen = true
            Log.d("TAG", "setAlarmV3: ${it.res?.items.toString()}")
            var idoAlarmModel1: IDOAlarmItem = it.res?.items?.get(1) as IDOAlarmItem
            idoAlarmModel1.isOpen = false
            idoAlarmModel1.alarmId =2
            idoAlarmModel1.status = IDOAlarmStatus.HIDDEN;
            var idoAlarmModel2: IDOAlarmItem = it.res?.items?.get(2) as IDOAlarmItem
            idoAlarmModel2.isOpen = false
            idoAlarmModel2.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel2.alarmId =3

            var idoAlarmModel3: IDOAlarmItem = it.res?.items?.get(3) as IDOAlarmItem
            idoAlarmModel3.isOpen = false
            idoAlarmModel3.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel3.alarmId =4

            var idoAlarmModel4: IDOAlarmItem = it.res?.items?.get(4) as IDOAlarmItem
            idoAlarmModel4.isOpen = false
            idoAlarmModel4.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel4.alarmId =5

            var idoAlarmModel5: IDOAlarmItem = it.res?.items?.get(5) as IDOAlarmItem
            idoAlarmModel5.isOpen = false
            idoAlarmModel5.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel5.alarmId =6


            var idoAlarmModel6: IDOAlarmItem = it.res?.items?.get(6) as IDOAlarmItem
            idoAlarmModel6.isOpen = false
            idoAlarmModel6.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel6.alarmId =7

            var idoAlarmModel7: IDOAlarmItem = it.res?.items?.get(7) as IDOAlarmItem
            idoAlarmModel7.isOpen = false
            idoAlarmModel7.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel7.alarmId =8

            var idoAlarmModel8: IDOAlarmItem = it.res?.items?.get(8) as IDOAlarmItem
            idoAlarmModel8.isOpen = false
            idoAlarmModel8.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel8.alarmId =9

            var idoAlarmModel9: IDOAlarmItem = it.res?.items?.get(9) as IDOAlarmItem
            idoAlarmModel9.isOpen = false
            idoAlarmModel9.status = IDOAlarmStatus.HIDDEN;
            idoAlarmModel9.alarmId =10

            var alarmV3 = Cmds.setAlarmV3(
                IDOAlarmModel(
                    listOf(
                        idoAlarmModel,
                        idoAlarmModel1,
                        idoAlarmModel2,
                        idoAlarmModel3,
                        idoAlarmModel4,
                        idoAlarmModel5,
                        idoAlarmModel6,
                        idoAlarmModel7,
                        idoAlarmModel8,
                        idoAlarmModel9
                    )
                )
            )



            alarmV3.send {
                if (it.error.code == 0) {
                    tv_response.text = it.res?.toJsonString()
                } else {
                    tv_response.text = "设置失败 / Setup failure"
                }
            }
            paramter_tv.text = alarmV3.json
        }
    }

    /**
     * 设置运动模式排序
     * [IDOSportModeSortParamModel]
     * 属性	类型	说明
     * index	Int	排序索引（从1开始，0无效）
     * type	IDOSportType	运动类型
     *
     * Set the motion mode sort
     * [IDOSportModeSortParamModel]
     * Attribute type declaration
     * index Int Sort index (starting from 1, 0 is invalid)
     * type IDOSportType Sports type
     * */
    private fun setSportModeSort() {
        var sportModeSort = Cmds.setSportModeSort(
            listOf(
                IDOSportModeSortParamModel(
                    1,
                    IDOSportType.SPORTTYPEAEROBICS
                )
            )
        )
        sportModeSort.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sportModeSort.json

    }

    /**
     * v3 app设置回复快速信息
     * [IDOFastMsgSettingModel]
     * 属性	类型	说明
     * type	Int	0其它（默认）， 1来电消息版本号
     * fastItems	List	快速消息详情
     *
     * [IDOFastMsgItem]
     * 属性	类型	说明
     * msgId	Int	快速消息id 1开始
     * msgData	String	快速消息内容最大68个字节
     *
     * v3 app set the quick reply message
     * [IDOFastMsgSettingModel]
     * Attribute type declaration
     * type Int 0 Other (default), 1 Version of the incoming call message
     * fastItems List Quick message details
     * [IDOFastMsgItem]
     * Attribute type declaration
     * msgId Int Fast message id 1 Start
     * msgData String Fast message content contains a maximum of 68 bytes
     * */
    private fun setDefaultQuickMsgReplyList() {
        val param = IDOFastMsgSettingModel(
            0, listOf(
                IDOFastMsgItem(1, "test1"),
                IDOFastMsgItem(2, "test2"),
                IDOFastMsgItem(3, "test3"),
                IDOFastMsgItem(4, "test4"),
                IDOFastMsgItem(5, "test5")
            )
        )
        Cmds.setDefaultQuickMsgReplyList(param).send {
            if (it.error.code == 0) {
                // 成功
                // it.res is IDOCmdSetResponseModel
            } else {
                // 失败
            }
        }
    }

    /**
     *快捷消息回复使用详情参考NotificationIconTransferActivity.kt
     *[IDOFastMsgUpdateParamModel]
     * 属性	类型	说明
     * isSuccess	int	0app发送信息失败，1app发送信息成功
     * msgID	int	回复的ID :每个消息对应一个ID
     * msgType	int	消息类型
     * msgNotice	int	0是没有对应的短信回复，对应回复列表
     *
     * Quick reply message with details reference NotificationIconTransferActivity. Kt
     * [IDOFastMsgUpdateParamModel]
     * Attribute type declaration
     * isSuccess int 0app failed to send the message, 1app succeeded in sending the message
     * msgID int Reply ID: Each message corresponds to an ID
     * msgType int Indicates the message type
     * msgNotice int 0 indicates that there is no corresponding SMS reply, corresponding to the reply list
     * */
    private fun setFastMsgUpdate() {
        var fastMsgUpdate = Cmds.setFastMsgUpdate(IDOFastMsgUpdateParamModel(1, 1, 1, 1))
        fastMsgUpdate.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = fastMsgUpdate.json

    }

    /**
     * [IDOMusicOpearteParamModel]
     * 属性	类型	说明
     * musicOperate	Int	音乐操作
     * 0：无效操作
     * 1：删除音乐
     * 2：添加音乐
     * folderOperate	Int	文件夹（播放列表）操作
     * 0：无效操作
     * 1：删除文件夹
     * 2：添加文件夹
     * 3：修改播放列表
     * 4：导入播放列表
     * 5 ：删除音乐
     * folderItems	IDOMusicFolderItem	音乐详情
     * musicItems	IDOMusicItem	(歌单)文件夹详情
     *
     * [IDOMusicOperateModel]
     * 属性	类型	说明
     * operateType	Int	操作类型：
     * 0：无效操作
     * 1：删除音乐
     * 2：添加音乐
     * 3：删除文件夹
     * 4：添加文件夹
     * 5：修改播放列表
     * 6：导入播放列表
     * 7：删除播放列表中的音乐
     * version	Int	固件SDK卡信息
     * 总空间
     * errCode	Int	0：成功；非零：失败
     * musicId	Int	添加音乐成功返回音乐id
     * folderItems	List	IDOMusicFolderItem 集合
     *
     * [IDOMusicFolderItem]
     * 属性	类型	说明
     * folderID	Int	播放列表（文件夹）id，范围从1到10
     * musicNum	Int	播放列表中的歌曲数，最多 100 首
     * folderName	String	播放列表（文件夹）名称，最大 19 字节
     * musicIndex	List	歌单中对应歌曲的id，按照添加的先后顺序，依次排列
     *
     * [IDOMusicOpearteParamModel]
     * Attribute type declaration
     * musicOperate Int Indicates the music operation
     * 0: invalid operation
     * 1: Delete music
     * 2: Add music
     * folderOperate Int The operation of the folder (playlist)
     * 0: invalid operation
     * 1: Delete the folder
     * 2: Add a folder
     * 3: Modify the playlist
     * 4: Import the playlist
     * 5: Delete music
     * folderItems IDOMusicFolderItem Details about music
     * musicItems IDOMusicItem Folder details
     * [DOMusicOperateModel]
     * Attribute type declaration
     * operateType Int Operation type:
     * 0: invalid operation
     * 1: Delete music
     * 2: Add music
     * 3: Delete the folder
     * 4: Add a folder
     * 5: Modify the playlist
     * 6: Import the playlist
     * 7: Delete music from the playlist
     * version Int Firmware SDK card information
     * Total space
     * errCode Int 0: Success; Non-zero: failure
     * musicId Int The music id is returned after adding music successfully
     * folderItems List IDOMusicFolderItem collection
     * [DOMusicFolderItem]
     * Attribute type declaration
     * folderID Int Playlist (folder) id. The value ranges from 1 to 10
     * musicNum Int Number of songs in a playlist, up to 100
     * folderName String Name of the playlist (folder). The value is a maximum of 19 bytes
     * musicIndex List Indicates the ids of the songs in the list. The ids are listed in the order in which the songs are added
     */
    private fun setMusicOperate() {
        var musicOperate = Cmds.setMusicOperate(
            IDOMusicOpearteParamModel(
                0, 2,
                IDOMusicFolderItem(
                    folderId = 1, musicNum = 0, folderName = "kd", musicIndex = listOf()
                ), null
            )
        )
        musicOperate.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = musicOperate.json

    }

    /**
     *
     * 设置天气数据
     * [IDOWeatherDataParamModel]
     * type	Int	天气类型
     *          0x00 其他
     *          0x01 晴
     *          0x02 阴
     *          0x03 阴
     *          0x04 雨
     *          0x05 大雨
     *          0x06 雷雨
     *          0x07雪
     *          0x08雨夹雪
     *          0x09台风
     *          0x0A沙尘暴
     *          0x0B晴夜
     *          0x0C阴夜
     *          0x0D炎热
     *          0x0E寒冷
     *          0x0F微风
     *          0x10大风
     *          0x11阴霾
     *          0x12阵雨
     *          0x13阴转晴
     *          0x30雷
     *          0x31冰雹
     *          0x32沙尘
     *          0x33 龙卷风
     * temp	Int	当前温度
     * maxTemp	Int	当日最高气温
     * minTemp	Int	当日最低气温
     * humidity	Int	当前湿度
     * uvIntensity	Int	当前紫外线强度
     * aqi	Int	当前空气质量指数（AQI）
     * future    [IDOWeatherDataFuture]	未来三天的天气情况
     *
     * Set weather data
     * [IDOWeatherDataParamModel]
     * type Int Weather type
     * 0x00 Other
     * 0x01 Sunny
     * 0x02 Negative
     * 0x03 negative
     * 0x04 Rain
     * 0x05 Heavy rain
     * 0x06 Thunderstorm
     * 0x07 Snow
     * 0x08 Sleet
     * 0x09 Typhoon
     * 0x0A Dust storm
     * 0x0B Clear night
     * 0x0C Cloudy night
     * 0x0D Hot
     * 0x0E Cold
     * 0x0F Breeze
     * 0x10 Strong Wind
     * 0x11 Haze
     * 0x12 Shower
     * 0x13 Cloudy to sunny
     * 0x30 Thunder
     * 0x31 Hail
     * 0x32 Dust
     * 0x33 Tornado
     * temp Int Indicates the current temperature
     * maxTemp Int The maximum temperature of the day
     * minTemp Int The minimum temperature of the day
     * humidity Int Current humidity
     * uvIntensity Int Current UV intensity
     * aqi Int Current Air Quality Index (AQI)
     * future [IDOWeatherDataFuture] The weather for the next three days
     *
     * */
    private fun setWeatherData() {
        var weatherData = Cmds.setWeatherData(
            IDOWeatherDataParamModel(
                10, 4, 10, 19, 10, 4, 5, listOf(
                    IDOWeatherDataFuture(
                        0, 0, 0
                    )
                )
            )
        )
        weatherData.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = weatherData.json

    }


    /**
     * 血压测量
     * [IDOBpMeasurementParamModel]
     * flag	Int	1：开始测量
     * 2：结束测量
     * 3：获取血压数据
     *
     * Blood pressure measurement
     * [IDOBpMeasurementParamModel]
     * flag Int 1: Start measurement
     * 2: End the measurement
     * 3: Obtain blood pressure data
     * */
    private fun setBpMeasurement() {
        var bpMeasurement = Cmds.setBpMeasurement(
            IDOBpMeasurementParamModel(
                1,
            )
        )
        bpMeasurement.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = bpMeasurement.json

    }

    /**
     * 血压校准
     * [IDOBpCalibrationParamModel]
     * flag	Int	1：血压校准设置
     * 2：血压校准查询结果
     * diastolic	Int	收缩压
     * systolic	Int	舒张压
     *
     * Blood pressure calibration
     * [IDOBpCalibrationParamModel]
     * flag Int 1: Blood pressure calibration Settings
     * 2: Blood pressure calibration query result
     * diastolic Int Systolic blood pressure
     * systolic Int diastolic blood pressure
     * */
    private fun setBpCalibration() {
        var bpCalibration = Cmds.setBpCalibration(
            IDOBpCalibrationParamModel(
                1, 0, 0
            )
        )
        bpCalibration.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = bpCalibration.json

    }

    /**
     * 设置洗手提醒
     * [IDOHandWashingReminderParamModel]
     * onOff	Int	0：关闭
     * 1：打开
     * 默认关闭
     * startHour	Int	提醒的开始时间
     * startMinute	Int	提醒的开始分钟
     * endHour	Int	提醒结束时间
     * endMinute	Int	提醒结束分钟
     * repeats	Set	重复IDOWeek 集合
     * interval	Int	提醒间隔（分钟）
     * 默认为 60 分钟
     *
     * Set reminders to wash your hands
     * [IDOHandWashingReminderParamModel]
     * onOff Int 0: off
     * 1: Open
     * Default off
     * startHour Int Indicates the start time of the reminder
     * startMinute Int Indicates the start minute of the reminder
     * endHour Int Indicates the end time of reminding
     * endMinute Int Indicates the minute when the reminder ends
     * repeats Set IDOWeek sets
     * interval Int Reminder interval (minutes)
     * The default value is 60 minutes
     *
     * */
    private fun setHandWashingReminder() {
        var handWashingReminder = Cmds.setHandWashingReminder(
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
        handWashingReminder.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = handWashingReminder.json

    }

    /**
     * v3血压校准控制
     * [IDOBpCalControlModel]
     * errorCode	Int	错误代码：0 表示成功，非 0 表示失败
     * operate	Int	操作
     * 0：无效
     * 1：开始血压校准
     * 2：停止血压校准
     * 3：获取特征向量
     * sbpPpgFeatureNum	Int	高血压PPG特征向量个数
     * operate=3时有效
     * dbpPpgFeatureNum	Int	低血压PPG特征向量个数
     * operate=3时有效
     * sbpPpgFeatureItems	List	高血压PPG特征向量集合
     * dbpPpgFeatureItems	List	低血压PPG特征向量集合
     *
     * v3 Blood pressure calibration control
     * [IDOBpCalControlModel]
     * errorCode Int Error codes: 0 indicates success, and non-0 indicates failure
     * operate Int Operate int
     * 0: invalid
     * 1: Start blood pressure calibration
     * 2: Stop blood pressure calibration
     * 3: Obtain the feature vector
     * sbpPpgFeatureNum Int Number of PPG feature vectors in hypertension
     * This operation takes effect when operate=3
     * dbpPpgFeatureNum Int Number of hypotensive PPG feature vectors
     * This operation takes effect when operate=3
     * sbpPpgFeatureItems List A collection of PPG feature vectors for hypertension
     * dbpPpgFeatureItems List A collection of hypotensive PPG feature vectors
     * */
    private fun setBpCalControlV3() {
        var bpCalControlV3 = Cmds.setBpCalControlV3(
            IDOBpCalControlModel(
                1, 0, 0, 23, listOf(
                    0, 0, 1
                ), listOf(
                    0, 0, 1
                )
            )
        )
        bpCalControlV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = bpCalControlV3.json

    }


    /**
     * v3 设置运动子项数据排列
     * operate	Int	操作
     * 0：无效 1：查询 2：设置
     * sportType	IDOSportType	运动类型
     * nowUserLocation	Int	显示的添加运动的当前位置
     * items    [Int]	运动排序列表 最大值150个
     * -------------------------------------
     * v3 Sets the motion subitem data arrangement
     * operate Int Operate int
     * 0: invalid 1: query 2: set
     * sportType IDOSportType Sports type
     * nowUserLocation Int Displays the current location of the add movement
     * items [Int] The maximum number of items in the motion sorting list is 150
     * */
    private fun setSportParamSort() {
        var sportParamSort = Cmds.setSportParamSort(
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
        sportParamSort.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sportParamSort.json

    }


    /**
     * Set the shortcut return switch for incoming calls
     * */
    private fun setCallQuickReplyOnOff() {
        var callQuickReplyOnOff = Cmds.setCallQuickReplyOnOff(true)
        callQuickReplyOnOff.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = callQuickReplyOnOff.json

    }


    /**
     * Set the phone voice assistant switch
     * */
    private fun setVoiceAssistantOnOff() {
        var voiceAssistantOnOff = Cmds.setVoiceAssistantOnOff(true)
        voiceAssistantOnOff.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = voiceAssistantOnOff.json

    }


    /**
     * Set motion sort
     * [IDOSportModeSortParamModel]
     * index Int Sort index (starting from 1, 0 is invalid)
     * type IDOSportType Sports type
     *
     * [IDOSportParamModel]
     * num number
     * Items: List < IDOSportModeSortParamModel > movement type sorting details (30)
     * */
    private fun setSportSortV3() {
        var sportSortV3 = Cmds.setSportSortV3(
            IDOSportParamModel(
                1,
                listOf(IDOSportModeSortParamModel(1, IDOSportType.SPORTTYPEBURPEE))
            )
        )
        sportSortV3.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
        paramter_tv.text = sportSortV3.json

    }


    /**
     * Pressure calibration
     * [IDOStressCalibrationParamModel]
     * stressScore Int Stressscore, which ranges from 1 to 10
     * status Int 0: Start calibration Settings 1: cancel calibration Settings
     *
     * [IDOStressCalibrationModel]
     * retCode Int 0: Into 1: failed - Calibrating 2: failed - Charging failed - not wearing 4: failed - Sports scenario
     *
     * */
    private fun setStressCalibration() {
        var stressCalibration = Cmds.setStressCalibration(
            IDOStressCalibrationParamModel(
                1,
                0,
            )
        )
        stressCalibration.send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }

        paramter_tv.text = stressCalibration.json
    }


    /**
     * Send a small program operation
     * operate Int 0: invalid 1: Starts the applet 2: deletes the applet 3: Gets the list of installed applet
     * appName String Applet name operate=0/operate=3 Invalid. No name is required to obtain the operation. The value contains a maximum of 29 bytes
     */
    private fun setAppletControl() {
        Cmds.setAppletControl(IDOAppletControlModel(3, "")).send { data ->
            if (data.error.code == 0) {

                var appName = data.res?.infoItem?.get(0)?.appName
                Cmds.setAppletControl(IDOAppletControlModel(1, appName)).send {
                    paramter_tv.text = IDOAppletControlModel(1, appName).toJsonString()
                    if (it.error.code == 0) {
                        tv_response.text =
                            it.res?.toJsonString() + "  \n" + data.res?.toJsonString()
                    }
                }
            }
        }
    }


}
