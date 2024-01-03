package com.example.example_android.activity

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AlertDialog
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.idosmart.enum.IDOAlexaLoginState
import com.idosmart.enum.IDOGetValueType
import com.idosmart.protocol_channel.IDOSDK
import com.idosmart.protocol_sdk.IDOAlexaDelegate
import com.idosmart.protocol_sdk.IDOCancellable
import kotlinx.android.synthetic.main.layout_alexa_activity.*

class AlexaActivity : BaseActivity(), IDOAlexaDelegate {
    private var alexa = IDOSDK.instance().alexa
    private var mIDOCancellable: IDOCancellable? = null
    override fun getLayoutId(): Int {
        return R.layout.layout_alexa_activity
    }

    override fun initView() {
        super.initView()
        alexa.setupAlexa(this@AlexaActivity, "amzn1.application-oa2-client.e45ff1ade6064c24a265fe6924c6f75d"/*only for test*/)
        tv_login?.text = getString(R.string.login)
        alexa.onLoginStateChanged {
            if (it == IDOAlexaLoginState.LOGINED) {
                tv_login?.text = getString(R.string.logout)
            } else {
                tv_login?.text = getString(R.string.login)
            }
        }
        tv_login.setOnClickListener {
            if (alexa.isLogin) {
                alexa.logout()
            } else {
                mIDOCancellable = alexa.authorizeRequest("IDW05", { verificationUri, pairCode ->
                    val dialog = AlertDialog.Builder(this@AlexaActivity).setTitle(getString(R.string.alexa_dialog_title))
                        .setMessage(getString(R.string.alexa_dialog_msg).format(pairCode))
                        .setPositiveButton(R.string.alexa_dialog_copy) { dialog, which ->
                            //获取剪贴板管理器：
                            val cm = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                            // 创建普通字符型ClipData
                            val mClipData = ClipData.newPlainText("Label", pairCode)
                            // 将ClipData内容放到系统剪贴板里。
                            cm.setPrimaryClip(mClipData)
                            val intent = Intent(Intent.ACTION_VIEW)
                            intent.data = Uri.parse(verificationUri)
                            startActivity(intent)
                            dialog.dismiss()
                        }.setNegativeButton(R.string.alexa_dialog_cancel, { dialog, which -> dialog.dismiss() }).show()
                }, { rs ->
                    println("登录结果：${rs.name}") })
            }
        }
    }

    override fun getHealthValue(valueType: IDOGetValueType): Int {
        TODO("Not yet implemented")
    }

    override fun getHrValue(dataType: Int, timeType: Int): Int {
        TODO("Not yet implemented")
    }

    override fun functionControl(funType: Int) {
        TODO("Not yet implemented")
    }

    override fun onDestroy() {
        super.onDestroy()
        mIDOCancellable?.cancel()
    }
}
