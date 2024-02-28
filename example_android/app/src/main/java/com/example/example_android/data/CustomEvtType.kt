package com.example.example_android.data

// !!! Demo为了方便罗列相关接口，此处定义了对应的事件枚举，
// 实际场景无需使用（根据需求调用对应接口即可）
enum class CustomEvtType {
    /**  获取mac地址*/
    GETMAC,
    /**  获取设备信息*/
    GETDEVICEINFO,
    /**  获取功能表*/
    GETFUNCTABLE,
    /**  获取功能表 扩展*/
    GETFUNCTABLEEX,
    /**  获取sn*/
    GETSNINFO,
    /**  获取单位*/
    GETUNIT,
    /**  获取bt蓝牙名称*/
    GETBTNAME,
    /**  获得实时数据*/
    GETLIVEDATA,
    /**  获取通知中心的状态*/
    GETNOTICESTATUS,
    /**  获取心率传感器参数*/
    GETHRSENSORPARAM,
    /**  获取加速度传感器参数*/
    GETGSENSORPARAM,
    /**  获取同步时间轴来计算百分比*/
    GETACTIVITYCOUNT,
    /**  获取hid信息*/
    GETHIDINFO,
    /**  获取gps信息*/
    GETGPSINFO,
    /**  获取gps状态*/
    GETGPSSTATUS,
    /**  获取热启动参数*/
    GETHOTSTARTPARAM,
    /**  获取版本信息*/
    GETVERSIONINFO,
    /**  获取mtu信息*/
    GETMTUINFO,
    /**  获取勿扰模式状态*/
    GETNOTDISTURBSTATUS,
    /**  获取默认的运动类型*/
    GETDEFAULTSPORTTYPE,
    /**  获取下载语言支持*/
    GETDOWNLANGUAGE,
    /**  获取错误记录*/
    GETERRORRECORD,
    /**  获取设置的卡路里/距离/中高运动时长 主界面*/
    GETMAINSPORTGOAL,
    /**  获取走动提醒*/
    GETWALKREMIND,
    /**  获取电池信息*/
    GETBATTERYINFO,
    /**  获取字库信息*/
    GETFLASHBININFO,
    /**  获取设备支持的列表*/
    GETMENULIST,
    /**  获取realme项目的硬件信息*/
    GETREALMEDEVINFO,
    /**  获取屏幕亮度*/
    GETSCREENBRIGHTNESS,
    /**  获取抬腕数据*/
    GETUPHANDGESTURE,
    /**  获取授权数据*/
    GETENCRYPTEDCODE,
    /**  获取设备升级状态*/
    GETUPDATESTATUS,
    /**  获取表盘id*/
    GETWATCHDIALID,
    /**  获取屏幕信息*/
    GETWATCHDIALINFO,
    /**  获取手表名字*/
    GETDEVICENAME,
    /**  获取设备的日志状态*/
    GETDEVICELOGSTATE,
    /**  获取所有的健康监测开关*/
    GETALLHEALTHSWITCHSTATE,
    /**  文件传输配置传输获取*/
    GETDATATRANCONFIG,
    /**  运动模式自动识别开关获取*/
    GETACTIVITYSWITCH,
    /**  获得固件三级版本和bt的3级版本*/
    GETFIRMWAREBTVERSION,
    /**  获取压力值*/
    GETSTRESSVAL,
    /**  获取血压算法三级版本号信息事件号*/
    GETBPALGVERSION,
    /**  获取心率监测模式*/
    GETHEARTRATEMODE,
    /**  获取全天步数目标*/
    GETSTEPGOAL,
    /**  获取lib版本号*/
    GETLIBVERSION,
    /**  获取appid ios only*/
    GETAPPID,
    /**  获取表盘列表*/
    GETWATCHFACELIST,
    /**  查询bt配对开关、连接、a2dp连接、hfp连接状态(仅支持带bt蓝牙的设备)*/
    GETBTNOTICE,
    /**  v3 获取运动默认的类型*/
    GETSPORTTYPEV3,
    /**  v3 app获取ble的闹钟*/
    GETALARMV3,
    /**  v3 获取设备字库列表*/
    GETLANGUAGELIBRARYDATAV3,
    /**  v3 获取表盘列表*/
    GETWATCHLISTV3,
    /**  v3 alexa获取v3的闹钟*/
    GETALEXAALARMV3,
    /**  v3 多运动数据数据交换中获取一段时间的gps数据*/
    GETACTIVITYEXCHANGEGPSDATA,
    /**  获取固件的歌曲名和文件夹*/
    GETBLEMUSICINFO,
    /**  经期的历史数据下发*/
    GETHISTORICALMENSTRUATION,
    /**  获取应用包名*/
    GETPACKNAME,
    /**  v3获取固件本地提示音文件信息*/
    GETBLEBEEPV3,
    /**  v3获取固件本地提示音文件信息*/
    GETHABITINFOV3,
    /**  获取固件支持的详情最大设置数量*/
    GETSUPPORTMAXSETITEMSNUM,
    /**  获取固件不可删除的快捷应用列表*/
    GETUNERASABLEMEUNLIST,
    /**  获取固件spp mtu长度   新增  spp蓝牙专用*/
    GETMTULENGTHSPP,
    /**  获取红点提醒开关*/
    GETUNREADAPPREMINDER,
    /**  获取固件本地保存联系人文件修改时间*/
    GETCONTACTREVISETIME,
    /**  开始获取flash log*/
    GETFLASHLOGSTART,
    /**  获取电池日志*/
    GETBATTERYLOG,
    /**  app下发跑步计划(运动计划)*/
    SETSENDRUNPLAN,
    /**  设置表盘顺序*/
    SETWATCHDIALSORT,
    /**  v3血压校准控制*/
    SETBPCALCONTROLV3,
    /**  设置多个走动提醒的时间点*/
    SETWALKREMINDTIMES,
    /**  v3 下发v3世界时间*/
    SETWORLDTIMEV3,
    /**  v3设置gps热启动参数*/
    SETHOTSTARTPARAMV3,
    /**  v3 下发v3天气协议*/
    SETWEATHERV3,
    /**  v3 设置消息通知状态*/
    SETNOTICEMESSAGESTATE,
    /**  v3 设置运动城市名称*/
    SETLONGCITYNAMEV3,
    /**  v3 设置运动子项数据排列*/
    SETBASESPORTPARAMSORTV3,
    /**  v3 设置主界面控件排序*/
    SETMAINUISORTV3,
    /**  v3 设置日程提醒*/
    SETSCHEDULERREMINDERV3,
    /**  v3 新的100种运动排序*/
    SET100SPORTSORTV3,
    /**  v3 设置壁纸表盘列表*/
    SETWALLPAPERDIALREPLYV3,
    /**  v3 alexa设置v3的闹钟*/
    SETALEXAALARMV3,
    /**  v3 语音设置提醒*/
    SETVOICEALARMREMINDERV3,
    /**  v3 语音设置闹钟数据*/
    SETVOICEALARMV3,
    /**  v3 语音回复文本*/
    SETVOICEREPLYTXTV3,
    /**  v3 app设置回复快速信息*/
    SETFASTMSGV3,
    /**  设置运动类型排序 v3协议*/
    SETSPORTSORTV3,
    /**  v3 app设置ble的闹钟*/
    SETALARMV3,
    /**  设置表盘*/
    SETWATCHFACEDATA,
    /**  操作歌曲或者文件夹*/
    SETMUSICOPERATE,
    /**  快速短信回复*/
    SETFASTMSGUPDATE,
    /**  文件传输配置传输*/
    SETDATATRANCONFIGURE,
    /**  gt01_pro app新增需求 未读信息红点提示开关*/
    SETUNREADAPPREMINDER,
    /**  手机app通过这个命令开关，实现通知应用状态设置*/
    SETNOTIFICATIONSTATUS,
    /**  健身指导*/
    SETFITNESSGUIDANCE,
    /**  设置科学睡眠开关*/
    SETSCIENTIFICSLEEPSWITCH,
    /**  设置夜间体温开关*/
    SETTEMPERATURESWITCH,
    /**  环境音量的开关和阀值*/
    SETV3NOISE,
    /**  设置心率模式*/
    SETHEARTMODE,
    /**  智能心率模式设置*/
    SETHEARTRATEMODESMART,
    /**  血氧压力测试一次*/
    SETONCETESTSPO2PRESSURE,
    /**  设置吃药提醒*/
    SETTAKINGMEDICINEREMINDER,
    /**  设置设备名称*/
    SETDEVICESNAME,
    /**  删除日志*/
    SETCLEAROPERATION,
    /**  手机音量下发给ble*/
    SETBLEVOICE,
    /**  手机设置屏幕颜色 不加功能表*/
    SETBLESCREENCOLOR,
    /**  app控制手表的震动强度*/
    SETBLESHARKINGGRADE,
    /**  设置久坐*/
    SETLONGSIT,
    /**  设置防丢*/
    SETLOSTFIND,
    /**  设置时间*/
    SETTIME,
    /**  设置运动目标*/
    SETSPORTGOAL,
    /**  设置睡眠目标*/
    SETSLEEPGOAL,
    /**  设置用户信息*/
    SETUSERINFO,
    /**  设置单位*/
    SETUNIT,
    /**  设置左右手*/
    SETHAND,
    /**  设置app系统*/
    SETAPPOS,
    /**  设置通知中心*/
    SETNOTIFICATIONCENTER,
    /**  设置心率区间*/
    SETHEARTRATEINTERVAL,
    /**  设置心率模式*/
    SETHEARTRATEMODE,
    /**  恢复模式设置*/
    SETDEFAULTCONFIG,
    /**  绑定*/
    SETBINDSTART,
    /**  解绑*/
    SETBINDREMOVE,
    /**  授权码绑定*/
    SETAUTHCODE,
    /**  发送计算好的授权数据*/
    SETENCRYPTEDAUTH,
    /**  抬手亮屏*/
    SETUPHANDGESTURE,
    /**  设置屏幕亮度*/
    SETSCREENBRIGHTNESS,
    /**  设置寻找手机*/
    SETFINDPHONE,
    /**  勿扰模式*/
    SETNOTDISTURB,
    /**  音乐开关*/
    SETMUSICONOFF,
    /**  显示模式*/
    SETDISPLAYMODE,
    /**  设置心率传感器参数*/
    SETHRSENSORPARAM,
    /**  设置加速度传感器参数*/
    SETGSENSORPARAM,
    /**  设置传感器实时数据*/
    SETREALTIMESENSORDATA,
    /**  设置马达*/
    SETSTARTMOTOR,
    /**  设置一键呼叫*/
    SETONEKEYSOS,
    /**  设置天气开关*/
    SETWEATHERSWITCH,
    /**  设置运动模式选择*/
    SETSPORTMODESELECT,
    /**  设置睡眠时间段*/
    SETSLEEPPERIOD,
    /**  设置天气数据*/
    SETWEATHERDATA,
    /**  设置天气城市名称*/
    SETWEATHERCITYNAME,
    /**  设置当天0~8时实时天气+温度*/
    SETWEATHERREALTIMEONE,
    /**  设置当天9~16时实时天气+温度*/
    SETWEATHERREALTIMETWO,
    /**  设置当天17~24时实时天气+温度*/
    SETWEATHERREALTIMETHREE,
    /**  设置日出日落时间*/
    SETWEATHERSUNTIME,
    /**  固件测试*/
    SETDEVICESTESTTYPE,
    /**  设置iot按钮*/
    SETIOTBUTTONNAME,
    /**  IoT按钮命令*/
    SETIOTCOMMAND,
    /**  设置表盘*/
    SETWATCHDIAL,
    /**  设置快捷方式*/
    SETSHORTCUT,
    /**  血压校准*/
    SETBPCALIBRATION,
    /**  血压测量*/
    SETBPMEASUREMENT,
    /**  压力校准*/
    SETSTRESSCALIBRATION,
    /**  设置gps信息*/
    SETGPSCONFIG,
    /**  ```*/
    SETGPSCONTROL,
    /**  控制连接参数*/
    SETCONNPARAM,
    /**  设置热启动参数*/
    SETHOTSTARTPARAM,
    /**  设置经期*/
    SETMENSTRUATION,
    /**  设置经期提醒*/
    SETMENSTRUATIONREMIND,
    /**  卡路里和距离目标*/
    SETCALORIEDISTANCEGOAL,
    /**  设置血氧开关*/
    SETSPO2SWITCH,
    /**  设置压力开关*/
    SETSTRESSSWITCH,
    /**  结束来电*/
    SETNOTICESTOPCALL,
    /**  未接来电*/
    SETNOTICEMISSEDCALL,
    /**  来电接通完成后下发通话时间给固件*/
    SETNOTICECALLTIME,
    /**  设置运动模式排序*/
    SETSPORTMODESORT,
    /**  设置走动提醒*/
    SETWALKREMIND,
    /**  呼吸训练*/
    SETBREATHETRAIN,
    /**  运动开关设置*/
    SETACTIVITYSWITCH,
    /**  设置喝水提醒*/
    SETDRINKWATERREMIND,
    /**  手环请求版本检查*/
    SETREQUESTCHECKUPDATE,
    /**  手环请求ota*/
    SETREQUESTSTARTOTA,
    /**  停止寻找手机*/
    SETOVERFINDPHONE,
    /**  设置洗手提醒*/
    SETHANDWASHINGREMINDER,
    /**  设置呼吸率开关*/
    SETRRESPIRATETURN,
    /**  设置身体电量开关*/
    SETBODYPOWERTURN,
    /**  v3 alexa设置天气*/
    SETALEXAWEATHER,
    /**  V3动态消息通知*/
    SETNOTICEAPPNAME,
    /**  app传输运动图标信息及状态通知固件*/
    SETNOTICEICONINFORMATION,
    /**  app通知固件开启bt广播*/
    SETNOTICEOPENBROADCASTN,
    /**  app被禁用功能权限导致某些功能无法启用，同时需要告知固件改功能已被禁用*/
    SETNOTICEDISABLEFUNC,
    /**  同步常用联系人*/
    SETSYNCCONTACT,
    /**  app 发起运动*/
    EXCHANGEAPPSTART,
    /**  app 发起结束*/
    EXCHANGEAPPEND,
    /**  app 发起暂停*/
    EXCHANGEAPPPAUSE,
    /**  app 发起恢复*/
    EXCHANGEAPPRESTORE,
    /**  app 运动计划操作*/
    EXCHANGEAPPPLAN,
    /**  app 发起数据v2交换过程*/
    EXCHANGEAPPV2ING,
    /**  app 发起数据v3交换过程*/
    EXCHANGEAPPV3ING,
    /**  app 获取v3心率数据*/
    EXCHANGEAPPGETV3HRDATA,
    /**  app 获取v3运动数据*/
    EXCHANGEAPPGETACTIVITYDATA,
    /**  ble发起运动 操作运动计划 app回复*/
    EXCHANGEAPPBLEPLAN,
    /**  蓝牙设备获取手机登录状态*/
    ALEXAVOICEBLEGETPHONELOGINSTATE,
    /**  简单文件操作*/
    FUNCSIMPLEFILEOPT,
    /**  设置菜单列表*/
    SETMENULIST,
    /**  控制拍照*/
    SETTAKEPICTURE,
    /**  连接成功*/
    CONNECTED,
    /**  断开连接*/
    DISCONNECT,
    /**  进入升级模式*/
    OTASTART,
    /**  ota 授权*/
    OTAAUTH,
    /**  直接进入升级模式(忽略电量)*/
    OTADIRECTSTART,
    /**  进入关机模式*/
    SYSTEMOFF,
    /**  重启设备*/
    REBOOT,
    /**  控制断线*/
    CONTROLDISCONNECT,
    /**  清除绑定信息*/
    CLEANBINDINFO,
    /**  关闭设备*/
    SHUTDOWN,
    /**  恢复出厂设置*/
    FACTORYRESET,
    /**  清除手环缓存*/
    CLEARCACHE,
    /**  设置闹钟*/
    SETALARM,
    /**  设置闹钟*/
    SETADDALARM,
    /**  开始 (app -> ble)*/
    MUSICSTART,
    /**  停止 (app -> ble)*/
    MUSICSTOP,
    /**  开始拍照 (app -> ble)*/
    PHOTOSTART,
    /**  结束拍照 (app -> ble)*/
    PHOTOSTOP,
    /**  寻找设备 (app -> ble)*/
    FINDDEVICESTART,
    /**  结束寻找设备 (app -> ble)*/
    FINDDEVICESTOP,
    /**  打开 ancs*/
    OPENANCS,
    /**  关闭 ancs*/
    CLOSEANCS,
    /**  APP设置alexa通知状态*/
    SETALEXAINDECATOR,
    /**  APP设置识别后的状态*/
    SETRECOGNITIONSTATE,
    /**  APP下发alexa控制命令*/
    SETVOICECONTROLUI,
    /**  APP下发alexa控制倒数计时*/
    SETCONTROLLCOUNTDOWN,
    /**  APP下发alexa多运动界面*/
    SETCONTROLLSPORTS,
    /**  APP下发alexa跳转ui界面*/
    SETCONTROLLUIJUMP,
    /**  APP下发alexa音乐控制界面*/
    SETCONTROLLALEXAMUSIC,
    /**  APP设置alexa开关命令*/
    SETCONTROLLALEXAONOFF,
    /**  APP开始定时器功能*/
    SETCONTROLLALEXASTOPWATCH,
    /**  语音控制跳转闹钟界面*/
    SETCONTROLLALEXAALARM,
    /**  控制音乐 v3协议*/
    MUSICCONTROL,
    /**  通知消息提醒 v3协议*/
    NOTICEMESSAGEV3,
    /**  内部测试*/
    INNERTESTCMD1,
    /**  设置来电快捷回复开关*/
    SETCALLQUICKREPLYONOFF,
    /**  设置手机语音助手开关*/
    SETVOICEASSISTANTONOFF,
    /** 获取BT连接手机型号*/
    GETBTCONNECTPHONEMODEL;
}