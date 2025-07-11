# 更新日志

IDOSDK 版本更新日志



## 资源

文档：[中文](https://idoosmart.github.io/Native_GitBook/zh/) | [English](https://idoosmart.github.io/Native_GitBook/en/)

Demo：[Gitee](https://gitee.com/idoosmart/Native_Demo) | [Github](https://github.com/idoosmart/Native_Demo)

Android SDK：[Gitee](https://gitee.com/idoosmart/android_sdk) | [Github](https://github.com/idoosmart/android_sdk)

iOS SDK： [Gitee](https://gitee.com/idoosmart/ios_sdk_full) | [Github](https://github.com/idoosmart/ios_sdk_full)



## 4.3.1<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/11</span>

##### 更新内容：

- bugfix；

- 适配新功能；

  

## 4.3.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/03</span>

##### 更新内容：

- bugfix；
- 适配新功能



## 4.2.14<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/06/17</span>

##### 更新内容：

- bugfix；

- 适配新功能

  

## 4.2.13<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/06/10</span>

##### 更新内容：

- bugfix；
- 适配新功能



## 4.2.11<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/05/16</span>

##### 更新内容：

- bugfix；
- 适配新功能



## 4.2.10<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/05/13</span>

##### 更新内容：

- bugfix；



## 4.2.9<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### 更新内容：

- 适配新功能；
- 部分功能优化;


## 4.2.8<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### 更新内容：

- 新增APP基本信息设置（仅限支持该功能的设备）；
- 部分功能优化;



## 4.2.7<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/17</span>

##### 更新内容：

- 去除蓝牙库非必要的后台定位权限配置（Android）；
- 自动EPO升级添加每30分钟更新热启动参数请求（启用自动EPO升级时有效）；
- 部分功能优化;



## 4.2.6<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/02/25</span>

##### 更新内容：

- 修复Cmds.getSportTypeV3()返回数据解析异常问题；
- 调整单项数据同步超时时长（10s -> 30s);



## 4.2.5（Android only)<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/02/11</span>

##### 更新内容：

- 修复BT配对时点取消后，状态回调两次问题；




## 4.2.5（iOS only)<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/01/17</span>

##### 更新内容：

- Demo补充国际化支持；

- Demo修复动态/静态消息图标及通知列表页获取失败后跳转问题；

- 修复关闭蓝牙时未触发markDisconnect方法调用问题；



## 4.2.4<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/12/28</span>

##### 更新内容：

- 完善app启动户外骑行，补充手机gps信号及距离参数；

- 添加动态消息图标及通知开关设置完整示例（iOS）；

- 添加静态消息通知开关完整示例（iOS）；



## 4.2.3<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/12/05</span>

##### 更新内容：

- 数据同步当天心率数据添加未来时间数据清洗逻辑（仅限部分老设备）；

- 数据同步超时时长调整为120秒（仅限部分老设备）

  

## 4.2.2<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/28</span>

##### 更新内容：

- 添加手机系统设置中关闭Bluetooth时更新deviceState代理回调 (iOS)；



## 4.2.1<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/19</span>

##### 更新内容：

- 移除内置的tencent icon (Android)；
- 修改IDOHeartModeParamModel构造方法中部分参数为可选；



## 4.2.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/14</span>

##### 更新内容：

- 兼容Android14 (Android)；
- 解决framework签名问题 (iOS)；
- 调整icon_assets.bundle资源包的管理方式（手动集成时需关注)(iOS)；



## 4.1.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/07</span>

##### 更新内容：

- 补充新增功能表；
- 解决数据同步状态未刷新问题；
- 解决android非主线程调用异常问题；



## 4.0.46<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/10/25</span>

##### 更新内容：

- 修复世界时钟设置接口参数实体转json问题（android）；
- 获取闹钟接口添加指定优先级支持；



## 4.0.45<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/10/14</span>

##### 更新内容：

- 升级指定平台的表盘相关so库（android）；
- 添加icon_assets.bundle资源文件加载异常捕获（iOS）；
- 修复部分已知bug；



## 4.0.44<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/09/12</span>

##### 更新内容：

- 升级指定平台的OTA相关so库（android）；
- 修复热启动参数设置；



## 4.0.43<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/09/05</span>

##### 更新内容：

- 优化数据同步，屏蔽无效数据返回；

- epo升级重试功能调整为每步重试，次数可指定；

- 接口添加线程安全处理，支持非主线程调用；

  

## 4.0.42<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/26</span>

##### 更新内容：

- v3天气实体添加风力属性 windForce；
- 优化文件传输速度；
- 修复单项数据同步同步不到数据问题；



## 4.0.41<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/16</span>

##### 更新内容：

- 添加EPO升级管理接口；



## 4.0.40<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/09</span>

##### 更新内容：

- 添加acc算法日志和gps算法日志文件获取接口；
- 内置EPO自动更新功能（部分设备支持）；



## 4.0.39（iOS only)<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/22</span>

##### 更新内容：

- 修复加载缓存的默认app应用信息返回不完整问题（ios）；



## 4.0.38<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/22</span>

##### 更新内容：

- 添加设置默认app应用信息列表接口（ios）；



## 4.0.37<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/17</span>

##### 更新内容：

- 添加bt连接状态通知（android）；

- 开放获取音频采样率接口；

- 消息图标相关问题修复；



## 4.0.36<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/16</span>

##### 更新内容：

- 修复IDOBleDeviceModel只读属性无法赋值问题（android）；

- 音乐实体类部分属性调整为可选属性

  

## 4.0.35<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/11</span>

##### 更新内容：

- 添加小程序操作接口（获取版本、启动小程序）；

  

## 4.0.34<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/04</span>

##### 更新内容：

- 添加小程序升级功能；

  

## 4.0.33<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/01</span>

##### 更新内容：

- 适配新的BLE服务特征；

  

## 4.0.32<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/06/26</span>

##### 更新内容：

- 解决缺省消息图标读取异常问题；



## 4.0.31<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/06/20</span>

##### 更新内容：

- 适配新设备OTA升级；



## 4.0.30<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/05/30</span>

##### 更新内容：

- 添加同步指定类型数据接口；
- 设备信息添加sn、btName、gpsPlatform字段；
- 添加获取智能心率模式、获取血氧开关、获取压力开关、设置默认消息应用列表接口；
- 修复调用bt配对无效问题（android）
- 修复固件返回异常数据导致获取闹钟闪退问题
- 修复无法修改设备音量问题



## 4.0.29<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/05/14</span>

##### 更新内容：

- 解决部分包冲突问题（android)
- 修复实时运动显示失败问题（android)
- 修复实时运动代理未回调问题（iOS）
- 移除path_provider_xx三方库



