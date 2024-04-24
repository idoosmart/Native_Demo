# 更新日志

IDOSDK 版本更新日志

---

## 资源

文档：https://idoosmart.github.io/Native_GitBook/zh/

Demo：https://gitee.com/idoosmart/Native_Demo.git

Android SDK：https://gitee.com/idoosmart/android_sdk.git

iOS SDK： [Podfile](https://gitee.com/idoosmart/Native_Demo/blob/main/example_ios/IDODemo/Podfile)文件



## 4.0.27<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/24</span>

##### 更新内容：

- 修复时间设置接口时区各周参数错误问题

  

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

