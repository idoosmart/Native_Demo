package com.example.example_android.activity

import android.os.Build
import androidx.annotation.RequiresApi
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.CmdSet
import com.example.example_android.data.SetFuncData
import com.idosmart.model.IDOBleVoiceParamModel
import com.idosmart.model.IDODateTimeParamModel
import com.idosmart.pigeon_implement.Cmds
import kotlinx.android.synthetic.main.layout_comme_send_data.*
import kotlinx.android.synthetic.main.layout_comme_send_data.view.*
import java.time.LocalDateTime
import java.time.ZoneId

class SetFunctionDetailActivity : BaseActivity() {
    private var type: Int = SetFuntionActivity.setDateTime
    private var setFuncData: SetFuncData? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_send_data
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun initView() {
        super.initView()
        setFuncData = intent.getSerializableExtra(SetFuntionActivity.SET_FUNCTION_DATA) as SetFuncData
        supportActionBar?.setTitle(setFuncData?.title)
        val myType = setFuncData?.type
        val idoBaseModel = setFuncData?.idoBaseModel
        send_btn.setOnClickListener {
            CmdSet.set(myType, idoBaseModel, {
                paramter_tv.text = it
            }) {
                tv_response.text = it
            }
        }

//        type = intent.getIntExtra(SetFuntionActivity.settypeInfo,SetFuntionActivity.setDateTime)
//        when(type) {
//            SetFuntionActivity.setDateTime -> supportActionBar?.setTitle("setDateTime")
//            SetFuntionActivity.setBleVoice -> supportActionBar?.setTitle("setBleVoice")
//        }
//        send_btn.setOnClickListener {
//            when(type) {
//                SetFuntionActivity.setDateTime ->{
//                    paramter_tv.text = "setDateTime:"
//                    val currentDateTime = LocalDateTime.now()
//                    val year = currentDateTime.year
//                    val month = currentDateTime.month.value
//                    val day = currentDateTime.dayOfMonth
//                    val hour = currentDateTime.hour
//                    val minute = currentDateTime.minute
//                    val second = currentDateTime.second
//                    val week = currentDateTime.dayOfWeek.value
//                    val zoneId = 8
//                    Cmds.setDateTime(IDODateTimeParamModel(year,month,day,hour,minute,second,week,zoneId)).send {
//                        if (it.error.code == 0) {
//                            tv_response.text = "set command success"
//                        }else {
//                            tv_response.text = "set command failed"
//                        }
//                    }
//                }
//                SetFuntionActivity.setBleVoice -> {
//                    var idoBleVoiceParamModel : IDOBleVoiceParamModel = IDOBleVoiceParamModel(2,10)
//                    paramter_tv.text = idoBleVoiceParamModel.toString()
//                    Cmds.setBleVoice(idoBleVoiceParamModel).send {
//                        tv_response.text = it.res.toString()
//                    }
//                }
//            }
//        }
    }


}
