package com.example.example_android.activity

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import com.example.example_android.base.BaseActivity
import com.example.example_android.R


class FunctionListActivity : BaseActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun getLayoutId(): Int {
       return R.layout.activity_function_list
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("FunctionList")
    }


}