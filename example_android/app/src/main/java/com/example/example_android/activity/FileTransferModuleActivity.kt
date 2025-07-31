package com.example.example_android.activity

import android.content.Intent
import android.view.View
import com.example.example_android.base.BaseActivity
import com.example.example_android.activity.FileTransferActivity
import com.example.example_android.R
import kotlinx.android.synthetic.main.activity_transfer_module_file.*

class FileTransferModuleActivity : BaseActivity(), View.OnClickListener {

    override fun getLayoutId(): Int {
        return R.layout.activity_transfer_module_file
    }

    override fun initView() {
        super.initView()
        supportActionBar?.setTitle("Transfer File")
        tvWallpaper.setOnClickListener(this)
        tvContact.setOnClickListener(this)
        tvMusic.setOnClickListener(this)
        tvOta.setOnClickListener(this)
    }

    override fun onClick(v: View?) {
        when (v?.id) {
            R.id.tvWallpaper -> {
                startActivity(Intent(this, DialFileTransferActivity::class.java))
            }

            R.id.tvContact -> {
                startActivity(Intent(this, FileTransferActivity::class.java).putExtra("type", 2))
            }

            R.id.tvMusic -> {
                startActivity(Intent(this, MusicTransferActivity::class.java))
            }
            R.id.tvOta -> {
                startActivity(Intent(this, OtaFileTransferActivity::class.java))
            }
        }
    }
}