package com.example.example_android.data

import com.idosmart.pigeongen.api_evt_type.ApiEvtType
import java.io.Serializable

open class IDoDataBean constructor(var type : ApiEvtType,
                               var title : String ?= null ,var  sub_title : String ?= null ):Serializable{
 }