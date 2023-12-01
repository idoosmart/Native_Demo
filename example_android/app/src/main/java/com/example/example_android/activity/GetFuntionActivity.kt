package com.example.example_android.activity

import android.content.Intent
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.adapter.GetFuntionAdapter
import com.example.example_android.data.GetFuntionData
import com.example.example_android.data.IDoDataBean
import kotlinx.android.synthetic.main.layout_get_funtion.ry_view

/**
 * get device function  list
 */
class GetFuntionActivity :BaseActivity() {
    private var function_list = mutableListOf<IDoDataBean>()
    var type:Int = getDeviceInfo;

    override fun getLayoutId(): Int {
        return R.layout.layout_get_funtion
    }
    fun  getDeviceInfo(view: View){
        type = getDeviceInfo
        toGetInfoDetailActivity()
    }
    fun  getFuntionTable(view: View){
        type = getFuntionTable
        toGetInfoDetailActivity()
    }
    fun  getSn(view: View){
        type = getSn
        toGetInfoDetailActivity()
    }
    fun  getMenuList(view: View){
        type = getMenuList
        toGetInfoDetailActivity()
    }
    fun  getNoticeStatus(view: View){
        type = getNoticeStatus
        toGetInfoDetailActivity()
    }
    fun  getMainSportGoal(view: View){
        type = getMainSportGoal
        toGetInfoDetailActivity()
    }
    fun  getWatchDiallinfo(view: View){
        type = getWatchDiallinfo
        toGetInfoDetailActivity()
    }

    fun toGetInfoDetailActivity(){
        val  intent = Intent(this,GetFunctionDetailActivity::class.java)
        intent.putExtra(typeInfo,type)
        startActivity(intent)
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("GetFuntionActivity")
        function_list.addAll(GetFuntionData.getFunctions(this))
        ry_view.layoutManager = LinearLayoutManager(this)
        var mAdapter = GetFuntionAdapter(function_list)
        mAdapter.setonItemClickListener(object : GetFuntionAdapter.onItemClickListener{
            override fun onItemClick(position: Int) {
                var intent =Intent(this@GetFuntionActivity,GetFunctionDetailActivity::class.java)
                intent.putExtra(GetFuntionActivity.FUNCTION_DATA,function_list[position])
                startActivity(intent)
            }


        })
        ry_view.adapter = mAdapter

    }
    companion object{
        val FUNCTION_DATA = "functon_data"
        var typeInfo : String = "typeInfo";
        var getDeviceInfo:Int = 1;
        var getFuntionTable:Int = 2;
        var getSn:Int = 3;
        var getMenuList:Int = 4;
        var getNoticeStatus:Int =5;
        var getMainSportGoal:Int =6;
        var getWatchDiallinfo:Int = 7;
    }


}