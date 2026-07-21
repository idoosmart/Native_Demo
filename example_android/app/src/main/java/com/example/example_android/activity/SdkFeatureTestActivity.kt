package com.example.example_android.activity

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Typeface
import android.net.Uri
import android.view.Gravity
import android.view.Menu
import android.view.MenuItem
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.idosmart.enums.IDOSyncDataType
import com.idosmart.model.IDOBleExecType
import com.idosmart.model.IDOBleReplyType
import com.idosmart.model.IDOAppDownloadStatusInfoModel
import com.idosmart.model.IDOAppInfoModel
import com.idosmart.model.IDOAppListStyleParamModel
import com.idosmart.model.IDOAppSleepModeParamModel
import com.idosmart.model.IDOAppletControlModel
import com.idosmart.model.IDOAppletListQueryType
import com.idosmart.model.IDODataTranConfigParamModel
import com.idosmart.model.IDOFallMonitoringSwitchModel
import com.idosmart.model.IDOFirmwarePositionInfoModel
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOHeartModeParamModel
import com.idosmart.model.IDOHeartRateModeParamModel
import com.idosmart.model.IDOLocationInfoNotifyModel
import com.idosmart.model.IDOPurchasedWatchFaceInfoModel
import com.idosmart.model.IDOPositionSwitchModeModel
import com.idosmart.model.IDOTakeMedicineRemindModel
import com.idosmart.model.IDOTakeMedicineRemindInfoItemModel
import com.idosmart.model.IDOTakeMedicineRemindTimeItemModel
import com.idosmart.pigeon_implement.IDOTransMedicModel
import com.idosmart.model.IDODeviceVibrationRingtoneModel
import com.idosmart.model.IDOPhoneCalendarSyncDeleteModel
import com.idosmart.model.IDOPhoneCalendarSyncSetModel
import com.idosmart.model.IDOHeartRateModeSmartModel
import com.idosmart.model.IDOHeartRateModeSmartParamModel
import com.idosmart.model.IDOSpo2SwitchModel
import com.idosmart.model.IDOSpo2SwitchParamModel
import com.idosmart.model.IDOStressSwitchModel
import com.idosmart.model.IDOStressSwitchParamModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOExchangeDataDelegate
import java.io.File
import java.io.FileOutputStream
import kotlin.math.max
import kotlinx.android.synthetic.main.activity_sdk_feature_test.ll_buttons
import kotlinx.android.synthetic.main.activity_sdk_feature_test.sv_log
import kotlinx.android.synthetic.main.activity_sdk_feature_test.tv_log

/**
 * 标准化 SDK 已落地功能联调（对齐 Flutter SdkFeatureTestPage / iOS SdkFeatureTestVC）
 */
class SdkFeatureTestActivity : BaseActivity() {

    private val logBuffer = StringBuilder()
    private var supportSyncTypesText = ""

    /** 选图后裁剪为 160×160 PNG，再走 `.medic` 传输（对齐 iOS SdkFeatureTestVC） */
    private val pickMedicIconLauncher =
        registerForActivityResult(ActivityResultContracts.GetContent()) { uri ->
            if (uri == null) {
                log("已取消选择吃药提醒图标")
                return@registerForActivityResult
            }
            val imgPath = makeMedicIconPngFile(uri)
            if (imgPath == null) {
                toast("裁剪 160×160 失败")
                return@registerForActivityResult
            }
            log("  已裁剪为 160×160 PNG: $imgPath")
            startMedicIconTransfer(imgPath)
        }

    private val exchangeDelegate = object : IDOExchangeDataDelegate {
        override fun appListenBleExec(type: IDOBleExecType) {
            // 本页仅联调 app 侧主动请求
        }

        override fun appListenAppExec(type: IDOBleReplyType) {
            when (type) {
                is IDOBleReplyType.appActivityDataReply -> {
                    val model = type.model
                    log(
                        "[exchangeData] 15.20 运动小结 step=${model?.step} distance=${model?.distance}"
                    )
                    log(
                        "  bodyAge=${model?.bodyAge} swimmingPoolDistance=${model?.swimmingPoolDistance} actType=${model?.actType} gpsStatus=${model?.gpsStatus}"
                    )
                }
                else -> log("[exchangeData] ${type.javaClass.simpleName}")
            }
        }

        override fun exchangeV2Data(model: com.idosmart.model.IDOExchangeV2Model) {
            log("[exchangeV2Data] $model")
        }

        override fun exchangeV3Data(model: com.idosmart.model.IDOExchangeV3Model) {
            log("[exchangeV3Data] $model")
        }
    }

