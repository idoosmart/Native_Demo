package com.example.example_android.activity

import android.Manifest
import android.app.AlertDialog
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.TextView
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.tasklist.DeviceNotificationBus
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDOWalkRemindModel
import com.idosmart.model.IDOWeek
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.activity_walk_remind.btn_clear_log
import kotlinx.android.synthetic.main.activity_walk_remind.btn_query
import kotlinx.android.synthetic.main.activity_walk_remind.btn_set
import kotlinx.android.synthetic.main.activity_walk_remind.et_dnd_end_hour
import kotlinx.android.synthetic.main.activity_walk_remind.et_dnd_end_minute
import kotlinx.android.synthetic.main.activity_walk_remind.et_dnd_start_hour
import kotlinx.android.synthetic.main.activity_walk_remind.et_dnd_start_minute
import kotlinx.android.synthetic.main.activity_walk_remind.et_end_hour
import kotlinx.android.synthetic.main.activity_walk_remind.et_end_minute
import kotlinx.android.synthetic.main.activity_walk_remind.et_goal_step
import kotlinx.android.synthetic.main.activity_walk_remind.et_goal_time
import kotlinx.android.synthetic.main.activity_walk_remind.et_start_hour
import kotlinx.android.synthetic.main.activity_walk_remind.et_start_minute
import kotlinx.android.synthetic.main.activity_walk_remind.ll_log_section
import kotlinx.android.synthetic.main.activity_walk_remind.seg_notify_0
import kotlinx.android.synthetic.main.activity_walk_remind.seg_notify_1
import kotlinx.android.synthetic.main.activity_walk_remind.seg_notify_2
import kotlinx.android.synthetic.main.activity_walk_remind.seg_notify_3
import kotlinx.android.synthetic.main.activity_walk_remind.sv_log
import kotlinx.android.synthetic.main.activity_walk_remind.sv_main
import kotlinx.android.synthetic.main.activity_walk_remind.sw_dnd
import kotlinx.android.synthetic.main.activity_walk_remind.sw_on_off
import kotlinx.android.synthetic.main.activity_walk_remind.tv_conn_chip
import kotlinx.android.synthetic.main.activity_walk_remind.tv_log
import kotlinx.android.synthetic.main.activity_walk_remind.tv_notify_panel
import kotlinx.android.synthetic.main.activity_walk_remind.tv_notify_status
import kotlinx.android.synthetic.main.activity_walk_remind.tv_support_chip
import kotlinx.android.synthetic.main.activity_walk_remind.week_fri
import kotlinx.android.synthetic.main.activity_walk_remind.week_mon
import kotlinx.android.synthetic.main.activity_walk_remind.week_sat
import kotlinx.android.synthetic.main.activity_walk_remind.week_sun
import kotlinx.android.synthetic.main.activity_walk_remind.week_thu
import kotlinx.android.synthetic.main.activity_walk_remind.week_tue
import kotlinx.android.synthetic.main.activity_walk_remind.week_wed
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * 走动提醒独立联调页（与 iOS WalkRemindVC UI / 交互对齐）。
 */
class WalkRemindActivity : BaseActivity() {

