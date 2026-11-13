package com.example.example_android.data

// !!! Demo为了方便罗列相关接口，此处定义了对应的事件枚举，
// !!! Demo defines the corresponding event enum here just to list the related APIs conveniently;
// 实际场景无需使用（根据需求调用对应接口即可）
// it is not needed in real scenarios (just call the corresponding API as required)
enum class CustomEvtType {
    /**  获取mac地址*/
    /**  Get MAC address*/
    GETMAC,
    /**  获取设备信息*/
    /**  Get device info*/
    GETDEVICEINFO,
    /**  获取功能表*/
    /**  Get function table*/
    GETFUNCTABLE,
    /**  获取功能表 扩展*/
    /**  Get function table (extended)*/
    GETFUNCTABLEEX,
    /**  获取sn*/
    /**  Get sn*/
    GETSNINFO,
    /**  获取单位*/
    /**  Get unit*/
    GETUNIT,
    /**  获取bt蓝牙名称*/
    /**  Get BT Bluetooth name*/
    GETBTNAME,
    /**  获得实时数据*/
    /**  Get real-time data*/
    GETLIVEDATA,
    /**  获取通知中心的状态*/
    /**  Get notification center status*/
    GETNOTICESTATUS,
    /**  获取心率传感器参数*/
    /**  Get heart rate sensor parameters*/
    GETHRSENSORPARAM,
    /**  获取加速度传感器参数*/
    /**  Get accelerometer sensor parameters*/
    GETGSENSORPARAM,
    /**  获取同步时间轴来计算百分比*/
    /**  Get sync timeline to calculate percentage*/
    GETACTIVITYCOUNT,
    /**  获取hid信息*/
    /**  Get HID info*/
    GETHIDINFO,
    /**  获取gps信息*/
    /**  Get GPS info*/
    GETGPSINFO,
    /**  获取gps状态*/
    /**  Get GPS status*/
    GETGPSSTATUS,
    /**  获取热启动参数*/
    /**  Get hot start parameters*/
    GETHOTSTARTPARAM,
    /**  获取版本信息*/
    /**  Get version info*/
    GETVERSIONINFO,
    /**  获取mtu信息*/
    /**  Get MTU info*/
    GETMTUINFO,
    /**  获取勿扰模式状态*/
    /**  Get Do Not Disturb mode status*/
    GETNOTDISTURBSTATUS,
    /**  获取默认的运动类型*/
    /**  Get default sport types*/
    GETDEFAULTSPORTTYPE,
    /**  获取下载语言支持*/
    /**  Get supported download languages*/
    GETDOWNLANGUAGE,
    /**  获取错误记录*/
    /**  Get error records*/
    GETERRORRECORD,
    /**  获取设置的卡路里/距离/中高运动时长 主界面*/
    /**  Get the set calorie/distance/medium-high intensity sport duration goals (main screen)*/
    GETMAINSPORTGOAL,
    /**  获取走动提醒*/
    /**  Get walk reminder*/
    GETWALKREMIND,
    /**  获取电池信息*/
    /**  Get battery info*/
    GETBATTERYINFO,
    /**  获取字库信息*/
    /**  Get font library info*/
    GETFLASHBININFO,
    /**  获取设备支持的列表*/
    /**  Get the list supported by the device*/
    GETMENULIST,
    /**  获取realme项目的硬件信息*/
    /**  Get hardware info for the realme project*/
    GETREALMEDEVINFO,
    /**  获取屏幕亮度*/
    /**  Get screen brightness*/
    GETSCREENBRIGHTNESS,
    /**  获取抬腕数据*/
    /**  Get wrist lift data*/
    GETUPHANDGESTURE,
    /**  获取授权数据*/
    /**  Get authorization data*/
    GETENCRYPTEDCODE,
    /**  获取设备升级状态*/
    /**  Get device upgrade status*/
    GETUPDATESTATUS,
    /**  获取表盘id*/
    /**  Get watch face id*/
    GETWATCHDIALID,
    /**  获取屏幕信息*/
    /**  Get screen info*/
    GETWATCHDIALINFO,
    /**  获取手表名字*/
    /**  Get watch name*/
    GETDEVICENAME,
    /**  获取设备的日志状态*/
    /**  Get device log status*/
    GETDEVICELOGSTATE,
    /**  获取所有的健康监测开关*/
    /**  Get all health monitoring switches*/
    GETALLHEALTHSWITCHSTATE,
    /**  文件传输配置传输获取*/
    /**  Get file transfer config*/
    GETDATATRANCONFIG,
    /**  运动模式自动识别开关获取*/
    /**  Get sport mode auto-recognition switch*/
    GETACTIVITYSWITCH,
    /**  获得固件三级版本和bt的3级版本*/
    /**  Get firmware 3-level version and BT 3-level version*/
    GETFIRMWAREBTVERSION,
    /**  获取压力值*/
    /**  Get stress value*/
    GETSTRESSVAL,
    /**  获取血压算法三级版本号信息事件号*/
    /**  Event number for getting blood pressure algorithm 3-level version info*/
    GETBPALGVERSION,
    /**  获取心率监测模式*/
    /**  Get heart rate monitoring mode*/
    GETHEARTRATEMODE,
    /**  获取全天步数目标*/
    /**  Get all-day step goal*/
    GETSTEPGOAL,
    /**  获取lib版本号*/
    /**  Get lib version number*/
    GETLIBVERSION,
    /**  获取appid ios only*/
    /**  Get appid ios only*/
    GETAPPID,
    /**  获取表盘列表*/
    /**  Get watch face list*/
    GETWATCHFACELIST,
    /**  查询bt配对开关、连接、a2dp连接、hfp连接状态(仅支持带bt蓝牙的设备)*/
    /**  Query BT pairing switch, connection, a2dp connection, hfp connection status (only devices with BT)*/
    GETBTNOTICE,
    /**  v3 获取运动默认的类型*/
    /**  v3 Get default sport types*/
    GETSPORTTYPEV3,
    /**  v3 app获取ble的闹钟*/
    /**  v3 app gets ble alarms*/
    GETALARMV3,
    /**  v3 获取设备字库列表*/
    /**  v3 Get device font library list*/
    GETLANGUAGELIBRARYDATAV3,
    /**  v3 获取表盘列表*/
    /**  v3 Get watch face list*/
    GETWATCHLISTV3,
    /**  v3 alexa获取v3的闹钟*/
    /**  v3 alexa gets v3 alarms*/
    GETALEXAALARMV3,
    /**  v3 多运动数据数据交换中获取一段时间的gps数据*/
    /**  v3 Get GPS data for a time period during multi-sport data exchange*/
    GETACTIVITYEXCHANGEGPSDATA,
    /**  获取固件的歌曲名和文件夹*/
    /**  Get song names and folders from the firmware*/
    GETBLEMUSICINFO,
    /**  经期的历史数据下发*/
    /**  Send menstrual cycle history data*/
    GETHISTORICALMENSTRUATION,
    /**  获取应用包名*/
    /**  Get app package name*/
    GETPACKNAME,
    /**  v3获取固件本地提示音文件信息*/
    /**  v3 Get firmware local prompt sound file info*/
    GETBLEBEEPV3,
    /**  v3获取固件本地提示音文件信息*/
    /**  v3 Get firmware local prompt sound file info*/
    GETHABITINFOV3,
    /**  获取固件支持的详情最大设置数量*/
    /**  Get the max number of detail items the firmware supports*/
    GETSUPPORTMAXSETITEMSNUM,
    /**  获取固件不可删除的快捷应用列表*/
    /**  Get the list of quick apps that cannot be deleted from the firmware*/
    GETUNERASABLEMEUNLIST,
    /**  获取固件spp mtu长度   新增  spp蓝牙专用*/
    /**  Get firmware SPP MTU length (new, SPP Bluetooth only)*/
    GETMTULENGTHSPP,
    /**  获取红点提醒开关*/
    /**  Get unread red dot reminder switch*/
    GETUNREADAPPREMINDER,
    /**  获取固件本地保存联系人文件修改时间*/
    /**  Get the modification time of the contacts file saved on the firmware*/
    GETCONTACTREVISETIME,
    /**  开始获取flash log*/
    /**  Start getting flash log*/
    GETFLASHLOGSTART,
    /**  获取电池日志*/
    /**  Get battery log*/
    GETBATTERYLOG,
    /**  app下发跑步计划(运动计划)*/
    /**  app sends running plan (sport plan)*/
    SETSENDRUNPLAN,
    /**  设置表盘顺序*/
    /**  Set watch face order*/
    SETWATCHDIALSORT,
    /**  v3血压校准控制*/
    /**  v3 Blood pressure calibration control*/
    SETBPCALCONTROLV3,
    /**  设置多个走动提醒的时间点*/
    /**  Set multiple walk reminder times*/
    SETWALKREMINDTIMES,
    /**  v3 下发v3世界时间*/
    /**  v3 Send v3 world time*/
    SETWORLDTIMEV3,
    /**  v3设置gps热启动参数*/
    /**  v3 Set GPS hot start parameters*/
    SETHOTSTARTPARAMV3,
    /**  v3 下发v3天气协议*/
    /**  v3 Send v3 weather protocol*/
    SETWEATHERV3,
    /**  v3 设置消息通知状态*/
    /**  v3 Set message notification status*/
    SETNOTICEMESSAGESTATE,
    /**  v3 设置运动城市名称*/
    /**  v3 Set sport city name*/
    SETLONGCITYNAMEV3,
    /**  v3 设置运动子项数据排列*/
    /**  v3 Set sport sub-item data order*/
    SETBASESPORTPARAMSORTV3,
    /**  v3 设置主界面控件排序*/
    /**  v3 Set main screen widget order*/
    SETMAINUISORTV3,
    /**  v3 设置日程提醒*/
    /**  v3 Set schedule reminder*/
    SETSCHEDULERREMINDERV3,
    /**  v3 新的100种运动排序*/
    /**  v3 New order for the 100 sport types*/
    SET100SPORTSORTV3,
    /**  v3 设置壁纸表盘列表*/
    /**  v3 Set wallpaper watch face list*/
    SETWALLPAPERDIALREPLYV3,
    /**  v3 alexa设置v3的闹钟*/
    /**  v3 alexa sets v3 alarms*/
    SETALEXAALARMV3,
    /**  v3 语音设置提醒*/
    /**  v3 Set reminder by voice*/
    SETVOICEALARMREMINDERV3,
    /**  v3 语音设置闹钟数据*/
    /**  v3 Set alarm data by voice*/
    SETVOICEALARMV3,
    /**  v3 语音回复文本*/
    /**  v3 Voice reply text*/
    SETVOICEREPLYTXTV3,
    /**  v3 app设置回复快速信息*/
    /**  v3 app sets quick reply messages*/
    SETFASTMSGV3,
    /**  设置运动类型排序 v3协议*/
    /**  Set sport type order (v3 protocol)*/
    SETSPORTSORTV3,
    /**  v3 app设置ble的闹钟*/
    /**  v3 app sets ble alarms*/
    SETALARMV3,
    /**  设置表盘*/
    /**  Set watch face*/
    SETWATCHFACEDATA,
    /**  操作歌曲或者文件夹*/
    /**  Operate on songs or folders*/
    SETMUSICOPERATE,
    /**  快速短信回复*/
    /**  Quick SMS reply*/
    SETFASTMSGUPDATE,
    /**  文件传输配置传输*/
    /**  Send file transfer config*/
    SETDATATRANCONFIGURE,
    /**  gt01_pro app新增需求 未读信息红点提示开关*/
    /**  gt01_pro app new requirement: unread message red dot switch*/
    SETUNREADAPPREMINDER,
    /**  手机app通过这个命令开关，实现通知应用状态设置*/
    /**  The phone app uses this command switch to set the notification app status*/
    SETNOTIFICATIONSTATUS,
    /**  健身指导*/
    /**  Fitness guidance*/
    SETFITNESSGUIDANCE,
    /**  设置科学睡眠开关*/
    /**  Set scientific sleep switch*/
    SETSCIENTIFICSLEEPSWITCH,
    /**  设置夜间体温开关*/
    /**  Set night body temperature switch*/
    SETTEMPERATURESWITCH,
    /**  环境音量的开关和阀值*/
    /**  Ambient volume switch and threshold*/
    SETV3NOISE,
    /**  设置心率模式*/
    /**  Set heart rate mode*/
    SETHEARTMODE,
    /**  智能心率模式设置*/
    /**  Set smart heart rate mode*/
    SETHEARTRATEMODESMART,
    /**  血氧压力测试一次*/
    /**  Measure SpO2/stress once*/
    SETONCETESTSPO2PRESSURE,
    /**  设置吃药提醒*/
    /**  Set medication reminder*/
    SETTAKINGMEDICINEREMINDER,
    /**  设置设备名称*/
    /**  Set device name*/
    SETDEVICESNAME,
    /**  删除日志*/
    /**  Delete log*/
    SETCLEAROPERATION,
    /**  手机音量下发给ble*/
    /**  Send phone volume to ble*/
    SETBLEVOICE,
    /**  手机设置屏幕颜色 不加功能表*/
    /**  Phone sets screen color (not in function table)*/
    SETBLESCREENCOLOR,
    /**  app控制手表的震动强度*/
    /**  app controls the watch vibration intensity*/
    SETBLESHARKINGGRADE,
    /**  设置久坐*/
    /**  Set sedentary reminder*/
    SETLONGSIT,
    /**  设置防丢*/
    /**  Set anti-lost*/
    SETLOSTFIND,
    /**  设置时间*/
    /**  Set time*/
    SETTIME,
    /**  设置运动目标*/
    /**  Set sport goal*/
    SETSPORTGOAL,
    /**  设置睡眠目标*/
    /**  Set sleep goal*/
    SETSLEEPGOAL,
    /**  设置用户信息*/
    /**  Set user info*/
    SETUSERINFO,
    /**  设置单位*/
    /**  Set unit*/
    SETUNIT,
    /**  设置左右手*/
    /**  Set left/right hand*/
    SETHAND,
    /**  设置app系统*/
    /**  Set app system*/
    SETAPPOS,
    /**  设置通知中心*/
    /**  Set notification center*/
    SETNOTIFICATIONCENTER,
    /**  设置心率区间*/
    /**  Set heart rate zones*/
    SETHEARTRATEINTERVAL,
    /**  设置心率模式*/
    /**  Set heart rate mode*/
    SETHEARTRATEMODE,
    /**  恢复模式设置*/
    /**  Restore default config*/
    SETDEFAULTCONFIG,
    /**  绑定*/
    /**  Bind*/
    SETBINDSTART,
    /**  解绑*/
    /**  Unbind*/
    SETBINDREMOVE,
    /**  授权码绑定*/
    /**  Bind with auth code*/
    SETAUTHCODE,
    /**  发送计算好的授权数据*/
    /**  Send computed authorization data*/
    SETENCRYPTEDAUTH,
    /**  抬手亮屏*/
    /**  Wrist lift to wake screen*/
    SETUPHANDGESTURE,
    /**  设置屏幕亮度*/
    /**  Set screen brightness*/
    SETSCREENBRIGHTNESS,
    /**  设置寻找手机*/
    /**  Set find phone*/
    SETFINDPHONE,
    /**  勿扰模式*/
    /**  Do Not Disturb mode*/
    SETNOTDISTURB,
    /**  音乐开关*/
    /**  Music switch*/
    SETMUSICONOFF,
    /**  显示模式*/
    /**  Display mode*/
    SETDISPLAYMODE,
    /**  设置心率传感器参数*/
    /**  Set heart rate sensor parameters*/
    SETHRSENSORPARAM,
    /**  设置加速度传感器参数*/
    /**  Set accelerometer sensor parameters*/
    SETGSENSORPARAM,
    /**  设置传感器实时数据*/
    /**  Set sensor real-time data*/
    SETREALTIMESENSORDATA,
    /**  设置马达*/
    /**  Set motor*/
    SETSTARTMOTOR,
    /**  设置一键呼叫*/
    /**  Set one-key SOS call*/
    SETONEKEYSOS,
    /**  设置天气开关*/
    /**  Set weather switch*/
    SETWEATHERSWITCH,
    /**  设置运动模式选择*/
    /**  Set sport mode selection*/
    SETSPORTMODESELECT,
    /**  设置睡眠时间段*/
    /**  Set sleep period*/
    SETSLEEPPERIOD,
    /**  设置天气数据*/
    /**  Set weather data*/
    SETWEATHERDATA,
    /**  设置天气城市名称*/
    /**  Set weather city name*/
    SETWEATHERCITYNAME,
    /**  设置当天0~8时实时天气+温度*/
    /**  Set today's 0~8h real-time weather + temperature*/
    SETWEATHERREALTIMEONE,
    /**  设置当天9~16时实时天气+温度*/
    /**  Set today's 9~16h real-time weather + temperature*/
    SETWEATHERREALTIMETWO,
    /**  设置当天17~24时实时天气+温度*/
    /**  Set today's 17~24h real-time weather + temperature*/
    SETWEATHERREALTIMETHREE,
    /**  设置日出日落时间*/
    /**  Set sunrise/sunset time*/
    SETWEATHERSUNTIME,
    /**  固件测试*/
    /**  Firmware test*/
    SETDEVICESTESTTYPE,
    /**  设置iot按钮*/
    /**  Set IoT button*/
    SETIOTBUTTONNAME,
    /**  IoT按钮命令*/
    /**  IoT button command*/
    SETIOTCOMMAND,
    /**  设置表盘*/
    /**  Set watch face*/
    SETWATCHDIAL,
    /**  设置快捷方式*/
    /**  Set shortcuts*/
    SETSHORTCUT,
    /**  血压校准*/
    /**  Blood pressure calibration*/
    SETBPCALIBRATION,
    /**  血压测量*/
    /**  Blood pressure measurement*/
    SETBPMEASUREMENT,
    /**  压力校准*/
    /**  Stress calibration*/
    SETSTRESSCALIBRATION,
    /**  设置gps信息*/
    /**  Set GPS info*/
    SETGPSCONFIG,
    /**  ```*/
    SETGPSCONTROL,
    /**  控制连接参数*/
    /**  Control connection parameters*/
    SETCONNPARAM,
    /**  设置热启动参数*/
    /**  Set hot start parameters*/
    SETHOTSTARTPARAM,
    /**  设置经期*/
    /**  Set menstrual cycle*/
    SETMENSTRUATION,
    /**  设置经期提醒*/
    /**  Set menstrual cycle reminder*/
    SETMENSTRUATIONREMIND,
    /**  卡路里和距离目标*/
    /**  Calorie and distance goals*/
    SETCALORIEDISTANCEGOAL,
    /**  设置血氧开关*/
    /**  Set SpO2 switch*/
    SETSPO2SWITCH,
    /**  设置压力开关*/
    /**  Set stress switch*/
    SETSTRESSSWITCH,
    /**  结束来电*/
    /**  End incoming call*/
    SETNOTICESTOPCALL,
    /**  未接来电*/
    /**  Missed call*/
    SETNOTICEMISSEDCALL,
    /**  通话中挂断*/
    /**  Hang up during call*/
    SETNOTICEHANGUPINCALL,
    /**  来电接通完成后下发通话时间给固件*/
    /**  Send call duration to the firmware after the incoming call is answered*/
    SETNOTICECALLTIME,
    /**  设置运动模式排序*/
    /**  Set sport mode order*/
    SETSPORTMODESORT,
    /**  设置走动提醒*/
    /**  Set walk reminder*/
    SETWALKREMIND,
    /**  呼吸训练*/
    /**  Breathing training*/
    SETBREATHETRAIN,
    /**  运动开关设置*/
    /**  Set sport switch*/
    SETACTIVITYSWITCH,
    /**  设置喝水提醒*/
    /**  Set drink-water reminder*/
    SETDRINKWATERREMIND,
    /**  手环请求版本检查*/
    /**  Band requests version check*/
    SETREQUESTCHECKUPDATE,
    /**  手环请求ota*/
    /**  Band requests ota*/
    SETREQUESTSTARTOTA,
    /**  停止寻找手机*/
    /**  Stop find phone*/
    SETOVERFINDPHONE,
    /**  设置洗手提醒*/
    /**  Set hand-washing reminder*/
    SETHANDWASHINGREMINDER,
    /**  设置呼吸率开关*/
    /**  Set respiratory rate switch*/
    SETRRESPIRATETURN,
    /**  设置身体电量开关*/
    /**  Set body battery switch*/
    SETBODYPOWERTURN,
    /**  v3 alexa设置天气*/
    /**  v3 alexa sets weather*/
    SETALEXAWEATHER,
    /**  V3动态消息通知*/
    /**  V3 dynamic message notification*/
    SETNOTICEAPPNAME,
    /**  app传输运动图标信息及状态通知固件*/
    /**  app transfers sport icon info and status to notify the firmware*/
    SETNOTICEICONINFORMATION,
    /**  app通知固件开启bt广播*/
    /**  app notifies the firmware to enable BT broadcast*/
    SETNOTICEOPENBROADCASTN,
    /**  app被禁用功能权限导致某些功能无法启用，同时需要告知固件改功能已被禁用*/
    /**  app permissions were disabled so some functions cannot be enabled; the firmware must also be told that the function is disabled*/
    SETNOTICEDISABLEFUNC,
    /**  同步常用联系人*/
    /**  Sync frequently used contacts*/
    SETSYNCCONTACT,
    /**  app 发起运动*/
    /**  app starts sport*/
    EXCHANGEAPPSTART,
    /**  app 发起结束*/
    /**  app ends sport*/
    EXCHANGEAPPEND,
    /**  app 发起暂停*/
    /**  app pauses sport*/
    EXCHANGEAPPPAUSE,
    /**  app 发起恢复*/
    /**  app resumes sport*/
    EXCHANGEAPPRESTORE,
    /**  app 运动计划操作*/
    /**  app sport plan operation*/
    EXCHANGEAPPPLAN,
    /**  app 发起数据v2交换过程*/
    /**  app initiates v2 data exchange process*/
    EXCHANGEAPPV2ING,
    /**  app 发起数据v3交换过程*/
    /**  app initiates v3 data exchange process*/
    EXCHANGEAPPV3ING,
    /**  app 获取v3心率数据*/
    /**  app gets v3 heart rate data*/
    EXCHANGEAPPGETV3HRDATA,
    /**  app 获取v3运动数据*/
    /**  app gets v3 sport data*/
    EXCHANGEAPPGETACTIVITYDATA,
    /**  ble发起运动 操作运动计划 app回复*/
    /**  ble starts sport or operates the sport plan, app replies*/
    EXCHANGEAPPBLEPLAN,
    /**  蓝牙设备获取手机登录状态*/
    /**  Bluetooth device gets phone login status*/
    ALEXAVOICEBLEGETPHONELOGINSTATE,
    /**  简单文件操作*/
    /**  Simple file operation*/
    FUNCSIMPLEFILEOPT,
    /**  设置菜单列表*/
    /**  Set menu list*/
    SETMENULIST,
    /**  控制拍照*/
    /**  Control taking photos*/
    SETTAKEPICTURE,
    /**  连接成功*/
    /**  Connected*/
    CONNECTED,
    /**  断开连接*/
    /**  Disconnect*/
    DISCONNECT,
    /**  进入升级模式*/
    /**  Enter upgrade mode*/
    OTASTART,
    /**  ota 授权*/
    /**  ota authorization*/
    OTAAUTH,
    /**  直接进入升级模式(忽略电量)*/
    /**  Enter upgrade mode directly (ignore battery level)*/
    OTADIRECTSTART,
    /**  进入关机模式*/
    /**  Enter shutdown mode*/
    SYSTEMOFF,
    /**  重启设备*/
    /**  Reboot device*/
    REBOOT,
    /**  控制断线*/
    /**  Control disconnect*/
    CONTROLDISCONNECT,
    /**  清除绑定信息*/
    /**  Clear binding info*/
    CLEANBINDINFO,
    /**  关闭设备*/
    /**  Shut down device*/
    SHUTDOWN,
    /**  恢复出厂设置*/
    /**  Factory reset*/
    FACTORYRESET,
    /**  清除手环缓存*/
    /**  Clear band cache*/
    CLEARCACHE,
    /**  设置闹钟*/
    /**  Set alarm*/
    SETALARM,
    /**  设置闹钟*/
    /**  Set alarm*/
    SETADDALARM,
    /**  开始 (app -> ble)*/
    /**  Start (app -> ble)*/
    MUSICSTART,
    /**  停止 (app -> ble)*/
    /**  Stop (app -> ble)*/
    MUSICSTOP,
    /**  开始拍照 (app -> ble)*/
    /**  Start taking photos (app -> ble)*/
    PHOTOSTART,
    /**  结束拍照 (app -> ble)*/
    /**  Stop taking photos (app -> ble)*/
    PHOTOSTOP,
    /**  寻找设备 (app -> ble)*/
    /**  Find device (app -> ble)*/
    FINDDEVICESTART,
    /**  结束寻找设备 (app -> ble)*/
    /**  Stop finding device (app -> ble)*/
    FINDDEVICESTOP,
    /**  打开 ancs*/
    /**  Enable ancs*/
    OPENANCS,
    /**  关闭 ancs*/
    /**  Disable ancs*/
    CLOSEANCS,
    /**  APP设置alexa通知状态*/
    /**  APP sets alexa notification status*/
    SETALEXAINDECATOR,
    /**  APP设置识别后的状态*/
    /**  APP sets the post-recognition status*/
    SETRECOGNITIONSTATE,
    /**  APP下发alexa控制命令*/
    /**  APP sends alexa control command*/
    SETVOICECONTROLUI,
    /**  APP下发alexa控制倒数计时*/
    /**  APP sends alexa countdown control*/
    SETCONTROLLCOUNTDOWN,
    /**  APP下发alexa多运动界面*/
    /**  APP sends alexa multi-sport screen*/
    SETCONTROLLSPORTS,
    /**  APP下发alexa跳转ui界面*/
    /**  APP sends alexa command to jump to a ui screen*/
    SETCONTROLLUIJUMP,
    /**  APP下发alexa音乐控制界面*/
    /**  APP sends alexa music control screen*/
    SETCONTROLLALEXAMUSIC,
    /**  APP设置alexa开关命令*/
    /**  APP sets alexa on/off command*/
    SETCONTROLLALEXAONOFF,
    /**  APP开始定时器功能*/
    /**  APP starts the timer function*/
    SETCONTROLLALEXASTOPWATCH,
    /**  语音控制跳转闹钟界面*/
    /**  Voice control jumps to the alarm screen*/
    SETCONTROLLALEXAALARM,
    /**  控制音乐 v3协议*/
    /**  Control music (v3 protocol)*/
    MUSICCONTROL,
    /**  通知消息提醒 v3协议*/
    /**  Notification message reminder (v3 protocol)*/
    NOTICEMESSAGEV3,
    /**  内部测试*/
    /**  Internal test*/
    INNERTESTCMD1,
    /**  设置来电快捷回复开关*/
    /**  Set incoming call quick reply switch*/
    SETCALLQUICKREPLYONOFF,
    /**  设置手机语音助手开关*/
    /**  Set phone voice assistant switch*/
    SETVOICEASSISTANTONOFF,
    /** 获取BT连接手机型号*/
    /** Get BT-connected phone model*/
    GETBTCONNECTPHONEMODEL,
    /** 操作小程序信息*/
    /** Operate applet info*/
    SETAPPLETCONTROL,
    /**获取固件算法文件信息（ACC/GPS）*/
    /**Get firmware algorithm file info (ACC/GPS)*/
    GETALGFILE,
    /**请求固件算法文件信息（ACC/GPS））*/
    /**Request firmware algorithm file info (ACC/GPS)*/
    REQUESTALGFILE,
        /**  运动中设置提示音开关*/
        /**  Set prompt sound switch during sport*/
    SETDURINGEXERCISE,
    /**  获取左右手佩戴设置*/
    /**  Get left/right hand wearing setting*/
    GETLEFTRIGHTWEARSETTINGS,
    /**  获取运动中设置提示音开关*/
    /**  Get prompt sound switch during sport*/
    GETSETTINGSDURINGEXERCISE,
    /**  运动中提醒设置*/
    /**  Set reminders during sport*/
    SETSPORTINGREMINDSETTING,
    /**  简单心率区间设置*/
    /**  Set simple heart rate zones*/
    SETSIMPLEHEARTRATEZONE,
    /**  获取用户信息*/
    /**  Get user info*/
    GETUSERINFO,
    /**  获取简单心率区间设置*/
    /**  Get simple heart rate zone settings*/
    GETSIMPLEHEARTRATEZONE,
    GETBIKELOCKLIST,
    SETHISTORICALMENSTRUATION,
    GETFINDPHONESWITCH,
    /**  获取 Find My 设备名称（V3 15.113）*/
    /**  Get Find My device name (V3 15.113)*/
    GETFINDMYDEVICENAME,
    /**  查询运动自动暂停/结束支持的运动类型（V3 15.111）*/
    /**  Query sport types that support auto pause/end (V3 15.111)*/
    GETSPORTAUTOPAUSEENDTYPES,
    GETHEARTMODE,
    SETSPORTSTYPEV3,
    GETSMARTHEARTRATEMODE,
    GETSPORTINGREMINDSETTING,
    GETMENULISTV3,
    SETPETINFO,
    SETDATETIME,
    SETSPORTPARAMSORT,
    SETBATTERYREMINDERSWITCH,
    SETAPPSLEEPMODE,
    GETSPORTSTYPEV3,
    SETSPORT100SORT,
    GETWATCHLISTV2,
    SETSCHEDULEREMINDER,
    GETPETINFO,
    GETFUNCTIONTABLE,
    SETDEFAULTMSGLIST,
    GETSTRESSSWITCH,
    GETAPPLETCONTROL,
    GETDOWNLOADLANGUAGE,
    SETMENULISTV3,
    GETSPO2SWITCH,
    GETBATTERYREMINDERSWITCH,
    GETAPPSLEEPMODE,
    SETBIKELOCKLIST,
    SETCGMKEYANDDEVICE,
    DELETECGMKEYANDDEVICE,
    CONNECTCGM,
    DISCONNECTCGM,
    SETBLOODGLUCOSEDATAV01,
    SETALGORITHMRAWDATASENSORCONFIG,
}