    override fun getLayoutId(): Int = R.layout.activity_sdk_feature_test

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.sdk_feature_test)
        sdk.dataExchange.addExchange(exchangeDelegate)
        setupButtons()
        refreshFuncTableSummary()
    }

    override fun onDestroy() {
        sdk.dataExchange.addExchange(null)
        super.onDestroy()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_sdk_feature_test, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.menu_refresh -> {
                clearLog()
                refreshFuncTableSummary()
                true
            }
            R.id.menu_clear -> {
                clearLog()
                renderLog()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupButtons() {
        appendSection(
            "基础获取类 Cmd",
            listOf(
                "2.61 设备状态" to { getDeviceStatus() },
                "15.104 左右手运动" to { getSportTypesWristSide() },
                "15.106 振动铃声(查询)" to { getVibrationRingtone() },
                "手机日历同步开关" to { getPhoneCalendarSyncSwitch() },
                "手机日历待删列表" to { getPhoneCalendarDeleteList() },
            )
        )
        appendSection(
            "V2 开关 GET/SET",
            listOf(
                "2.47 血氧 GET" to { getSpo2Switch() },
                "2.47 血氧 SET" to { setSpo2SwitchSample() },
                "2.47 血氧 回写" to { roundtripSpo2() },
                "2.46 压力 GET" to { getStressSwitch() },
                "2.46 压力 SET" to { setStressSwitchSample() },
                "2.46 压力 回写" to { roundtripStress() },
                "2.45 智能心率 GET" to { getSmartHrSwitch() },
                "2.45 智能心率 SET" to { setSmartHrSwitchSample() },
                "2.45 智能心率 回写" to { roundtripSmartHr() },
            )
        )
        appendSection(
            "V3 设置类 Cmd",
            listOf(
                "15.106 振动铃声(设置)" to { setVibrationRingtone() },
                "15.106 振动铃声 回写" to { roundtripVibrationRingtone() },
                "手机日历同步(设置)" to { setPhoneCalendarSync() },
                "手机日历增量删除(示例)" to { setPhoneCalendarSyncDeleteSample() },
            )
        )
        appendSection(
            "数据交换 exchangeData",
            listOf(
                "15.20 运动小结" to { getActivitySummaryExchange() },
                "15.103 全量快照" to { getFullSnapshotExchange() },
            )
        )
        appendSection(
            "健康同步 syncData",
            listOf(
                "15.4.1 血氧" to { syncSpo2() },
                "15.4.2 压力" to { syncPressure() },
            )
        )
        appendSection(
            "2026-07-06 新增 GET",
            listOf(
                "2.53 固件状态" to { getFirmwareStatusInfo() },
                "2.39 心率监测模式" to { getHeartRateMode() },
                "2.63 睡眠模式 GET" to { getAppSleepMode() },
                "2.54 跌倒监测 GET" to { getFallMonitoringSwitch() },
                "2.56 定位开关 GET" to { getPositionSwitchMode() },
                "2.28 文件传输配置" to { getDataTranConfig() },
                "15.26 表盘列表 V3" to { getWatchListV3() },
            )
        )
        appendSection(
            "2026-07-06 新增 SET/查询",
            listOf(
                "2.54 跌倒监测 SET" to { setFallMonitoringSwitchSample() },
                "2.56 定位开关 SET" to { setPositionSwitchModeSample() },
                "5.6 位置通知" to { setLocationInfoNotify() },
                "2.39 心率监测 SET(示例)" to { setHeartRateModeSample() },
                "2.63 睡眠模式 SET(示例)" to { setAppSleepModeSample() },
                "15.9 V3心率模式(示例)" to { setHeartModeSample() },
                "15.54 小程序列表" to { getAppletList() },
                "15.54 小程序删除第一个" to { deleteAppletFirst() },
                "15.79 APP基本信息" to { setAppBaseInfoSample() },
                "15.90 吃药提醒设置" to { takeMedicineRemindSet() },
                "15.90 吃药提醒查询" to { takeMedicineRemindQuery() },
                "15.90 吃药提醒删除第一条" to { takeMedicineRemindDeleteFirst() },
                "15.90 吃药提醒图标" to { takeMedicineRemindIconTransfer() },
                "15.90 吃药提醒设置总开关" to { takeMedicineRemindSetSwitch() },
                "15.91 已购表盘" to { setPurchasedWatchFaceInfoSample() },
                "15.92 下载状态" to { setAppDownloadStatusInfoSample() },
                "15.93 固件定位查询" to { getFirmwarePositionInfoQuery() },
                "15.93 固件定位确认" to { getFirmwarePositionInfoConfirm() },
                "15.73 应用列表样式查询" to { appListStyleQuery() },
                "15.73 应用列表样式删除" to { appListStyleDeleteFirst() },
            )
        )
    }

    private fun appendSection(title: String, buttons: List<Pair<String, () -> Unit>>) {
        val titleView = TextView(this).apply {
            text = title
            textSize = 13f
            setTypeface(null, Typeface.BOLD)
            setTextColor(0xFF757575.toInt())
            val lp = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            lp.topMargin = dp(8)
            layoutParams = lp
        }
        ll_buttons.addView(titleView)

        buttons.forEach { (label, action) ->
            val btn = TextView(this).apply {
                text = label
                gravity = Gravity.CENTER
                textSize = 14f
                setTextColor(resources.getColor(android.R.color.white, theme))
                setBackgroundResource(R.drawable.bg_btn_send)
                val lp = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    dp(40)
                )
                lp.topMargin = dp(8)
                layoutParams = lp
                setOnClickListener { action() }
            }
            ll_buttons.addView(btn)
        }
    }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    private fun clearLog() {
        logBuffer.clear()
    }

    private fun log(msg: String) {
        logBuffer.append(msg).append('\n')
        android.util.Log.d("SdkFeatureTest", msg)
        renderLog()
    }

    private fun renderLog() {
        tv_log.text = if (logBuffer.isEmpty()) "（无日志）" else logBuffer.toString()
        sv_log.post { sv_log.fullScroll(ScrollView.FOCUS_DOWN) }
    }

    private fun refreshFuncTableSummary() {
        val ft = sdk.funcTable
        sdk.syncData.getSupportSyncDataTypeList { list ->
            runOnUiThread {
                supportSyncTypesText = list.joinToString { it.name }
                val summary = """
                    【连接】${if (sdk.state.isConnected) "已连接" else "未连接"}
                    【V2 开关】spo2Get=${ft.getSupportGetSpo2SwitchInfo} pressureGet=${ft.getSupportGetPressureSwitchInfo} smartHrGet=${ft.getSupportGetSmartHeartRate}
                    【健康同步】spo2=${ft.syncV3Spo2} pressure=${ft.syncV3Pressure}
                      血氧version兼容=${ft.getSupportSyncSpo2UseVersionCompatible}
                      压力version兼容=${ft.getSupportSyncPressureUseVersionCompatible}
                    【数据交换】syncV3ActivityExchangeData=${ft.syncV3ActivityExchangeData}
                      supportV3ActivityExchange=${sdk.dataExchange.supportV3ActivityExchange}
                    支持同步类型: $supportSyncTypesText
                """.trimIndent()
                log(summary)
            }
        }
    }

    private fun ensureConnected(): Boolean {
        if (sdk.state.isConnected) return true
        toast("未连接设备")
        log("错误：设备未连接")
        return false
    }

    private fun preview(text: String?, limit: Int = 800): String {
        if (text.isNullOrEmpty()) return "NULL"
        return if (text.length <= limit) text else text.substring(0, limit) + "..."
    }

    private fun getDeviceStatus() {
        if (!ensureConnected()) return
        log("--- 2.61 设备状态 (getDeviceStatusInfo) ---")
        log("  请求: {\"get_type\":1}")
        showProgressDialog("2.61 设备状态")
        Cmds.getDeviceStatusInfo(1).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun getSportTypesWristSide() {
        if (!ensureConnected()) return
        log("--- 15.104 左右手运动类型 (getSportTypesRequiringWristSideSetting) ---")
        log("  请求: {}")
        showProgressDialog("15.104 左右手运动")
        Cmds.getSportTypesRequiringWristSideSetting().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun getVibrationRingtone() {
        if (!ensureConnected()) return
        log("--- 15.106 振动铃声(查询) (deviceVibrationRingtone) ---")
        log("  请求: {\"operate\":1}")
        showProgressDialog("15.106 振动铃声")
        Cmds.deviceVibrationRingtone(IDODeviceVibrationRingtoneModel(operate = 1)).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun getPhoneCalendarSyncSwitch() {
        if (!ensureConnected()) return
        log("--- 手机日历同步开关 (getPhoneCalendarSyncSwitch) ---")
        showProgressDialog("手机日历同步开关")
        Cmds.getPhoneCalendarSyncSwitch().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setPhoneCalendarSync() {
        if (!ensureConnected()) return
        val model = IDOPhoneCalendarSyncSetModel(syncOnOff = 1, calendarPermissionStatus = 1)
        log("--- 手机日历同步(设置) (setPhoneCalendarSync) ---")
        showProgressDialog("手机日历同步(设置)")
        Cmds.setPhoneCalendarSync(model).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun getPhoneCalendarDeleteList() {
        if (!ensureConnected()) return
        log("--- 手机日历待删列表 (getPhoneCalendarDeleteList) ---")
        showProgressDialog("手机日历待删列表")
        Cmds.getPhoneCalendarDeleteList().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setPhoneCalendarSyncDeleteSample() {
        if (!ensureConnected()) return
        val model = IDOPhoneCalendarSyncDeleteModel(items = emptyList(), itemCount = 0)
        log("--- 手机日历增量删除(示例) (setPhoneCalendarSyncDelete) ---")
        showProgressDialog("手机日历增量删除")
        Cmds.setPhoneCalendarSyncDelete(model).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setVibrationRingtone() {
        if (!ensureConnected()) return
        val model = IDODeviceVibrationRingtoneModel(
            operate = 2,
            type = 3,
            vibrationIntensity = 2,
            alarmVolume = 5,
        )
        log("--- 15.106 振动铃声(设置) ---")
        log("  请求: ${model.toJsonString()}")
        showProgressDialog("15.106 振动铃声(设置)")
        Cmds.deviceVibrationRingtone(model).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun roundtripVibrationRingtone() {
        if (!ensureConnected()) return
        log("--- 15.106 振动铃声 GET→SET 回写 ---")
        showProgressDialog("振动铃声回写...")
        Cmds.deviceVibrationRingtone(IDODeviceVibrationRingtoneModel(operate = 1)).send { getRes ->
            if (getRes.error.code != 0 || getRes.res == null) {
                closeProgressDialog()
                log("  GET code=${getRes.error.code}，中止")
                toast("GET 失败")
                return@send
            }
            val getModel = getRes.res!!
            log("  GET: ${preview(getModel.toJsonString())}")
            val type = getModel.type ?: 0
            if (type == 0) {
                closeProgressDialog()
                log("  type=0，跳过 SET")
                toast("无可设置子项")
                return@send
            }
            val setModel = IDODeviceVibrationRingtoneModel(
                operate = 2,
                type = type,
                vibrationIntensity = if (type and 0x01 != 0) getModel.vibrationIntensity else null,
                alarmVolume = if (type and 0x02 != 0) getModel.alarmVolume else null,
                callReminderVolume = if (type and 0x04 != 0) getModel.callReminderVolume else null,
            )
            log("  SET 请求: ${setModel.toJsonString()}")
            Cmds.deviceVibrationRingtone(setModel).send { setRes ->
                closeProgressDialog()
                if (setRes.error.code == 0) {
                    log("  SET code=0 json: ${preview(setRes.res?.toJsonString())}")
                    toast("回写成功")
                } else {
                    log("  SET code=${setRes.error.code} msg=${setRes.error.message}")
                    toast("SET 失败")
                }
            }
        }
    }

    private fun switchValue(v: Int): Int = if (v == 1) 1 else 0

    private fun spo2ModelToParam(model: IDOSpo2SwitchModel) = IDOSpo2SwitchParamModel(
        switchValue(model.onOff),
        model.startHour,
        model.startMinute,
        model.endHour,
        model.endMinute,
        model.lowSpo2OnOff?.let { switchValue(it) },
        model.lowSpo2Value,
        model.notifyFlag,
        model.measurementInterval,
    )

    private fun stressModelToParam(model: IDOStressSwitchModel) = IDOStressSwitchParamModel(
        switchValue(model.onOff),
        model.startHour,
        model.startMinute,
        model.endHour,
        model.endMinute,
        switchValue(model.remindOnOff),
        model.interval,
        model.highThreshold,
        model.stressThreshold,
        model.notifyFlag,
        HashSet(model.repeats),
        model.measurementInterval,
    )

    private fun smartHrModelToParam(model: IDOHeartRateModeSmartModel) = IDOHeartRateModeSmartParamModel(
        switchValue(model.mode),
        model.notifyFlag,
        switchValue(model.highHeartMode),
        switchValue(model.lowHeartMode),
        model.highHeartValue,
        model.lowHeartValue,
        model.startHour,
        model.startMinute,
        model.endHour,
        model.endMinute,
        model.measurementInterval,
    )

    private fun getSpo2Switch() {
        if (!ensureConnected()) return
        log("--- 2.47 血氧开关(查询) (getSpo2Switch) ---")
        showProgressDialog("2.47 血氧 GET")
        Cmds.getSpo2Switch().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                it.res?.let { m -> log("  measurement_interval=${m.measurementInterval}") }
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setSpo2SwitchSample() {
        if (!ensureConnected()) return
        val param = IDOSpo2SwitchParamModel(
            1, 0, 0, 23, 59, 1, 90, 1, 5
        )
        log("--- 2.47 血氧开关(设置) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.47 血氧 SET")
        Cmds.setSpo2Switch(param).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun roundtripSpo2() {
        if (!ensureConnected()) return
        log("--- 2.47 血氧开关 GET→SET 回写 ---")
        showProgressDialog("2.47 血氧回写")
        Cmds.getSpo2Switch().send { getRes ->
            if (getRes.error.code != 0 || getRes.res == null) {
                closeProgressDialog()
                log("  GET 失败，中止")
                toast("GET 失败")
                return@send
            }
            val getModel = getRes.res!!
            log("  GET: ${preview(getModel.toJsonString())}")
            log("  measurement_interval=${getModel.measurementInterval}")
            val param = spo2ModelToParam(getModel)
            log("  SET 请求: ${param.toJsonString()}")
            Cmds.setSpo2Switch(param).send { setRes ->
                closeProgressDialog()
                if (setRes.error.code == 0) {
                    log("  SET code=0 json: ${preview(setRes.res?.toJsonString())}")
                    toast("回写成功")
                } else {
                    log("  SET code=${setRes.error.code} msg=${setRes.error.message}")
                    toast("SET 失败")
                }
            }
        }
    }

    private fun getStressSwitch() {
        if (!ensureConnected()) return
        log("--- 2.46 压力开关(查询) (getStressSwitch) ---")
        showProgressDialog("2.46 压力 GET")
        Cmds.getStressSwitch().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                it.res?.let { m -> log("  measurement_interval=${m.measurementInterval}") }
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setStressSwitchSample() {
        if (!ensureConnected()) return
        val param = IDOStressSwitchParamModel(
            1, 0, 0, 23, 59, 1, 60, 80, 80, 1, hashSetOf(), 5
        )
        log("--- 2.46 压力开关(设置) ---")
        log("  请求: $param")
        showProgressDialog("2.46 压力 SET")
        Cmds.setStressSwitch(param).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun roundtripStress() {
        if (!ensureConnected()) return
        log("--- 2.46 压力开关 GET→SET 回写 ---")
        showProgressDialog("2.46 压力回写")
        Cmds.getStressSwitch().send { getRes ->
            if (getRes.error.code != 0 || getRes.res == null) {
                closeProgressDialog()
                log("  GET 失败，中止")
                toast("GET 失败")
                return@send
            }
            val getModel = getRes.res!!
            log("  GET: ${preview(getModel.toJsonString())}")
            log("  measurement_interval=${getModel.measurementInterval}")
            val param = stressModelToParam(getModel)
            log("  SET 请求: $param")
            Cmds.setStressSwitch(param).send { setRes ->
                closeProgressDialog()
                if (setRes.error.code == 0) {
                    log("  SET code=0 json: ${preview(setRes.res?.toJsonString())}")
                    toast("回写成功")
                } else {
                    log("  SET code=${setRes.error.code} msg=${setRes.error.message}")
                    toast("SET 失败")
                }
            }
        }
    }

    private fun getSmartHrSwitch() {
        if (!ensureConnected()) return
        log("--- 2.45 智能心率(查询) (getSmartHeartRateMode) ---")
        showProgressDialog("2.45 智能心率 GET")
        Cmds.getSmartHeartRateMode().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                it.res?.let { m -> log("  measurement_interval=${m.measurementInterval}") }
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun setSmartHrSwitchSample() {
        if (!ensureConnected()) return
        val param = IDOHeartRateModeSmartParamModel(
            1, 1, 1, 1, 100, 60, 0, 0, 23, 59, 300
        )
        log("--- 2.45 智能心率(设置) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.45 智能心率 SET")
        Cmds.setHeartRateModeSmart(param).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0 json: ${preview(it.res?.toJsonString())}")
                toast("成功")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 code=${it.error.code}")
            }
        }
    }

    private fun roundtripSmartHr() {
        if (!ensureConnected()) return
        log("--- 2.45 智能心率 GET→SET 回写 ---")
        showProgressDialog("2.45 智能心率回写")
        Cmds.getSmartHeartRateMode().send { getRes ->
            if (getRes.error.code != 0 || getRes.res == null) {
                closeProgressDialog()
                log("  GET 失败，中止")
                toast("GET 失败")
                return@send
            }
            val getModel = getRes.res!!
            log("  GET: ${preview(getModel.toJsonString())}")
            log("  measurement_interval=${getModel.measurementInterval}")
            val param = smartHrModelToParam(getModel)
            log("  SET 请求: ${param.toJsonString()}")
            Cmds.setHeartRateModeSmart(param).send { setRes ->
                closeProgressDialog()
                if (setRes.error.code == 0) {
                    log("  SET code=0 json: ${preview(setRes.res?.toJsonString())}")
                    toast("回写成功")
                } else {
                    log("  SET code=${setRes.error.code} msg=${setRes.error.message}")
                    toast("SET 失败")
                }
            }
        }
    }

    private fun getActivitySummaryExchange() {
        if (!ensureConnected()) return
        if (!sdk.dataExchange.supportV3ActivityExchange) {
            log("跳过：不支持 V3 多运动数据交换")
            toast("不支持数据交换")
            return
        }
        log("--- 15.20 运动小结 exchangeData.getLastActivityData() ---")
        showProgressDialog("获取运动小结...")
        sdk.dataExchange.getLastActivityData()
        closeProgressDialog()
        log("getLastActivityData 已触发（详情见 exchangeData 回调）")
        toast("已触发")
    }

    private fun getFullSnapshotExchange() {
        if (!ensureConnected()) return
        log("--- 15.103 全量快照 exchangeData.getActivityExchangeFullSnapshot() ---")
        showProgressDialog("全量快照...")
        sdk.dataExchange.getActivityExchangeFullSnapshot { json ->
            runOnUiThread {
                closeProgressDialog()
                if (!json.isNullOrEmpty()) {
                    log("json: ${preview(json)}")
                    toast("成功")
                } else {
                    log("返回为空或失败")
                    toast("失败")
                }
            }
        }
    }

    private fun syncSpo2() {
        if (!ensureConnected()) return
        if (!sdk.funcTable.syncV3Spo2) {
            log("跳过：syncV3Spo2=false")
            toast("不支持 V3 血氧")
            return
        }
        log("--- 15.4.1 同步血氧 ---")
        showProgressDialog("同步血氧...")
        sdk.syncData.startSync(
            types = listOf(IDOSyncDataType.BLOODOXYGEN),
            funcData = { type, jsonStr, errorCode ->
                if (type != IDOSyncDataType.BLOODOXYGEN) return@startSync
                runOnUiThread {
                    log("血氧 errorCode=$errorCode")
                    if (errorCode == 0 && jsonStr.isNotEmpty()) {
                        log("  payload: ${preview(jsonStr)}")
                    }
                }
            },
            funcCompleted = { errorCode ->
                runOnUiThread {
                    closeProgressDialog()
                    log("血氧完成 errorCode=$errorCode")
                    toast(if (errorCode == 0) "完成" else "失败 $errorCode")
                }
            }
        )
    }

    private fun syncPressure() {
        if (!ensureConnected()) return
        if (!sdk.funcTable.syncV3Pressure) {
            log("跳过：syncV3Pressure=false")
            toast("不支持 V3 压力")
            return
        }
        log("--- 15.4.2 同步压力 ---")
        showProgressDialog("同步压力...")
        sdk.syncData.startSync(
            types = listOf(IDOSyncDataType.PRESSURE),
            funcData = { type, jsonStr, errorCode ->
                if (type != IDOSyncDataType.PRESSURE) return@startSync
                runOnUiThread {
                    log("压力 errorCode=$errorCode")
                    if (errorCode == 0 && jsonStr.isNotEmpty()) {
                        log("  payload: ${preview(jsonStr)}")
                    }
                }
            },
            funcCompleted = { errorCode ->
                runOnUiThread {
                    closeProgressDialog()
                    log("压力完成 errorCode=$errorCode")
                    toast(if (errorCode == 0) "完成" else "失败 $errorCode")
                }
            }
        )
    }

    // MARK: - 2026-07-06 新增功能联调

    private fun logCmd(title: String, res: com.idosmart.pigeon_implement.CmdResponse<*>) {
        if (res.error.code == 0) {
            // CmdResponse<*> 的 res 为星投影，需落到 IDOBaseModel 才能调 toJsonString
            log("  code=0 json: ${preview((res.res as? IDOBaseModel)?.toJsonString())}")
            toast("成功")
        } else {
            log("  code=${res.error.code} msg=${res.error.message}")
            toast("失败 code=${res.error.code}")
        }
    }

    private fun getFirmwareStatusInfo() {
        if (!ensureConnected()) return
        log("--- 2.53 固件状态 (getFirmwareStatusInfo) ---")
        showProgressDialog("2.53 固件状态")
        Cmds.getFirmwareStatusInfo().send {
            closeProgressDialog()
            logCmd("2.53 固件状态", it)
        }
    }

    private fun getHeartRateMode() {
        if (!ensureConnected()) return
        log("--- 2.39 心率监测模式 (getHeartRateMode) ---")
        showProgressDialog("2.39 心率监测")
        Cmds.getHeartRateMode().send {
            closeProgressDialog()
            logCmd("2.39 心率监测", it)
        }
    }

    private fun getAppSleepMode() {
        if (!ensureConnected()) return
        log("--- 2.63 睡眠模式 (getAppSleepMode) ---")
        showProgressDialog("2.63 睡眠模式")
        Cmds.getAppSleepMode().send {
            closeProgressDialog()
            logCmd("2.63 睡眠模式", it)
        }
    }

    private fun getFallMonitoringSwitch() {
        if (!ensureConnected()) return
        log("--- 2.54 跌倒监测 GET (getFallMonitoringSwitch) ---")
        showProgressDialog("2.54 跌倒监测 GET")
        Cmds.getFallMonitoringSwitch().send {
            closeProgressDialog()
            logCmd("2.54 跌倒监测 GET", it)
        }
    }

    private fun getPositionSwitchMode() {
        if (!ensureConnected()) return
        log("--- 2.56 定位开关 GET (getPositionSwitchMode) ---")
        showProgressDialog("2.56 定位开关 GET")
        Cmds.getPositionSwitchMode().send {
            closeProgressDialog()
            logCmd("2.56 定位开关 GET", it)
        }
    }

    private fun getDataTranConfig() {
        if (!ensureConnected()) return
        val param = IDODataTranConfigParamModel(type = 0, medicineType = 1)
        log("--- 2.28 文件传输配置 (getDataTranConfig) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.28 文件传输配置")
        Cmds.getDataTranConfig(param).send {
            closeProgressDialog()
            logCmd("2.28 文件传输配置", it)
        }
    }

    private fun getWatchListV3() {
        if (!ensureConnected()) return
        log("--- 15.26 表盘列表 V3 (getWatchListV3) ---")
        showProgressDialog("15.26 表盘列表")
        Cmds.getWatchListV3().send {
            closeProgressDialog()
            logCmd("15.26 表盘列表", it)
        }
    }

    private fun setFallMonitoringSwitchSample() {
        if (!ensureConnected()) return
        val param = IDOFallMonitoringSwitchModel(fallMonitoringSwitch = 1)
        log("--- 2.54 跌倒监测 SET ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.54 跌倒监测 SET")
        Cmds.setFallMonitoringSwitch(param).send {
            closeProgressDialog()
            logCmd("2.54 跌倒监测 SET", it)
        }
    }

    private fun setPositionSwitchModeSample() {
        if (!ensureConnected()) return
        val param = IDOPositionSwitchModeModel(
            switchMode = 1, startHour = 0, startMinute = 0, endHour = 23, endMinute = 59
        )
        log("--- 2.56 定位开关 SET ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.56 定位开关 SET")
        Cmds.setPositionSwitchMode(param).send {
            closeProgressDialog()
            logCmd("2.56 定位开关 SET", it)
        }
    }

    private fun setLocationInfoNotify() {
        if (!ensureConnected()) return
        val param = IDOLocationInfoNotifyModel(status = 1)
        log("--- 5.6 位置通知 (setLocationInfoNotify) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("5.6 位置通知")
        Cmds.setLocationInfoNotify(param).send {
            closeProgressDialog()
            logCmd("5.6 位置通知", it)
        }
    }

    private fun setHeartRateModeSample() {
        if (!ensureConnected()) return
        val param = IDOHeartRateModeParamModel(1, 1, 0, 0, 23, 59, 5)
        log("--- 2.39 心率监测 SET(示例) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.39 心率监测 SET")
        Cmds.setHeartRateMode(param).send {
            closeProgressDialog()
            logCmd("2.39 心率监测 SET", it)
        }
    }

    private fun setAppSleepModeSample() {
        if (!ensureConnected()) return
        val param = IDOAppSleepModeParamModel(sleepModeSwitch = 1)
        log("--- 2.63 睡眠模式 SET(示例) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("2.63 睡眠模式 SET")
        Cmds.setAppSleepMode(param).send {
            closeProgressDialog()
            logCmd("2.63 睡眠模式 SET", it)
        }
    }

    private fun setHeartModeSample() {
        if (!ensureConnected()) return
        val param = IDOHeartModeParamModel(
            updateTime = 0, mode = 1, hasTimeRange = 1,
            startHour = 0, startMinute = 0, endHour = 23, endMinute = 59,
            measurementInterval = 300, notifyFlag = 1
        )
        log("--- 15.9 V3心率模式(示例) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.9 V3心率模式")
        Cmds.setHeartMode(param).send {
            closeProgressDialog()
            logCmd("15.9 V3心率模式", it)
        }
    }

    private fun getAppletList() {
        if (!ensureConnected()) return
        log("--- 15.54 小程序列表 (setAppletControl queryTypes) ---")
        showProgressDialog("15.54 小程序列表")
        Cmds.setAppletControl(
            IDOAppletListQueryType.DOWNLOADING,
            IDOAppletListQueryType.INSTALLING,
            IDOAppletListQueryType.INSTALLED,
        ).send {
            closeProgressDialog()
            logCmd("15.54 小程序列表", it)
        }
    }

    /** 先查询列表，再删除返回的第一条小程序（operate=2） */
    private fun deleteAppletFirst() {
        if (!ensureConnected()) return
        log("--- 15.54 小程序删除第一个 (先查询再 delete) ---")
        showProgressDialog("15.54 查询小程序列表")
        Cmds.setAppletControl(
            IDOAppletListQueryType.DOWNLOADING,
            IDOAppletListQueryType.INSTALLING,
            IDOAppletListQueryType.INSTALLED,
        ).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.54 小程序列表(删前查询)", queryRes)
                return@send
            }
            logCmd("15.54 小程序列表(删前查询)", queryRes)
            val appName = queryRes.res?.infoItem?.firstOrNull()?.appName
            if (appName.isNullOrEmpty()) {
                closeProgressDialog()
                log("  列表为空或 appName 为空，跳过删除")
                toast("无可删除项")
                return@send
            }
            val param = IDOAppletControlModel(operate = 2, appName = appName)
            log("  删除第一条: $appName")
            log("  请求: ${param.toJsonString()}")
            showProgressDialog("15.54 删除 $appName")
            Cmds.setAppletControl(param).send { delRes ->
                closeProgressDialog()
                logCmd("15.54 小程序删除第一个", delRes)
            }
        }
    }

    private fun setAppBaseInfoSample() {
        if (!ensureConnected()) return
        val param = appBaseInfoSampleParam()
        log("--- 15.79 APP基本信息 (setAppBaseInfo) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.79 APP基本信息")
        Cmds.setAppBaseInfo(param).send {
            closeProgressDialog()
            logCmd("15.79 APP基本信息", it)
        }
    }

    private fun takeMedicineRemindQuery() {
        if (!ensureConnected()) return
        val param = IDOTakeMedicineRemindModel(operate = 2)
        log("--- 15.90 吃药提醒查询 (takeMedicineRemind operate=2) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.90 吃药提醒查询")
        Cmds.takeMedicineRemind(param).send {
            closeProgressDialog()
            logCmd("15.90 吃药提醒查询", it)
        }
    }

    /** 先查询，再删除返回列表第一条（operate=3，index 取首条） */
    private fun takeMedicineRemindDeleteFirst() {
        if (!ensureConnected()) return
        log("--- 15.90 吃药提醒删除第一条 (先查询再 operate=3) ---")
        showProgressDialog("15.90 查询吃药提醒")
        Cmds.takeMedicineRemind(IDOTakeMedicineRemindModel(operate = 2)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.90 吃药提醒(删前查询)", queryRes)
                return@send
            }
            logCmd("15.90 吃药提醒(删前查询)", queryRes)
            val first = queryRes.res?.takeMedicineInfoItems?.firstOrNull()
            val index = first?.index
            if (index == null || index <= 0) {
                closeProgressDialog()
                log("  列表为空或 index 无效，跳过删除")
                toast("无可删除项")
                return@send
            }
            val del = IDOTakeMedicineRemindModel(operate = 3, index = index)
            log("  删除第一条 index=$index name=${first.name}")
            log("  请求: ${del.toJsonString()}")
            showProgressDialog("15.90 吃药提醒删除")
            Cmds.takeMedicineRemind(del).send { delRes ->
                closeProgressDialog()
                logCmd("15.90 吃药提醒删除第一条", delRes)
            }
        }
    }

    private fun takeMedicineRemindSetSwitch() {
        if (!ensureConnected()) return
        val param = IDOTakeMedicineRemindModel(operate = 4, medicineShowOnOff = 1)
        log("--- 15.90 吃药提醒设置总开关 (takeMedicineRemind operate=4) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.90 吃药提醒设置总开关")
        Cmds.takeMedicineRemind(param).send {
            closeProgressDialog()
            logCmd("15.90 吃药提醒设置总开关", it)
        }
    }

    private fun takeMedicineRemindSet() {
        if (!ensureConnected()) return
        val cal1 = java.util.Calendar.getInstance().apply { add(java.util.Calendar.MINUTE, 1) }
        val cal2 = java.util.Calendar.getInstance().apply { add(java.util.Calendar.MINUTE, 2) }
        val t1 = IDOTakeMedicineRemindTimeItemModel().apply {
            hour = cal1.get(java.util.Calendar.HOUR_OF_DAY)
            minute = cal1.get(java.util.Calendar.MINUTE)
        }
        val t2 = IDOTakeMedicineRemindTimeItemModel().apply {
            hour = cal2.get(java.util.Calendar.HOUR_OF_DAY)
            minute = cal2.get(java.util.Calendar.MINUTE)
        }
        val infoItem = IDOTakeMedicineRemindInfoItemModel().apply {
            index = 1
            year = cal1.get(java.util.Calendar.YEAR)
            month = cal1.get(java.util.Calendar.MONTH) + 1
            day = cal1.get(java.util.Calendar.DAY_OF_MONTH)
            repeatValue = 127
            name = "阿司匹林"
            dailyTimes = 2
            timeCount = 2
            timeItems = listOf(t1, t2)
        }
        val param = IDOTakeMedicineRemindModel(
            operate = 1,
            medicineShowOnOff = 1,
            takeMedicineInfoCount = 1,
            takeMedicineInfoItem = infoItem,
        )
        log("--- 15.90 吃药提醒设置 (takeMedicineRemind operate=1) ---")
        log("  提醒时间: ${t1.hour}:${t1.minute.toString().padStart(2, '0')}(+1min), ${t2.hour}:${t2.minute.toString().padStart(2, '0')}(+2min)")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.90 吃药提醒设置")
        Cmds.takeMedicineRemind(param).send {
            closeProgressDialog()
            logCmd("15.90 吃药提醒设置", it)
        }
    }

    private fun takeMedicineRemindIconTransfer() {
        if (!ensureConnected()) return
        val ft = sdk.funcTable
        if (!ft.getNotifyIconAdaptive) {
            log("跳过：support_v3_notify_icon_adaptive=false")
            toast("不支持图标自适应")
            return
        }
        if (!ft.supportTakeMedicineReminder) {
            log("跳过：support_take_medicine_reminder=false")
            toast("不支持吃药提醒")
            return
        }
        log("--- 15.90 吃药提醒图标传输：请选择图片，将裁剪为 160×160 PNG ---")
        pickMedicIconLauncher.launch("image/*")
    }

    /** 中心裁剪为正方后缩放到 160×160，写出临时 PNG（对齐 iOS makeMedicIconPNGFile） */
    private fun makeMedicIconPngFile(uri: Uri): String? {
        val src = try {
            contentResolver.openInputStream(uri)?.use { BitmapFactory.decodeStream(it) }
        } catch (e: Exception) {
            log("读相册图片失败: ${e.message}")
            null
        } ?: return null
        if (src.width <= 0 || src.height <= 0) {
            src.recycle()
            return null
        }
        val side = MEDIC_ICON_PIXEL_SIZE
        val scale = max(side.toFloat() / src.width, side.toFloat() / src.height)
        val drawnW = src.width * scale
        val drawnH = src.height * scale
        val out = Bitmap.createBitmap(side, side, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(out)
        val left = (side - drawnW) / 2f
        val top = (side - drawnH) / 2f
        canvas.drawBitmap(
            src,
            null,
            RectF(left, top, left + drawnW, top + drawnH),
            Paint(Paint.FILTER_BITMAP_FLAG),
        )
        src.recycle()
        val file = File(cacheDir, "medic_icon_160.png")
        return try {
            FileOutputStream(file).use { fos ->
                if (!out.compress(Bitmap.CompressFormat.PNG, 100, fos)) {
                    out.recycle()
                    return null
                }
            }
            out.recycle()
            file.absolutePath
        } catch (e: Exception) {
            out.recycle()
            log("写临时 PNG 失败: ${e.message}")
            null
        }
    }

    private fun startMedicIconTransfer(imgPath: String) {
        log("--- 15.90 吃药提醒图标传输 (.medic / 0x1C) ---")
        log("  源图: $imgPath (160×160 PNG)")
        showProgressDialog("传输图标...")
        val fileSize = File(imgPath).length().toInt()
        val item = IDOTransMedicModel(imgPath, "1", fileSize)
        sdk.transfer.transferFiles(
            fileItems = listOf(item),
            cancelPrevTranTask = true,
            transProgress = { curIdx, total, _, totalProg ->
                log("  进度: ${curIdx + 1}/$total ${(totalProg * 100).toInt()}%")
            },
            transStatus = { curIdx, status, errCode, _ ->
                log("  状态[$curIdx]: $status err=$errCode")
            },
        ) { results ->
            closeProgressDialog()
            val ok = results.isNotEmpty() && results.all { it }
            log("传输完成: $results")
            runOnUiThread {
                toast(if (ok) "图标传输成功" else "图标传输失败")
            }
        }
    }

    private fun setPurchasedWatchFaceInfoSample() {
        if (!ensureConnected()) return
        val param = IDOPurchasedWatchFaceInfoModel(
            paymentStatus = 3, userId = "user_123", watchId = "dial_001"
        )
        log("--- 15.91 已购表盘 (setPurchasedWatchFaceInfo) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.91 已购表盘")
        Cmds.setPurchasedWatchFaceInfo(param).send {
            closeProgressDialog()
            logCmd("15.91 已购表盘", it)
        }
    }

    private fun setAppDownloadStatusInfoSample() {
        if (!ensureConnected()) return
        val param = IDOAppDownloadStatusInfoModel(type = 1, status = 1, id = "watch_face_001")
        log("--- 15.92 下载状态 (setAppDownloadStatusInfo) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.92 下载状态")
        Cmds.setAppDownloadStatusInfo(param).send {
            closeProgressDialog()
            logCmd("15.92 下载状态", it)
        }
    }

    private fun getFirmwarePositionInfoQuery() {
        if (!ensureConnected()) return
        val param = IDOFirmwarePositionInfoModel(operate = 1)
        log("--- 15.93 固件定位查询 (getFirmwarePositionInfo operate=1) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.93 固件定位查询")
        Cmds.getFirmwarePositionInfo(param).send {
            closeProgressDialog()
            logCmd("15.93 固件定位查询", it)
        }
    }

    /** 先查询，再对返回记录的 timestamp 做 operate=2 确认接收 */
    private fun getFirmwarePositionInfoConfirm() {
        if (!ensureConnected()) return
        log("--- 15.93 固件定位确认 (先查询再 operate=2) ---")
        showProgressDialog("15.93 查询定位数据")
        Cmds.getFirmwarePositionInfo(IDOFirmwarePositionInfoModel(operate = 1)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.93 固件定位(确认前查询)", queryRes)
                return@send
            }
            logCmd("15.93 固件定位(确认前查询)", queryRes)
            val model = queryRes.res
            val ts = model?.positionInfoItem?.timestamp
            val count = model?.positionInfoCount ?: 0
            if (ts == null || count <= 0) {
                closeProgressDialog()
                log("  无定位数据或 timestamp 缺失，跳过确认")
                toast("无可确认数据")
                return@send
            }
            val ack = IDOFirmwarePositionInfoModel(operate = 2, timestamp = ts)
            log("  确认 timestamp=$ts")
            log("  请求: ${ack.toJsonString()}")
            showProgressDialog("15.93 确认接收")
            Cmds.getFirmwarePositionInfo(ack).send { ackRes ->
                closeProgressDialog()
                logCmd("15.93 固件定位确认", ackRes)
            }
        }
    }

    private fun appListStyleQuery() {
        if (!ensureConnected()) return
        val param = IDOAppListStyleParamModel(operate = 2)
        log("--- 15.73 应用列表样式查询 (appListStyle operate=2) ---")
        log("  请求: ${param.toJsonString()}")
        showProgressDialog("15.73 应用列表样式查询")
        Cmds.appListStyle(param).send {
            closeProgressDialog()
            it.res?.let { m ->
                log("  已用 ${m.userApplicationListItemNum}/${m.applicationListTotalNum}，list=${m.listItems?.size ?: 0}")
            }
            logCmd("15.73 应用列表样式查询", it)
        }
    }

    /** 先查询，再删除返回列表第一项（operate=3） */
    private fun appListStyleDeleteFirst() {
        if (!ensureConnected()) return
        log("--- 15.73 应用列表样式删除 (先查询再 operate=3) ---")
        showProgressDialog("15.73 查询应用列表样式")
        Cmds.appListStyle(IDOAppListStyleParamModel(operate = 2)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.73 应用列表样式(删前查询)", queryRes)
                return@send
            }
            logCmd("15.73 应用列表样式(删前查询)", queryRes)
            val first = queryRes.res?.listItems?.firstOrNull()
            val name = first?.name
            if (name.isNullOrEmpty()) {
                closeProgressDialog()
                log("  列表为空或 name 为空，跳过删除")
                toast("无可删除项")
                return@send
            }
            val del = IDOAppListStyleParamModel(operate = 3, name = name)
            log("  删除 name=$name")
            log("  请求: ${del.toJsonString()}")
            showProgressDialog("15.73 应用列表样式删除")
            Cmds.appListStyle(del).send { delRes ->
                closeProgressDialog()
                logCmd("15.73 应用列表样式删除", delRes)
            }
        }
    }

    private fun appBaseInfoSampleParam() = IDOAppInfoModel(
        operate = 1,
        userName = "mssj52u@163.com",
        userId = "271314614262829056",
        token = APP_BASE_INFO_SAMPLE_TOKEN,
        domainName = "ali",
        appVersion = "3.5.0",
        appKey = "548a50bc9f0a45d0bdfcdb5d194641d8",
        phoneSystem = 1,
        isFilterWatch = 2,
        appFaceVersion = "6",
    )

    companion object {
        /** 吃药提醒图标边长（像素），协议 `.medic` 要求 160×160 PNG */
        private const val MEDIC_ICON_PIXEL_SIZE = 160

        private const val APP_BASE_INFO_SAMPLE_TOKEN =
            "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRldGltZSI6MTc4MzkyODcwNjkzMiwidXNlcl90eXBlIjoiVVNFUiIsInVzZXJfaWQiOiIyNzEzMTQ2MTQyNjI4MjkwNTYiLCJzb3VyY2UiOiJhcHAiLCJ0eXBlIjoiYXBwIiwiYXBwX2lkIjoiMTAwMDAiLCJhY2NvdW50IjoibXNzajUydUAxNjMuY29tIiwiaWF0IjoxNzgzOTI4NzA2LCJleHAiOjQ5Mzc1Mjg3MDZ9.-FPYg231BUTM2LzfihWdIeoStGJGNT6G1Oga0Ik6VWsivIhWTfQzH32C5to7C5txa5QhmVhW-aAD9q73phOeAw"
    }
}