    private val logBuilder = StringBuilder()
    private var notifyFlag = 1
    private var walkReminderNotifId = 13400
    private val walkReminderPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            appendLog("7.8 本地通知权限 granted=$granted")
            toast(if (granted) "通知权限已授予" else "未授予通知权限，将无法弹出系统通知")
        }

    private val weekViews: List<TextView> by lazy {
        listOf(week_mon, week_tue, week_wed, week_thu, week_fri, week_sat, week_sun)
    }
    private val weekEnum = listOf(
        IDOWeek.MONDAY, IDOWeek.TUESDAY, IDOWeek.WEDNESDAY, IDOWeek.THURSDAY,
        IDOWeek.FRIDAY, IDOWeek.SATURDAY, IDOWeek.SUNDAY,
    )
    private val notifySegViews: List<TextView> by lazy {
        listOf(seg_notify_0, seg_notify_1, seg_notify_2, seg_notify_3)
    }

    private val notifyListener: (IDODeviceNotificationModel) -> Unit = listener@{ model ->
        if (model.dataType != DATA_TYPE_WALK_REMINDER) return@listener
        val status = model.walkReminderStatus ?: 0
        val goal = model.walkReminderGoalValue ?: 0
        val achieved = model.walkReminderAchievedValue ?: 0
        runOnUiThread {
            showWalkReminderResult(status, goal, achieved, fromNotify = true)
        }
    }

    override fun getLayoutId(): Int = R.layout.activity_walk_remind

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.walk_remind_title)
        setupWeekChips()
        setupNotifySeg()
        fillDefaults()
        refreshStatusBar()
        btn_query.setOnClickListener {
            hideKeyboard()
            queryWalkRemind()
        }
        btn_set.setOnClickListener {
            hideKeyboard()
            setWalkRemind()
        }
        btn_clear_log.setOnClickListener { clearLog() }
        DeviceNotificationBus.addListener(notifyListener)
        ensureWalkReminderNotificationPermission()
        ensureWalkReminderNotificationChannel()
        appendLog("7.8 走动提醒通知(134)：已监听，收到后弹系统通知并展示状态/目标/达成")
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        val ok = super.onCreateOptionsMenu(menu)
        menu?.add(0, MENU_HIDE_KEYBOARD, 0, "收起键盘")
            ?.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS)
        return ok
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == MENU_HIDE_KEYBOARD) {
            hideKeyboard()
            currentFocus?.clearFocus()
            return true
        }
        return super.onOptionsItemSelected(item)
    }

    override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
        if (ev.action == MotionEvent.ACTION_DOWN) {
            val focus = currentFocus
            if (focus is EditText) {
                val out = IntArray(2)
                focus.getLocationOnScreen(out)
                val x = ev.rawX
                val y = ev.rawY
                if (x < out[0] || x > out[0] + focus.width || y < out[1] || y > out[1] + focus.height) {
                    hideKeyboard()
                    focus.clearFocus()
                }
            }
        }
        return super.dispatchTouchEvent(ev)
    }

    override fun onResume() {
        super.onResume()
        refreshStatusBar()
    }

    override fun onDestroy() {
        DeviceNotificationBus.removeListener(notifyListener)
        super.onDestroy()
    }

    private fun setupWeekChips() {
        weekViews.forEachIndexed { index, tv ->
            tv.setOnClickListener {
                tv.isSelected = !tv.isSelected
                refreshWeekChip(tv)
            }
            tv.isSelected = index < 5
            refreshWeekChip(tv)
        }
    }

    private fun refreshWeekChip(tv: TextView) {
        tv.setTextColor(if (tv.isSelected) Color.WHITE else Color.parseColor("#007AFF"))
    }

    private fun setupNotifySeg() {
        notifySegViews.forEachIndexed { index, tv ->
            tv.setOnClickListener { selectNotifyFlag(index) }
        }
        selectNotifyFlag(1)
    }

    private fun selectNotifyFlag(index: Int) {
        notifyFlag = index.coerceIn(0, 3)
        notifySegViews.forEachIndexed { i, tv ->
            tv.isSelected = i == notifyFlag
            tv.setTextColor(
                if (tv.isSelected) Color.WHITE else Color.parseColor("#111111")
            )
        }
    }

    private fun fillDefaults() {
        sw_on_off.isChecked = true
        et_goal_step.setText("2000")
        et_goal_time.setText("60")
        et_start_hour.setText("9")
        et_start_minute.setText("0")
        et_end_hour.setText("18")
        et_end_minute.setText("0")
        selectNotifyFlag(1)
        sw_dnd.isChecked = false
        et_dnd_start_hour.setText("0")
        et_dnd_start_minute.setText("0")
        et_dnd_end_hour.setText("0")
        et_dnd_end_minute.setText("0")
        weekViews.forEachIndexed { i, tv ->
            tv.isSelected = i < 5
            refreshWeekChip(tv)
        }
    }

    private fun refreshStatusBar() {
        val connected = sdk.state.isConnected
        tv_conn_chip.text = if (connected) "已连接" else "未连接"
        tv_conn_chip.setBackgroundResource(
            if (connected) R.drawable.bg_walk_chip_ok else R.drawable.bg_walk_chip_bad
        )
        val supported = sdk.funcTable.setWalkReminder
        tv_support_chip.text = if (supported) "支持 setWalkReminder" else "功能表不支持"
        tv_support_chip.setBackgroundResource(
            if (supported) R.drawable.bg_walk_chip_ok else R.drawable.bg_walk_chip_warn
        )
    }

    private fun ensureConnected(): Boolean {
        if (sdk.state.isConnected) return true
        toast("未连接设备")
        return false
    }

    private fun hideKeyboard() {
        val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        val focus = currentFocus ?: window.decorView
        imm.hideSoftInputFromWindow(focus.windowToken, 0)
    }

    private fun intOf(et: EditText, def: Int = 0): Int =
        et.text.toString().trim().toIntOrNull() ?: def

    private fun collectRepeats(): HashSet<IDOWeek> {
        val set = HashSet<IDOWeek>()
        weekViews.forEachIndexed { i, tv ->
            if (tv.isSelected) set.add(weekEnum[i])
        }
        return set
    }

    private fun applyRepeats(repeats: HashSet<IDOWeek>?) {
        val set = repeats ?: hashSetOf()
        weekViews.forEachIndexed { i, tv ->
            tv.isSelected = set.contains(weekEnum[i])
            refreshWeekChip(tv)
        }
    }

    private fun buildParamFromUi(): IDOWalkRemindModel {
        return IDOWalkRemindModel(
            onOff = if (sw_on_off.isChecked) 1 else 0,
            goalStep = intOf(et_goal_step, 2000),
            startHour = intOf(et_start_hour, 9),
            startMinute = intOf(et_start_minute),
            endHour = intOf(et_end_hour, 18),
            endMinute = intOf(et_end_minute),
            repeats = collectRepeats(),
            goalTime = intOf(et_goal_time, 60),
            notifyFlag = notifyFlag,
            doNotDisturbOnOff = if (sw_dnd.isChecked) 1 else 0,
            noDisturbStartHour = intOf(et_dnd_start_hour),
            noDisturbStartMinute = intOf(et_dnd_start_minute),
            noDisturbEndHour = intOf(et_dnd_end_hour),
            noDisturbEndMinute = intOf(et_dnd_end_minute),
        )
    }

    private fun fillUiFromModel(model: IDOWalkRemindModel) {
        sw_on_off.isChecked = model.onOff == 1
        et_goal_step.setText(model.goalStep.toString())
        et_goal_time.setText(model.goalTime.toString())
        et_start_hour.setText(model.startHour.toString())
        et_start_minute.setText(model.startMinute.toString())
        et_end_hour.setText(model.endHour.toString())
        et_end_minute.setText(model.endMinute.toString())
        selectNotifyFlag(model.notifyFlag.coerceIn(0, 3))
        sw_dnd.isChecked = model.doNotDisturbOnOff == 1
        et_dnd_start_hour.setText(model.noDisturbStartHour.toString())
        et_dnd_start_minute.setText(model.noDisturbStartMinute.toString())
        et_dnd_end_hour.setText(model.noDisturbEndHour.toString())
        et_dnd_end_minute.setText(model.noDisturbEndMinute.toString())
        applyRepeats(model.repeats)
    }

    private fun queryWalkRemind() {
        if (!ensureConnected()) return
        val cmd = Cmds.getWalkRemind()
        appendLog("———— 查询 ————")
        appendLog("请求:\n${prettyJson(cmd.json)}")
        scrollToLog()
        showProgressDialog("查询中…")
        cmd.send { res ->
            closeProgressDialog()
            if (res.error.code != 0) {
                appendLog("响应: 失败 code=${res.error.code}")
                toast("查询失败 code=${res.error.code}")
                scrollToLog()
                return@send
            }
            val model = res.res
            if (model == null) {
                appendLog("响应: (空)")
                toast("无回复")
                scrollToLog()
                return@send
            }
            fillUiFromModel(model)
            appendLog("响应:\n${prettyJson(model.toJsonString())}")
            toast("查询完成")
            scrollToLog()
        }
    }

    private fun setWalkRemind() {
        if (!ensureConnected()) return
        val param = buildParamFromUi()
        val cmd = Cmds.setWalkReminder(param)
        appendLog("———— 设置 ————")
        appendLog("请求:\n${prettyJson(cmd.json)}")
        scrollToLog()
        showProgressDialog("设置中…")
        cmd.send { res ->
            closeProgressDialog()
            if (res.error.code != 0) {
                appendLog("响应: 失败 code=${res.error.code}")
                toast("设置失败 code=${res.error.code}")
                scrollToLog()
                return@send
            }
            val reply = res.res?.toJsonString()?.takeIf { it.isNotBlank() } ?: """{"is_success":1}"""
            appendLog("响应:\n${prettyJson(reply)}")
            toast("设置成功")
            scrollToLog()
        }
    }

    private fun showWalkReminderResult(status: Int, goal: Int, achieved: Int, fromNotify: Boolean) {
        val statusText = if (status == 1) "已达成" else "未达成"
        tv_notify_status.text = "走动提醒通知 · $statusText"
        tv_notify_panel.text = "状态 status = $status\n目标值 goal = $goal\n达成值 achieved = $achieved"
        val notifyJson = JSONObject()
            .put("data_type", DATA_TYPE_WALK_REMINDER)
            .put("walk_reminder_status", status)
            .put("walk_reminder_goal_value", goal)
            .put("walk_reminder_achieved_value", achieved)
            .toString(2)
        appendLog("———— 7.8 通知 134 ————")
        appendLog("响应:\n$notifyJson")
        postWalkReminderLocalNotification(status, goal, achieved)
        scrollToLog()
        if (fromNotify) {
            AlertDialog.Builder(this)
                .setTitle("走动提醒通知")
                .setMessage("状态：$status（$statusText）\n目标值：$goal\n达成值：$achieved")
                .setPositiveButton("知道了", null)
                .show()
        }
    }

    private fun ensureWalkReminderNotificationPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val granted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.POST_NOTIFICATIONS
        ) == PackageManager.PERMISSION_GRANTED
        if (!granted) {
            walkReminderPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
    }

    private fun ensureWalkReminderNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(NotificationManager::class.java) ?: return
        if (nm.getNotificationChannel(WALK_REMINDER_CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            WALK_REMINDER_CHANNEL_ID,
            "走动提醒",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "设备走动提醒通知（dataType=134）"
        }
        nm.createNotificationChannel(channel)
    }

    private fun postWalkReminderLocalNotification(status: Int, goal: Int, achieved: Int) {
        ensureWalkReminderNotificationChannel()
        val statusText = if (status == 1) "1 已达成" else "0 未达成"
        val body = "状态：$statusText，目标值：$goal，达成值：$achieved"
        val notification = NotificationCompat.Builder(this, WALK_REMINDER_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("走动提醒")
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        val nm = getSystemService(NotificationManager::class.java) ?: return
        nm.notify(walkReminderNotifId++, notification)
        appendLog("已弹出走动提醒本地通知: $body")
    }

    private fun prettyJson(raw: String?): String {
        if (raw.isNullOrBlank()) return "(空)"
        return try {
            val trimmed = raw.trim()
            when {
                trimmed.startsWith("{") -> JSONObject(trimmed).toString(2)
                trimmed.startsWith("[") -> JSONArray(trimmed).toString(2)
                else -> raw
            }
        } catch (_: Exception) {
            raw
        }
    }

    private fun clearLog() {
        logBuilder.clear()
        tv_log.text = "操作后会在此显示「请求」与「响应」JSON"
    }

    private fun appendLog(text: String) {
        val ts = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
        val line = "[$ts] $text"
        if (logBuilder.isEmpty() ||
            tv_log.text.toString().startsWith("操作后会在此显示")
        ) {
            logBuilder.clear()
            logBuilder.append(line)
        } else {
            logBuilder.append('\n').append(line)
        }
        tv_log.text = logBuilder.toString()
        sv_log.post { sv_log.fullScroll(View.FOCUS_DOWN) }
    }

    private fun scrollToLog() {
        sv_main.post {
            sv_main.smoothScrollTo(0, ll_log_section.top)
        }
    }

    companion object {
        private const val DATA_TYPE_WALK_REMINDER = 134
        private const val WALK_REMINDER_CHANNEL_ID = "walk_reminder_134"
        private const val MENU_HIDE_KEYBOARD = 0x5701
    }
}
