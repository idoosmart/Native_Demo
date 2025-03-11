package com.clj.fastble.logs;

/**
 * @author: zhouzj
 * @date: 2017/10/25 14:23
 */

public class LogTag {
    public static final String TAG_CMD = "IDO_CMD";
    /**
     * 绑定，解绑
     */
    public static final String TAG_CMD_BIND_UNBIND = "[BIND_UNBIND] ";

    /**
     * 同步
     */
    public static final String TAG_CMD_SYNC = "[SYNC_DATA] ";

    /**
     * 获取信息
     */
    public static final String TAG_CMD_GET = "[GET_INFO] ";
    /**
     * 设置参数
     */
    public static final String TAG_CMD_SET = "[SET_PARA] ";

    /**
     * 操作参数（增，删，改，查）
     */
    public static final String TAG_CMD_OPERATE = "[OPERATE_PARA] ";

    /**
     * 获取参数
     */
    public static final String TAG_CMD_GET_PARA = "[GET_PARA] ";

    /**
     * 数据操作
     */
    public static final String TAG_DATA_OPERATOR = "IDO_DATA ";

    /**
     * SO库动作
     */
    public static final String TAG_SO_LIB_ACTION = "SO_LIB_ACTION ";

    /**
     * GPS
     */
    public static final String TAG_GPS = "IDO_GPS ";

    /**
     * Voice
     */
    public static final String TAG_VOICE = "IDO_VOICE";

    /**
     * 通知提醒
     */
    public static final String TAG_NOTICE = "IDO_NOTICE";

    /**
     * WATCH_PLATE
     */
    public static final String TAG_WATCH_PLATE = "[IDO_WATCH_PLATE] ";
    public static final String TAG_CMD_COMMON = "[GET_SET_COMMON] ";
    public static final String TAG_EXCHANGE_DATA = "[EXCHANGE_DATA]";

    /**
     * 发送数据
     */
    public static final String TAG_APP_SEND_DATA = "[APP_SEND_DATA] ";

    public static final String TAG_BT_CONNECT = "BT_CONNECT";
}
