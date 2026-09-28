package com.example.example_android.activity

import android.app.AlertDialog
import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.ViewGroup
import android.widget.BaseExpandableListAdapter
import android.widget.EditText
import android.widget.ExpandableListView
import android.widget.NumberPicker
import android.widget.ScrollView
import android.widget.TextView
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.tasklist.DeviceNotificationBus
import com.example.example_android.tasklist.TaskListItemDraft
import com.example.example_android.tasklist.TaskListStorage
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDOTaskListItemModel
import com.idosmart.model.IDOTaskListModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import kotlinx.android.synthetic.main.activity_task_list_full_set.btn_full_set
import kotlinx.android.synthetic.main.activity_task_list_full_set.elv_tasks
import kotlinx.android.synthetic.main.activity_task_list_full_set.sv_log
import kotlinx.android.synthetic.main.activity_task_list_full_set.tv_log
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.Random

/**
 * 15.114 任务清单 — 全量设置（operate=1）
 * 对齐 iOS TaskListFullSetVC：待发送 / 已发送、随机添加、请求回复日志
 */
class TaskListFullSetActivity : BaseActivity() {

    private val sentItems = mutableListOf<TaskListItemDraft>()
    private val pendingItems = mutableListOf<TaskListItemDraft>()
    private val rng = Random()
    private lateinit var listAdapter: TaskListExpandableAdapter
    private val logBuilder = StringBuilder()

    private val notifyListener: (IDODeviceNotificationModel) -> Unit = listener@{ model ->
        if (model.dataType != TASK_STATUS_DATA_TYPE) return@listener
        val rawTaskId = model.taskId ?: return@listener
        val taskId = rawTaskId and 0xFFFFFFFFL
        val status = model.taskCompletStatus ?: return@listener
        runOnUiThread {
            appendLog("通知 dataType=133 task_id=$taskId status=$status")
            val ok = applyStatusUpdate(taskId, status, persist = false)
            commitStatusRefresh(if (ok) 1 else 0, "通知")
            // 133 不含 complete_timestamp，自动查询补齐完成时间
            if (sdk.state.isConnected) {
                queryStatusChanges(showFeedback = false)
            }
        }
    }

