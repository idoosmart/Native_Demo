package com.example.example_android.util

import com.clj.fastble.logs.LogTool
import io.flutter.Log

object Logutil {

    fun logMessage(tag: String, content: String) {
//        Log.e(tag,content)
        LogTool.p(tag, content)
    }
}