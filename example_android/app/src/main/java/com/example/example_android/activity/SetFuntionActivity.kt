package com.example.example_android.activity

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.example_android.base.BaseActivity
import com.example.example_android.R
import com.example.example_android.adapter.GetFuntionAdapter
import com.example.example_android.data.IDoDataBean
import com.example.example_android.data.SetFuncData
import com.google.android.material.tabs.TabLayout
import kotlinx.android.synthetic.main.layout_set_funtion.ry_view
import kotlinx.android.synthetic.main.layout_set_funtion.tab_layout

class SetFuntionActivity : BaseActivity() {

    private var supportedList = mutableListOf<IDoDataBean>()
    private var unsupportedList = mutableListOf<IDoDataBean>()
    private lateinit var mAdapter: GetFuntionAdapter

    override fun getLayoutId(): Int {
        return R.layout.layout_set_funtion
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("SetFuntion")

        val fullList = SetFuncData.getFunctions(this)
        
        // Split lists by support status
        supportedList.addAll(fullList.filter { it.isSupported })
        unsupportedList.addAll(fullList.filter { !it.isSupported })

        // Initialize TabLayout
        tab_layout.addTab(tab_layout.newTab().setText("Supported"))
        tab_layout.addTab(tab_layout.newTab().setText("Unsupported"))

        ry_view.layoutManager = LinearLayoutManager(this)
        mAdapter = GetFuntionAdapter(supportedList)
        mAdapter.setonItemClickListener(object : GetFuntionAdapter.onItemClickListener {
            override fun onItemClick(position: Int) {
                val item = mAdapter.getFuntionList[position]
                if (!item.isSupported) {
                    toast(getString(R.string.unsupported_feature) ?: "Unsupported Feature")
                    return
                }

                val intent = Intent(this@SetFuntionActivity, SetFunctionDetailActivity::class.java)
                intent.putExtra(SET_FUNCTION_DATA, item)
                startActivity(intent)
            }
        })
        ry_view.adapter = mAdapter

        tab_layout.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                if (tab?.position == 0) {
                    mAdapter.getFuntionList = supportedList
                } else {
                    mAdapter.getFuntionList = unsupportedList
                }
                mAdapter.notifyDataSetChanged()
            }
            override fun onTabUnselected(tab: TabLayout.Tab?) {}
            override fun onTabReselected(tab: TabLayout.Tab?) {}
        })
    }

    companion object {
        val SET_FUNCTION_DATA = "set_function_data"
    }
}
