package com.clj.fastble.logs;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;


import com.clj.fastble.BleManager;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.LinkedBlockingDeque;

/**
 * @author: zhouzj
 * @date: 2017/11/2 15:11
 * 日志输出工具，
 * !!!!!!!!!注意：只有P，E级别的输出，才会保存到文件!!!!!!!!!!
 */
public class LogTool {
    private static final String FILE_NAME_PATTERN = "yyyyMMdd";
    private static final String FILE_TIMESTAMP_PATTERN = "yyyy-MM-dd HH:mm:ss.SSSZ";
    private static final String LINE_SEP = System.getProperty("line.separator");
    private static final String TAG = "[IDO_BLE_SDK] LogTool";
    private static final int SDCARD_LOG_FILE_SAVE_DAYS = 7;
    private static final String LOG_FILE_PREFIX_NAME = ".log";
    private static final int WHAT_MESSAGE = 1;
    private static final SimpleDateFormat mLogSimpleDateFormat = new SimpleDateFormat(FILE_TIMESTAMP_PATTERN, Locale.CHINA);
    private final static SimpleDateFormat mFileSimpleDateFormat = new SimpleDateFormat(FILE_NAME_PATTERN, Locale.CHINA);
    private final LinkedBlockingDeque<LogBean> mLogQueue = new LinkedBlockingDeque<>();
    private volatile boolean mIsStopLog = false;
    private Thread mLogThread;
    private static String LOG_PATH_SDCARD_DIR = "";

    private static LogTool instance = new LogTool();
    private static boolean isPermissionOk = true;