    override fun getLayoutId(): Int = R.layout.activity_task_list_full_set

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.task_list_full_set_title)
        listAdapter = TaskListExpandableAdapter()
        elv_tasks.setAdapter(listAdapter)
        elv_tasks.setOnChildClickListener { _, _, groupPosition, childPosition, _ ->
            if (groupPosition == GROUP_PENDING && pendingItems.isNotEmpty()) {
                showEditPendingDialog(childPosition)
                true
            } else {
                false
            }
        }
        elv_tasks.setOnItemLongClickListener { _, _, flatPos, _ ->
            val packed = elv_tasks.getExpandableListPosition(flatPos)
            val type = ExpandableListView.getPackedPositionType(packed)
            if (type != ExpandableListView.PACKED_POSITION_TYPE_CHILD) return@setOnItemLongClickListener false
            val group = ExpandableListView.getPackedPositionGroup(packed)
            val child = ExpandableListView.getPackedPositionChild(packed)
            if (group != GROUP_PENDING || pendingItems.isEmpty()) return@setOnItemLongClickListener false
            AlertDialog.Builder(this)
                .setMessage("删除该待发送任务？")
                .setPositiveButton("删除") { _, _ ->
                    pendingItems.removeAt(child)
                    refreshListUi()
                }
                .setNegativeButton("取消", null)
                .show()
            true
        }
        btn_full_set.setOnClickListener { onFullSet() }
        DeviceNotificationBus.addListener(notifyListener)
        bootstrap()
    }

    override fun onDestroy() {
        DeviceNotificationBus.removeListener(notifyListener)
        super.onDestroy()
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menu?.add(0, MENU_QUERY, 0, R.string.task_list_query_short)
            ?.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM)
        menu?.add(0, MENU_ADD, 1, R.string.task_list_add)
            ?.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            MENU_QUERY -> {
                queryStatusChanges(showFeedback = true)
                true
            }
            MENU_ADD -> {
                onAddRandomTasks()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun macAddress(): String {
        val full = sdk.device.macAddressFull
        if (full.isNotEmpty()) return full
        return sdk.device.macAddress
    }

    private fun bootstrap() {
        loadCacheFromLocal()
        // 查询状态不判断功能表，仅要求已连接
        if (sdk.state.isConnected) {
            queryStatusChanges(showFeedback = false)
        }
    }

    private fun loadCacheFromLocal() {
        sentItems.clear()
        sentItems.addAll(TaskListStorage.load(macAddress()))
        refreshListUi()
    }

    private fun persistSentItems() {
        TaskListStorage.save(macAddress(), sentItems)
    }

    private fun ensureConnected(): Boolean {
        if (sdk.state.isConnected) return true
        toast("未连接设备")
        return false
    }

    private fun refreshListUi() {
        listAdapter.notifyDataSetChanged()
        elv_tasks.expandGroup(GROUP_PENDING)
        elv_tasks.expandGroup(GROUP_SENT)
    }

    private fun usedTaskIds(): MutableSet<Long> {
        val used = mutableSetOf<Long>()
        sentItems.forEach { used.add(it.taskId) }
        pendingItems.forEach { used.add(it.taskId) }
        return used
    }

    /** task_id 从 1 起；已用最大 id 上每次 +1；上限 uint32_t */
    private fun allocUniqueTaskId(used: MutableSet<Long>): Long? {
        val next = (used.maxOrNull() ?: 0L) + 1L
        if (next > TaskListItemDraft.TASK_ID_MAX) return null
        return if (used.contains(next)) null else next
    }

    private fun onAddRandomTasks() {
        val count = RANDOM_ADD_MIN + rng.nextInt(RANDOM_ADD_MAX - RANDOM_ADD_MIN + 1)
        val usedIds = usedTaskIds()
        val existingDetails = (sentItems + pendingItems)
            .map { it.taskDetail.trim() }
            .filter { it.isNotEmpty() }
            .toMutableSet()
        var detailChoices = TaskListItemDraft.detailPool()
            .filter { !existingDetails.contains(it) }
            .shuffled(rng)
            .toMutableList()
        if (detailChoices.size < count) {
            detailChoices = TaskListItemDraft.detailPool().shuffled(rng).toMutableList()
        }

        val now = System.currentTimeMillis() / 1000L
        val usedReminds = (sentItems + pendingItems).map { it.remindTimestamp }.toMutableSet()
        val pickedDetails = mutableSetOf<String>()
        val generated = mutableListOf<TaskListItemDraft>()

        for (i in 0 until count) {
            val taskId = allocUniqueTaskId(usedIds) ?: run {
                toast("无法生成唯一任务ID")
                return
            }
            usedIds.add(taskId)

            val detail = when {
                i < detailChoices.size && !pickedDetails.contains(detailChoices[i]) ->
                    detailChoices[i]
                else ->
                    TaskListItemDraft.detailPool().firstOrNull { !pickedDetails.contains(it) }
                        ?: "任务提醒$taskId"
            }
            pickedDetails.add(detail)

            var remind = now + 600 + i * 900 + rng.nextInt(300)
            var guardCount = 0
            while ((remind <= now || usedReminds.contains(remind)) && guardCount < 40) {
                remind = now + 600 + i * 900 + rng.nextInt(3600) + guardCount
                guardCount++
            }
            usedReminds.add(remind)

            generated.add(
                TaskListItemDraft.makeRandom(
                    taskId = taskId,
                    remindTimestamp = remind,
                    taskDetail = detail,
                )
            )
        }
        pendingItems.addAll(generated)
        refreshListUi()
        toast("已生成 ${generated.size} 条待发送任务")
    }

    private fun onFullSet() {
        if (!ensureConnected()) return
        val fullList = sentItems + pendingItems
        sendFullSet(fullList) {
            sentItems.clear()
            sentItems.addAll(fullList)
            pendingItems.clear()
            persistSentItems()
            refreshListUi()
            appendLog("已缓存已下发任务 ${sentItems.size} 条")
        }
    }

    private fun toSdkItems(list: List<TaskListItemDraft>): List<IDOTaskListItemModel> {
        return list.map { draft ->
            IDOTaskListItemModel().apply {
                taskId = draft.taskIdForSdk()
                remindTimestamp = draft.remindTimestampForSdk()
                taskDetail = draft.taskDetail.ifEmpty { null }
            }
        }
    }

    private fun sendFullSet(
        list: List<TaskListItemDraft>,
        showFeedback: Boolean = true,
        onSuccess: (() -> Unit)? = null,
    ) {
        if (!ensureConnected()) return
        val param = IDOTaskListModel(operate = 1, items = toSdkItems(list))
        appendLog("全量设置 请求:\n${prettyJson(param.toJsonString() ?: """{"operate":1}""")}")
        if (showFeedback) showProgressDialog("全量下发中…")
        Cmds.taskList(param).send { res ->
            if (showFeedback) closeProgressDialog()
            if (res.error.code != 0) {
                appendLog("全量设置 回复: 失败 code=${res.error.code}")
                if (showFeedback) toast("失败 code=${res.error.code}")
                return@send
            }
            val model = res.res
            if (model != null) {
                appendLog("全量设置 回复:\n${formatReply(model)}")
            } else {
                appendLog("全量设置 回复: (空)")
            }
            val err = model?.errorCode
            if (err != null && err != 0) {
                if (showFeedback) toast("error_code 非 0")
                return@send
            }
            onSuccess?.invoke()
            if (showFeedback) {
                toast(if (list.isEmpty()) "已全量清空" else "已全量下发 ${list.size} 条")
            }
        }
    }

    private fun applyStatusUpdate(
        taskId: Long,
        status: Int,
        completeTimestamp: Long = 0L,
        persist: Boolean = true,
    ): Boolean {
        val idx = sentItems.indexOfFirst { it.taskId == taskId }
        if (idx < 0) return false
        sentItems[idx].status = status
        if (status == TaskListItemDraft.STATUS_DONE) {
            // 通知不含完成时间；仅查询带回有效时间戳时覆盖
            if (completeTimestamp > 0L) {
                sentItems[idx].completeTimestamp = completeTimestamp
            }
        } else {
            sentItems[idx].completeTimestamp = 0L
        }
        if (persist) {
            refreshListUi()
            persistSentItems()
        }
        return true
    }

    private fun commitStatusRefresh(updatedCount: Int, source: String) {
        if (updatedCount <= 0) {
            appendLog("$source：本地已发送列表无匹配任务，未刷新")
            return
        }
        persistSentItems()
        refreshListUi()
        appendLog("$source：已刷新 $updatedCount 条状态/完成时间并写缓存")
    }

    private fun queryStatusChanges(showFeedback: Boolean) {
        if (!sdk.state.isConnected) return
        val param = IDOTaskListModel(operate = 2)
        appendLog("查询状态 请求:\n${prettyJson(param.toJsonString() ?: """{"operate":2}""")}")
        if (showFeedback) showProgressDialog("查询状态变化…")
        Cmds.taskList(param).send { res ->
            if (showFeedback) closeProgressDialog()
            if (res.error.code != 0) {
                appendLog("查询状态 回复: 失败 code=${res.error.code}")
                if (showFeedback) toast("查询失败 code=${res.error.code}")
                return@send
            }
            val model = res.res ?: run {
                appendLog("查询状态 回复: (空)")
                if (showFeedback) toast("无 JSON 回复")
                return@send
            }
            appendLog("查询状态 回复:\n${formatReply(model)}")
            val err = model.errorCode
            if (err != null && err != 0) {
                if (showFeedback) toast("error_code=$err")
                return@send
            }
            var updated = 0
            model.statusItems?.forEach { item ->
                if (applyStatusUpdate(
                        item.taskId and 0xFFFFFFFFL,
                        item.status,
                        item.completeTimestamp and 0xFFFFFFFFL,
                        persist = false,
                    )
                ) {
                    updated++
                }
            }
            commitStatusRefresh(updated, "查询状态")
            if (showFeedback) {
                val num = model.statusItemNum ?: model.statusItems?.size ?: 0
                when {
                    updated > 0 -> toast("已刷新 $updated 条状态/完成时间")
                    num > 0 -> toast("设备返回 $num 条，本地无匹配")
                    else -> toast("无状态变化")
                }
            }
        }
    }

    private fun showEditPendingDialog(index: Int) {
        if (index !in pendingItems.indices) return
        val draft = pendingItems[index]
        val container = LayoutInflater.from(this).inflate(R.layout.dialog_task_list_add, null)
        val etTaskId = container.findViewById<EditText>(R.id.et_task_id)
        val tvRemindDisplay = container.findViewById<TextView>(R.id.tv_remind_display)
        val tvRemindUtcHint = container.findViewById<TextView>(R.id.tv_remind_utc_hint)
        val btnPickRemind = container.findViewById<TextView>(R.id.btn_pick_remind)
        val etDetail = container.findViewById<EditText>(R.id.et_task_detail)

        // 编辑过程中暂存选中的 UTC 秒；选择器用本地墙钟展示
        var selectedUtcSec = draft.remindTimestamp

        fun refreshRemindUi() {
            tvRemindDisplay.text = TaskListItemDraft.formatLocalDateTime(selectedUtcSec)
            tvRemindUtcHint.text = "UTC 时间戳：$selectedUtcSec"
        }

        etTaskId.setText(draft.taskId.toString())
        etTaskId.isEnabled = false
        refreshRemindUi()
        etDetail.setText(draft.taskDetail)
        etDetail.filters = arrayOf(
            android.text.InputFilter.LengthFilter(TaskListItemDraft.TASK_DETAIL_MAX_CHARS)
        )

        val pickClick = View.OnClickListener { pickRemindDateTime(selectedUtcSec) { sec ->
            selectedUtcSec = sec
            refreshRemindUi()
        } }
        btnPickRemind.setOnClickListener(pickClick)
        tvRemindDisplay.setOnClickListener(pickClick)

        AlertDialog.Builder(this)
            .setTitle("编辑待发送 · 任务ID=${draft.taskId}")
            .setView(container)
            .setNegativeButton("取消", null)
            .setPositiveButton("保存") { _, _ ->
                if (!TaskListItemDraft.isValidUInt32(selectedUtcSec)) {
                    toast("提醒时间无效")
                    return@setPositiveButton
                }
                val now = System.currentTimeMillis() / 1000L
                if (selectedUtcSec <= now) {
                    toast("提醒时间须大于当前时间")
                    return@setPositiveButton
                }
                pendingItems[index].remindTimestamp = selectedUtcSec
                pendingItems[index].taskDetail =
                    TaskListItemDraft.clampTaskDetail(etDetail.text.toString())
                refreshListUi()
            }
            .show()
    }

    /**
     * 依次弹出：日期 → 时分 → 秒；按手机本地时区选择，再换算为协议 UTC 秒时间戳。
     */
    private fun pickRemindDateTime(initialUtcSec: Long, onPicked: (Long) -> Unit) {
        val initial = TaskListItemDraft.localCalendarFromUtcSec(initialUtcSec)
        DatePickerDialog(
            this,
            { _, year, month0, dayOfMonth ->
                TimePickerDialog(
                    this,
                    { _, hourOfDay, minute ->
                        pickRemindSecond(
                            year = year,
                            month = month0 + 1,
                            day = dayOfMonth,
                            hour = hourOfDay,
                            minute = minute,
                            initialSecond = initial.get(Calendar.SECOND),
                            onPicked = onPicked,
                        )
                    },
                    initial.get(Calendar.HOUR_OF_DAY),
                    initial.get(Calendar.MINUTE),
                    true,
                ).show()
            },
            initial.get(Calendar.YEAR),
            initial.get(Calendar.MONTH),
            initial.get(Calendar.DAY_OF_MONTH),
        ).show()
    }

    private fun pickRemindSecond(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        initialSecond: Int,
        onPicked: (Long) -> Unit,
    ) {
        val picker = NumberPicker(this).apply {
            minValue = 0
            maxValue = 59
            value = initialSecond.coerceIn(0, 59)
            wrapSelectorWheel = true
        }
        AlertDialog.Builder(this)
            .setTitle("选择秒")
            .setView(picker)
            .setNegativeButton("取消", null)
            .setPositiveButton("确定") { _, _ ->
                val utcSec = TaskListItemDraft.utcSecFromLocal(
                    year = year,
                    month = month,
                    day = day,
                    hour = hour,
                    minute = minute,
                    second = picker.value,
                )
                onPicked(utcSec)
            }
            .show()
    }

    private fun appendLog(text: String) {
        val ts = SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(Date())
        val line = "[$ts] $text"
        if (logBuilder.isEmpty()) {
            logBuilder.append(line)
        } else {
            logBuilder.append('\n').append(line)
        }
        tv_log.text = logBuilder.toString()
        sv_log.post { sv_log.fullScroll(ScrollView.FOCUS_DOWN) }
    }

    private fun prettyJson(raw: String): String {
        return try {
            when {
                raw.trimStart().startsWith("[") -> JSONArray(raw).toString(2)
                else -> JSONObject(raw).toString(2)
            }
        } catch (_: Exception) {
            raw
        }
    }

    private fun formatReply(model: IDOTaskListModel): String {
        val root = JSONObject()
        root.put("operate", model.operate)
        model.errorCode?.let { root.put("error_code", it) }
        if (model.operate == 2) {
            model.statusItemNum?.let { root.put("status_item_num", it) }
            val arr = JSONArray()
            model.statusItems?.forEach { item ->
                arr.put(
                    JSONObject()
                        .put("task_id", item.taskId)
                        .put("status", item.status)
                        .put("complete_timestamp", item.completeTimestamp)
                )
            }
            root.put("status_items", arr)
        }
        return root.toString(2)
    }

    private inner class TaskListExpandableAdapter : BaseExpandableListAdapter() {
        override fun getGroupCount(): Int = 2
        override fun getChildrenCount(groupPosition: Int): Int {
            return when (groupPosition) {
                GROUP_PENDING -> pendingItems.size.coerceAtLeast(1)
                else -> sentItems.size.coerceAtLeast(1)
            }
        }

        override fun getGroup(groupPosition: Int): Any = groupPosition
        override fun getChild(groupPosition: Int, childPosition: Int): Any = childPosition
        override fun getGroupId(groupPosition: Int): Long = groupPosition.toLong()
        override fun getChildId(groupPosition: Int, childPosition: Int): Long = childPosition.toLong()
        override fun hasStableIds(): Boolean = false
        override fun isChildSelectable(groupPosition: Int, childPosition: Int): Boolean = true

        override fun getGroupView(
            groupPosition: Int,
            isExpanded: Boolean,
            convertView: View?,
            parent: ViewGroup?,
        ): View {
            val tv = (convertView as? TextView) ?: TextView(this@TaskListFullSetActivity).apply {
                setPadding(32, 24, 32, 12)
                textSize = 13f
                setTypeface(typeface, android.graphics.Typeface.BOLD)
            }
            val count = if (groupPosition == GROUP_PENDING) pendingItems.size else sentItems.size
            val title = if (groupPosition == GROUP_PENDING) {
                getString(R.string.task_list_pending_section)
            } else {
                getString(R.string.task_list_sent_section)
            }
            tv.text = "$title（$count）"
            return tv
        }

        override fun getChildView(
            groupPosition: Int,
            childPosition: Int,
            isLastChild: Boolean,
            convertView: View?,
            parent: ViewGroup?,
        ): View {
            val tv = (convertView as? TextView) ?: TextView(this@TaskListFullSetActivity).apply {
                setPadding(40, 16, 32, 16)
                textSize = 13f
            }
            when (groupPosition) {
                GROUP_PENDING -> {
                    if (pendingItems.isEmpty()) {
                        tv.text = getString(R.string.task_list_empty_hint)
                        tv.setTextColor(0xFF9E9E9E.toInt())
                    } else {
                        tv.text = pendingItems[childPosition].listDisplayText()
                        tv.setTextColor(0xFF212121.toInt())
                    }
                }
                else -> {
                    if (sentItems.isEmpty()) {
                        tv.text = getString(R.string.task_list_sent_empty)
                        tv.setTextColor(0xFF9E9E9E.toInt())
                    } else {
                        tv.text = sentItems[childPosition].listDisplayText()
                        tv.setTextColor(0xFF212121.toInt())
                    }
                }
            }
            return tv
        }
    }

    companion object {
        private const val TASK_STATUS_DATA_TYPE = 133
        private const val MENU_QUERY = 1
        private const val MENU_ADD = 2
        private const val GROUP_PENDING = 0
        private const val GROUP_SENT = 1
        private const val RANDOM_ADD_MIN = 2
        private const val RANDOM_ADD_MAX = 5
    }
}
