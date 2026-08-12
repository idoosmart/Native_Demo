package com.example.example_android.activity

import android.content.Intent
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Button
import android.widget.LinearLayout
import android.widget.Spinner
import android.widget.Switch
import android.widget.TextView
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.idosmart.model.IDOGestureControlModel
import com.idosmart.model.IDOGestureFunctionItemModel
import com.idosmart.model.IDOGestureSubFunctionItemModel
import com.idosmart.model.IDOGestureTypeItemModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk

/**
 * 15.82 手势控制联调页（对齐 PulseBand GestureActivity）：
 * 进页 03→02；动态能力树；功能多选一；同功能子功能手势互斥；设置走 01。
 */
class GestureControlActivity : BaseActivity() {

    private lateinit var switchMaster: Switch
    private lateinit var llTree: LinearLayout
    private lateinit var tvStatus: TextView
    private lateinit var tvSummary: TextView
    private lateinit var tvResult: TextView

    private val funcUis = mutableListOf<FuncUi>()
    private var supportModel: IDOGestureControlModel? = null
    private var currentModel: IDOGestureControlModel? = null
    private var awaitCurrentAfterSupport = false
    private var suppressSpinnerCallback = false
    private var suppressFuncSwitchCallback = false

    private data class SubUi(
        val subType: Int,
        val allowedGestures: List<Int>,
        val label: TextView,
        val spinner: Spinner,
        var selectedGesture: Int,
    )

    private data class FuncUi(
        val functionType: Int,
        val switch: Switch,
        val subs: List<SubUi>,
    )

    override fun getLayoutId(): Int = R.layout.activity_gesture_control

    override fun initView() {
        super.initView()
        supportActionBar?.title = getString(R.string.gesture_control)

        tvStatus = findViewById(R.id.tv_gesture_status)
        tvSummary = findViewById(R.id.tv_gesture_summary)
        tvResult = findViewById(R.id.tv_gesture_result)
        switchMaster = findViewById(R.id.switch_gesture_master)
        llTree = findViewById(R.id.ll_gesture_tree)

        findViewById<Button>(R.id.btn_gesture_support).setOnClickListener {
            if (!ensureSupport()) return@setOnClickListener
            awaitCurrentAfterSupport = false
            querySupport()
        }
        findViewById<Button>(R.id.btn_gesture_get).setOnClickListener {
            if (!ensureSupport()) return@setOnClickListener
            queryCurrent()
        }
        findViewById<Button>(R.id.btn_gesture_refresh).setOnClickListener {
            if (!ensureSupport()) return@setOnClickListener
            enterPage()
        }
        findViewById<Button>(R.id.btn_gesture_set).setOnClickListener {
            if (!ensureSupport()) return@setOnClickListener
            setFromUi()
        }
        findViewById<Button>(R.id.btn_gesture_call_notice).setOnClickListener {
            startActivity(Intent(this, CallNoticeActivity::class.java))
        }
        findViewById<Button>(R.id.btn_gesture_clear).setOnClickListener {
            clearDisplay()
        }

        switchMaster.setOnCheckedChangeListener { _, _ ->
            refreshSummaryFromUi()
        }

        if (!ensureSupport()) {
            return
        }
        enterPage()
    }

    private fun ensureSupport(): Boolean {
        if (!sdk.funcTable.supportOperateGestureControl) {
            tvStatus.text = getString(R.string.gesture_control_not_support)
            toast(getString(R.string.gesture_control_not_support))
            return false
        }
        return true
    }

    /** 进页：03 → 成功后自动 02 */
    private fun enterPage() {
        tvStatus.text = getString(R.string.gesture_control_status_loading_support)
        awaitCurrentAfterSupport = true
        querySupport()
    }

    private fun querySupport() {
        showProgressDialog(getString(R.string.gesture_control_btn_support))
        Cmds.getGestureControlSupportConfigs().send { resp ->
            closeProgressDialog()
            runOnUiThread {
                if (resp.error.code != 0 || resp.res == null) {
                    tvStatus.text = getString(
                        R.string.gesture_control_status_fail,
                        "03",
                        resp.error.code
                    )
                    tvResult.text = resp.res?.toJsonString() ?: "error=${resp.error.code}"
                    awaitCurrentAfterSupport = false
                    return@runOnUiThread
                }
                supportModel = resp.res
                tvResult.text = resp.res!!.toJsonString()
                tvStatus.text = getString(R.string.gesture_control_status_support_ok)
                buildTreeFromSupport(resp.res!!)
                currentModel?.let { applyCurrentToUi(it) }
                if (awaitCurrentAfterSupport) {
                    awaitCurrentAfterSupport = false
                    queryCurrent()
                }
            }
        }
    }

