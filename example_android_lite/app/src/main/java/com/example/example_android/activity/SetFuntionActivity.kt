package com.example.example_android.activity

import android.content.Intent
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.adapter.GetFuntionAdapter
import com.example.example_android.data.IDoDataBean
import com.example.example_android.data.SetFuncData
import kotlinx.android.synthetic.main.layout_get_funtion.ry_view

class SetFuntionActivity :BaseActivity(){
    var type:Int = setDateTime
    private var function_list = mutableListOf<IDoDataBean>()
    override fun getLayoutId(): Int {
        return R.layout.layout_set_funtion
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("SetFuntion")
        function_list.addAll((SetFuncData.getFunctions(this)))
        ry_view.layoutManager = LinearLayoutManager(this)
        var mAdapter = GetFuntionAdapter(function_list.toMutableList())
        mAdapter.setonItemClickListener(object : GetFuntionAdapter.onItemClickListener{
            override fun onItemClick(position: Int) {
                var intent =Intent(this@SetFuntionActivity,SetFunctionDetailActivity::class.java)
                intent.putExtra(SET_FUNCTION_DATA,function_list[position])
                startActivity(intent)
            }


        })
        ry_view.adapter = mAdapter
        val date ="dd"
    }
    fun  setDateTime(view: View){
         type = setDateTime
        toSeteInfoDetailActivity()
    }
    fun  setBleVoice(view: View){
         type = setBleVoice
         toSeteInfoDetailActivity()
    }

    fun toSeteInfoDetailActivity(){
        val  intent = Intent(this,SetFunctionDetailActivity::class.java)
        intent.putExtra(SetFuntionActivity.settypeInfo,type)
        startActivity(intent)
    }

    companion object{
        val SET_FUNCTION_DATA = "set_function_data"
        var settypeInfo : String = "settypeInfo";
        var setDateTime:Int = 1;
        var setBleVoice:Int = 2;
    }
}
