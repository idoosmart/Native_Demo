package com.example.example_android.data

import java.io.Serializable

open class IDoDataBean constructor(var type : CustomEvtType,
                                   var title : String ?= null ,var  sub_title : String ?= null ):Serializable{
}