package com.clj.fastble.utils;


import android.util.Log;

import com.clj.fastble.logs.LogTool;

public final class BleLog {

    public static boolean isPrint = true;
    private static final String defaultTag = "FastBle";

    public static void d(String msg) {
        if (isPrint && msg != null)
//            Log.d(defaultTag, msg);
            LogTool.p(defaultTag,msg);
    }

    public static void i(String msg) {
        if (isPrint && msg != null)
//            Log.i(defaultTag, msg);
            LogTool.p(defaultTag,msg);
    }

    public static void w(String msg) {
        if (isPrint && msg != null)
//            Log.w(defaultTag, msg);
            LogTool.p(defaultTag,msg);
    }

    public static void e(String msg) {
        if (isPrint && msg != null)
//            Log.e(defaultTag, msg);
            LogTool.e(defaultTag,msg);
    }

}
