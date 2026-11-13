package com.example.example_android.sport;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ScreenSportItem implements Serializable {
    public int sport_type;               //运动类型 / Sport type
    public int screen_num;              //使用屏幕个数     屏幕项最大个数15 / Number of screens used; max number of screen items: 15
    public int support_data_type_num;   //支持的数据项类型个数   最大个数30 / Number of supported data item types; max count: 30
    public List<SportScreenSetting.ScreenItem> screen_item_s = new ArrayList<>();  //屏幕项 / Screen items
    public List<SportScreenSetting.DataItem> data_item_conf_t = new ArrayList<>(); //获取数据项信息，查基础使用，查详情返回NULL / Get data item info, used for the basic query; the detail query returns NULL

    @Override
    public String toString() {
        return "SportItem{" +
                "sport_type=" + sport_type +
                ", screen_num=" + screen_num +
                ", support_data_type_num=" + support_data_type_num +
                ", screen_item_s=" + screen_item_s +
                ", data_item_conf_t=" + data_item_conf_t +
                '}';
    }
}
