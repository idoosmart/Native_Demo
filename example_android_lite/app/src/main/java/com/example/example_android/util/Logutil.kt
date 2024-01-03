package com.example.example_android.util

import io.flutter.Log

 object Logutil {

    fun logMessage(tag:String,content:String){
        Log.e(tag,content)
    }
}