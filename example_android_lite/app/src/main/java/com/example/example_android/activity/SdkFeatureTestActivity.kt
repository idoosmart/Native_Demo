package com.example.example_android.activity

import android.graphics.Typeface
import android.view.Gravity
import android.view.Menu
import android.view.MenuItem
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.idosmart.enums.IDOSyncDataType
import com.idosmart.model.IDOAppDownloadStatusInfoModel
import com.idosmart.model.IDOAppInfoModel
import com.idosmart.model.IDOAppListStyleParamModel
import com.idosmart.model.IDOAppSleepModeParamModel
import com.idosmart.model.IDOAppletControlModel
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
import com.idosmart.model.IDODeviceVibrationRingtoneModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOExchangeDataDelegate
import com.idosmart.model.IDOBleExecType
import com.idosmart.model.IDOBleReplyType
import kotlinx.android.synthetic.main.activity_sdk_feature_test.ll_buttons
import kotlinx.android.synthetic.main.activity_sdk_feature_test.sv_log
import kotlinx.android.synthetic.main.activity_sdk_feature_test.tv_log

/**
 * 标准化 SDK 已落地功能联调（对齐 Flutter SdkFeatureTestPage / iOS SdkFeatureTestVC）
 * Integration test of the standardized SDK features already delivered (aligned with Flutter SdkFeatureTestPage / iOS SdkFeatureTestVC)
 */
class SdkFeatureTestActivity : BaseActivity() {

    private val logBuffer = StringBuilder()
    private var supportSyncTypesText = ""

