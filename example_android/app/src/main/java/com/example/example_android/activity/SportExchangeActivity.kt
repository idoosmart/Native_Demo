package com.example.example_android.activity

import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import com.example.example_android.base.BaseActivity
import com.example.flutter_bluetooth.logger.Logger
import com.example.example_android.R
import com.idosmart.model.IDOAppBleEndReplyExchangeModel
import com.idosmart.model.IDOAppBlePauseReplyExchangeModel
import com.idosmart.model.IDOAppBleRestoreReplyExchangeModel
import com.idosmart.model.IDOAppEndExchangeModel
import com.idosmart.model.IDOAppExecType
import com.idosmart.model.IDOAppIngExchangeModel
import com.idosmart.model.IDOAppIngV3ExchangeModel
import com.idosmart.model.IDOAppPauseExchangeModel
import com.idosmart.model.IDOAppReplyType
import com.idosmart.model.IDOAppRestoreExchangeModel
import com.idosmart.model.IDOAppStartExchangeModel
import com.idosmart.model.IDOBleEndReplyExchangeModel
import com.idosmart.model.IDOBleExecType
import com.idosmart.model.IDOBleIngReplyExchangeModel
import com.idosmart.model.IDOBleOperatePlanReplyExchangeModel
import com.idosmart.model.IDOBlePauseReplyExchangeModel
import com.idosmart.model.IDOBleReplyType
import com.idosmart.model.IDOBleRestoreReplyExchangeModel
import com.idosmart.model.IDOBleStartReplyExchangeModel
import com.idosmart.model.IDOExchangeBaseModel
import com.idosmart.model.IDOExchangeV2Model
import com.idosmart.model.IDOExchangeV3Model
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOExchangeDataDelegate
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_response
import java.util.Calendar
import kotlin.math.max

class SportExchangeActivity : BaseActivity() {
    companion object {
        //2秒一次交换简要运动数据
        const val INTERVAL_EXCHANGE_DATA = 2 * 1000L

        //40秒一次交换运动完整数据
        const val INTERVAL_EXCHANGE_COMPLETE_DATA = 40 * 1000L

        //30秒一次交换V3心率数据
        const val INTERVAL_EXCHANGE_HR_DATA = 30 * 1000L
    }

    private var baseModel: IDOExchangeBaseModel? = null

    private var mHandler = Handler(Looper.getMainLooper())

    private var duration = 0
    private var calories = 0
    private var distance = 0

    override fun getLayoutId(): Int {
        return R.layout.activity_sport_exchange
    }

    override fun initView() {
        super.initView()
        sdk.dataExchange.addExchange(object : IDOExchangeDataDelegate {
            override fun appListenBleExec(type: IDOBleExecType) {
                when (type) {
                    is IDOBleExecType.appBleEnd -> {
                        log("appBleEnd: ${type.model}")
                        mHandler.removeCallbacksAndMessages(null)
                        val model = IDOAppBleEndReplyExchangeModel(0, duration, calories, distance, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBleEndReply(model))
                    }

                    is IDOBleExecType.appBlePause -> {
                        log("appBlePause: ${type.model}")
                        val model = IDOAppBlePauseReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBlePauseReply(model))
                    }

                    is IDOBleExecType.appBleRestore -> {
                        log("appBleRestore: ${type.model}")
                        val model = IDOAppBleRestoreReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBleRestoreReply(model))
                    }

                    is IDOBleExecType.bleEnd -> {
                        log("bleEnd: ${type.model}")
                        val model = IDOBleEndReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleEndReply(model))
                    }

                    is IDOBleExecType.bleIng -> {
                        log("bleIng: ${type.model}")
                        val model = IDOBleIngReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleIngReply(model))
                    }

                    is IDOBleExecType.bleOperatePlan -> {
                        log("bleOperatePlan: ${type.model}")
//                        val model = IDOBleOperatePlanReplyExchangeModel(0, baseModel)
//                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleOperatePlanReply(model))
                    }

                    is IDOBleExecType.blePause -> {
                        log("blePause: ${type.model}")
                        val model = IDOBlePauseReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.blePauseReply(model))
                    }

