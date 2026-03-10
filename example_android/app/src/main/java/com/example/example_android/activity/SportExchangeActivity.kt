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
import com.idosmart.model.IDOSportType
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOExchangeDataDelegate
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_response
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_start
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_pause
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_resume
import kotlinx.android.synthetic.main.activity_sport_exchange.tv_end
import java.util.Calendar
import kotlin.math.asin
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.sin
import kotlin.math.sqrt

// 标记当前是谁发起的运动 / Marker indicating who initiated the current sport
enum class SportInitiator { NONE, APP, BLE }

enum class SportStatus { STOPPED, STARTED, PAUSED, RESUMED }

private const val SUCCESS_CODE = 0
private const val FAIL_CODE = 1

class SportExchangeActivity : BaseActivity() {
    companion object {
        //2秒一次交换简要运动数据
        const val INTERVAL_EXCHANGE_DATA = 2 * 1000L

        //40秒一次交换运动完整数据
        const val INTERVAL_EXCHANGE_COMPLETE_DATA = 40 * 1000L

        //30秒一次交换V3心率数据
        const val INTERVAL_EXCHANGE_HR_DATA = 30 * 1000L
        const val LOCATION_PERMISSION_REQUEST_CODE = 1

        // BLE发起运动准备时的权限请求码
        const val BLE_LOCATION_PERMISSION_REQUEST_CODE = 2
    }

    // 标记当前是谁发起的运动 / Marker indicating who initiated the current sport
    private var activeSportInitiator: SportInitiator = SportInitiator.NONE

    private var baseModel: IDOExchangeBaseModel? = null

    private var mHandler = Handler(Looper.getMainLooper())

    private var duration = 0
    private var calories = 0
    private var distance = 0
    private var isSportEnd = false
    private var isSportPrepareSuccess = false
    private var mLocationManager: LocationManager? = null
    private var lastLocation: Location? = null
    private var signal: Int = 0
    private var exchangeType: SportStatus = SportStatus.STOPPED
        set(value) {
            field = value
            runOnUiThread { refreshState() }
        }

    // BLE发起运动准备时暂存的operate值
    private var pendingBleOperate: Int = 0

    override fun getLayoutId(): Int {
        return R.layout.activity_sport_exchange
    }

    override fun initView() {
        super.initView()

        // 初始化按钮状态
        refreshState()

        sdk.dataExchange.addExchange(object : IDOExchangeDataDelegate {
            override fun appListenBleExec(type: IDOBleExecType) {
                when (type) {
                    is IDOBleExecType.appBleEnd -> {
                        log("appBleEnd: ${type.model}")
                        val model = IDOAppBleEndReplyExchangeModel(
                            0,
                            type.model.duration ?: 0,
                            type.model.calories ?: 0,
                            type.model.distance ?: 0,
                            baseModel
                        )
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBleEndReply(model))
                        exchangeType = SportStatus.STOPPED
                        sdk.dataExchange.getActivityHrData()
                        sdk.dataExchange.getLastActivityData()
                        activeSportInitiator = SportInitiator.NONE // 释放标记锁定 / Initiator target released
                        isSportEnd = true
                    }

                    is IDOBleExecType.appBlePause -> {
                        log("appBlePause: ${type.model}")
                        val model = IDOAppBlePauseReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBlePauseReply(model))
                        exchangeType = SportStatus.PAUSED
                    }

                    is IDOBleExecType.appBleRestore -> {
                        log("appBleRestore: ${type.model}")
                        val model = IDOAppBleRestoreReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.appBleRestoreReply(model))
                        exchangeType = SportStatus.RESUMED
                    }

                    is IDOBleExecType.bleEnd -> {
                        log("bleEnd: ${type.model}")
                        val model = IDOBleEndReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleEndReply(model))
                        exchangeType = SportStatus.STOPPED
                        baseModel = null
                        activeSportInitiator = SportInitiator.NONE // 释放标记锁定 / Initiator target released
                    }

                    is IDOBleExecType.bleIng -> {
                        log("bleIng: ${type.model}")
                        val model = IDOBleIngReplyExchangeModel(type.model?.distance ?: 0, baseModel)
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
                        exchangeType = SportStatus.PAUSED
                    }

                    is IDOBleExecType.bleRestore -> {
                        log("bleRestore: ${type.model}")
                        val model = IDOBleRestoreReplyExchangeModel(0, baseModel)
                        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleRestoreReply(model))
                        exchangeType = SportStatus.RESUMED
                    }