    private fun queryCurrent() {
        showProgressDialog(getString(R.string.gesture_control_btn_get))
        Cmds.getGestureControl().send { resp ->
            closeProgressDialog()
            runOnUiThread {
                if (resp.error.code != 0 || resp.res == null) {
                    tvStatus.text = getString(
                        R.string.gesture_control_status_fail,
                        "02",
                        resp.error.code
                    )
                    tvResult.text = resp.res?.toJsonString() ?: "error=${resp.error.code}"
                    return@runOnUiThread
                }
                currentModel = resp.res
                tvResult.text = resp.res!!.toJsonString()
                tvStatus.text = getString(R.string.gesture_control_status_current_ok)
                if (funcUis.isNotEmpty()) {
                    applyCurrentToUi(resp.res!!)
                }
            }
        }
    }

    private fun setFromUi() {
        val support = supportModel
        if (support == null) {
            tvStatus.text = getString(R.string.gesture_control_need_support_first)
            return
        }
        val model = buildSetModelFromUi(support)
        if (model == null) {
            tvStatus.text = getString(R.string.gesture_control_build_fail)
            return
        }
        tvStatus.text = getString(R.string.gesture_control_status_setting)
        showProgressDialog(getString(R.string.gesture_control_btn_set))
        Cmds.setGestureControl(model).send { resp ->
            closeProgressDialog()
            runOnUiThread {
                tvResult.text = resp.res?.toJsonString()
                    ?: "error=${resp.error.code} setReq=${model.toJsonString()}"
                tvStatus.text = if (resp.error.code == 0) {
                    getString(R.string.gesture_control_status_set_ok)
                } else {
                    getString(R.string.gesture_control_status_fail, "01", resp.error.code)
                }
            }
        }
    }

    private fun clearDisplay() {
        supportModel = null
        currentModel = null
        clearTreeUi()
        tvResult.text = getString(R.string.gesture_control_empty)
        tvSummary.text = getString(R.string.gesture_control_flow_hint)
        tvStatus.text = getString(R.string.gesture_control_status_idle)
    }

    private fun clearTreeUi() {
        llTree.removeAllViews()
        funcUis.clear()
        switchMaster.isChecked = false
    }

    private fun buildTreeFromSupport(support: IDOGestureControlModel) {
        val items = support.gestureFunctionItems.orEmpty()
        llTree.removeAllViews()
        funcUis.clear()

        for (item in items) {
            val funcType = item.functionType
            val funcSwitch = Switch(this).apply {
                text = gestureFuncLabel(funcType)
                textSize = 15f
                isChecked = false
            }
            llTree.addView(funcSwitch)

            val subUis = mutableListOf<SubUi>()
            for (sub in item.gestureSubFunctionItems.orEmpty()) {
                val allowed = sub.gestureTypeItems.orEmpty()
                    .map { it.gestureType }
                    .filter { it > 0 }
                if (allowed.isEmpty()) continue

                val row = LinearLayout(this).apply {
                    orientation = LinearLayout.HORIZONTAL
                    setPadding(24, 4, 0, 4)
                }
                val label = TextView(this).apply {
                    text = gestureSubLabel(funcType, sub.subFunctionType)
                    textSize = 14f
                    layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
                }
                val spinner = Spinner(this).apply {
                    layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1.2f)
                }
                val defaultGesture = allowed.first()
                val subUi = SubUi(sub.subFunctionType, allowed, label, spinner, defaultGesture)
                spinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                    override fun onItemSelected(
                        parent: AdapterView<*>?,
                        view: View?,
                        position: Int,
                        id: Long,
                    ) {
                        if (suppressSpinnerCallback) return
                        val options = spinner.tag as? List<*> ?: return
                        val gesture = options.getOrNull(position) as? Int ?: return
                        subUi.selectedGesture = gesture
                        val parentFunc = funcUis.find { it.subs.contains(subUi) } ?: return
                        refreshMutualExclusiveSpinners(parentFunc)
                        refreshSummaryFromUi()
                    }

                    override fun onNothingSelected(parent: AdapterView<*>?) = Unit
                }
                row.addView(label)
                row.addView(spinner)
                llTree.addView(row)
                subUis.add(subUi)
            }

