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
import com.idosmart.model.IDODeviceVibrationRingtoneModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOExchangeDataDelegate
import com.idosmart.protocol_sdk.IDOBleExecType
import com.idosmart.protocol_sdk.IDOBleReplyType
import kotlinx.android.synthetic.main.activity_sdk_feature_test.ll_buttons
import kotlinx.android.synthetic.main.activity_sdk_feature_test.sv_log
import kotlinx.android.synthetic.main.activity_sdk_feature_test.tv_log

/**
 * 标准化 SDK 已落地功能联调（对齐 Flutter SdkFeatureTestPage / iOS SdkFeatureTestVC）
 */
class SdkFeatureTestActivity : BaseActivity() {

    private val logBuffer = StringBuilder()
    private var supportSyncTypesText = ""

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
                "15.106 振动铃声" to { getVibrationRingtone() },
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
}
