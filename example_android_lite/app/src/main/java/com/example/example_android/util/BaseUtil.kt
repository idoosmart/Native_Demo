package com.example.example_android.util

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File

object BaseUtil {

    fun share(context: Context,path:String){
        if (path.isNotEmpty()) {
            // 设置弹出框标题
            val intent = Intent(Intent.ACTION_SEND)
            intent.type = "application/zip"

            val file = File(path)
            val fileUri: Uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // Android 版本大于等于 Nougat (7.0)
                FileProvider.getUriForFile(
                    context,
                    "com.example.example_android.fileprovider",
                    file
                )
            } else {
                // Android 版本低于 Nougat (7.0)
                Uri.fromFile(file)
            }
            intent.putExtra(Intent.EXTRA_STREAM, fileUri)
            intent.putExtra(Intent.EXTRA_SUBJECT, "分享日志输出工具")
            intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            context.startActivity(Intent.createChooser(intent, "分享日志输出工具"))
        }
    }
}