                    is IDOBleExecType.bleRestore -> {
                        log("bleRestore: ${type.model}")
                        val model = IDOBleRestoreReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleRestoreReply(model))
                    }

                    is IDOBleExecType.bleStart -> {
                        log("bleStart: ${type.model}")
                        val model = IDOBleStartReplyExchangeModel(type.model.operate, 0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleStartReply(model))
                    }
                }
            }

            override fun appListenAppExec(type: IDOBleReplyType) {
                when (type) {
                    is IDOBleReplyType.appEndReply -> {
                        log("reply for app's end reply: ${type.model}")
                        mHandler.removeCallbacksAndMessages(null)
                    }

                    is IDOBleReplyType.appIngReply -> {
                        log("data of sport from device: ${type.model}")
                    }

                    is IDOBleReplyType.appIngV3Reply -> {
                        log("v3 data of sport from device: ${type.model}")
                    }

                    is IDOBleReplyType.appOperatePlanReply -> {
                        log("reply for app's operate plan cmd: ${type.model}")
                    }

                    is IDOBleReplyType.appPauseReply -> {
                        log("reply for app's pause cmd: ${type.model}")
                    }

                    is IDOBleReplyType.appRestoreReply -> {
                        log("reply for app's restore cmd: ${type.model}")
                    }

                    is IDOBleReplyType.appStartReply -> {
                        log("sport started now : ${type.model}")
                        if (type.model?.retCode != 0) {
                            //* - 0:成功; 1:设备已经进入运动模式失败;
                            //* - 2:设备电量低失败;3:手环正在充电
                            //* - 4:正在使用Alexa 5:通话中
                            tv_response.text = "sport failed to launch, because of ${type.model?.retCode}"
                            return
                        }
                        tv_response.text = "sport launched successfully"
                        mHandler.postDelayed(object : Runnable {
                            override fun run() {
                                mHandler.postDelayed(this, INTERVAL_EXCHANGE_DATA)
                                exchangeData()
                            }
                        }, INTERVAL_EXCHANGE_DATA)
                        mHandler.postDelayed(object : Runnable {
                            override fun run() {
                                mHandler.postDelayed(this, INTERVAL_EXCHANGE_COMPLETE_DATA)
                                exchangeCompleteData()
                            }

                        }, INTERVAL_EXCHANGE_COMPLETE_DATA)
                        mHandler.postDelayed(object : Runnable {
                            override fun run() {
                                mHandler.postDelayed(this, INTERVAL_EXCHANGE_COMPLETE_DATA)
                                exchangeV3HrData()
                            }
                        }, INTERVAL_EXCHANGE_HR_DATA)
                    }

                    is IDOBleReplyType.appActivityDataReply -> {
                        //result for exchangeCompleteData
                        val model = type.model
                        log("appActivityDataReply: ${type.model}")
                        duration = max(duration, model?.durations ?: 0)
                        calories = max(calories, model?.calories ?: 0)
                        distance = max(distance, model?.distance ?: 0)
                    }

                    is IDOBleReplyType.appActivityGpsReply -> {
                        log("appActivityGpsReply: ${type.model}")
                    }

                    is IDOBleReplyType.appActivityHrReply -> {
                        log("appActivityHrReply: ${type.model}")
                    }
                }
            }

            override fun exchangeV2Data(model: IDOExchangeV2Model) {
//                log("exchangeV2Data: ${GsonUtil.toJson(model)}")
            }

            override fun exchangeV3Data(model: IDOExchangeV3Model) {
//                log("exchangeV3Data: ${GsonUtil.toJson(model)}")
            }

        })
    }

    fun start(view: View) {
        val calendar = Calendar.getInstance()
        baseModel = IDOExchangeBaseModel(
            calendar.get(Calendar.DAY_OF_MONTH),
            calendar.get(Calendar.HOUR_OF_DAY),
            calendar.get(Calendar.MINUTE),
            calendar.get(Calendar.SECOND),
            48/*运动类型*/
        )
        val model = IDOAppStartExchangeModel(baseModel = baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appStart(model))
        log("start")
        tv_response.text = ""
    }

    /**
     * Synchronize brief sports data for app display
     * Sync every 2 seconds
     */
    private fun exchangeData() {
        if (baseModel == null) return
        if (sdk.dataExchange.supportV3ActivityExchange) {
            val mode = IDOAppIngV3ExchangeModel(0, 0/*gps status*/, distance, 0, duration, calories, baseModel)
            sdk.dataExchange.appExec(IDOAppExecType.appIngV3(mode))
        } else {
            val mode = IDOAppIngExchangeModel(duration, calories, distance, 0/*gps status*/, baseModel)
            sdk.dataExchange.appExec(IDOAppExecType.appIng(mode))
        }
    }

    /**
     * Synchronize complete data once
     * Sync every 40 seconds
     */
    private fun exchangeCompleteData() {
        sdk.dataExchange.getLastActivityData()
    }

    /**
     * Sync exercise heart rate data
     * Sync every 30 seconds
     */
    private fun exchangeV3HrData() {
        if (sdk.dataExchange.supportV3ActivityExchange) {
            sdk.dataExchange.getActivityHrData()
        }
    }

    fun pause(view: View) {
        if (baseModel == null) return
        val model = IDOAppPauseExchangeModel(baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appPause(model))
        log("pause")
    }

    fun resume(view: View) {
        if (baseModel == null) return
        val model = IDOAppRestoreExchangeModel(baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appRestore(model))
        log("resume")
    }

    fun end(view: View) {
        if (baseModel == null) return
        val model = IDOAppEndExchangeModel(0, 0, 0, 1, baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appEnd(model))
        log("end")
    }

    private fun log(msg: String) {
        Log.d("ExchangeSport", msg)
    }
}