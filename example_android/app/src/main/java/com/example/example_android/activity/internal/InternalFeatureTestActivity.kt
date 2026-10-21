package com.example.example_android.activity.internal

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Typeface
import android.view.Gravity
import android.view.Menu
import android.view.MenuItem
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import com.example.example_android.R
import com.example.example_android.activity.MainActivity
import com.example.example_android.base.BaseActivity
import com.example.example_android.util.FunctionUtils
import com.idosmart.enums.IDOBindStatus
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDOEncryptedAuthData
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.activity_internal_feature_test.ll_buttons
import kotlinx.android.synthetic.main.activity_internal_feature_test.sv_log
import kotlinx.android.synthetic.main.activity_internal_feature_test.tv_log

/**
 * 内部功能测试：脏数据 / 边界 JSON / 本地解码 / 绑定加密授权等。
 * 临时从 channel example 同步到 native Full（联调）。
 */
class InternalFeatureTestActivity : BaseActivity() {

    private val logBuffer = StringBuilder()
    private var device: IDOBleDeviceModel? = null

    override fun getLayoutId(): Int = R.layout.activity_internal_feature_test

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.internal_feature_test)
        device = intent.getSerializableExtra(MainActivity.DEVICE) as? IDOBleDeviceModel
        setupButtons()
        log("Internal Feature Test — native Full temp sync from channel example")
        val mac = resolveMacAddress()
        if (mac != null) {
            log("current mac=$mac")
        } else {
            log("current mac=(none) — set/get 需 mac；可从 Function 页带入设备")
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menu?.add(0, MENU_CLEAR, 0, "Clear")
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            MENU_CLEAR -> {
                logBuffer.clear()
                renderLog()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun setupButtons() {
        appendSection(
            "绑定加密授权",
            listOf(
                "bind + onEncryptedAuthData" to { bindWithEncryptedAuthCallback() },
                "setEncryptedAuthData(样例)" to { setEncryptedAuthSample() },
                "getEncryptedAuthData" to { getEncryptedAuthCached() },
                "get → 复制 JSON" to { getEncryptedAuthAndCopy() },
                "粘贴 → set" to { pasteEncryptedAuthAndSet() },
                "setEncryptedAuth + 标记已绑定" to { runSetEncryptedAuthAndMarkBound() }
            )
        )
        appendSection(
            "闹钟 JSON",
            listOf(
                "空 item / 脏 name / 越界 type·status" to { runAlarmJsonCases() }
            )
        )
    }

    private fun runAlarmJsonCases() {
        val result = InternalAlarmJsonCases.runAll()
        result.lines.forEach { line ->
            log(line)
        }
        Toast.makeText(
            this,
            if (result.passed) result.summary else "FAIL ${result.summary}",
            Toast.LENGTH_LONG
        ).show()
    }

    private fun encryptedAuthSample(): IDOEncryptedAuthData {
        return IDOEncryptedAuthData(
            authData = byteArrayOf(
                0xAF.toByte(), 0x83.toByte(), 0xDA.toByte(), 0x7B.toByte(),
                0xAE.toByte(), 0x93.toByte(), 0x47.toByte(), 0x3C.toByte(),
                0xF4.toByte(), 0x75.toByte(), 0xB3.toByte(), 0xB6.toByte()
            ),
            encryptedVersion = 0,
            authLength = 12
        )
    }

    private fun ensureConnected(): Boolean {
        if (sdk.state.isConnected) return true
        toast("未连接设备")
        log("错误：设备未连接")
        return false
    }

    private fun bindWithEncryptedAuthCallback() {
        if (!ensureConnected()) return
        log("--- bind + onEncryptedAuthData ---")
        showProgressDialog("binding...")
        sdk.cmd.bind(
            15,
            { info -> log("  onDeviceInfo battLevel=${info.battLevel}") },
            { log("  onFuncTable received") },
            { authData ->
                log(
                    "  onEncryptedAuthData encryptedVersion=${authData.encryptedVersion} authLength=${authData.authLength} authData=${formatAuthBytes(authData.authData)}"
                )
                toast("encrypted auth len=${authData.authLength}")
            },
            { status ->
                closeProgressDialog()
                log("  bind status=$status")
                if (status == IDOBindStatus.NEEDCONFIRMBYAPP) {
                    Cmds.sendBindResult(true).send {
                        if (it.error.code == 0) {
                            sdk.cmd.appMarkBindResult(true)
                            log("  appMarkBindResult success=true")
                        } else {
                            sdk.cmd.appMarkBindResult(false)
                            log("  appMarkBindResult success=false")
                        }
                    }
                }
            }
        )
    }

    private fun setEncryptedAuthSample() {
        val mac = resolveMacAddress()
        if (mac.isNullOrEmpty()) {
            toast("no macAddress")
            log("错误：无 macAddress")
            return
        }
        log("--- setEncryptedAuthData mac=$mac ---")
        sdk.cmd.setEncryptedAuthData(mac, encryptedAuthSample()) { ok ->
            log("  result=$ok")
            toast(if (ok) "set encrypted auth ok" else "set encrypted auth failed")
        }
    }

    private fun getEncryptedAuthCached() {
        val mac = resolveMacAddress()
        if (mac.isNullOrEmpty()) {
            toast("no macAddress")
            log("错误：无 macAddress")
            return
        }
        log("--- getEncryptedAuthData mac=$mac ---")
        sdk.cmd.getEncryptedAuthData(mac) { cached ->
            if (cached == null) {
                log("  no cache")
                toast("no cache")
                return@getEncryptedAuthData
            }
            log(
                "  encryptedVersion=${cached.encryptedVersion} authLength=${cached.authLength} authData=${formatAuthBytes(cached.authData)}"
            )
            toast("len=${cached.authLength} ver=${cached.encryptedVersion}")
        }
    }

    /** 无符号 0–255，与协议 uint8 / JSON auth_data 一致（勿用 ByteArray.contentToString） */
    private fun formatAuthBytes(bytes: ByteArray): String =
        bytes.joinToString(prefix = "[", postfix = "]") { (it.toInt() and 0xFF).toString() }

    /** get 缓存并复制 JSON 到剪贴板（跨手机粘贴用） */
    private fun getEncryptedAuthAndCopy() {
        val mac = resolveMacAddress()
        if (mac.isNullOrEmpty()) {
            toast("no macAddress")
            log("错误：无 macAddress")
            return
        }
        log("--- get → 复制 JSON mac=$mac ---")
        sdk.cmd.getEncryptedAuthData(mac) { cached ->
            if (cached == null) {
                log("  no cache")
                toast("no cache")
                return@getEncryptedAuthData
            }
            val json = cached.toJsonString()
            copyToClipboard(json)
            log("  copied: $json")
            toast("已复制 JSON")
        }
    }

    /** 从剪贴板读 JSON 并 setEncryptedAuthData */
    private fun pasteEncryptedAuthAndSet() {
        val mac = resolveMacAddress()
        if (mac.isNullOrEmpty()) {
            toast("no macAddress")
            log("错误：无 macAddress")
            return
        }
        val text = readClipboardText()
        if (text.isNullOrBlank()) {
            toast("剪贴板为空")
            log("错误：剪贴板为空")
            return
        }
        val data = IDOEncryptedAuthData.fromJsonString(text.trim())
        if (data == null) {
            toast("剪贴板不是合法 auth JSON")
            log("错误：解析失败\n  clipboard=$text")
            return
        }
        log("--- 粘贴 → set mac=$mac ---")
        log("  json=$text")
        sdk.cmd.setEncryptedAuthData(mac, data) { ok ->
            log("  result=$ok")
            toast(if (ok) "paste set ok" else "paste set failed")
        }
    }

    private fun copyToClipboard(text: String) {
        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        cm.setPrimaryClip(ClipData.newPlainText("EncryptedAuth", text))
    }

    private fun readClipboardText(): String? {
        val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = cm.primaryClip ?: return null
        if (clip.itemCount <= 0) return null
        return clip.getItemAt(0).coerceToText(this)?.toString()
    }

    /** 连接前写入加密授权并标记本地已绑定（模拟换机略过绑定） */
    private fun runSetEncryptedAuthAndMarkBound() {
        val mac = resolveMacAddress()
        if (mac.isNullOrEmpty()) {
            toast("no macAddress")
            log("错误：无 macAddress")
            return
        }
        val data = InternalEncryptedAuthCases.parseSampleJson()
        if (data == null) {
            toast("JSON parse failed")
            log("错误：JSON parse failed")
            return
        }
        log("--- setEncryptedAuthData mac=$mac ver=${data.encryptedVersion} len=${data.authLength} ---")
        showProgressDialog("setEncryptedAuthData...")
        sdk.cmd.setEncryptedAuthData(mac, data) { ok ->
            closeProgressDialog()
            if (ok) {
                val d = device
                if (d != null) {
                    FunctionUtils.saveBoundDevice(d)
                } else {
                    FunctionUtils.saveDeviceMac(mac)
                }
                log("  ok → bind=true")
                toast("setAuth ok, bind=true")
            } else {
                log("  failed")
                toast("setEncryptedAuthData failed")
            }
        }
    }

    private fun resolveMacAddress(): String? {
        device?.macAddress?.takeIf { it.isNotEmpty() }?.let { return it }
        val full = sdk.device.macAddressFull
        if (full.isNotEmpty()) return full
        val short = sdk.device.macAddress
        return short.takeIf { it.isNotEmpty() }
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

    private fun log(msg: String) {
        android.util.Log.d(LOG_TAG, msg)
        logBuffer.append(msg).append('\n')
        renderLog()
    }

    private fun renderLog() {
        tv_log.text = if (logBuffer.isEmpty()) "（无日志）" else logBuffer.toString()
        sv_log.post { sv_log.fullScroll(ScrollView.FOCUS_DOWN) }
    }

    companion object {
        private const val MENU_CLEAR = 1001
        private const val LOG_TAG = "InternalFeatureTest"
    }
}
