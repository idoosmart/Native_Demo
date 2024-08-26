# 更新日志

IDOSDK 版本更新日志

---

## 资源

文档：[中文](https://idoosmart.github.io/Native_GitBook/zh/) | [English](https://idoosmart.github.io/Native_GitBook/en/)

Demo：[Gitee](https://gitee.com/idoosmart/Native_Demo) | [Github](https://github.com/idoosmart/Native_Demo)

Android SDK：[Gitee](https://gitee.com/idoosmart/android_sdk) | [Github](https://github.com/idoosmart/android_sdk)

iOS SDK： [Gitee](https://gitee.com/idoosmart/Native_Demo/blob/main/example_ios/IDODemo/Podfile) | [Github](https://github.com/idoosmart/Native_Demo/blob/main/example_ios/IDODemo/Podfile)



## 4.0.42<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/09</span>

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

