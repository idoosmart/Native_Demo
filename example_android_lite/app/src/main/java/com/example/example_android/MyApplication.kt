package com.example.example_android

import android.app.Application
import android.content.res.AssetManager
import com.clj.fastble.BleManager
import com.example.example_android.data.BLEdata
import com.idosmart.protocol_channel.sdk
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.util.Arrays


private fun copyAssetFolder(
    assetManager: AssetManager,
    fromAssetPath: String, toPath: String
): Boolean {
    return try {
        val files = assetManager.list(fromAssetPath)
        File(toPath).mkdirs()
        var res = true
        for (file in files!!) res = if (file.contains(".")) res and copyAsset(
            assetManager,
            "$fromAssetPath/$file",
            "$toPath/$file"
        ) else res and copyAssetFolder(
            assetManager,
            "$fromAssetPath/$file",
            "$toPath/$file"
        )
        res
    } catch (e: Exception) {
        e.printStackTrace()
        false
    }
}

private fun copyAsset(
    assetManager: AssetManager,
    fromAssetPath: String, toPath: String
): Boolean {
    var `in`: InputStream? = null
    var out: OutputStream? = null
    return try {
        `in` = assetManager.open(fromAssetPath)
        File(toPath).createNewFile()
        out = FileOutputStream(toPath)
        copyFile(`in`, out)
        true
    } catch (e: Exception) {
        e.printStackTrace()
        false
    } finally {
        `in`?.close()
        `in` = null
        out?.flush()
        out?.close()
        out = null
    }
}

@Throws(IOException::class)
private fun copyFile(`in`: InputStream, out: OutputStream) {
    val buffer = ByteArray(1024)
    var read: Int
    while (`in`.read(buffer).also { read = it } != -1) {
        out.write(buffer, 0, read)
    }
}


class MyApplication : Application() {
    companion object {
        lateinit var instance: Application
    }

    init {
        instance = this
    }

    override fun onCreate() {
        super.onCreate()
        BleManager.getInstance().init(this);
        registerIdoSDK()
        //第三方的蓝牙库初始化，如果自己有蓝牙就不需要接入
        initResource()
    }

    private fun registerIdoSDK(){
        /// 只初始化一次
        sdk.init(this)
        BLEdata.registBridge()
    }

    private fun initResource() {
        Thread {
            try {
                copyAssetFolder(assets, "resource", filesDir.absolutePath + "/resources")
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }

}