    private val exchangeDelegate = object : IDOExchangeDataDelegate {
        override fun appListenBleExec(type: IDOBleExecType) {
            // 本页仅联调 app 侧主动请求
            // This page only exercises app-initiated requests
        }

        override fun appListenAppExec(type: IDOBleReplyType) {
            when (type) {
                is IDOBleReplyType.appActivityDataReply -> {
                    val model = type.model
                    log(
                        "[exchangeData] 15.20 运动小结 / Sport summary step=${model?.step} distance=${model?.distance}"
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
            "基础获取类 / Basic get Cmd",
            listOf(
                "2.61 设备状态 / Device status" to { getDeviceStatus() },
                "15.104 左右手运动 / Wrist-side sports" to { getSportTypesWristSide() },
                "15.106 振动铃声 / Vibration ringtone" to { getVibrationRingtone() },
            )
        )
        appendSection(
            "数据交换 / Data exchange exchangeData",
            listOf(
                "15.20 运动小结 / Sport summary" to { getActivitySummaryExchange() },
                "15.103 全量快照 / Full snapshot" to { getFullSnapshotExchange() },
            )
        )
        appendSection(
            "健康同步 / Health sync syncData",
            listOf(
                "15.4.1 血氧 / SpO2" to { syncSpo2() },
                "15.4.2 压力 / Stress" to { syncPressure() },
            )
        )
        appendSection(
            "2026-07-06 新增 / New GET",
            listOf(
                "2.53 固件状态 / Firmware status" to { getFirmwareStatusInfo() },
                "2.39 心率监测模式 / Heart rate monitoring mode" to { getHeartRateMode() },
                "2.63 睡眠模式 / Sleep mode GET" to { getAppSleepMode() },
                "2.54 跌倒监测 / Fall monitoring GET" to { getFallMonitoringSwitch() },
                "2.56 定位开关 / Positioning switch GET" to { getPositionSwitchMode() },
                "2.28 文件传输配置 / File transfer config" to { getDataTranConfig() },
                "15.26 表盘列表 / Watch face list V3" to { getWatchListV3() },
            )
        )
        appendSection(
            "2026-07-06 新增 SET/查询 / New SET/query",
            listOf(
                "2.54 跌倒监测 / Fall monitoring SET" to { setFallMonitoringSwitchSample() },
                "2.56 定位开关 / Positioning switch SET" to { setPositionSwitchModeSample() },
                "5.6 位置通知 / Location notification" to { setLocationInfoNotify() },
                "2.39 心率监测 SET(示例) / Heart rate monitoring SET(example)" to { setHeartRateModeSample() },
                "2.63 睡眠模式 SET(示例) / Sleep mode SET(example)" to { setAppSleepModeSample() },
                "15.9 V3心率模式(示例) / V3 heart rate mode (example)" to { setHeartModeSample() },
                "15.54 小程序列表 / Applet list" to { getAppletList() },
                "15.54 小程序删除第一个 / Delete first applet" to { deleteAppletFirst() },
                "15.79 APP基本信息 / APP basic info" to { setAppBaseInfoSample() },
                "15.90 吃药提醒查询 / Medication reminder query" to { takeMedicineRemindQuery() },
                "15.90 吃药提醒删除第一条 / Medication reminder delete first" to { takeMedicineRemindDeleteFirst() },
                "15.90 吃药提醒设置总开关 / Medication reminder set master switch" to { takeMedicineRemindSetSwitch() },
                "15.91 已购表盘 / Purchased watch faces" to { setPurchasedWatchFaceInfoSample() },
                "15.92 下载状态 / Download status" to { setAppDownloadStatusInfoSample() },
                "15.93 固件定位查询 / Firmware position query" to { getFirmwarePositionInfoQuery() },
                "15.93 固件定位确认 / Firmware position confirm" to { getFirmwarePositionInfoConfirm() },
                "15.73 应用列表样式查询 / App list style query" to { appListStyleQuery() },
                "15.73 应用列表样式删除 / App list style delete" to { appListStyleDeleteFirst() },
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
        tv_log.text = if (logBuffer.isEmpty()) "（无日志） / (no log)" else logBuffer.toString()
        sv_log.post { sv_log.fullScroll(ScrollView.FOCUS_DOWN) }
    }

    private fun refreshFuncTableSummary() {
        val ft = sdk.funcTable
        sdk.syncData.getSupportSyncDataTypeList { list ->
            runOnUiThread {
                supportSyncTypesText = list.joinToString { it.name }
                val summary = """
                    【连接 / Connection】${if (sdk.state.isConnected) "已连接 / Connected" else "未连接 / Disconnected"}
                    【健康同步】spo2=${ft.syncV3Spo2} pressure=${ft.syncV3Pressure} / [Health sync] spo2=${ft.syncV3Spo2} pressure=${ft.syncV3Pressure}
                      血氧version兼容=${ft.getSupportSyncSpo2UseVersionCompatible} / SpO2 version compatible=${ft.getSupportSyncSpo2UseVersionCompatible}
                      压力version兼容=${ft.getSupportSyncPressureUseVersionCompatible} / Stress version compatible=${ft.getSupportSyncPressureUseVersionCompatible}
                    【数据交换】syncV3ActivityExchangeData=${ft.syncV3ActivityExchangeData} / [Data exchange] syncV3ActivityExchangeData=${ft.syncV3ActivityExchangeData}
                      supportV3ActivityExchange=${sdk.dataExchange.supportV3ActivityExchange}
                    支持同步类型 / Supported sync types: $supportSyncTypesText
                """.trimIndent()
                log(summary)
            }
        }
    }

    private fun ensureConnected(): Boolean {
        if (sdk.state.isConnected) return true
        toast("未连接设备 / No device connected")
        log("错误：设备未连接 / Error: device not connected")
        return false
    }

    private fun preview(text: String?, limit: Int = 800): String {
        if (text.isNullOrEmpty()) return "NULL"
        return if (text.length <= limit) text else text.substring(0, limit) + "..."
    }

    private fun getDeviceStatus() {
        if (!ensureConnected()) return
        log("--- 2.61 设备状态 / Device status (getDeviceStatusInfo) ---")
        log("  请求 / Request: {\"get_type\":1}")
        showProgressDialog("2.61 设备状态 / Device status")
        Cmds.getDeviceStatusInfo(1).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功 / Succeeded")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 / Failed code=${it.error.code}")
            }
        }
    }

    private fun getSportTypesWristSide() {
        if (!ensureConnected()) return
        log("--- 15.104 左右手运动类型 / Wrist-side sport types (getSportTypesRequiringWristSideSetting) ---")
        log("  请求 / Request: {}")
        showProgressDialog("15.104 左右手运动 / Wrist-side sports")
        Cmds.getSportTypesRequiringWristSideSetting().send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功 / Succeeded")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 / Failed code=${it.error.code}")
            }
        }
    }

    private fun getVibrationRingtone() {
        if (!ensureConnected()) return
        log("--- 15.106 振动铃声(查询) / Vibration & ringtone (query) (deviceVibrationRingtone) ---")
        log("  请求 / Request: {\"operate\":1}")
        showProgressDialog("15.106 振动铃声 / Vibration & ringtone")
        Cmds.deviceVibrationRingtone(IDODeviceVibrationRingtoneModel(operate = 1)).send {
            closeProgressDialog()
            if (it.error.code == 0) {
                log("  code=0")
                log("  json: ${preview(it.res?.toJsonString())}")
                toast("成功 / Succeeded")
            } else {
                log("  code=${it.error.code} msg=${it.error.message}")
                toast("失败 / Failed code=${it.error.code}")
            }
        }
    }

    private fun getActivitySummaryExchange() {
        if (!ensureConnected()) return
        if (!sdk.dataExchange.supportV3ActivityExchange) {
            log("跳过：不支持 V3 多运动数据交换 / Skipped: V3 multi-sport data exchange not supported")
            toast("不支持数据交换 / Data exchange not supported")
            return
        }
        log("--- 15.20 运动小结 / Sport summary exchangeData.getLastActivityData() ---")
        showProgressDialog("获取运动小结 / Getting sport summary...")
        sdk.dataExchange.getLastActivityData()
        closeProgressDialog()
        log("getLastActivityData 已触发（详情见 exchangeData 回调） / triggered (see the exchangeData callback for details)")
        toast("已触发 / Triggered")
    }

    private fun getFullSnapshotExchange() {
        if (!ensureConnected()) return
        log("--- 15.103 全量快照 / Full snapshot exchangeData.getActivityExchangeFullSnapshot() ---")
        showProgressDialog("全量快照 / Full snapshot...")
        sdk.dataExchange.getActivityExchangeFullSnapshot { json ->
            runOnUiThread {
                closeProgressDialog()
                if (!json.isNullOrEmpty()) {
                    log("json: ${preview(json)}")
                    toast("成功 / Succeeded")
                } else {
                    log("返回为空或失败 / Empty result or failed")
                    toast("失败 / Failed")
                }
            }
        }
    }

    private fun syncSpo2() {
        if (!ensureConnected()) return
        if (!sdk.funcTable.syncV3Spo2) {
            log("跳过：syncV3Spo2=false / Skipped: syncV3Spo2=false")
            toast("不支持 V3 血氧 / V3 SpO2 not supported")
            return
        }
        log("--- 15.4.1 同步血氧 / Sync SpO2 ---")
        showProgressDialog("同步血氧 / Syncing SpO2...")
        sdk.syncData.startSync(
            types = listOf(IDOSyncDataType.BLOODOXYGEN),
            funcData = { type, jsonStr, errorCode ->
                if (type != IDOSyncDataType.BLOODOXYGEN) return@startSync
                runOnUiThread {
                    log("血氧 / SpO2 errorCode=$errorCode")
                    if (errorCode == 0 && jsonStr.isNotEmpty()) {
                        log("  payload: ${preview(jsonStr)}")
                    }
                }
            },
            funcCompleted = { errorCode ->
                runOnUiThread {
                    closeProgressDialog()
                    log("血氧完成 / SpO2 done errorCode=$errorCode")
                    toast(if (errorCode == 0) "完成 / Done" else "失败 / Failed $errorCode")
                }
            }
        )
    }

    private fun syncPressure() {
        if (!ensureConnected()) return
        if (!sdk.funcTable.syncV3Pressure) {
            log("跳过：syncV3Pressure=false / Skipped: syncV3Pressure=false")
            toast("不支持 V3 压力 / V3 stress not supported")
            return
        }
        log("--- 15.4.2 同步压力 / Sync stress ---")
        showProgressDialog("同步压力 / Syncing stress...")
        sdk.syncData.startSync(
            types = listOf(IDOSyncDataType.PRESSURE),
            funcData = { type, jsonStr, errorCode ->
                if (type != IDOSyncDataType.PRESSURE) return@startSync
                runOnUiThread {
                    log("压力 / Stress errorCode=$errorCode")
                    if (errorCode == 0 && jsonStr.isNotEmpty()) {
                        log("  payload: ${preview(jsonStr)}")
                    }
                }
            },
            funcCompleted = { errorCode ->
                runOnUiThread {
                    closeProgressDialog()
                    log("压力完成 / Stress done errorCode=$errorCode")
                    toast(if (errorCode == 0) "完成 / Done" else "失败 / Failed $errorCode")
                }
            }
        )
    }

    // MARK: - 2026-07-06 新增功能联调 / New feature integration test

    private fun logCmd(title: String, res: com.idosmart.pigeon_implement.CmdResponse<*>) {
        if (res.error.code == 0) {
            // CmdResponse<*> 的 res 为星投影，需落到 IDOBaseModel 才能调 toJsonString
            // CmdResponse<*> uses a star projection for res; it must be cast to IDOBaseModel before calling toJsonString
            log("  code=0 json: ${preview((res.res as? IDOBaseModel)?.toJsonString())}")
            toast("成功 / Succeeded")
        } else {
            log("  code=${res.error.code} msg=${res.error.message}")
            toast("失败 / Failed code=${res.error.code}")
        }
    }

    private fun getFirmwareStatusInfo() {
        if (!ensureConnected()) return
        log("--- 2.53 固件状态 / Firmware status (getFirmwareStatusInfo) ---")
        showProgressDialog("2.53 固件状态 / Firmware status")
        Cmds.getFirmwareStatusInfo().send { closeProgressDialog(); logCmd("2.53 固件状态 / Firmware status", it) }
    }

    private fun getHeartRateMode() {
        if (!ensureConnected()) return
        log("--- 2.39 心率监测模式 / Heart rate monitoring mode (getHeartRateMode) ---")
        showProgressDialog("2.39 心率监测 / Heart rate monitoring")
        Cmds.getHeartRateMode().send { closeProgressDialog(); logCmd("2.39 心率监测 / Heart rate monitoring", it) }
    }

    private fun getAppSleepMode() {
        if (!ensureConnected()) return
        log("--- 2.63 睡眠模式 / Sleep mode (getAppSleepMode) ---")
        showProgressDialog("2.63 睡眠模式 / Sleep mode")
        Cmds.getAppSleepMode().send { closeProgressDialog(); logCmd("2.63 睡眠模式 / Sleep mode", it) }
    }

    private fun getFallMonitoringSwitch() {
        if (!ensureConnected()) return
        log("--- 2.54 跌倒监测 / Fall monitoring GET ---")
        showProgressDialog("2.54 跌倒监测 / Fall monitoring GET")
        Cmds.getFallMonitoringSwitch().send { closeProgressDialog(); logCmd("2.54 跌倒监测 / Fall monitoring GET", it) }
    }

    private fun getPositionSwitchMode() {
        if (!ensureConnected()) return
        log("--- 2.56 定位开关 / Positioning switch GET ---")
        showProgressDialog("2.56 定位开关 / Positioning switch GET")
        Cmds.getPositionSwitchMode().send { closeProgressDialog(); logCmd("2.56 定位开关 / Positioning switch GET", it) }
    }

    private fun getDataTranConfig() {
        if (!ensureConnected()) return
        val param = IDODataTranConfigParamModel(type = 0, medicineType = 1)
        log("--- 2.28 文件传输配置 --- 请求 / File transfer config --- request: ${param.toJsonString()}")
        showProgressDialog("2.28 文件传输配置 / File transfer config")
        Cmds.getDataTranConfig(param).send { closeProgressDialog(); logCmd("2.28 文件传输配置 / File transfer config", it) }
    }

    private fun getWatchListV3() {
        if (!ensureConnected()) return
        log("--- 15.26 表盘列表 / Watch face list V3 ---")
        showProgressDialog("15.26 表盘列表 / Watch face list")
        Cmds.getWatchListV3().send { closeProgressDialog(); logCmd("15.26 表盘列表 / Watch face list", it) }
    }

    private fun setFallMonitoringSwitchSample() {
        if (!ensureConnected()) return
        val param = IDOFallMonitoringSwitchModel(fallMonitoringSwitch = 1)
        log("--- 2.54 跌倒监测 SET --- 请求 / Fall monitoring SET --- request: ${param.toJsonString()}")
        showProgressDialog("2.54 跌倒监测 / Fall monitoring SET")
        Cmds.setFallMonitoringSwitch(param).send { closeProgressDialog(); logCmd("2.54 跌倒监测 / Fall monitoring SET", it) }
    }

    private fun setPositionSwitchModeSample() {
        if (!ensureConnected()) return
        val param = IDOPositionSwitchModeModel(switchMode = 1, startHour = 0, startMinute = 0, endHour = 23, endMinute = 59)
        log("--- 2.56 定位开关 SET --- 请求 / Positioning switch SET --- request: ${param.toJsonString()}")
        showProgressDialog("2.56 定位开关 / Positioning switch SET")
        Cmds.setPositionSwitchMode(param).send { closeProgressDialog(); logCmd("2.56 定位开关 / Positioning switch SET", it) }
    }

    private fun setLocationInfoNotify() {
        if (!ensureConnected()) return
        val param = IDOLocationInfoNotifyModel(status = 1)
        log("--- 5.6 位置通知 --- 请求 / Location notification --- request: ${param.toJsonString()}")
        showProgressDialog("5.6 位置通知 / Location notification")
        Cmds.setLocationInfoNotify(param).send { closeProgressDialog(); logCmd("5.6 位置通知 / Location notification", it) }
    }

    private fun setHeartRateModeSample() {
        if (!ensureConnected()) return
        val param = IDOHeartRateModeParamModel(1, 1, 0, 0, 23, 59, 5)
        log("--- 2.39 心率监测 SET --- 请求 / Heart rate monitoring SET --- request: ${param.toJsonString()}")
        showProgressDialog("2.39 心率监测 / Heart rate monitoring SET")
        Cmds.setHeartRateMode(param).send { closeProgressDialog(); logCmd("2.39 心率监测 / Heart rate monitoring SET", it) }
    }

    private fun setAppSleepModeSample() {
        if (!ensureConnected()) return
        val param = IDOAppSleepModeParamModel(sleepModeSwitch = 1)
        log("--- 2.63 睡眠模式 SET --- 请求 / Sleep mode SET --- request: ${param.toJsonString()}")
        showProgressDialog("2.63 睡眠模式 / Sleep mode SET")
        Cmds.setAppSleepMode(param).send { closeProgressDialog(); logCmd("2.63 睡眠模式 / Sleep mode SET", it) }
    }

    private fun setHeartModeSample() {
        if (!ensureConnected()) return
        val param = IDOHeartModeParamModel(
            updateTime = 0, mode = 1, hasTimeRange = 1,
            startHour = 0, startMinute = 0, endHour = 23, endMinute = 59,
            measurementInterval = 300, notifyFlag = 1
        )
        log("--- 15.9 V3心率模式 --- 请求 / V3 heart rate mode --- request: ${param.toJsonString()}")
        showProgressDialog("15.9 V3心率模式 / V3 heart rate mode")
        Cmds.setHeartMode(param).send { closeProgressDialog(); logCmd("15.9 V3心率模式 / V3 heart rate mode", it) }
    }

    private fun getAppletList() {
        if (!ensureConnected()) return
        val param = IDOAppletControlModel(operate = 3)
        log("--- 15.54 小程序列表 --- 请求 / Applet list --- request: ${param.toJsonString()}")
        showProgressDialog("15.54 小程序列表 / Applet list")
        Cmds.setAppletControl(param).send { closeProgressDialog(); logCmd("15.54 小程序列表 / Applet list", it) }
    }

    /** 先查询列表，再删除返回的第一条小程序（operate=2） */
    /** Query the list first, then delete the first applet returned (operate=2) */
    private fun deleteAppletFirst() {
        if (!ensureConnected()) return
        log("--- 15.54 小程序删除第一个 (先查询再 delete) / Delete first applet (query first, then delete) ---")
        showProgressDialog("15.54 查询小程序列表 / Query applet list")
        Cmds.setAppletControl(IDOAppletControlModel(operate = 3)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.54 小程序列表(删前查询) / Applet list (pre-delete query)", queryRes)
                return@send
            }
            logCmd("15.54 小程序列表(删前查询) / Applet list (pre-delete query)", queryRes)
            val appName = queryRes.res?.infoItem?.firstOrNull()?.appName
            if (appName.isNullOrEmpty()) {
                closeProgressDialog()
                log("  列表为空或 appName 为空，跳过删除 / List is empty or appName is empty, skipping delete")
                toast("无可删除项 / Nothing to delete")
                return@send
            }
            val param = IDOAppletControlModel(operate = 2, appName = appName)
            log("  删除第一条 / Deleting first item: $appName")
            log("  请求 / Request: ${param.toJsonString()}")
            showProgressDialog("15.54 删除 / Delete $appName")
            Cmds.setAppletControl(param).send { delRes ->
                closeProgressDialog()
                logCmd("15.54 小程序删除第一个 / Delete first applet", delRes)
            }
        }
    }

    private fun setAppBaseInfoSample() {
        if (!ensureConnected()) return
        val param = appBaseInfoSampleParam()
        log("--- 15.79 APP基本信息 --- 请求 / APP basic info --- request: ${param.toJsonString()}")
        showProgressDialog("15.79 APP基本信息 / APP basic info")
        Cmds.setAppBaseInfo(param).send { closeProgressDialog(); logCmd("15.79 APP基本信息 / APP basic info", it) }
    }

    private fun takeMedicineRemindQuery() {
        if (!ensureConnected()) return
        val param = IDOTakeMedicineRemindModel(operate = 2)
        log("--- 15.90 吃药提醒查询 --- 请求 / Medication reminder query --- request: ${param.toJsonString()}")
        showProgressDialog("15.90 吃药提醒查询 / Medication reminder query")
        Cmds.takeMedicineRemind(param).send { closeProgressDialog(); logCmd("15.90 吃药提醒查询 / Medication reminder query", it) }
    }

    /** 先查询，再删除返回列表第一条（operate=3，index 取首条） */
    /** Query first, then delete the first item of the returned list (operate=3, index of the first item) */
    private fun takeMedicineRemindDeleteFirst() {
        if (!ensureConnected()) return
        log("--- 15.90 吃药提醒删除第一条 (先查询再 operate=3) / Medication reminder delete first (query first, then operate=3) ---")
        showProgressDialog("15.90 查询吃药提醒 / Query medication reminders")
        Cmds.takeMedicineRemind(IDOTakeMedicineRemindModel(operate = 2)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.90 吃药提醒(删前查询) / Medication reminder (pre-delete query)", queryRes)
                return@send
            }
            logCmd("15.90 吃药提醒(删前查询) / Medication reminder (pre-delete query)", queryRes)
            val first = queryRes.res?.takeMedicineInfoItems?.firstOrNull()
            val index = first?.index
            if (index == null || index <= 0) {
                closeProgressDialog()
                log("  列表为空或 index 无效，跳过删除 / List is empty or index is invalid, skipping delete")
                toast("无可删除项 / Nothing to delete")
                return@send
            }
            val del = IDOTakeMedicineRemindModel(operate = 3, index = index)
            log("  删除第一条 / Deleting first item index=$index name=${first.name}")
            log("  请求 / Request: ${del.toJsonString()}")
            showProgressDialog("15.90 吃药提醒删除 / Medication reminder delete")
            Cmds.takeMedicineRemind(del).send { delRes ->
                closeProgressDialog()
                logCmd("15.90 吃药提醒删除第一条 / Medication reminder delete first", delRes)
            }
        }
    }

    private fun takeMedicineRemindSetSwitch() {
        if (!ensureConnected()) return
        val param = IDOTakeMedicineRemindModel(operate = 4, medicineShowOnOff = 1)
        log("--- 15.90 吃药提醒设置总开关 --- 请求 / Medication reminder master switch --- request: ${param.toJsonString()}")
        showProgressDialog("15.90 吃药提醒设置总开关 / Medication reminder set master switch")
        Cmds.takeMedicineRemind(param).send { closeProgressDialog(); logCmd("15.90 吃药提醒设置总开关 / Medication reminder master switch", it) }
    }

    private fun setPurchasedWatchFaceInfoSample() {
        if (!ensureConnected()) return
        val param = IDOPurchasedWatchFaceInfoModel(paymentStatus = 3, userId = "user_123", watchId = "dial_001")
        log("--- 15.91 已购表盘 --- 请求 / Purchased watch face --- request: ${param.toJsonString()}")
        showProgressDialog("15.91 已购表盘 / Purchased watch faces")
        Cmds.setPurchasedWatchFaceInfo(param).send { closeProgressDialog(); logCmd("15.91 已购表盘 / Purchased watch face", it) }
    }

    private fun setAppDownloadStatusInfoSample() {
        if (!ensureConnected()) return
        val param = IDOAppDownloadStatusInfoModel(type = 1, status = 1, id = "watch_face_001")
        log("--- 15.92 下载状态 --- 请求 / Download status --- request: ${param.toJsonString()}")
        showProgressDialog("15.92 下载状态 / Download status")
        Cmds.setAppDownloadStatusInfo(param).send { closeProgressDialog(); logCmd("15.92 下载状态 / Download status", it) }
    }

    private fun getFirmwarePositionInfoQuery() {
        if (!ensureConnected()) return
        val param = IDOFirmwarePositionInfoModel(operate = 1)
        log("--- 15.93 固件定位查询 --- 请求 / Firmware positioning query --- request: ${param.toJsonString()}")
        showProgressDialog("15.93 固件定位查询 / Firmware position query")
        Cmds.getFirmwarePositionInfo(param).send { closeProgressDialog(); logCmd("15.93 固件定位查询 / Firmware positioning query", it) }
    }

    /** 先查询，再对返回记录的 timestamp 做 operate=2 确认接收 */
    /** Query first, then confirm receipt of the returned record's timestamp with operate=2 */
    private fun getFirmwarePositionInfoConfirm() {
        if (!ensureConnected()) return
        log("--- 15.93 固件定位确认 (先查询再 operate=2) / Firmware positioning confirm (query first, then operate=2) ---")
        showProgressDialog("15.93 查询定位数据 / Query position data")
        Cmds.getFirmwarePositionInfo(IDOFirmwarePositionInfoModel(operate = 1)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.93 固件定位(确认前查询) / Firmware position (pre-confirm query)", queryRes)
                return@send
            }
            logCmd("15.93 固件定位(确认前查询) / Firmware position (pre-confirm query)", queryRes)
            val ts = queryRes.res?.positionInfoItem?.timestamp
            val count = queryRes.res?.positionInfoCount ?: 0
            if (ts == null || count <= 0) {
                closeProgressDialog()
                log("  无定位数据或 timestamp 缺失，跳过确认 / No position data or timestamp missing, skipping confirm")
                toast("无可确认数据 / No data to confirm")
                return@send
            }
            val ack = IDOFirmwarePositionInfoModel(operate = 2, timestamp = ts)
            log("  确认 timestamp=$ts 请求 / Confirm timestamp=$ts request: ${ack.toJsonString()}")
            showProgressDialog("15.93 确认接收 / Confirm receipt")
            Cmds.getFirmwarePositionInfo(ack).send { ackRes ->
                closeProgressDialog()
                logCmd("15.93 固件定位确认 / Firmware position confirm", ackRes)
            }
        }
    }

    private fun appListStyleQuery() {
        if (!ensureConnected()) return
        val param = IDOAppListStyleParamModel(operate = 2)
        log("--- 15.73 应用列表样式查询 --- 请求 / App list style query --- request: ${param.toJsonString()}")
        showProgressDialog("15.73 应用列表样式查询 / App list style query")
        Cmds.appListStyle(param).send {
            closeProgressDialog()
            it.res?.let { m ->
                log("  已用 ${m.userApplicationListItemNum}/${m.applicationListTotalNum}，list=${m.listItems?.size ?: 0} / Used ${m.userApplicationListItemNum}/${m.applicationListTotalNum}, list=${m.listItems?.size ?: 0}")
            }
            logCmd("15.73 应用列表样式查询 / App list style query", it)
        }
    }

    private fun appListStyleDeleteFirst() {
        if (!ensureConnected()) return
        log("--- 15.73 应用列表样式删除 (先查询再 operate=3) / App list style delete (query first, then operate=3) ---")
        showProgressDialog("15.73 查询应用列表样式 / Query app list style")
        Cmds.appListStyle(IDOAppListStyleParamModel(operate = 2)).send { queryRes ->
            if (queryRes.error.code != 0) {
                closeProgressDialog()
                logCmd("15.73 应用列表样式(删前查询) / App list style (pre-delete query)", queryRes)
                return@send
            }
            logCmd("15.73 应用列表样式(删前查询) / App list style (pre-delete query)", queryRes)
            val name = queryRes.res?.listItems?.firstOrNull()?.name
            if (name.isNullOrEmpty()) {
                closeProgressDialog()
                log("  列表为空或 name 为空，跳过删除 / List is empty or name is empty, skipping delete")
                toast("无可删除项 / Nothing to delete")
                return@send
            }
            val del = IDOAppListStyleParamModel(operate = 3, name = name)
            log("  删除 name=$name 请求 / Delete name=$name request: ${del.toJsonString()}")
            showProgressDialog("15.73 应用列表样式删除 / App list style delete")
            Cmds.appListStyle(del).send { delRes ->
                closeProgressDialog()
                logCmd("15.73 应用列表样式删除 / App list style delete", delRes)
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
        private const val APP_BASE_INFO_SAMPLE_TOKEN =
            "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJkYXRldGltZSI6MTc4MzkyODcwNjkzMiwidXNlcl90eXBlIjoiVVNFUiIsInVzZXJfaWQiOiIyNzEzMTQ2MTQyNjI4MjkwNTYiLCJzb3VyY2UiOiJhcHAiLCJ0eXBlIjoiYXBwIiwiYXBwX2lkIjoiMTAwMDAiLCJhY2NvdW50IjoibXNzajUydUAxNjMuY29tIiwiaWF0IjoxNzgzOTI4NzA2LCJleHAiOjQ5Mzc1Mjg3MDZ9.-FPYg231BUTM2LzfihWdIeoStGJGNT6G1Oga0Ik6VWsivIhWTfQzH32C5to7C5txa5QhmVhW-aAD9q73phOeAw"
    }
}
