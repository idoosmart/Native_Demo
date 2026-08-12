package com.example.example_android.activity

import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.idosmart.protocol_channel.sdk

/**
 * 来电提醒联调（对齐 PulseBand CallNoticeActivity）。
 * 用于配合手势控制页测接听/拒接/挂断闭环。
 */
class CallNoticeActivity : BaseActivity() {

    private lateinit var etContact: EditText
    private lateinit var etPhone: EditText
    private lateinit var tvLog: TextView

    override fun getLayoutId(): Int = R.layout.activity_call_notice

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.call_notice)

        etContact = findViewById(R.id.et_call_contact)
        etPhone = findViewById(R.id.et_call_phone)
        tvLog = findViewById(R.id.tv_call_log)

        findViewById<Button>(R.id.btn_call_incoming).setOnClickListener {
            val contact = etContact.text?.toString().orEmpty().ifBlank { "Demo User" }
            val phone = etPhone.text?.toString().orEmpty().ifBlank { "13800138000" }
            appendLog("来电… contact=$contact phone=$phone")
            sdk.cmd.setV2CallEvt(contact, phone) { ok ->
                runOnUiThread { appendLog("来电结果 ok=$ok") }
            }
        }

        findViewById<Button>(R.id.btn_call_answered).setOnClickListener {
            appendLog("来电已接…")
            sdk.cmd.stopV2CallEvt { ok ->
                runOnUiThread { appendLog("来电已接结果 ok=$ok") }
            }
        }

        findViewById<Button>(R.id.btn_call_rejected).setOnClickListener {
            appendLog("来电已拒…")
            sdk.cmd.missedV2MissedCallEvt { ok ->
                runOnUiThread { appendLog("来电已拒结果 ok=$ok") }
            }
        }

        findViewById<Button>(R.id.btn_call_hang_up).setOnClickListener {
            if (!sdk.funcTable.setNoticeHangUpInCallV2) {
                toast(getString(R.string.call_notice_hang_up_not_support))
                appendLog("通话中挂断跳过：setNoticeHangUpInCallV2=false")
                return@setOnClickListener
            }
            appendLog("通话中挂断…")
            sdk.cmd.hangUpV2InCallEvt { ok ->
                runOnUiThread { appendLog("通话中挂断结果 ok=$ok") }
            }
        }
    }

    private fun appendLog(msg: String) {
        val old = tvLog.text?.toString().orEmpty()
        val base = if (old == getString(R.string.call_notice_log_empty)) "" else old
        tvLog.text = listOf(base, msg).filter { it.isNotBlank() }.joinToString("\n")
    }
}
