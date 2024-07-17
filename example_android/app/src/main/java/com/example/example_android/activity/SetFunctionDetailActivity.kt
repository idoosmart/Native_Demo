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
import com.idosmart.model.IDOMusicFolderItem
import com.idosmart.model.IDOMusicOnOffParamModel
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDONotDisturbParamModel
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageParamModel
import com.idosmart.model.IDONoticeMessageStateParamModel
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
        var idoBaseModel = setFuncData?.idoBaseModel
        Log.e("alarm", "$myType----${CustomEvtType.SETALARMV3}")
        when (myType) {
            CustomEvtType.SETALARMV3 -> {
                Cmds.getAlarm().send {
                    idoBaseModel = it.res
                    idoBaseModel?.toJsonString()?.let { it1 -> Log.e("alarm11111", it1) }
                    //闹钟首先要从固件拿到列表，然后对列表修改用户设置的，然后下发即可，
                    var idoAlarmModel: IDOAlarmItem = it.res?.items?.get(0) as IDOAlarmItem
                    idoAlarmModel.hour = 9
                    idoAlarmModel.minute = 10
                    idoAlarmModel.name = "dddd"
                    idoAlarmModel.repeatTimes = 1;
                    idoBaseModel?.toJsonString()?.let { it1 -> Log.e("alarm11111", it1) }
                }
            }

            CustomEvtType.SETWATCHDIALSORT -> {
                Cmds.getWatchListV2().send { it ->

                    var size = it.res?.items?.size
                    var list = mutableListOf<IDOWatchDialSortItem>()
                    var i = 0
                    it.res?.items?.forEach {
                        list.add(IDOWatchDialSortItem(1, i++, it.fileName))
                    }
                    idoBaseModel = IDOWatchDialSortParamModel(size!!, list)

                }


            }

            else -> {}


        }

        send_btn.setOnClickListener {
            if (paramter_et.text.isNotEmpty()) {
                idoBaseModel = GsonBuilder().create()
                    .fromJson(paramter_et.text.toString(), setFuncData!!.idoBaseModel::class.java)
            }
            CmdSet.set(myType, idoBaseModel, {
                paramter_tv.text = it
            }) {
                tv_response.text = it
            }



        }

    }

    private fun setMusicOperate() {
        Cmds.setMusicOperate(
            IDOMusicOpearteParamModel(
                0, 2,
                IDOMusicFolderItem(
                    folderId = 1, musicNum = 0, folderName = "kd", musicIndex = listOf()
                ), null
            )
        )
    }

    /**
     *
     * 设置天气数据
     * IDOWeatherDataParamModel
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
     * */
    private fun setWeatherData() {
        Cmds.setWeatherData(
            IDOWeatherDataParamModel(
                10, 4, 10, 19, 10, 4, 5, listOf(
                    IDOWeatherDataFuture(
                        0, 0, 0
                    )
                )
            )
        ).send { }
    }


    /**
     * 血压测量
     * IDOBpMeasurementParamModel
     * flag	Int	1：开始测量
     * 2：结束测量
     * 3：获取血压数据
     *
     * */
    private fun setBpMeasurement() {
        Cmds.setBpMeasurement(
            IDOBpMeasurementParamModel(
                1,
            )
        ).send { }
    }

    /**
     * 血压校准
     * IDOBpCalibrationParamModel
     * flag	Int	1：血压校准设置
     * 2：血压校准查询结果
     * diastolic	Int	收缩压
     * systolic	Int	舒张压
     * */
    private fun setBpCalibration() {
        Cmds.setBpCalibration(
            IDOBpCalibrationParamModel(
                1, 0, 0
            )
        ).send {

        }
    }

    /**
     * 设置洗手提醒
     * IDOHandWashingReminderParamModel
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
     *
     * */
    private fun setHandWashingReminder() {
        Cmds.setHandWashingReminder(
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
        ).send {

        }
    }

    /**
     * v3血压校准控制
     * IDOBpCalControlModel
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
     * */
    private fun setBpCalControlV3() {
        Cmds.setBpCalControlV3(
            IDOBpCalControlModel(
                1, 0, 0, 23, listOf(
                    0, 0, 1
                ), listOf(
                    0, 0, 1
                )
            )
        ).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     *  v3 设置运动子项数据排列
     * operate	Int	操作
     * 0：无效 1：查询 2：设置
     * sportType	IDOSportType	运动类型
     * nowUserLocation	Int	显示的添加运动的当前位置
     * items    [Int]	运动排序列表 最大值150个
     * */
    private fun setSportParamSort() {
        Cmds.setSportParamSort(
            IDOSportSortParamModel(
                1,
                IDOSportType.SPORTTYPEAEROBICS,
                1,
                listOf(
                    1,
                    2,
                )
            )
        ).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     * 设置来电快捷回复开关
     *
     * */
    private fun setCallQuickReplyOnOff() {
        Cmds.setCallQuickReplyOnOff(true).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     * 设置手机语音助手开关
     *
     * */
    private fun setVoiceAssistantOnOff() {
        Cmds.setVoiceAssistantOnOff(true).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     * 设置运动排序
     * IDOSportModeSortParamModel
     * index	Int	排序索引（从1开始，0无效）
     * type	IDOSportType	运动类型
     *
     * IDOSportParamModel
     * num 数量
     * items ：List<IDOSportModeSortParamModel> 运动类型排序详情（最大30个）
     * */
    private fun setSportSortV3() {
        Cmds.setSportSortV3(
            IDOSportParamModel(
                1,
                listOf(IDOSportModeSortParamModel(1, IDOSportType.SPORTTYPEBURPEE))
            )
        ).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     * 压力校准
     * IDOStressCalibrationParamModel
     * stressScore	Int	压力分数，范围从 1 到 10
     * status	Int	0：开始校准设置 1：取消校准设置
     *
     * IDOStressCalibrationModel
     * retCode	Int	0：成  1：失败-正在校准  2：失败-充电  失败-未佩戴 4：失败-运动场景
     *
     * */
    private fun setStressCalibration() {
        Cmds.setStressCalibration(
            IDOStressCalibrationParamModel(
                1,
                0,
            )
        ).send {
            if (it.error.code == 0) {
                tv_response.text = it.res?.toJsonString()
            } else {
                tv_response.text = "设置失败 / Setup failure"
            }
        }
    }


    /**
     * 发送小程序操作
     * operate	Int	0:无效 1:启动小程序 2:删除小程序 3:获取已安装的小程序列表
     * appName	String	小程序名称 operate=0/operate=3无效,获取操作不需要下发名称，最大29个字节
     */
    private fun setAppletControl() {
        Cmds.setAppletControl(IDOAppletControlModel(3, "")).send { it ->
            if (it.error.code == 0) {
                var appName = it.res?.infoItem?.get(0)?.appName
                Cmds.setAppletControl(IDOAppletControlModel(1, appName)).send {
                    paramter_tv.text = IDOAppletControlModel(1, appName).toJsonString()
                    if (it.error.code == 0) {
                        tv_response.text = it.res?.toJsonString()
                    }
                }
            }
        }
    }


}
