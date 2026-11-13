package com.example.example_android.sport;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 备注：
 * Remarks:
 * 1、获取基础信息：ble回复（err_code、operate、min_data_num、max_data_num、min_screen_num、max_screen_num、
 * 1. Get basic info: ble reply (err_code, operate, min_data_num, max_data_num, min_screen_num, max_screen_num,
 * sport_num、sport_item->sport_type、data_num、***data_item**）
 * 2、获取详情信息：ble回复（err_code、operate、sport_num、*sport_item）
 * 2. Get detail info: ble reply (err_code, operate, sport_num, *sport_item)
 * 3、编辑屏幕内容：ble回复（err_code、operate）
 * 3. Edit screen content: ble reply (err_code, operate)
 * */
public class SportScreenSetting implements Serializable {
    public final static int OPERATE_GET_BASE_INFO = 1;
    public final static int OPERATE_GET_DETAIL_INFO = 2;
    public final static int OPERATE_EDIT_SCREEN_CONTENT = 3;
    public int operate;//操作类型 0x01查询基础信息,0x02查询详情信息,0x03编辑 / Operation type: 0x01 query basic info,0x02 query detail info,0x03 edit
    public int sport_num;//当操作类型为0x02查询详情信息使用，最多2个运动类型同时获取配置详细，例如支持6个运动类型，下发3次，每次获取类型数量为2  获取到的运动类型个数   最大个数255 / Used when the operation type is 0x02 query detail info; at most 2 sport types can fetch their config details at once, e.g. with 6 sport types send 3 times, fetching 2 types each time. Number of sport types fetched; max count: 255
    public List<ScreenSportItem> sport_item_s = new ArrayList<>(); //运动项 / Sport items
    //回复数据
    //Reply data
    public int version;                              // 版本号 / Version number
    public int err_code;                             //错误码 0成功，非0是错误码、 / Error code: 0 succeeded, non-0 is an error code.
    public int min_data_num;                         //最小布局显示个数 / Min number of layout items displayed
    public int max_data_num;                         //最大布局显示个数 / Max number of layout items displayed
    public int min_screen_num;                       //最小屏幕显示个数 / Min number of screens displayed
    public int max_screen_num = 6;                       //最大屏幕显示个数 / Max number of screens displayed
    public int data_num;                             //获取到所有数据项的个数 获取详情信息时返回0  最大个数30 / Number of all data items fetched; returns 0 for the detail info query; max count: 30
    public List<ScreenSportItem> sport_item_reply_s = new ArrayList<>();
    public List<ScreenItemConf> screen_item_conf_t = new ArrayList<>();//获取屏幕信息，查基础使用，查详情返回NULL / Get screen info, used for the basic query; the detail query returns NULL

    public static class DataItem implements Serializable {
        public int data_type;           //当前数据项的类型 / Type of the current data item
        public int data_sub_type;       //当前选中的数据项子项，正常取值范围:0~15； 无效值：0XFF，表示没有选择任何子选项 / Currently selected data item sub-item, normal range: 0~15; invalid value: 0XFF, meaning no sub-option is selected
        @Override
        public String toString() {
            return "DataItem{" +
                    "data_type=" + data_type +
                    ", data_sub_type=" + data_sub_type +
                    '}';
        }
    }
    public static class ScreenItem implements Serializable {
        public int data_item_count;    //数据项数量 / Number of data items
        public List<DataItem> data_item_s = new ArrayList<>();//数据项 / Data items

        @Override
        public String toString() {
            return "ScreenItem{" +
                    "data_item_count=" + data_item_count +
                    ", data_item_s=" + data_item_s +
                    '}';
        }
    }

    public static class ScreenItemConf implements Serializable {
        public int layout_type;            //屏幕布局类型 / Screen layout type
        public int style;                  //风格 / Style

        @Override
        public String toString() {
            return "ScreenItemConf{" +
                    "layout_type=" + layout_type +
                    ", style=" + style +
                    '}';
        }
    }

}
