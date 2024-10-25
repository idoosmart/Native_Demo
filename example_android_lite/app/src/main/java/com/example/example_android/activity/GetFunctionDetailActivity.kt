package com.example.example_android.activity

import android.util.Log
import com.clj.fastble.BleManager
import com.clj.fastble.callback.BleMtuChangedCallback
import com.clj.fastble.exception.BleException
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.data.CmdGet
import com.example.example_android.data.GetFuntionData
import com.example.example_android.data.CustomEvtType
import com.google.gson.GsonBuilder
import com.idosmart.model.IDOMtuInfoModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOCancellable
import kotlinx.android.synthetic.main.layout_comme_send_data.*

class GetFunctionDetailActivity : BaseActivity() {
    private var getFunctionData: GetFuntionData? = null
    private var mIDOCancellable: IDOCancellable? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_comme_send_data
    }

    override fun initView() {
        super.initView()
        getFunctionData =
            intent.getSerializableExtra(GetFuntionActivity.FUNCTION_DATA) as GetFuntionData?
        supportActionBar?.title = getFunctionData?.title
        val myType = getFunctionData?.type ?: return
        send_btn.setOnClickListener {
            if (myType == CustomEvtType.GETDEVICEINFO) {
                val deviceInfo = sdk.device
                tv_response?.text = deviceInfo.toString()
            } else {
                mIDOCancellable =
                    CmdGet.get(myType, { params -> paramter_tv?.text = params }) { s ->
                        tv_response?.text = s


                    }
            }

        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (mIDOCancellable != null && !mIDOCancellable!!.isCancelled) {
            mIDOCancellable?.cancel()
        }
    }
}