    private final Handler mMainHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (msg.what == WHAT_MESSAGE) {
                if (mLogListener != null) {
                    String log = (String) msg.obj;
                    mLogListener.onLog(log + LINE_SEP);
                }
            }
        }
    };

    private LogListener mLogListener;

    public interface LogListener {
        void onLog(String log);
    }

    private static void checkPermission() {
    }

    public static void init() {
        Log.i(TAG, "init...");
        checkPermission();

        if (isPermissionOk) {
            instance.start();
        }

    }

    public static void destroy() {
        Log.i(TAG, "destroy...");
        if (isPermissionOk) {
            instance.stop();
        }
    }

    public static void setLogListenner(LogListener logListener) {
        instance.mLogListener = logListener;
    }

    private LogTool() {

    }

    private Runnable mLooperRunnable = new Runnable() {

        public void run() {
            if (!createLogFileDir()) {
                Log.e(TAG, "createLogFileDir failed");
                return;
            }

            deleteOutDateLog();
            while (!mIsStopLog) {
                try {
                    if (mIsStopLog) {
                        break;
                    }
                    LogBean logBean = mLogQueue.takeFirst();
                    String log = logBean.convertToMessage(logBean.Level, logBean.Tag, logBean.Text);
                    if (TextUtils.isEmpty(log)) {
                        continue;
                    }

                    //发送日志内容给主线程
                    Message message = Message.obtain(mMainHandler);
                    message.what = WHAT_MESSAGE;
                    message.obj = log;
                    message.sendToTarget();

                    writeToFile(log);
                } catch (InterruptedException e) {
                    Log.e(TAG, e.getMessage(), e);
                    Thread.currentThread().interrupt();
                }

            }

            Log.i(TAG, "exit loop ok!");

        }
    };

    private boolean createLogFileDir() {
        File file = new File(getLogPathSdcardDir());
        if (!file.exists()) {
            return file.mkdirs();
        }

        return true;
    }


    private void start() {
        Log.d(TAG, "start");
        mIsStopLog = false;
        if (mLogThread == null) {
            mLogThread = new Thread(mLooperRunnable);
        }
        if (!mLogThread.isAlive()) {
            try {
                mLogThread.start();
            } catch (IllegalThreadStateException e) {
//                Log.e(TAG, e.getMessage());
            }
        }

    }

    private void stop() {
        Log.d(TAG, "stop");
        mIsStopLog = true;
        if ((mLogThread == null) || (!mLogThread.isAlive())) {
            return;
        }
        mLogQueue.clear();
        mLogThread = null;
    }


    public static void v(String pTag, String pMessage) {
        if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
            return;
        }
        Log.v(pTag, pMessage);
    }

    public static void d(String pTag, String pMessage) {
        if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
            return;
        }
        Log.d(pTag, pMessage);
    }


    public static void i(String pTag, String pMessage) {
        if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
            return;
        }
        Log.i(pTag, pMessage);
    }

    public static void w(String pTag, String pMessage) {
        if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
            return;
        }
        Log.w(pTag, pMessage);
    }


    public static void e(String pTag, String pMessage) {
        if (BleManager.getInstance().isEnableLog()) {
            if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
                return;
            }
            Log.e(pTag, pMessage);
            instance.writeLogToBuffer("E", pTag, pMessage);
        }
    }

    public static void p(String pTag, String pMessage) {
        if (BleManager.getInstance().isEnableLog()) {
            if (TextUtils.isEmpty(pTag) || TextUtils.isEmpty(pMessage)) {
                return;
            }
            Log.i(pTag, pMessage);
            instance.writeLogToBuffer("P", pTag, pMessage);
        }

    }

    private synchronized void writeLogToBuffer(String logLevel, String tag, String text) {
        if (!isPermissionOk) {
            checkPermission();
            return;
        }
        if ((mLogThread == null) || (!mLogThread.isAlive()) || (mIsStopLog)) {
            start();
        }
        mLogQueue.add(new LogBean(logLevel, tag, text));
    }

    private static String getLogPathSdcardDir() {
        if (LOG_PATH_SDCARD_DIR.equals("")) {
            boolean sdCardExist = Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED);
            if (sdCardExist) {
                StringBuilder builder = new StringBuilder();
                LOG_PATH_SDCARD_DIR = builder.append(
                                getRootPath()).
                        append("Log").toString();
            }
        }
        return LOG_PATH_SDCARD_DIR;
    }


    private static String APP_ROOT_PATH;

    public static String getRootPath() {
        if (TextUtils.isEmpty(APP_ROOT_PATH)) {
            String root = Environment.getExternalStorageDirectory().getAbsolutePath();
            File file = BleManager.getInstance().getContext().getFilesDir();
            if (file != null) {
                root = file.getAbsolutePath();
            }
            APP_ROOT_PATH = root
                    + File.separator + "IDO_BLE_SDK" + File.separator;
        }
        return APP_ROOT_PATH;
    }

    private void writeToFile(String log) {
        if (!BleManager.getInstance().isEnableLog()) {
            return;
        }
        BufferedWriter bw = null;
        String fullPath = getLogPathSdcardDir() + File.separator + getFileName();
        File file = new File(fullPath);
        boolean isFileExist = true;
        if (!file.exists()) {
            try {
                isFileExist = file.createNewFile();
            } catch (IOException e) {
                Log.e(TAG, e.toString());
            }
        }
        if (!isFileExist) {
            Log.e(TAG, "create log file failed!");
            return;
        }

        try {
            bw = new BufferedWriter(new FileWriter(file, true));
            bw.write(log);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        } finally {
            try {
                if (bw != null) {
                    bw.close();
                }
            } catch (IOException e) {
                Log.e(TAG, e.toString());
            }
        }
    }


    private void deleteOutDateLog() {
        File dir = new File(LOG_PATH_SDCARD_DIR);
        if (!dir.exists()) {
            return;
        }
        File[] files = dir.listFiles();
        if (files == null || files.length == 0) {
            return;
        }

        for (int i = 0; i < files.length; i++) {
            File file = files[i];
            if (file.isDirectory()) {
                continue;
            }

            Date beforeDate = getDateBefore();
            if (file.getName().endsWith(LOG_FILE_PREFIX_NAME)) {
                String logDateStr = file.getName().replace(LOG_FILE_PREFIX_NAME, "");
                Date logCalendar = getFileDateByStr(logDateStr);
                if (logCalendar.before(beforeDate)) {
                    file.delete();
                }
            }
        }

    }

    private Date getDateBefore() {
        int logSaveDays;
        logSaveDays = SDCARD_LOG_FILE_SAVE_DAYS;

        Calendar now = Calendar.getInstance();
        now.set(Calendar.DAY_OF_MONTH, (now.get(Calendar.DAY_OF_MONTH) - logSaveDays));
        now.set(Calendar.HOUR, 0);
        now.set(Calendar.MINUTE, 0);
        now.set(Calendar.SECOND, 0);
        return now.getTime();
    }

    private synchronized Date getFileDateByStr(String dateStr) {
        Date date = Calendar.getInstance().getTime();
        synchronized (LogTool.class) {
            try {
                date = mFileSimpleDateFormat.parse(dateStr);
            } catch (ParseException e) {
                Log.e(TAG, e.getMessage(), e);
            }
        }
        return date;
    }

    private synchronized String getFileName() {
        Date date = Calendar.getInstance().getTime();
        synchronized (LogTool.class) {
            return mFileSimpleDateFormat.format(date) + LOG_FILE_PREFIX_NAME;

        }
    }

    private synchronized String getLogTimeString() {
        Date date = Calendar.getInstance().getTime();
        synchronized (LogTool.class) {
            return mLogSimpleDateFormat.format(date);

        }
    }

    private static class LogBean {
        String Level;
        String Tag;
        String Text;

        public LogBean(String level, String tag, String text) {
            Level = level;
            Tag = tag;
            Text = text;
        }

        public String convertToMessage(String logLevel, String tag, String text) {
            if (TextUtils.isEmpty(logLevel) || TextUtils.isEmpty(tag) || TextUtils.isEmpty(text))
                return null;
            if (!isPermissionOk) {
                checkPermission();
                return null;
            }
            if (TextUtils.isEmpty(getLogPathSdcardDir())) {
                Log.e(TAG, "getLogPathSdcardDir or dirPath is null");
                return null;
            }
            if (tag.length() < 20) {
                StringBuilder builder = new StringBuilder(tag);
                for (int i = builder.length(); i < 20; i++) {
                    builder.append(" ");
                }
                tag = builder.toString();
            }
            return new StringBuilder().append(logLevel)
                    .append("    [").append(mLogSimpleDateFormat.format(Calendar.getInstance().getTime())).append("]    ")
                    .append("    [").append(tag).append("]    ")
                    .append(text)
                    .append(LINE_SEP)
                    .toString();
        }
    }
}


