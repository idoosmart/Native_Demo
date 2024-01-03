package com.example.example_android.util

import android.util.Log
import java.lang.StringBuilder
import kotlin.experimental.and

object ByteUtil {
    fun bytesToHexString(src: ByteArray?): String? {
        val stringBuilder = StringBuilder()
        if (src == null || src.size <= 0) {
            return null
        }
        for (i in src.indices) {
            val v: Int = (src[i].toInt() and 0xff)
            val hv = Integer.toHexString(v)
            if (hv.length < 2) {
                stringBuilder.append(0)
            }
            stringBuilder.append(hv)
            stringBuilder.append(" ")
        }
        return stringBuilder.toString()
    }

}