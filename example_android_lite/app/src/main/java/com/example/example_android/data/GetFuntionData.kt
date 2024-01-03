package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.model.IDOAppExecType
import com.idosmart.pigeongen.api_evt_type.ApiEvtType
import java.io.Serializable

 class GetFuntionData(type: ApiEvtType, title: String? = null, sub_title: String? = null) :
     IDoDataBean(type, title, sub_title){
     companion object{
         fun getFunctions(context: Context):MutableList<GetFuntionData>{
             return mutableListOf<GetFuntionData>(
//                 GetFuntionData(ApiEvtType.GETMAC,"获取mac地址",""),
                 GetFuntionData(ApiEvtType.GETDEVICEINFO,context.getString(R.string.getdeviceinfo),  ""),
//                 GetFuntionData(ApiEvtType.GETFUNCTABLE,"获取功能表",""),
//                 GetFuntionData(ApiEvtType.GETFUNCTABLEEX," 获取功能表 扩展",""),
                 GetFuntionData(ApiEvtType.GETSNINFO,context.getString(R.string.getsninfo),""),
                 GetFuntionData(ApiEvtType.GETBTNAME,context.getString(R.string.getbtname),""),
                 GetFuntionData(ApiEvtType.GETLIVEDATA,context.getString(R.string.getlivedata),""),
                         GetFuntionData(ApiEvtType.GETNOTICESTATUS,context.getString(R.string.getnoticestatus),""),
//                 GetFuntionData(ApiEvtType.GETHRSENSORPARAM,"获取心率传感器参数",""),
//                 GetFuntionData(ApiEvtType.GETGSENSORPARAM,"获取加速度传感器参数",""),
//                 GetFuntionData(ApiEvtType.GETACTIVITYCOUNT,"获取同步时间轴来计算百分比",""),
                 GetFuntionData(ApiEvtType.GETHIDINFO,context.getString(R.string.gethidinfo),""),
                 GetFuntionData(ApiEvtType.GETGPSINFO,context.getString(R.string.getgpsinfo),""),
                 GetFuntionData(ApiEvtType.GETGPSSTATUS,context.getString(R.string.getgpsstatus),""),
                 GetFuntionData(ApiEvtType.GETHOTSTARTPARAM,context.getString(R.string.gethotstartparam),""),
                 GetFuntionData(ApiEvtType.GETVERSIONINFO,context.getString(R.string.getversioninfo),""),
                 GetFuntionData(ApiEvtType.GETMTUINFO,context.getString(R.string.getmtuinfo),""),
                 GetFuntionData(ApiEvtType.GETNOTDISTURBSTATUS,context.getString(R.string.getnotdisturbstatus),""),
//                 GetFuntionData(ApiEvtType.GETDEFAULTSPORTTYPE,"获取默认的运动类型",""),
                 GetFuntionData(ApiEvtType.GETDOWNLANGUAGE,context.getString(R.string.getdownlanguage),""),
                 GetFuntionData(ApiEvtType.GETERRORRECORD,context.getString(R.string.geterrorrecord),""),
                 GetFuntionData(ApiEvtType.GETMAINSPORTGOAL,context.getString(R.string.getmainsportgoalordistance),""),
                 GetFuntionData(ApiEvtType.GETWALKREMIND,context.getString(R.string.getwalkremind),""),
                 GetFuntionData(ApiEvtType.GETBATTERYINFO,context.getString(R.string.getbatteryinfo),""),
                 GetFuntionData(ApiEvtType.GETFLASHBININFO,context.getString(R.string.getflashbininfo),""),
                 GetFuntionData(ApiEvtType.GETMENULIST,context.getString(R.string.getsupportedlist),""),
//                 GetFuntionData(ApiEvtType.GETREALMEDEVINFO,"获取realme项目的硬件信息",""),
                 GetFuntionData(ApiEvtType.GETSCREENBRIGHTNESS,context.getString(R.string.getscreenbrightness),""),
                 GetFuntionData(ApiEvtType.GETUPHANDGESTURE,context.getString(R.string.getuphandgesture),""),
//                 GetFuntionData(ApiEvtType.GETENCRYPTEDCODE,"获取授权数据",""),
                 GetFuntionData(ApiEvtType.GETUPDATESTATUS,context.getString(R.string.getupdatestatus),""),
                 GetFuntionData(ApiEvtType.GETWATCHDIALID,context.getString(R.string.getwatchdialid),""),
                 GetFuntionData(ApiEvtType.GETWATCHDIALINFO,context.getString(R.string.getwatchdialinfo),""),
                 GetFuntionData(ApiEvtType.GETDEVICENAME,context.getString(R.string.getdevicename),""),
                 GetFuntionData(ApiEvtType.GETDEVICELOGSTATE,context.getString(R.string.getdevicelogstate),""),
                 GetFuntionData(ApiEvtType.GETALLHEALTHSWITCHSTATE,context.getString(R.string.getallhealthswitchstate),""),
//                 GetFuntionData(ApiEvtType.GETDATATRANCONFIG,"文件传输配置传输获取",""),
                 GetFuntionData(ApiEvtType.GETACTIVITYSWITCH,context.getString(R.string.getactivityswitch),""),
//                 GetFuntionData(ApiEvtType.GETFIRMWAREBTVERSION,"获得固件三级版本和bt的3级版本",""),
                 GetFuntionData(ApiEvtType.GETSTRESSVAL,context.getString(R.string.getstressval),""),
                 GetFuntionData(ApiEvtType.GETBPALGVERSION,context.getString(R.string.getbpalgversion),""),
                 GetFuntionData(ApiEvtType.GETHEARTRATEMODE,context.getString(R.string.getheartratemode),""),
                 GetFuntionData(ApiEvtType.GETSTEPGOAL,context.getString(R.string.getstepgoal),""),
//                 GetFuntionData(ApiEvtType.GETLIBVERSION,"获取lib版本号",""),
//                 GetFuntionData(ApiEvtType.GETAPPID,"获取appid ios only",""),
                 GetFuntionData(ApiEvtType.GETWATCHFACELIST,context.getString(R.string.getwatchfacelist),""),
                 GetFuntionData(ApiEvtType.GETBTNOTICE,context.getString(R.string.getbtnotice),""),
//                 GetFuntionData(ApiEvtType.GETSPORTTYPEV3,"v3 获取运动默认的类型",""),
                 GetFuntionData(ApiEvtType.GETALARMV3,context.getString(R.string.getalarmv3) ,""),
                 GetFuntionData(ApiEvtType.GETLANGUAGELIBRARYDATAV3,context.getString(R.string.getlanguagelibrarydatav3),""),
                 GetFuntionData(ApiEvtType.GETWATCHLISTV3,context.getString(R.string.getwatchlistv3) ,""),
//                 GetFuntionData(ApiEvtType.GETALEXAALARMV3,"v3 alexa获取v3的闹钟",""),
//                 GetFuntionData(ApiEvtType.GETACTIVITYEXCHANGEGPSDATA,"v3 多运动数据数据交换中获取一段时间的gps数据",""),
//                 GetFuntionData(ApiEvtType.GETHISTORICALMENSTRUATION,"经期的历史数据下发",""),
                 GetFuntionData(ApiEvtType.GETBLEBEEPV3,context.getString(R.string.getblebeepv3),""),
                 GetFuntionData(ApiEvtType.GETHABITINFOV3,context.getString(R.string.gethabitinfov3),""),
                 GetFuntionData(ApiEvtType.GETSUPPORTMAXSETITEMSNUM,context.getString(R.string.getsupportmaxsetitemsnum),""),
                 GetFuntionData(ApiEvtType.GETUNERASABLEMEUNLIST,context.getString(R.string.getunerasablemeunlist),""),
//                 GetFuntionData(ApiEvtType.GETMTULENGTHSPP,"获取固件spp mtu长度   新增  spp蓝牙专用",""),
                 GetFuntionData(ApiEvtType.GETUNREADAPPREMINDER,context.getString(R.string.getunreadappreminder),""),
                 GetFuntionData(ApiEvtType.GETCONTACTREVISETIME,context.getString(R.string.getcontactrevisetime),""),
//                 GetFuntionData(ApiEvtType.GETFLASHLOGSTART,"开始获取flash log",""),
//                 GetFuntionData(ApiEvtType.GETBATTERYLOG,"获取电池日志",""),
                 GetFuntionData(ApiEvtType.GETBLEMUSICINFO,context.getString(R.string.getblemusicinfo),""),
             )
         }
     }
 }

