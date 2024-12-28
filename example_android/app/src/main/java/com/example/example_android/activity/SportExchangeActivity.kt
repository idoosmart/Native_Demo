package com.example.example_android.activity

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Criteria
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
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
import kotlin.math.asin
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt

class SportExchangeActivity : BaseActivity() {
    companion object {
        //2秒一次交换简要运动数据
        const val INTERVAL_EXCHANGE_DATA = 2 * 1000L

        //40秒一次交换运动完整数据
        const val INTERVAL_EXCHANGE_COMPLETE_DATA = 40 * 1000L

        //30秒一次交换V3心率数据
        const val INTERVAL_EXCHANGE_HR_DATA = 30 * 1000L
        const val LOCATION_PERMISSION_REQUEST_CODE = 1;
    }

    private var baseModel: IDOExchangeBaseModel? = null

    private var mHandler = Handler(Looper.getMainLooper())

    private var duration = 0
    private var calories = 0
    private var distance = 0
    private var isSportEnd = false
    private var mLocationManager: LocationManager? = null
    private var lastLocation: Location? = null
    private var signal: Int = 0
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
                        sdk.dataExchange.getActivityHrData()
                        sdk.dataExchange.getLastActivityData()
                        isSportEnd = true
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
                        sdk.dataExchange.getActivityHrData()
                        sdk.dataExchange.getLastActivityData()
                        isSportEnd = true
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
                        if (isSportEnd) {
                            isSportEnd = false
                            // TODO: 运动任务结束
                            log("运动任务结束!! / Sports mission completed!!")
                        }
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
        enableMyLocation()
    }

    fun startSport() {
        startLocation()
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

    fun getBaseProvider(): String {
        val criteria = Criteria()
        // Criteria是一组筛选条件
        criteria.accuracy = Criteria.ACCURACY_FINE
        //设置定位精准度
        criteria.isAltitudeRequired = true
        //是否要求速度
        criteria.powerRequirement = Criteria.NO_REQUIREMENT
        //设置电池耗电要求
        criteria.bearingAccuracy = Criteria.ACCURACY_HIGH
        criteria.horizontalAccuracy = Criteria.ACCURACY_HIGH
        //设置水平方向精确度
        criteria.verticalAccuracy = Criteria.ACCURACY_HIGH
        // 获取GPS信息
        return mLocationManager!!.getBestProvider(criteria, true) ?: ""
    }

    @SuppressLint("MissingPermission")
    private fun startLocation() {
        if (mLocationManager == null) mLocationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager?
        val provider: String = getBaseProvider()
        val location = mLocationManager!!.getLastKnownLocation(provider)
        if (location != null) {
            updateLocation(location)
        }
        mLocationManager?.requestLocationUpdates(provider, 3000, 1f, mLocationListener)
    }

    private val mLocationListener = LocationListener { location -> updateLocation(location) }

    private fun stopLocation() {
    }

    //户外骑行
    private fun updateLocation(location: Location?) {
        if (location != null) {
            if (lastLocation != null) {
                distance = calculateLineDistance(location, lastLocation!!).toInt()
            }
            signal = translateGps(location.accuracy)
            lastLocation = location
        }
    }

    val GPS_INVALID: Int = 0x00 //无效
    val GPS_VALID: Int = 0x01 //有效
    val GPS_BAD: Int = 0x02 //GPS信号弱
    private fun translateGps(accuracy: Float): Int {
        var gpsSignValue: Int = GPS_INVALID
        if (accuracy < 19) {
            gpsSignValue = GPS_VALID
        } else if (accuracy < 30) {
            gpsSignValue = GPS_BAD
        }
        return gpsSignValue
    }

    fun calculateLineDistance(var0: Location, var1: Location): Float {
        try {
            var var2: Double = var0.longitude
            var var4: Double = var0.latitude
            var var6: Double = var1.longitude
            var var8: Double = var1.latitude
            var2 *= 0.01745329251994329
            var4 *= 0.01745329251994329
            var6 *= 0.01745329251994329
            var8 *= 0.01745329251994329
            val var10 = sin(var2)
            val var12 = sin(var4)
            val var14 = cos(var2)
            val var16 = cos(var4)
            val var18 = sin(var6)
            val var20 = sin(var8)
            val var22 = cos(var6)
            val var24 = cos(var8)
            val var26 = DoubleArray(3)
            val var27 = DoubleArray(3)
            var26[0] = var16 * var14
            var26[1] = var16 * var10
            var26[2] = var12
            var27[0] = var24 * var22
            var27[1] = var24 * var18
            var27[2] = var20
            val var28 =
                sqrt((var26[0] - var27[0]) * (var26[0] - var27[0]) + ((var26[1] - var27[1]) * (var26[1] - var27[1])) + ((var26[2] - var27[2]) * (var26[2] - var27[2])))
            return (asin(var28 / 2.0) * 1.27420015798544E7).toFloat()
        } catch (var30: Throwable) {
            var30.printStackTrace()
            return 0.0f
        }
    }

    private fun enableMyLocation(): Boolean {
        // 1. Check if permissions are granted, if so, enable the my location layer
        if (ContextCompat.checkSelfPermission(
                this, Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(
                this, Manifest.permission.ACCESS_COARSE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            startSport()
            return true
        }

        // 2. If if a permission rationale dialog should be shown
        if (ActivityCompat.shouldShowRequestPermissionRationale(
                this, Manifest.permission.ACCESS_FINE_LOCATION
            ) || ActivityCompat.shouldShowRequestPermissionRationale(
                this, Manifest.permission.ACCESS_COARSE_LOCATION
            )
        ) {
            Toast.makeText(this, "no location permissions", Toast.LENGTH_SHORT).show()
            return false
        }

        // 3. Otherwise, request permission
        ActivityCompat.requestPermissions(
            this, arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION
            ), LOCATION_PERMISSION_REQUEST_CODE
        )
        return false
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<String>, grantResults: IntArray
    ) {
        if (requestCode != LOCATION_PERMISSION_REQUEST_CODE) {
            super.onRequestPermissionsResult(
                requestCode, permissions, grantResults
            )
            return
        }

        enableMyLocation()
    }

    /**
     * Synchronize brief sports data for app display
     * Sync every 2 seconds
     */
    private fun exchangeData() {
        if (baseModel == null) return
        if (sdk.dataExchange.supportV3ActivityExchange) {
            val mode = IDOAppIngV3ExchangeModel(signal, distance, 0, duration, calories, baseModel)
            sdk.dataExchange.appExec(IDOAppExecType.appIngV3(mode))
        } else {
            val mode = IDOAppIngExchangeModel(duration, calories, distance, signal, baseModel)
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