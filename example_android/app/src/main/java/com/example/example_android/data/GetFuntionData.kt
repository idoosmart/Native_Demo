package com.example.example_android.data

import android.content.Context
import com.example.example_android.R
import com.idosmart.protocol_channel.sdk
/**
 * 此类做用是统一管理各功能列表操作
 * 实际开发时，根据事件类型，关注单个功能直接调用接口即可，在使用前请参考该类中的功能表判断逻辑
 * This class is used to manage the list of functions in a unified manner
 * In actual development, you can directly invoke the interface of a single function based on the event type.
 * You can refer to the function table in this class to determine the logic before using it
 * */

class GetFuntionData(type: CustomEvtType, title: String? = null, sub_title: String? = null) :
    IDoDataBean(type, title, sub_title) {
    companion object {
        fun getFunctions(context: Context): MutableList<GetFuntionData> {

            var mutableListOf = mutableListOf<GetFuntionData>(
//                 GetFuntionData(CustomEvtType.GETMAC,"获取mac地址",""),
//                GetFuntionData(
//                    CustomEvtType.OTASTART,
//                    context.getString(R.string.enter_upgrade_mode),
//                    ""
//                ),
                GetFuntionData(CustomEvtType.REBOOT, context.getString(R.string.reboot_device), ""),
                GetFuntionData(
                    CustomEvtType.FACTORYRESET,
                    context.getString(R.string.restore_factory_settings),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.FINDDEVICESTART,
                    context.getString(R.string.find_devices),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.FINDDEVICESTOP,
                    context.getString(R.string.end_device_search),
                    ""
                ),

                GetFuntionData(
                    CustomEvtType.GETDEVICEINFO,
                    context.getString(R.string.getdeviceinfo),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETFUNCTABLE,"获取功能表",""),
//                 GetFuntionData(CustomEvtType.GETFUNCTABLEEX," 获取功能表 扩展",""),

                GetFuntionData(
                    CustomEvtType.GETNOTICESTATUS,
                    context.getString(R.string.getnoticestatus),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETHRSENSORPARAM,"获取心率传感器参数",""),
//                 GetFuntionData(CustomEvtType.GETGSENSORPARAM,"获取加速度传感器参数",""),
//                 GetFuntionData(CustomEvtType.GETACTIVITYCOUNT,"获取同步时间轴来计算百分比",""),
//                GetFuntionData(
//                    CustomEvtType.GETHIDINFO,
//                    context.getString(R.string.gethidinfo),
//                    ""
//                ),


//                GetFuntionData(
//                    CustomEvtType.GETHOTSTARTPARAM,
//                    context.getString(R.string.gethotstartparam),
//                    ""
//                ),


                GetFuntionData(
                    CustomEvtType.GETNOTDISTURBSTATUS,
                    context.getString(R.string.getnotdisturbstatus),
                    ""
                ),
                 GetFuntionData(CustomEvtType.GETDEFAULTSPORTTYPE,"获取默认的运动类型",""),


                GetFuntionData(
                    CustomEvtType.GETMAINSPORTGOAL,
                    context.getString(R.string.getmainsportgoalordistance),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETWALKREMIND,
                    context.getString(R.string.getwalkremind),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETBATTERYINFO,
                    context.getString(R.string.getbatteryinfo),
                    ""
                ),

                GetFuntionData(
                    CustomEvtType.GETMENULIST,
                    context.getString(R.string.getsupportedlist),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETREALMEDEVINFO,"获取realme项目的硬件信息",""),
                GetFuntionData(
                    CustomEvtType.GETSCREENBRIGHTNESS,
                    context.getString(R.string.getscreenbrightness),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETUPHANDGESTURE,
                    context.getString(R.string.getuphandgesture),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETENCRYPTEDCODE,"获取授权数据",""),


                GetFuntionData(
                    CustomEvtType.GETWATCHDIALINFO,
                    context.getString(R.string.getwatchdialinfo),
                    ""
                ),
//                GetFuntionData(
//                    CustomEvtType.GETDEVICENAME,
//                    context.getString(R.string.getdevicename),
//                    ""
//                ),
                GetFuntionData(
                    CustomEvtType.GETDEVICELOGSTATE,
                    context.getString(R.string.getdevicelogstate),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETALLHEALTHSWITCHSTATE,
                    context.getString(R.string.getallhealthswitchstate),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETDATATRANCONFIG,"文件传输配置传输获取",""),
                GetFuntionData(
                    CustomEvtType.GETACTIVITYSWITCH,
                    context.getString(R.string.getactivityswitch),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETFIRMWAREBTVERSION,"获得固件三级版本和bt的3级版本",""),


                GetFuntionData(
                    CustomEvtType.GETSTEPGOAL,
                    context.getString(R.string.getstepgoal),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETLIBVERSION,"获取lib版本号",""),
//                 GetFuntionData(CustomEvtType.GETAPPID,"获取appid ios only",""),
                GetFuntionData(
                    CustomEvtType.GETWATCHFACELIST,
                    context.getString(R.string.getwatchfacelist),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETBTNOTICE,
                    context.getString(R.string.getbtnotice),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETSPORTTYPEV3,"v3 获取运动默认的类型",""),
                GetFuntionData(
                    CustomEvtType.GETALARMV3,
                    context.getString(R.string.getalarmv3),
                    ""
                ),
//                GetFuntionData(
//                    CustomEvtType.GETLANGUAGELIBRARYDATAV3,
//                    context.getString(R.string.getlanguagelibrarydatav3),
//                    ""
//                ),
                GetFuntionData(
                    CustomEvtType.GETWATCHLISTV3,
                    context.getString(R.string.getwatchlistv3),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETALEXAALARMV3,"v3 alexa获取v3的闹钟",""),
//                 GetFuntionData(CustomEvtType.GETACTIVITYEXCHANGEGPSDATA,"v3 多运动数据数据交换中获取一段时间的gps数据",""),
//                 GetFuntionData(CustomEvtType.GETHISTORICALMENSTRUATION,"经期的历史数据下发",""),


                GetFuntionData(
                    CustomEvtType.GETSUPPORTMAXSETITEMSNUM,
                    context.getString(R.string.getsupportmaxsetitemsnum),
                    ""
                ),

//                 GetFuntionData(CustomEvtType.GETMTULENGTHSPP,"获取固件spp mtu长度   新增  spp蓝牙专用",""),
                GetFuntionData(
                    CustomEvtType.GETUNREADAPPREMINDER,
                    context.getString(R.string.getunreadappreminder),
                    ""
                ),
                GetFuntionData(
                    CustomEvtType.GETCONTACTREVISETIME,
                    context.getString(R.string.getcontactrevisetime),
                    ""
                ),
//                 GetFuntionData(CustomEvtType.GETFLASHLOGSTART,"开始获取flash log",""),
//                 GetFuntionData(CustomEvtType.GETBATTERYLOG,"获取电池日志",""),

                GetFuntionData(
                    CustomEvtType.GETBTCONNECTPHONEMODEL,
                    context.getString(R.string.getBtConnectPhoneModel),
                    ""
                ),


                )
//            if (sdk.funcTable.getRealtimeData) {
//                mutableListOf.add(
//                    GetFuntionData(
//                        CustomEvtType.GETLIVEDATA,
//                        context.getString(R.string.getlivedata),
//                        ""
//                    )
//                )
//            }
            if (sdk.funcTable.getSupportUpdateGps) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETGPSINFO,
                        context.getString(R.string.getgpsinfo),
                        ""
                    )
                )
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETGPSSTATUS,
                        context.getString(R.string.getgpsstatus),
                        ""
                    )
                )
            }
            if (
                sdk.funcTable.getVersionInfo
            ) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETVERSIONINFO,
                        context.getString(R.string.getversioninfo),
                        ""
                    ),
                )
            }

            if (sdk.funcTable.getDownloadLanguage) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETDOWNLANGUAGE,
                        context.getString(R.string.getdownlanguage),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getFlashLog) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETERRORRECORD,
                        context.getString(R.string.geterrorrecord),
                        ""
                    )
                )
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETFLASHBININFO,
                        context.getString(R.string.getflashbininfo),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getDeviceUpdateState) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETUPDATESTATUS,
                        context.getString(R.string.getupdatestatus),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getWatchID) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETWATCHDIALID,
                        context.getString(R.string.getwatchdialid),
                        ""
                    )
                )
            }
            if (sdk.funcTable.setSetStressCalibration) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETSTRESSVAL,
                        context.getString(R.string.getstressval),
                        ""
                    )
                )
            }
            if (sdk.funcTable.setSupportV3Bp) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETBPALGVERSION,
                        context.getString(R.string.getbpalgversion),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getHeartRateModeV2) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETHEARTRATEMODE,
                        context.getString(R.string.getheartratemode),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getSupportGetBleBeepV3) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETBLEBEEPV3,
                        context.getString(R.string.getblebeepv3),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getSupportSedentaryTensileHabitInfo) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETHABITINFOV3,
                        context.getString(R.string.gethabitinfov3),
                        ""
                    ),
                )
            }
            if (sdk.funcTable.getDeletableMenuListV2) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETUNERASABLEMEUNLIST,
                        context.getString(R.string.getunerasablemeunlist),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETBLEMUSICINFO,
                        context.getString(R.string.getblemusicinfo),
                        ""
                    )
                )
            }
            if (sdk.funcTable.setV3GetSportSortField) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETDEFAULTSPORTTYPE,
                        context.getString(R.string.getDefaultSportType),
                        ""
                    )
                )
            }
            if (sdk.funcTable.setV3GetSportSortField) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETSPORTTYPEV3,
                        context.getString(R.string.getSportTypeV3),
                        ""
                    )
                )
            }
            if (sdk.funcTable.getSupportGetSnInfo) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETSNINFO,
                        context.getString(R.string.getsninfo),
                        ""
                    )
                )
            }

            if (sdk.funcTable.getBtAddrV2) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETBTNAME,
                        context.getString(R.string.getbtname),
                        ""
                    )

                )
            }

            if (sdk.funcTable.getMtu) {
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETMTUINFO,
                        context.getString(R.string.getmtuinfo),
                        ""
                    )

                )
            }
            if (sdk.funcTable.getSupportDeviceOperateAlgFile){
                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.GETALGFILE,
                        context.getString(R.string.getAlgFileInfo),
                        ""
                    )

                )

                mutableListOf.add(
                    GetFuntionData(
                        CustomEvtType.REQUESTALGFILE,
                        context.getString(R.string.requestAlgFile),
                        ""
                    )
                )
            }



            return mutableListOf
        }
    }
}