            val funcUi = FuncUi(funcType, funcSwitch, subUis)
            funcUis.add(funcUi)
            assignInitialGestures(funcUi, item)
            refreshMutualExclusiveSpinners(funcUi)

            funcSwitch.setOnCheckedChangeListener { _, checked ->
                if (suppressFuncSwitchCallback) return@setOnCheckedChangeListener
                if (checked) {
                    selectOnlyFunction(funcType)
                }
                refreshSummaryFromUi()
            }
        }

        val onOff = support.gestureControlOnOff
        if (onOff == 0 || onOff == 1) {
            switchMaster.isChecked = onOff == 1
        }
        tvSummary.text = getString(R.string.gesture_control_support_loaded, funcUis.size)
    }

    private fun selectOnlyFunction(functionType: Int) {
        suppressFuncSwitchCallback = true
        for (f in funcUis) {
            f.switch.isChecked = f.functionType == functionType
        }
        suppressFuncSwitchCallback = false
    }

    private fun refreshSummaryFromUi() {
        val masterText = if (switchMaster.isChecked) "ON" else "OFF"
        val enabled = funcUis.firstOrNull { it.switch.isChecked }
        tvSummary.text = buildString {
            append("master=$masterText")
            for (f in funcUis) {
                append(" | ")
                append(gestureFuncLabel(f.functionType))
                append("=")
                append(if (f.switch.isChecked) "ON" else "OFF")
            }
            append(" | enabled=")
            append(enabled?.let { gestureFuncLabel(it.functionType) } ?: "none")
        }
    }

    private fun assignInitialGestures(funcUi: FuncUi, item: IDOGestureFunctionItemModel) {
        val used = mutableSetOf<Int>()
        val subs = item.gestureSubFunctionItems.orEmpty()
        for (subUi in funcUi.subs) {
            val types = subs.firstOrNull { it.subFunctionType == subUi.subType }
                ?.gestureTypeItems.orEmpty()
                .map { it.gestureType }
                .filter { it > 0 }
            val chosen = types.firstOrNull { it !in used }
                ?: subUi.allowedGestures.firstOrNull { it !in used }
                ?: subUi.allowedGestures.first()
            subUi.selectedGesture = chosen
            used.add(chosen)
        }
    }

    private fun applyCurrentToUi(current: IDOGestureControlModel) {
        val onOff = current.gestureControlOnOff
        if (onOff == 0 || onOff == 1) {
            switchMaster.isChecked = onOff == 1
        }

        val byType = current.gestureFunctionItems.orEmpty()
            .associateBy { it.functionType }

        var selectedType: Int? = null
        for (funcUi in funcUis) {
            val item = byType[funcUi.functionType] ?: continue
            if (item.functionSwitch == 1 && selectedType == null) {
                selectedType = funcUi.functionType
            }
        }

        suppressFuncSwitchCallback = true
        for (funcUi in funcUis) {
            val item = byType[funcUi.functionType]
            funcUi.switch.isChecked = selectedType != null && funcUi.functionType == selectedType
            if (item != null) {
                val used = mutableSetOf<Int>()
                val subs = item.gestureSubFunctionItems.orEmpty()
                for (subUi in funcUi.subs) {
                    val picked = subs.firstOrNull { it.subFunctionType == subUi.subType }
                        ?.gestureTypeItems.orEmpty()
                        .map { it.gestureType }
                        .firstOrNull { it in subUi.allowedGestures }
                    val g = when {
                        picked != null && picked !in used -> picked
                        else -> subUi.allowedGestures.firstOrNull { it !in used }
                            ?: subUi.selectedGesture
                    }
                    subUi.selectedGesture = g
                    used.add(g)
                }
            }
            refreshMutualExclusiveSpinners(funcUi)
        }
        suppressFuncSwitchCallback = false
        refreshSummaryFromUi()
    }

    private fun refreshMutualExclusiveSpinners(funcUi: FuncUi) {
        suppressSpinnerCallback = true
        for (subUi in funcUi.subs) {
            val takenByOthers = funcUi.subs
                .filter { it !== subUi }
                .map { it.selectedGesture }
                .toSet()
            var options = subUi.allowedGestures.filter { it !in takenByOthers }
            if (options.isEmpty()) {
                options = subUi.allowedGestures
            }
            if (subUi.selectedGesture !in options) {
                subUi.selectedGesture = options.first()
            }
            val labels = options.map { gestureTypeLabel(it) }
            val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, labels).also {
                it.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
            }
            subUi.spinner.adapter = adapter
            subUi.spinner.tag = options
            subUi.spinner.setSelection(options.indexOf(subUi.selectedGesture).coerceAtLeast(0), false)
        }
        suppressSpinnerCallback = false
    }

    /** 以 support 树为骨架，叠 UI 状态，组装设置 Model */
    private fun buildSetModelFromUi(support: IDOGestureControlModel): IDOGestureControlModel? {
        val enabledType = funcUis.firstOrNull { it.switch.isChecked }?.functionType
        val items = support.gestureFunctionItems ?: return null
        val outItems = items.map { supportItem ->
            val funcUi = funcUis.find { it.functionType == supportItem.functionType }
            val subs = supportItem.gestureSubFunctionItems.orEmpty().map { supportSub ->
                val subUi = funcUi?.subs?.find { it.subType == supportSub.subFunctionType }
                val gesture = subUi?.selectedGesture
                    ?: supportSub.gestureTypeItems?.firstOrNull()?.gestureType
                    ?: 0
                IDOGestureSubFunctionItemModel(
                    subFunctionType = supportSub.subFunctionType,
                    gestureTypeItems = listOf(IDOGestureTypeItemModel(gestureType = gesture)),
                )
            }
            IDOGestureFunctionItemModel(
                functionSwitch = if (enabledType != null && supportItem.functionType == enabledType) 1 else 0,
                functionType = supportItem.functionType,
                gestureSubFunctionItems = subs,
            )
        }
        return IDOGestureControlModel(
            operate = 1,
            gestureControlOnOff = if (switchMaster.isChecked) 1 else 0,
            gestureFunctionItems = outItems,
        )
    }

    companion object {
        private const val FUNC_CALL = 1
        private const val FUNC_PHOTO = 2
        private const val FUNC_MUSIC = 3
        private const val SUB_ANSWER = 1
        private const val SUB_HANG_UP = 2
        private const val SUB_PHOTO = 1
        private const val SUB_MUSIC_NEXT = 1
        private const val TYPE_FLIP_PALM = 1
        private const val TYPE_PLAY_TWICE = 2
        private const val TYPE_ARM_HORIZONTAL = 3
        private const val TYPE_ARM_VERTICAL = 4

        fun gestureFuncLabel(type: Int): String = when (type) {
            FUNC_CALL -> "控制通话"
            FUNC_PHOTO -> "遥控拍照"
            FUNC_MUSIC -> "音乐控制"
            else -> "功能$type"
        }

        fun gestureSubLabel(funcType: Int, subType: Int): String = when (funcType) {
            FUNC_CALL -> when (subType) {
                SUB_ANSWER -> "接听电话"
                SUB_HANG_UP -> "挂断电话"
                else -> "子功能$subType"
            }
            FUNC_PHOTO -> when (subType) {
                SUB_PHOTO -> "遥控拍照"
                else -> "子功能$subType"
            }
            FUNC_MUSIC -> when (subType) {
                SUB_MUSIC_NEXT -> "下一曲"
                else -> "子功能$subType"
            }
            else -> "子功能$subType"
        }

        fun gestureTypeLabel(type: Int): String = when (type) {
            TYPE_FLIP_PALM -> "手掌翻转90°×2"
            TYPE_PLAY_TWICE -> "弹两下"
            TYPE_ARM_HORIZONTAL -> "手臂水平旋转90°×2"
            TYPE_ARM_VERTICAL -> "手臂垂直旋转90°×2"
            else -> "手势$type"
        }
    }
}
