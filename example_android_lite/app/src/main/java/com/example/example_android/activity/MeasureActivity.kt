package com.example.example_android.activity

import android.view.View
import android.widget.ArrayAdapter
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.idosmart.pigeon_implement.IDOMeasureManager
import com.idosmart.pigeon_implement.IDOMeasureType
import kotlinx.android.synthetic.main.layout_measure_activity.*

class MeasureActivity : BaseActivity() {
    private var resultText = ""
    private val measureTypes = listOf(
        "Blood Pressure", "Heart Rate", "SpO2", "Stress", "One Click", "Temperature", "Body Composition"
    )

    override fun getLayoutId(): Int {
        return R.layout.layout_measure_activity
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("Measure")
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, measureTypes)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        spinner_type.adapter = adapter

        IDOMeasureManager.shared.listenProcessMeasureData { result ->
            log("Receive Data: status=${result.status}, value=${result.value}, oneClickHr=${result.oneClickHr}, oneClickSpo2=${result.oneClickSpo2}, oneClickStress=${result.oneClickStress}")
        }
    }

    private fun getSelectedType(): IDOMeasureType {
        return when (spinner_type.selectedItemPosition) {
            0 -> IDOMeasureType.BLOOD_PRESSURE
            1 -> IDOMeasureType.HEART_RATE
            2 -> IDOMeasureType.SPO2
            3 -> IDOMeasureType.STRESS
            4 -> IDOMeasureType.ONE_CLICK
            5 -> IDOMeasureType.TEMPERATURE
            6 -> IDOMeasureType.BODY_COMPOSITION
            else -> IDOMeasureType.BLOOD_PRESSURE
        }
    }

    fun start(view: View) {
        val type = getSelectedType()
        log("Start Measure: $type")
        IDOMeasureManager.shared.startMeasure(type) { success ->
            log("Start Result: $success")
        }
    }

    fun stop(view: View) {
        val type = getSelectedType()
        log("Stop Measure: $type")
        IDOMeasureManager.shared.stopMeasure(type) { success ->
            log("Stop Result: $success")
        }
    }

    fun get_data(view: View) {
        val type = getSelectedType()
        log("Get Measure Data: $type")
        IDOMeasureManager.shared.getMeasureData(type) { result ->
            log("Get Data Result: status=${result.status}, value=${result.value}, oneClickHr=${result.oneClickHr}, oneClickSpo2=${result.oneClickSpo2}, oneClickStress=${result.oneClickStress}")
        }
    }

    private fun log(msg: String) {
        runOnUiThread {
            resultText += "$msg\n\n"
            tv_response.text = resultText
        }
    }
}
