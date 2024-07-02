package com.example.example_android.activity

import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.CmdSet
import com.example.example_android.data.CustomEvtType
import com.example.example_android.data.SetFuncData
import com.google.gson.GsonBuilder
import com.idosmart.model.IDOAlarmItem
import com.idosmart.model.IDOBaseModel
import com.idosmart.model.IDOWatchDialSortItem
import com.idosmart.model.IDOWatchDialSortParamModel
import com.idosmart.pigeon_implement.Cmds
import kotlinx.android.synthetic.main.layout_comme_send_data.*
import kotlinx.android.synthetic.main.layout_comme_send_data.view.*

class SetFunctionDetailActivity : BaseActivity() {
    private var type: Int = SetFuntionActivity.setDateTime
    private var setFuncData: SetFuncData? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_send_data
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun initView() {
        super.initView()
        setFuncData =
            intent.getSerializableExtra(SetFuntionActivity.SET_FUNCTION_DATA) as SetFuncData
        supportActionBar?.setTitle(setFuncData?.title)
        val myType = setFuncData?.type
        var idoBaseModel = setFuncData?.idoBaseModel
        Log.e("alarm", "$myType----${CustomEvtType.SETALARMV3}")
        when (myType) {
            CustomEvtType.SETALARMV3 -> {
                Cmds.getAlarm().send {
                    idoBaseModel = it.res
                    idoBaseModel?.toJsonString()?.let { it1 -> Log.e("alarm11111", it1) }
                    //闹钟首先要从固件拿到列表，然后对列表修改用户设置的，然后下发即可，
                    var idoAlarmModel: IDOAlarmItem = it.res?.items?.get(0) as IDOAlarmItem
                    idoAlarmModel.hour = 9
                    idoAlarmModel.minute = 10
                    idoAlarmModel.name = "dddd"
                    idoAlarmModel.repeatTimes = 1;
                    idoBaseModel?.toJsonString()?.let { it1 -> Log.e("alarm11111", it1) }
                }
            }

            CustomEvtType.SETWATCHDIALSORT -> {
                Cmds.getWatchListV2().send { it ->

                    var size = it.res?.items?.size
                    var list = mutableListOf<IDOWatchDialSortItem>()
                    var i = 0
                    it.res?.items?.forEach {
                        list.add(IDOWatchDialSortItem(1, i++, it.fileName))
                    }
                    idoBaseModel = IDOWatchDialSortParamModel(size!!, list)

                }


            }
            else -> {}
        }

        send_btn.setOnClickListener {
            if (paramter_et.text.isNotEmpty()) {

                idoBaseModel = GsonBuilder().create()
                    .fromJson(paramter_et.text.toString(), setFuncData!!.idoBaseModel::class.java)

            }
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