## 4.0.28<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/24</span>

##### 更新内容：

- 包名中关键字enum替换为enums（enum在java中是保留字）（android)
- 设备绑定成功添加清除v3健康数据缓存逻辑



## 4.0.27<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/24</span>

##### 更新内容：

- 修复时间设置接口时区和周参数错误问题

  

## 4.0.26<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/18</span>

##### 更新内容：

- 补充接口：获取单位、设置热启动参数、获取spp mtu长度
- 修复蓝牙库日志记录问题



## 4.0.25<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/11</span>

##### 更新内容：

- 修复天气设置失败问题



## 4.0.24<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/10</span>

##### 更新内容：

- 补充[快速消息回复](https://idoosmart.github.io/Native_GitBook/zh/doc/logicDescription/quickMsgReplyList.html)、默认快速消息回复列表指令（android）
- 适配取消绑定功能
- 修复iOS Objective-C 部分指令接口参数异常问题（iOS）



## 4.0.23<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/03</span>

##### 更新内容：

- 设置压力开关接口实体添加周重复参数
- 修复设置通知中心json序列化问题（android)
- 协议库添加非v3协议的回复数据补齐20字节



## 4.0.22<span style="font-size:12px;">&nbsp;&nbsp;2024/03/29</span>

##### 更新内容：

- 修复部分json解析异常问题
- 修复闹钟、提醒类周提醒解析问题
- 调整实体属性为可读写（iOS）



## 4.0.21<span style="font-size:12px;">&nbsp;&nbsp;2024/03/26</span>

##### 更新内容：

- 解决部分json字段解析问题
- 补充开始/结束拍照接口（Android）



## 4.0.20<span style="font-size:12px;">&nbsp;&nbsp;2024/03/21</span>

##### 更新内容：

- 添加蓝牙库日志导出接口
- 完善取消当前绑定请求接口
- 修复天气实体部分字段错误（iOS）



## 4.0.19<span style="font-size:12px;">&nbsp;&nbsp;2024/03/08</span>

##### 更新内容：

- 新增APP下发配对结果指令接口
- 新增APP下发绑定结果方法接口
- 适配定制项目绑定流程需求



## 4.0.18（android only)

##### 更新内容：

- 公开设备信息获取接口



## 4.0.18（iOS only)

##### 更新内容：

- 适配OC（补充oc无法适配的swift classs可选属性）



## 4.0.17

##### 更新内容：

- 补充接口：

  - 获取默认的运动类型 - getDefaultSportType

  - 获取运动默认的类型 V3 - getSportTypeV3

  - 获取BT连接手机型号 - getBtConnectPhoneModel

  - 设置喝水提醒 - setDrinkWaterRemind

  - 设置经期提醒 - setMenstruationRemind

  - 设置压力开关 - setStressSwitch

  - 设置语音助手开关 - setVoiceAssistantOnOff

  - 设置勿扰模式 - setNotDisturb

  - 设置菜单列表 - setMenuList

  - 设置运动类型排序 - setSportSortV3

  - 设置固件来电快捷回复开关 - setCallQuickReplyOnOff

- 添加版本信息 (sdk.info.versionLib)



##### iOS:

- 添加代理方法：


```swift
/// 根据设备macAddress查询绑定状态
func checkDeviceBindState(macAddress: String) -> Bool
```

- 适配OC

  

##### Android:

- 添加代理方法：

```kotlin
/// 根据设备macAddress查询绑定状态
fun checkDeviceBindState(macAddress: String): Boolean
```