                    is IDOBleExecType.bleStart -> {
                        log("bleStart: ${type.model}")
                        val sportType = type.model.baseModel?.sportType
                        val operate = type.model.operate ?: 0

                        if (sportType == null) {
                            log("sportType is nil")
                            return
                        }

                        baseModel = type.model.baseModel

                        // operate 1：请求app打开gps 2：发起运动请求  3:发起运动开始后台联动请求
                        when (operate) {
                            1 -> {
                                prepareRun(operate)
                            }
                            3 -> {
                                val idoSportType = IDOSportType.ofRaw(sportType)
                                // 户外运动且运动已准备
                                val isOutdoorSport = idoSportType == IDOSportType.SPORTTYPEOUTDOORRUN ||
                                        idoSportType == IDOSportType.SPORTTYPEOUTDOORCYCLE ||
                                        idoSportType == IDOSportType.SPORTTYPEONFOOT ||
                                        idoSportType == IDOSportType.SPORTTYPEOUTDOORWALK ||
                                        idoSportType == IDOSportType.SPORTTYPETRAILRUNNING ||
                                        idoSportType == IDOSportType.SPORTTYPECLIMB

                                if (isOutdoorSport && isSportPrepareSuccess) {
                                    notifyDeviceSportState(SUCCESS_CODE, operate)
                                    exchangeType = SportStatus.STARTED
                                } else {
                                    notifyDeviceSportState(FAIL_CODE, operate)
                                    activeSportInitiator = SportInitiator.NONE // Reset
                                }
                            }
                            else -> {
                                // operate == 2 等其他情况
                                val model = IDOBleStartReplyExchangeModel(operate, 0, baseModel)
                                sdk.dataExchange.appReplyExec(IDOAppReplyType.bleStartReply(model))
                            }
                        }
                    }
                }
            }

            override fun appListenAppExec(type: IDOBleReplyType) {
                when (type) {
                    is IDOBleReplyType.appEndReply -> {
                        log("reply for app's end reply: ${type.model}")
                        exchangeType = SportStatus.STOPPED
                        baseModel = null
                        sdk.dataExchange.getActivityHrData()
                        sdk.dataExchange.getLastActivityData()
                        activeSportInitiator = SportInitiator.NONE // 释放标记锁定 / Initiator target released
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
                        exchangeType = SportStatus.PAUSED
                    }

                    is IDOBleReplyType.appRestoreReply -> {
                        log("reply for app's restore cmd: ${type.model}")
                        exchangeType = SportStatus.RESUMED
                    }

                    is IDOBleReplyType.appStartReply -> {
                        log("sport started now : ${type.model}")
                        //* - 0:成功; 1:设备已经进入运动模式失败;
                        //* - 2:设备电量低失败;3:手环正在充电
                        //* - 4:正在使用Alexa 5:通话中
                        if (type.model?.retCode != 0) {
                            runOnUiThread {
                                tv_response.text = "sport failed to launch, because of ${type.model?.retCode}"
                            }
                            return
                        }
                        exchangeType = SportStatus.STARTED
                        activeSportInitiator = SportInitiator.APP // 标记App端为操作者锁定 / Target Initiator set to App
                        startLocation()
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
//                log("exchangeV2Data: ${model}")
            }

            override fun exchangeV3Data(model: IDOExchangeV3Model) {
//                log("exchangeV3Data: ${model}")
            }

        })
    }

    // ======================== 状态管理 / State Management ========================

    /**
     * 根据当前运动状态刷新UI按钮和定时器
     * Refresh UI buttons and timers based on current sport status
     */
    private fun refreshState() {
        if (baseModel == null && exchangeType == SportStatus.STOPPED) {
            log("ignore - no baseModel")
            stopTimer()
            tv_response.text = ""
            updateBtnState(tv_start, true)
            updateBtnState(tv_pause, false)
            updateBtnState(tv_resume, false)
            updateBtnState(tv_end, false)
            return
        }

        when (exchangeType) {
            SportStatus.STOPPED -> {
                log("state: stopped")
                stopTimer()
                tv_response.text = ""
                updateBtnState(tv_start, true)
                updateBtnState(tv_pause, false)
                updateBtnState(tv_resume, false)
                updateBtnState(tv_end, false)
            }
            SportStatus.STARTED -> {
                log("state: started")
                startTimer()
                tv_response.text = "sport launched successfully"
                updateBtnState(tv_start, false)
                updateBtnState(tv_pause, true)
                updateBtnState(tv_resume, false)
                updateBtnState(tv_end, true)
            }
            SportStatus.PAUSED -> {
                log("state: paused")
                stopTimer()
                updateBtnState(tv_start, false)
                updateBtnState(tv_pause, false)
                updateBtnState(tv_resume, true)
                updateBtnState(tv_end, true)
            }
            SportStatus.RESUMED -> {
                log("state: resumed")
                startTimer()
                updateBtnState(tv_start, false)
                updateBtnState(tv_pause, true)
                updateBtnState(tv_resume, false)
                updateBtnState(tv_end, true)
            }
        }
    }

    /**
     * 更新按钮状态及视觉反馈
     * Update button enabled state with visual feedback (alpha)
     */
    private fun updateBtnState(view: View, enabled: Boolean) {
        view.isEnabled = enabled
        view.alpha = if (enabled) 1.0f else 0.4f
    }

    // ======================== BLE发起运动处理 / BLE-initiated sport handling ========================

    /**
     * 开始准备运动 (BLE发起)
     * Prepare for sport start (BLE-initiated)
     */
    private fun prepareRun(operate: Int) {
        activeSportInitiator = SportInitiator.BLE // 标记设备端为操作者锁定 / Target Initiator set to BLE

        // 快速配置同步中
        if (sdk.state.isFastSynchronizing) {
            log("快速配置中，忽略设备联动")
            notifyDeviceSportState(FAIL_CODE, operate)
            return
        }

        // 注意：实际场景需添加以下拦截
        // if (安装表盘中) { notifyDeviceSportState(FAIL_CODE, operate); return }
        // if (OTA中) { notifyDeviceSportState(FAIL_CODE, operate); return }

        // 检查位置权限
        if (checkLocationPermission()) {
            log("GPS权限通过")
            notifyDeviceSportState(SUCCESS_CODE, operate)
        } else {
            // 请求权限，在权限回调中处理
            pendingBleOperate = operate
            ActivityCompat.requestPermissions(
                this, arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ), BLE_LOCATION_PERMISSION_REQUEST_CODE
            )
        }
    }

    /**
     * 通知设备运动状态
     * code 0 成功 1 失败
     * state 1 = 准备运动, 2 = 开始运动, 3 = 后台联动
     */
    private fun notifyDeviceSportState(code: Int, state: Int) {
        isSportPrepareSuccess = !(code == FAIL_CODE && state == 1)
        val model = IDOBleStartReplyExchangeModel(state, code, baseModel)
        sdk.dataExchange.appReplyExec(IDOAppReplyType.bleStartReply(model))
    }

    private fun checkLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED || ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
    }

    // ======================== 按钮点击事件 / Button click handlers ========================

    fun start(view: View) {
        if (activeSportInitiator == SportInitiator.BLE) {
            showBleBlockedMsg()
            return
        }
        enableMyLocation()
    }

    fun pause(view: View) {
        if (activeSportInitiator == SportInitiator.BLE) {
            showBleBlockedMsg()
            return
        }
        if (baseModel == null) return
        val model = IDOAppPauseExchangeModel(baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appPause(model))
        log("pause")
    }

    fun resume(view: View) {
        if (activeSportInitiator == SportInitiator.BLE) {
            showBleBlockedMsg()
            return
        }
        if (baseModel == null) return
        val model = IDOAppRestoreExchangeModel(baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appRestore(model))
        log("resume")
    }

    fun end(view: View) {
        if (activeSportInitiator == SportInitiator.BLE) {
            showBleBlockedMsg()
            return
        }
        if (baseModel == null) return
        val model = IDOAppEndExchangeModel(duration, calories, distance, 1, baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appEnd(model))
        log("end")
    }

    // ======================== App发起运动 / App-initiated sport ========================

    fun startSport() {
        startLocation()
        val calendar = Calendar.getInstance()
        baseModel = IDOExchangeBaseModel(
            calendar.get(Calendar.DAY_OF_MONTH),
            calendar.get(Calendar.HOUR_OF_DAY),
            calendar.get(Calendar.MINUTE),
            calendar.get(Calendar.SECOND),
            48/*运动类型 Outdoor cycling*/
        )
        val model = IDOAppStartExchangeModel(baseModel = baseModel)
        sdk.dataExchange.appExec(IDOAppExecType.appStart(model))
        log("start")
        tv_response.text = ""
    }

    // ======================== 定时器管理 / Timer Management ========================

    private fun startTimer() {
        stopTimer()
        mHandler.postDelayed(object : Runnable {
            override fun run() {
                if (exchangeType == SportStatus.STARTED || exchangeType == SportStatus.RESUMED) {
                    exchangeData()
                    mHandler.postDelayed(this, INTERVAL_EXCHANGE_DATA)
                }
            }
        }, INTERVAL_EXCHANGE_DATA)
        mHandler.postDelayed(object : Runnable {
            override fun run() {
                if (exchangeType == SportStatus.STARTED || exchangeType == SportStatus.RESUMED) {
                    exchangeCompleteData()
                    mHandler.postDelayed(this, INTERVAL_EXCHANGE_COMPLETE_DATA)
                }
            }
        }, INTERVAL_EXCHANGE_COMPLETE_DATA)
        mHandler.postDelayed(object : Runnable {
            override fun run() {
                if (exchangeType == SportStatus.STARTED || exchangeType == SportStatus.RESUMED) {
                    exchangeV3HrData()
                    mHandler.postDelayed(this, INTERVAL_EXCHANGE_HR_DATA)
                }
            }
        }, INTERVAL_EXCHANGE_HR_DATA)
    }

    private fun stopTimer() {
        mHandler.removeCallbacksAndMessages(null)
    }

    // ======================== 数据交换 / Data Exchange ========================

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

    // ======================== 位置服务 / Location Services ========================

    fun getBaseProvider(): String {
        val criteria = Criteria()
        criteria.accuracy = Criteria.ACCURACY_FINE
        criteria.isAltitudeRequired = true
        criteria.powerRequirement = Criteria.NO_REQUIREMENT
        criteria.bearingAccuracy = Criteria.ACCURACY_HIGH
        criteria.horizontalAccuracy = Criteria.ACCURACY_HIGH
        criteria.verticalAccuracy = Criteria.ACCURACY_HIGH
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
        mLocationManager?.removeUpdates(mLocationListener)
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

    // ======================== 权限处理 / Permission Handling ========================

    private fun enableMyLocation(): Boolean {
        if (checkLocationPermission()) {
            startSport()
            return true
        }

        if (ActivityCompat.shouldShowRequestPermissionRationale(
                this, Manifest.permission.ACCESS_FINE_LOCATION
            ) || ActivityCompat.shouldShowRequestPermissionRationale(
                this, Manifest.permission.ACCESS_COARSE_LOCATION
            )
        ) {
            Toast.makeText(this, "no location permissions", Toast.LENGTH_SHORT).show()
            return false
        }

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
        when (requestCode) {
            LOCATION_PERMISSION_REQUEST_CODE -> {
                enableMyLocation()
            }
            BLE_LOCATION_PERMISSION_REQUEST_CODE -> {
                // BLE发起运动的权限回调
                if (checkLocationPermission()) {
                    log("GPS权限通过 (BLE)")
                    notifyDeviceSportState(SUCCESS_CODE, pendingBleOperate)
                } else {
                    log("GPS权限未通过 (BLE)")
                    notifyDeviceSportState(FAIL_CODE, pendingBleOperate)
                }
            }
            else -> {
                super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            }
        }
    }

    private fun showBleBlockedMsg() {
        val msg = "Cannot perform Action: BLE device sport is running. / 无法操作：设备端运动正在进行中。"
        runOnUiThread {
            Toast.makeText(this@SportExchangeActivity, msg, Toast.LENGTH_SHORT).show()
            tv_response.text = msg
        }
    }

    private fun log(msg: String) {
        Log.d("ExchangeSport", msg)
    }
}