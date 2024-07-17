package com.example.example_android.data

import android.graphics.drawable.Drawable
import java.io.Serializable
/**
 * 自定义应用实体数据类
 * evtType：事件类型，应用唯一识别号，每个应用有自己对应的事件类型
 * pkgName：包名
 * appName: app名称
 * icon：应用图标资源数据
 * status:应用通知状态
 * */
data class TranIconBean(
    var evtType: Int? =null,
    var pkgName: String?=null,
    var appName: String?=null,
    var icon: Drawable?=null,
    var status: Int?=null,
    var iconState: Int?=null,
    var isUpdateAppIcon: Boolean?=null
):Serializable{

}
