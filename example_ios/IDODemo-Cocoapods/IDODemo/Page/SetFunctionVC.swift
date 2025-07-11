//
//  SetFunctionVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import UIKit

import AVFoundation
import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class SetFunctionVC: UIViewController {
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    
    private lazy var items = [
        
        //        SetCmd(type: .setGpsControl, title: "setGpsControl", desc: "Control GPS event number"),
        
        SetCmd(type: .setWeatherSunTime, title: "setWeatherSunTime", desc: L10n.setWeatherSunTime),
        SetCmd(type: .setShortcut, title: "setShortcut", desc: L10n.setShortcut),
        SetCmd(type: .setSleepPeriod, title: "setSleepPeriod", desc: L10n.setSleepPeriod),
        // SetCmd(type: .setTakingMedicineReminder, title: "setTakingMedicineReminder", desc: L10n.setTakingMedicineReminder),
        SetCmd(type: .setDisplayMode, title: "setDisplayMode", desc: L10n.setDisplayMode),
        // SetCmd(type: .setBpMeasurement, title: "setBpMeasurement", desc: L10n.setBpMeasurement),
        // SetCmd(type: .setMusicOperate, title: "setMusicOperate", desc: L10n.setMusicOperate),
        SetCmd(type: .setNoticeAppName, title: "setNoticeAppName", desc: L10n.setNoticeAppName),
        // SetCmd(type: .setBpCalControlV3, title: "setBpCalControlV3", desc: L10n.setBpCalControlV3),
        // SetCmd(type: .setSportParamSort, title: "setSportParamSort", desc: L10n.setSportParamSort),
        // SetCmd(type: .setMainUISortV3, title: "setMainUISortV3", desc: L10n.setMainUISortV3),
        // SetCmd(type: .setVoiceReplyText, title: "setVoiceReplyText", desc: L10n.setVoiceReplyText),
        // SetCmd(type: .setWalkRemindTimes, title: "setWalkRemindTimes", desc: L10n.setWalkRemindTimes),
        // SetCmd(type: .setWallpaperDialReply, title: "setWallpaperDialReply", desc: L10n.setWallpaperDialReply),
        SetCmd(type: .setDateTime, title: "setDateTime", desc: L10n.setDateTime),
        SetCmd(type: .setUserInfo, title: "setUserInfo", desc: L10n.setUserInfo),
        SetCmd(type: .photoStart, title: "photoStart", desc: L10n.photoStart),
        SetCmd(type: .photoStop, title: "photoStop", desc: L10n.photoStop),
        SetCmd(type: .setHand, title: "setHand", desc: L10n.setHand),
        // SetCmd(type: .otaStart, title: "otaStart", desc: L10n.otaStart), // 未启用
        SetCmd(type: .factoryReset, title: "factoryReset", desc: L10n.factoryReset),
        SetCmd(type: .reboot, title: "reboot", desc: L10n.reboot),
        SetCmd(type: .setHotStartParam, title: "setHotStartParam", desc: L10n.setHotStartParam)
    ]
    
    private var funcTableNotContain = [
        SetCmd(type: .setSportGoal, title: "setSportGoal", desc: L10n.setSportGoal),
        SetCmd(type: .setWatchDial, title: "setWatchDial", desc: L10n.setWatchDial),
        SetCmd(type: .setOverFindPhone, title: "setOverFindPhone", desc: L10n.setOverFindPhone)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Set Function"
        view.backgroundColor = .white
        
        
        
        isInfunctionTable()
        
        
        items = items.sorted { $0.title < $1.title }
        
        print("可以调用的接口有：", items.count)
        
        print("set功能表数量:", CmdType.allCases.count)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
            make.left.right.equalTo(0)
        }
    }
    
  
    
    func isInfunctionTable() {
        
        let funcTable = sdk.funcTable
        func addToItems(_ setCmd: SetCmd) {
            items.append(setCmd)
        }
        
        if (funcTable.getFindDevice) {
            items.append(SetCmd(type: .findDeviceStart, title: "findDeviceStart", desc: L10n.findDeviceStart))
            items.append(SetCmd(type: .findDeviceStop, title: "findDeviceStop", desc: L10n.findDeviceStop))
        }
        
        if (funcTable.getSupportV3LongCityName) {
            items.append(SetCmd(type: .setLongCityNameV3, title: "setLongCityNameV3", desc: L10n.setLongCityNameV3))
        }
        
        if (funcTable.getNotifyMsgV3) {
            items.append(SetCmd(type: .noticeMessageV3, title: "noticeMessageV3", desc: L10n.noticeMessageV3))
        }
        
        if (funcTable.setWeatherCity) {
            items.append(SetCmd(type: .setWeatherCityName, title: "setWeatherCityName", desc: L10n.setWeatherCityName))
        }
        
        if funcTable.setSetPhoneVoice {
            addToItems(SetCmd(type: .setBleVoice, title: "setBleVoice", desc: L10n.setBleVoice))
        }
        
        if (funcTable.reminderAncs) {
            items.append(SetCmd(type: .setNoticeStatusBtPair, title: "setNoticeStatus(BT Pair)", desc: L10n.setNoticeStatusBtPair))
            items.append(SetCmd(type: .setNoticeStatusAllOn, title: "setNoticeStatus(Fully open)", desc: L10n.setNoticeStatusAllOn))
            items.append(SetCmd(type: .setNoticeStatusAllOff, title: "setNoticeStatus(Fully closed)", desc: L10n.setNoticeStatusAllOff))
        }
        
        if (funcTable.setPressureData) {
            items.append(SetCmd(type: .setStressSwitch, title: "setStressSwitch", desc: L10n.setStressSwitch))
        }
        
        // if funcTable.setSetStressCalibration {
        //     addToItems(SetCmd(type: .setStressCalibration, title: "setStressCalibration", desc: L10n.setStressCalibration))
        // }
        
        // if funcTable.setHandWashReminder {
        //     addToItems(SetCmd(type: .setHandWashingReminder, title: "setHandWashingReminder", desc: L10n.setHandWashingReminder))
        // }
        
        // if funcTable.supportSetWeatherDataV2 {
        //     addToItems(SetCmd(type: .setWeatherData, title: "setWeatherData", desc: L10n.setWeatherData))
        // }
        
        // 因为demo要适配所有设备，此处示例适配多种情况。
        // 当只适配一台设备时，只需处理以下一种即可（根据功能表判断设备使用哪种）。
        if (sdk.funcTable.setSmartHeartRate) {
            print("setSmartHeartRate")
            items.append(SetCmd(type: .setHeartMode, title: "setHeartMode", desc: L10n.setHeartMode))
        } else if (sdk.funcTable.syncV3Hr) {
            print("syncV3Hr")
            items.append(SetCmd(type: .setHeartMode, title: "setHeartMode", desc: L10n.setHeartMode))
        } else if (sdk.funcTable.syncHeartRateMonitor) {
            print("syncHeartRateMonitor")
            items.append(SetCmd(type: .setHeartMode, title: "setHeartMode", desc: L10n.setHeartMode))
        }
        
        if (funcTable.syncHeartRate) {
            items.append(SetCmd(type: .setHeartRateInterval, title: "setHeartRateInterval", desc: L10n.setHeartRateInterval))
        }
        
        if funcTable.setScreenBrightness5Level || funcTable.setScreenBrightness3Level || funcTable.setNightAutoBrightness {
            items.append(SetCmd(type: .setScreenBrightness, title: "setScreenBrightness", desc: L10n.setScreenBrightness))
        }
        
        if funcTable.setSetUnreadAppReminder {
            addToItems(SetCmd(type: .setUnreadAppReminder, title: "setUnreadAppReminder", desc: L10n.setUnreadAppReminder))
        }
        
        if funcTable.setMsgAllSwitch {
            addToItems(SetCmd(type: .setNotificationStatus, title: "setNotificationStatus", desc: L10n.setNotificationStatus))
        }
        
        addToItemsbyFunctable(funcTable.setScientificSleepSwitch, SetCmd(type: .setScientificSleepSwitch, title: "setScientificSleepSwitch", desc: L10n.setScientificSleepSwitch))
        
        // addToItemsbyFunctable(funcTable.syncHeartRateMonitor, SetCmd(type: .setHeartRateMode, title: "setHeartRateMode", desc: L10n.setHeartRateMode))
        
        addToItemsbyFunctable(funcTable.syncV3BodyPower, SetCmd(type: .setBodyPowerTurn, title: "setBodyPowerTurn", desc: L10n.setBodyPowerTurn))
        
        addToItemsbyFunctable(funcTable.setRespirationRate, SetCmd(type: .setRRespiRateTurn, title: "setRRespiRateTurn", desc: L10n.setRRespiRateTurn))
        
        addToItemsbyFunctable(funcTable.syncV3Noise, SetCmd(type: .setV3Noise, title: "setV3Noise", desc: L10n.setV3Noise))
        
        addToItemsbyFunctable(funcTable.setTemperatureSwitchSupport, SetCmd(type: .setTemperatureSwitch, title: "setTemperatureSwitch", desc: L10n.setTemperatureSwitch))
        
        addToItemsbyFunctable(funcTable.getUpHandGesture, SetCmd(type: .setUpHandGesture, title: "setUpHandGesture", desc: L10n.setUpHandGesture))
        
        addToItemsbyFunctable(funcTable.setSpo2Data, SetCmd(type: .setSpo2Switch, title: "setSpo2Switch", desc: L10n.setSpo2Switch))
        
        addToItemsbyFunctable(funcTable.syncV3SyncAlarm, SetCmd(type: .setAlarm, title: "setAlarm", desc: L10n.setAlarm))
        
        addToItemsbyFunctable(funcTable.setSetFitnessGuidance, SetCmd(type: .setFitnessGuidance, title: "setFitnessGuidance", desc: L10n.setFitnessGuidance))
        
        addToItemsbyFunctable(funcTable.setBleControlMusic, SetCmd(type: .setMusicOnOff, title: "setMusicOnOff", desc: L10n.setMusicOnOff))
        
        addToItemsbyFunctable(funcTable.setSupportSportPlan, SetCmd(type: .setSendRunPlan, title: "setSendRunPlan", desc: L10n.setSendRunPlan))
        
        addToItemsbyFunctable(funcTable.setSetV3Weather, SetCmd(type: .setWeatherV3, title: "setWeatherV3", desc: L10n.setWeatherV3))
        
        addToItemsbyFunctable(funcTable.setBleControlMusic, SetCmd(type: .musicControl, title: "musicControl", desc: L10n.musicControl))
        
        addToItemsbyFunctable(funcTable.setSetNotificationStatus, SetCmd(type: .setNoticeMessageState, title: "setNoticeMessageState", desc: L10n.setNoticeMessageState))
        
        addToItemsbyFunctable(funcTable.setSetV3WorldTime, SetCmd(type: .setWorldTimeV3, title: "setWorldTimeV3", desc: L10n.setWorldTimeV3))
        
        addToItemsbyFunctable(funcTable.setScheduleReminder, SetCmd(type: .setSchedulerReminder, title: "setSchedulerReminder", desc: L10n.setSchedulerReminder))
        
        addToItemsbyFunctable(funcTable.getMultiDial, SetCmd(type: .setWatchFaceData, title: "setWatchFaceData", desc: L10n.setWatchFaceData))
        
        addToItemsbyFunctable(funcTable.setSyncContact && funcTable.reminderCallContact, SetCmd(type: .setSyncContact, title: "setSyncContact", desc: L10n.setSyncContact))
        
        addToItemsbyFunctable(funcTable.getSportsTypeV3, SetCmd(type: .setSport100Sort, title: "setSport100Sort", desc: L10n.setSport100Sort))
        
        addToItemsbyFunctable(funcTable.setHistoryMenstrual, SetCmd(type: .setHistoricalMenstruation, title: "setHistoricalMenstruation", desc: L10n.setHistoricalMenstruation))
        
        addToItemsbyFunctable(funcTable.setWatchDialSort, SetCmd(type: .setWatchDialSort, title: "setWatchDialSort", desc: L10n.setWatchDialSort))
        
        addToItemsbyFunctable(funcTable.setWalkReminder, SetCmd(type: .setWalkRemind, title: "setWalkRemind", desc: L10n.setWalkRemind))
        
        addToItemsbyFunctable(funcTable.setMenstruation, SetCmd(type: .setMenstruation, title: "setMenstruation", desc: L10n.setMenstruation))
        
        addToItemsbyFunctable(funcTable.getSupportGetMainSportGoalV3 && funcTable.setCalorieGoal && funcTable.getSupportSetGetTimeGoalTypeV2, SetCmd(type: .setCalorieDistanceGoal, title: "setCalorieDistanceGoal", desc: L10n.setCalorieDistanceGoal))
        
        // addToItemsbyFunctable(funcTable.getSupportBpSetOrMeasurementV2, SetCmd(type: .setBpCalibration, title: "setBpCalibration", desc: L10n.setBpCalibration))
        
        addToItemsbyFunctable(funcTable.supportSetAntilost, SetCmd(type: .setLostFind, title: "setLostFind", desc: L10n.setLostFind))
        
        addToItemsbyFunctable(funcTable.setSetV3Weather, SetCmd(type: .setWeatherSwitch, title: "setWeatherSwitch", desc: L10n.setWeatherSwitch))
        
        addToItemsbyFunctable(true, SetCmd(type: .setUnit, title: "setUnit", desc: L10n.setUnit))
        
        addToItemsbyFunctable(funcTable.getFindPhone, SetCmd(type: .setFindPhone, title: "setFindPhone", desc: L10n.setFindPhone))
        
        addToItemsbyFunctable(funcTable.supportSetOnetouchCalling, SetCmd(type: .setOnekeySOS, title: "setOnekeySOS", desc: L10n.setOnekeySOS))
        
        addToItemsbyFunctable(funcTable.syncTimeLine, SetCmd(type: .setSportModeSelect, title: "setSportModeSelect", desc: L10n.setSportModeSelect))
        
        addToItemsbyFunctable(funcTable.setSportModeSort, SetCmd(type: .setSportModeSort, title: "setSportModeSort", desc: L10n.setSportModeSort))
        
        // addToItemsbyFunctable(funcTable.setSedentariness, SetCmd(type: .setLongSit, title: "setLongSit", desc: L10n.setLongSit))
        
        addToItemsbyFunctable(true, SetCmd(type: .setDefaultMsgList, title: "setDefaultMsgList", desc: L10n.setDefaultMsgList))
        addToItemsbyFunctable(sdk.funcTable.setSupportControlMiniProgram, SetCmd(type: .setAppletControl, title: "setAppletControl", desc: L10n.setAppletControl))
     
        addToItemsbyFunctable(sdk.funcTable.getSportsTypeV3, SetCmd(type: .setSportsTypeV3, title: "setSportsTypeV3", desc: L10n.setSportsTypeV3))

        addToItemsbyFunctable(sdk.funcTable.supportSettingsDuringExercise, SetCmd(type: .setDuringExercise, title: "setDuringExercise", desc: L10n.setSportsTypeV3))
        
        addToItemsbyFunctable(sdk.funcTable.supportSimpleHrZoneSetting, SetCmd(type: .setSimpleHeartRateZone, title: "setSimpleHeartRateZone", desc: L10n.setSportsTypeV3))
        
        addToItemsbyFunctable(sdk.funcTable.supportSportingRemindSetting, SetCmd(type: .setSportingRemindSetting, title: "setSportingRemindSetting", desc: L10n.setSportsTypeV3))
    }
    
    
    fileprivate func addToItemsbyFunctable(_ functable: Bool, _ item: SetCmd) {
        //let funcTable = sdk.funcTable
        func addToItems(_ setCmd: SetCmd) {
            items.append(setCmd)
        }
        if functable {
            addToItems(item)
        }
    }
        
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SetFunctionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .black
        cell.textLabel?.textAlignment = .left
        cell.detailTextLabel?.textAlignment = .left
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.numberOfLines = 2
        let cmd = items[indexPath.row]
        cell.textLabel?.text = cmd.title
        cell.detailTextLabel?.text = cmd.desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = items[indexPath.row]
        let vc = SetFunctionDetailVC(cmd: cmd)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - CmdType

private struct SetCmd {
    let type: CmdType
    let title: String
    let desc: String
    let isSupported: Bool
    
    init(type: CmdType, title: String, desc: String, isSupported: Bool = false) {
        self.title = title
        self.desc = desc
        self.type = type
        self.isSupported = isSupported
    }
}


private enum CmdType: CaseIterable{
    /// 手机音量下发给ble
    /// Set phone volume for device event number
    case setBleVoice
    /// 设置控制gps
    /// Control GPS event number
    case setGpsControl
    /// 设置压力校准
    /// Set Stress Calibration Event Code
    case setStressCalibration
    /// 设置洗手提醒
    /// Set Hand Washing Reminder Event
    case setHandWashingReminder
    /// 设置运动目标
    /// Set exercise goal event
    case setSportGoal
    /// 设置天气数据
    /// Set weather data event number
    case setWeatherData
    /// 未读信息红点提示开关
    /// Unread message reminder switch event number
    case setUnreadAppReminder
    /// 手机app通过这个命令开关，实现通知应用状态设置
    /// Notification app status setting event
    case setNotificationStatus
    /// 设置科学睡眠开关
    /// Scientific sleep switch setting event
    case setScientificSleepSwitch
    /// 血压校准
    /// Blood pressure calibration event number
    case setBpCalibration
    /// 设置防丢
    /// Set Lost Find Event
    case setLostFind
    /// 设置表盘
    /// Set watch face event number
    case setWatchDial
    /// 设置天气开关
    /// Set weather switch event number
    case setWeatherSwitch
    /// 设置单位
    /// Set Unit event number
    case setUnit
    /// 设置寻找手机
    /// Set Find Phone
    case setFindPhone
    /// 设置停止寻找手机
    /// Stop Find Phone
    case setOverFindPhone
    /// 设置一键呼叫
    /// Set the one-touch calling event number
    case setOnekeySOS
    /// 设置运动模式选择
    /// Set sport mode select event number
    case setSportModeSelect
    /// 设置运动模式排序
    /// Set Sport Mode Sorting
    case setSportModeSort
    /// 设置久坐
    /// Set Long Sit Event
    case setLongSit
    /// 设置身体电量开关
    /// Set body power switch event number
    case setBodyPowerTurn
    /// 设置呼吸率开关
    /// Respiration rate switch setting event
    case setRRespiRateTurn
    /// 环境音量的开关和阀值
    /// Set Environmental Noise Volume On/Off and Threshold Event
    case setV3Noise
    /// 设置日出日落时间
    /// Set sunrise and sunset time event number
    case setWeatherSunTime
    /// 设置快捷方式
    /// Set shortcut
    case setShortcut
    /// 设置通知中心 bt配对
    /// Set Notification Center Event, BT Pair
    case setNoticeStatusBtPair
    /// 设置通知中心(全开)
    /// Set Notification Center Event(on)
    case setNoticeStatusAllOn
    /// 设置通知中心(全关)
    /// Set Notification Center Event(all off)
    case setNoticeStatusAllOff
    /// 设置夜间体温开关
    /// Set Night-time Temperature Switch Event Code
    case setTemperatureSwitch
    /// 设置睡眠时间段
    /// Set sleep period event
    case setSleepPeriod
    /// 设置抬手亮屏
    /// Raise-to-wake gesture event number
    case setUpHandGesture
    /// 设置吃药提醒
    /// Set Taking Medicine Reminder Event Code
    case setTakingMedicineReminder
    /// 设置血氧开关
    /// Set SpO2 switch event
    case setSpo2Switch
    /// 设置天气城市名称
    /// Set weather city name event number
    case setWeatherCityName
    /// app设置ble的闹钟
    /// Getting Alarms for V3APP Devices
    case setAlarm
    /// 健身指导
    /// Fitness Guidance Event
    case setFitnessGuidance
    /// 显示模式
    /// Display mode event number
    case setDisplayMode
    /// 血压测量
    /// Blood pressure measurement event number
    case setBpMeasurement
    /// 音乐开关
    /// Set Music On/Off Event
    case setMusicOnOff
    /// app下发跑步计划(运动计划)
    /// App issued running plan (exercise plan) event number
    case setSendRunPlan
    /// v3 下发v3天气协议
    /// Send the v3 weather protocol event number under v3
    case setWeatherV3
    /// 控制音乐
    /// Music control event number
    case musicControl
    /// 操作歌曲或者文件夹
    /// Operation for songs or folders event
    case setMusicOperate
    /// 通知消息提醒
    /// Notification message reminder event number
    case noticeMessageV3
    /// 设置消息通知状态
    /// Setting Notification Status for a Single App
    case setNoticeMessageState
    /// 动态消息通知
    /// V3 dynamic notification message event number
    case setNoticeAppName
    /// 下发v3世界时间
    /// v3 set v3 world time
    case setWorldTimeV3
    /// 设置日程提醒
    /// Schedule Reminder
    case setSchedulerReminder
    /// 血压校准控制
    /// Blood Pressure Calibration Control
    case setBpCalControlV3
    /// 设置表盘
    /// Set Watch Face
    case setWatchFaceData
    /// 同步常用联系人
    /// Synchronization Protocol Bluetooth Call Common Contacts
    case setSyncContact
    /// 设置运动子项数据排列
    /// Set and Query Sports Sub-item Data Sorting
    case setSportParamSort
    /// 新的100种运动排序
    /// Set and Query 100 Sports Sorting
    case setSport100Sort
    /// 设置主界面控件排序
    /// Setting and Query Sorting of Main UI Controls
    case setMainUISortV3
    /// 经期的历史数据下发
    /// Menstrual historical data delivery event number
    case setHistoricalMenstruation
    /// 设置运动城市名称
    /// V3 Setting the Name of a Sports City event number
    case setLongCityNameV3
    /// V3设置心率模式
    /// Set Heart Rate Mode V3
    case setHeartMode
    /// 语音回复文本
    /// V3 voice reply text event number
    case setVoiceReplyText
    /// 设置表盘顺序
    /// Set watch dial sort event
    case setWatchDialSort
    /// 设置多个走动提醒的时间点
    /// Set multiple walk reminder times event number
    case setWalkRemindTimes
    /// 设置壁纸表盘列表
    /// Set wallpaper dial list event number
    case setWallpaperDialReply
    /// 设置时间
    /// Set Time
    case setDateTime
    /// 设置用户信息
    case setUserInfo
    /// 控制寻找设备开始
    case findDeviceStart
    /// 控制寻找设备结束
    case findDeviceStop
    /// 开始拍照 (app -> ble)
    case photoStart
    /// 结束拍照 (app -> ble)
    case photoStop
    /// 设置左右手
    case setHand
    /// 设置屏幕亮度
    case setScreenBrightness
    /// 进入升级模式
    case otaStart
    /// 设置心率区间
    case setHeartRateInterval
    /// 设置卡路里和距离目标(设置日常三环)
    case setCalorieDistanceGoal
    /// 设置走动提醒
    case setWalkRemind
    /// 设置经期
    case setMenstruation
    /// 恢复出厂设置
    case factoryReset
    /// 重启设备
    case reboot
    ///  设置压力开关
    case setStressSwitch
    /// 设置热启动参数
    /// Set hot boot parameters
    case setHotStartParam
    ///  设置默认的消息应用列表
    case setDefaultMsgList
    /// 发送小程序操作
    case setAppletControl
    /// 运动列表修改、排序、删除
    case setSportsTypeV3
    ///  运动中设置提示音开关
    case setDuringExercise
    ///  简单心率区间设置
    case setSimpleHeartRateZone
    ///  运动中提醒设置
    case setSportingRemindSetting
}

extension CmdType {
    func param() -> IDOBaseModel? {
        switch self {
        case .setDateTime:
            let currentDate = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            let day = calendar.component(.day, from: currentDate)
            let hour = calendar.component(.hour, from: currentDate)
            let minute = calendar.component(.minute, from: currentDate)
            let second = calendar.component(.second, from: currentDate)
            let timeZone = TimeZone.current.secondsFromGMT(for: currentDate)
            let weekday = calendar.component(.weekday, from: currentDate)
            var adjustedWeekday = weekday - 2
            if adjustedWeekday < 0 {
                adjustedWeekday += 7
            }
            return IDODateTimeParamModel(year: year, monuth: month, day: day,
                                         hour: hour, minute: minute, second: second,
                                         week: adjustedWeekday, timeZone: timeZone)
        case .setBleVoice:
            return IDOBleVoiceParamModel(totalVolume: 100, currentVolume: Int(getCurrentVolume()))
        case .setGpsControl:
            return IDOGpsControlParamModel(operate: 2, type: 1)
        case .setStressCalibration:
            return IDOStressCalibrationParamModel(stressScore: 1, status: 1)
        case .setHandWashingReminder:
            return IDOHandWashingReminderParamModel(onOff: 1,
                                                    startHour: 1,
                                                    startMinute: 0,
                                                    endHour: 2,
                                                    endMinute: 0,
                                                    repeats: [.wednesday, .monday],
                                                    interval: 60)
        case .setSportGoal:
            return IDOSportGoalParamModel(sportStep: 2000, walkGoalSteps: 15, targetType: 1)
        case .setWeatherData:
            let dataFuture1 = IDOWeatherDataFuture(type: 0, minTemp: 3, maxTemp: 13)
            let dataFuture2 = IDOWeatherDataFuture(type: 0, minTemp: 1, maxTemp: 10)
            let dataFuture3 = IDOWeatherDataFuture(type: 0, minTemp: 5, maxTemp: 16)
            return IDOWeatherDataParamModel(type: 1,
                                            temp: 5,
                                            maxTemp: 10,
                                            minTemp: 1,
                                            humidity: 45,
                                            uvIntensity: 20,
                                            aqi: 16,
                                            future: [dataFuture1, dataFuture2, dataFuture3])
        case .setUnreadAppReminder:
            return OtherParamModel(dic: ["open": true])
        case .setNotificationStatus:
            return IDONotificationStatusParamModel(notifyFlag: 1)
        case .setScientificSleepSwitch:
            return IDOScientificSleepSwitchParamModel(mode: 1,
                                                      startHour: 23,
                                                      startMinute: 0,
                                                      endHour: 9,
                                                      endMinute: 0)
        case .setBpCalibration:
            return IDOBpCalibrationParamModel(flag: 2, diastolic: 0, systolic: 0)
        case .setLostFind:
            return IDOLostFindParamModel(mode: 1)
        case .setWatchDial:
            return IDOWatchDialParamModel(dialId: 3)
        case .setWeatherSwitch:
            return OtherParamModel(dic: ["open": true])
        case .setUnit:
            return IDOUnitParamModel(distUnit: 1,
                                     weightUnit: 1,
                                     temp: 1,
                                     stride: 1,
                                     language: 2,
                                     is12HourFormat: 1,
                                     strideRun: 1,
                                     strideGpsCal: 1,
                                     weekStartDate: 1,
                                     calorieUnit: 1,
                                     swimPoolUnit: 1,
                                     cyclingUnit: 1,
                                     walkingRunningUnit: 1,heightUnit: 2)
        case .setFindPhone:
            return OtherParamModel(dic: ["open": true])
        case .setOverFindPhone:
            return OtherParamModel(dic: ["open": true])
        case .setOnekeySOS:
            return OtherParamModel(dic: ["open": true, "phoneType": 1])
        case .setSportModeSelect:
            return IDOSportModeSelectParamModel(flag: 10, sportType1: 4, sportType2: 10, sportType3: 19, sportType4: 10, sportType0Walk: false, sportType0Run: false, sportType0ByBike: false, sportType0OnFoot: false, sportType0Swim: false, sportType0MountainClimbing: false, sportType0Badminton: false, sportType0Other: false, sportType1Fitness: false, sportType1Spinning: false, sportType1Ellipsoid: false, sportType1Treadmill: false, sportType1SitUp: false, sportType1PushUp: false, sportType1Dumbbell: false, sportType1Weightlifting: false, sportType2BodybuildingExercise: false, sportType2Yoga: false, sportType2RopeSkipping: false, sportType2TableTennis: false, sportType2Basketball: false, sportType2Football: false, sportType2Volleyball: false, sportType2Tennis: false, sportType3Golf: false, sportType3Baseball: false, sportType3Skiing: false, sportType3RollerSkating: false, sportType3Dance: false, sportType3StrengthTraining: false, sportType3CoreTraining: false, sportType3TidyUpRelax: false)
        case .setSportModeSort:
            let items = [
                IDOSportModeSortParamModel(index: 1, type: .sportTypeAerobics).toJsonString(),
                IDOSportModeSortParamModel(index: 2, type: .sportTypeBMX).toJsonString(),
                IDOSportModeSortParamModel(index: 3, type: .sportTypeGym).toJsonString(),
                IDOSportModeSortParamModel(index: 4, type: .sportTypeHit).toJsonString()
            ]
            return OtherParamModel(dic: ["items": items])
        case .setLongSit:
            return IDOLongSitParamModel(startHour: 10, startMinute: 4, endHour: 10, endMinute: 19, interval: 10, repetitions: 39)
        case .setBodyPowerTurn:
            return OtherParamModel(dic: ["open": true])
        case .setRRespiRateTurn:
            return OtherParamModel(dic: ["open": true])
        case .setV3Noise:
            return IDOV3NoiseParamModel(mode: 1,
                                        startHour: 15,
                                        startMinute: 0,
                                        endHour: 20,
                                        endMinute: 0,
                                        highNoiseOnOff: 1,
                                        highNoiseValue: 100)
        case .setWeatherSunTime:
            return IDOWeatherSunTimeParamModel(sunriseHour: 6, sunriseMin: 12, sunsetHour: 18, sunsetMin: 30)
        case .setShortcut:
            return IDOShortcutParamModel(mode: 2)
        case .setNoticeStatusBtPair:
            return IDOSetNoticeStatusModel.createAllOffModel()
        case .setNoticeStatusAllOn:
            return IDOSetNoticeStatusModel.createDefaultModel()
        case .setNoticeStatusAllOff:
            return IDOSetNoticeStatusModel.createAllOffModel()
        case .setTemperatureSwitch:
            return IDOTemperatureSwitchParamModel(mode: 1,
                                                  startHour: 19,
                                                  startMinute: 0,
                                                  endHour: 23,
                                                  endMinute: 0,
                                                  unit: 1)
        case .setSleepPeriod:
            return IDOSleepPeriodParamModel(onOff: 0, startHour: 23, startMinute: 0, endHour: 7, endMinute: 0)
        case .setUpHandGesture:
            return IDOUpHandGestureParamModel(onOff: 0, showSecond: 5, hasTimeRange: 1, startHour: 8, startMinute: 0, endHour: 18, endMinute: 0)
        case .setTakingMedicineReminder:
            return IDOTakingMedicineReminderParamModel(takingMedicineId: 1,
                                                       onOff: 1,
                                                       startHour: 7,
                                                       startMinute: 0,
                                                       endHour: 18,
                                                       endMinute: 0,
                                                       repeats: [.monday, .tuesday, .wednesday, .tuesday, .friday, .saturday, .sunday],
                                                       interval: 60,
                                                       doNotDisturbOnOff: 0,
                                                       doNotDisturbStartHour: 0,
                                                       doNotDisturbStartMinute: 0,
                                                       doNotDisturbEndHour: 0,
                                                       doNotDisturbEndMinute: 0)
        case .setSpo2Switch:
            return IDOSpo2SwitchParamModel(onOff: 1,
                                           startHour: 14,
                                           startMinute: 0,
                                           endHour: 20,
                                           endMinute: 0,
                                           lowSpo2OnOff: 1,
                                           lowSpo2Value: 20,
                                           notifyFlag: 1)
        case .setWeatherCityName:
            return OtherParamModel(dic: ["cityName": "beijing"])
        case .setAlarm:
            let maxCount = sdk.funcTable.alarmCount
            let items = (0..<maxCount).map { idx in
                let alarmID = idx + 1
                let futureDate = Date().addingTimeInterval(Double(alarmID) * 60)
                let (hour, minute) = (Calendar.current.component(.hour, from: futureDate),
                                      Calendar.current.component(.minute, from: futureDate))
                return IDOAlarmItem(alarmID: alarmID,
                                    delayMin: 1,
                                    hour: hour,
                                    minute: minute,
                                    name: "Alarm-\(alarmID)",
                                    repeats: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
                                    isOpen: true,
                                    repeatTimes: 0,
                                    shockOnOff: 1,
                                    status: .displayed,
                                    tsnoozeDuration: 0,
                                    type: .other)
            }
            return IDOAlarmModel(items: items)
        case .setFitnessGuidance:
            return IDOFitnessGuidanceParamModel(mode: 1,
                                                startHour: 9,
                                                startMinute: 0,
                                                endHour: 18,
                                                endMinute: 0,
                                                notifyFlag: 1,
                                                goMode: 1,
                                                repeats: [.monday, .sunday],
                                                targetSteps: 5000)
        case .setDisplayMode:
            return IDODisplayModeParamModel(mode: 1)
        case .setBpMeasurement:
            return IDOBpMeasurementParamModel(flag: 1)
        case .setMusicOnOff:
            return IDOMusicOnOffParamModel(onOff: 1, showInfoStatus: 1)
        case .setSendRunPlan:
            let item1 = IDOItemItem(type: 1, time: 200, heightHeart: 110, lowHeart: 80)
            let item2 = IDOItemItem(type: 1, time: 500, heightHeart: 110, lowHeart: 80)
            let gpsInfo = IDOGpsInfoModelItem(type: 1, num: 2, item: [item1, item2])
            return IDORunPlanParamModel(verison: 1,
                                        operate: 1,
                                        type: 1,
                                        year: 2023,
                                        month: 11,
                                        day: 23,
                                        hour: 14,
                                        min: 0,
                                        sec: 0,
                                        dayNum: 0,
                                        items: [gpsInfo])
        case .setWeatherV3:
            return IDOWeatherV3ParamModel(month: 11,
                                          day: 29,
                                          hour: 16,
                                          min: 30,
                                          sec: 0,
                                          week: 1,
                                          weatherType: 1,
                                          todayTmp: 19+100,
                                          todayMaxTemp: 33+100,
                                          todayMinTemp: 15+100,
                                          cityName: "shenzhen",
                                          airQuality: 7,
                                          precipitationProbability: 40,
                                          humidity: 32,
                                          todayUvIntensity: 10,
                                          windSpeed: 5,
                                          windForce: 5,
                                          sunriseHour: 5,
                                          sunriseMin: 37,
                                          sunsetHour: 18,
                                          sunsetMin: 49,
                                          sunriseItemNum: 3,
                                          airGradeItem: "big",
                                          hoursWeatherItems: [
                                            IDOHoursWeatherItem(weatherType: 7, temperature: 8+100, probability: 40)
                                          ],
                                          futureItems: [
                                            IDOFutureItem(weatherType: 6, maxTemp: 33+100, minTemp: 8+100)
                                          ],
                                          sunriseItem: [
                                            IDOSunriseItem(sunriseHour: 5, sunriseMin: 35, sunsetHour: 15, sunsetMin: 35),
                                            IDOSunriseItem(sunriseHour: 6, sunriseMin: 36, sunsetHour: 16, sunsetMin: 36),
                                            IDOSunriseItem(sunriseHour: 7, sunriseMin: 37, sunsetHour: 17, sunsetMin: 37)
                                          ],
                                          aqiFutureItem: [23,24,25,26,27],
                                          aqiHistoryItem: [51,52,53,54,55,56])
        case .musicControl:
            return IDOMusicControlParamModel(status: 1, curTimeSecond: 10, totalTimeSecond: 30, musicName: "m1", singerName: "s1")
        case .setMusicOperate:
            return IDOMusicOpearteParamModel(musicOperate: 1,
                                             folderOperate: 1,
                                             folderItem: IDOMusicFolderItem(folderID: 1, musicNum: 0, folderName: "f1", musicIndex: [1]),
                                             musicItem: IDOMusicItem(musicID: 1, musicMemory: 300, musicName: "m1", singerName: "s1"))
        case .noticeMessageV3:
            return IDONoticeMessageParamModel(evtType: 1,
                                              msgID: 3,
                                              supportAnswering: false,
                                              supportMute: false,
                                              supportHangUp: false,
                                              contact: "xx001",
                                              phoneNumber: "xx003",
                                              dataText: "data text1")
        case .setNoticeMessageState:
            return IDONoticeMessageStateParamModel(operat: 1,
                                                   allOnOff: 1,
                                                   allSendNum: 0,
                                                   nowSendIndex: 0,
                                                   items: [
                                                       IDONoticeMessageStateItem(evtType: 15704, notifyState: 1, picFlag: 1),
                                                       IDONoticeMessageStateItem(evtType: 3678, notifyState: 1, picFlag: 1),
                                                       IDONoticeMessageStateItem(evtType: 3680, notifyState: 1, picFlag: 1),
                                                       IDONoticeMessageStateItem(evtType: 592, notifyState: 1, picFlag: 1),
                                                       IDONoticeMessageStateItem(evtType: 666, notifyState: 1, picFlag: 1),
                                                       IDONoticeMessageStateItem(evtType: 4744, notifyState: 1, picFlag: 1)
                                                   ])
        case .setNoticeAppName:
            return IDONoticeMesaageParamModel(osPlatform: 2,
                                              evtType: 1,
                                              notifyType: 1,
                                              msgID: 1,
                                              appItemsLen: 1,
                                              contact: "zhangsan",
                                              phoneNumber: "xxx333",
                                              msgData: "msg data",
                                              items: [
                                                  IDONoticeMesaageParamItem(language: 1, name: "中文"),
                                                  IDONoticeMesaageParamItem(language: 2, name: "en")
                                              ])
        case .setWorldTimeV3:
            return nil
        case .setSchedulerReminder:
            let item = IDOSchedulerReminderItem(id: 1,
                                                year: 2024,
                                                mon: 11,
                                                day: 26,
                                                hour: 8,
                                                min: 0,
                                                sec: 0,
                                                repeatType: 1,
                                                remindOnOff: 1,
                                                state: 2,
                                                title: "title1",
                                                note: "note1")
            return IDOSchedulerReminderParamModel(operate: 3, items: [item])
        case .setBpCalControlV3:
            return OtherParamModel(dic: ["operate": 1, "filePath": "xx/xx/xx"])
        case .setWatchFaceData:
            return IDOWatchFaceParamModel(operate: 1, fileName: "filename1", watchFileSize: 430)
        case .setSyncContact:
            return IDOSyncContactParamModel(operat: 2, items: [
                IDOContactItem(phone: "xx659", name: "zhangsan1"),
                IDOContactItem(phone: "xx660", name: "zhangsan2"),
                IDOContactItem(phone: "xx661", name: "zhangsan3")
            ])
        case .setSportParamSort:
            return IDOSportSortParamModel(operate: 1,
                                          sportType: .sportTypeHit,
                                          nowUserLocation: 5,
                                          items: [1, 2, 3, 4, 5])
        case .setSport100Sort:
            return IDOSport100SortParamModel(operate: 2,
                                             nowUserLocation: 2,
                                             items: [2, 3, 50, 198, 20, 32])
        case .setMainUISortV3:
            return IDOMainUISortParamModel(operate: 2, items: [1, 2, 3], locationX: 1, locationY: 1, sizeType: 2, widgetsType: 1)
        case .setHistoricalMenstruation:
            return IDOHistoricalMenstruationParamModel(avgMenstrualDay: 7,
                                                       avgCycleDay: 29,
                                                       items: [
                                                           IDOHistoricalMenstruationParamItem(year: 2023,
                                                                                              mon: 8,
                                                                                              day: 1,
                                                                                              menstrualDay: 7,
                                                                                              cycleDay: 30,
                                                                                              ovulationIntervalDay: 14,
                                                                                              ovulationBeforeDay: 5,
                                                                                              ovulationAfterDay: 5),
                                                           IDOHistoricalMenstruationParamItem(year: 2023,
                                                                                              mon: 9,
                                                                                              day: 1,
                                                                                              menstrualDay: 7,
                                                                                              cycleDay: 30,
                                                                                              ovulationIntervalDay: 14,
                                                                                              ovulationBeforeDay: 5,
                                                                                              ovulationAfterDay: 5),
                                                           IDOHistoricalMenstruationParamItem(year: 2023,
                                                                                              mon: 10,
                                                                                              day: 1,
                                                                                              menstrualDay: 7,
                                                                                              cycleDay: 30,
                                                                                              ovulationIntervalDay: 14,
                                                                                              ovulationBeforeDay: 5,
                                                                                              ovulationAfterDay: 5)
                                                       ])
        case .setLongCityNameV3:
            return OtherParamModel(dic: ["cityName": "北京"])
        case .setHeartMode:
            if (sdk.funcTable.setSmartHeartRate) {
                return IDOHeartRateModeSmartParamModel(mode: 1,
                                                       notifyFlag: 1,
                                                       highHeartMode: 1,
                                                       lowHeartMode: 1,
                                                       highHeartValue: 160,
                                                       lowHeartValue: 50,
                                                       startHour: 6,
                                                       startMinute: 0,
                                                       endHour: 19,
                                                       endMinute: 0)
            }else if(sdk.funcTable.syncV3Hr) {
                // 注：设置updateTime
                let param = IDOHeartModeParamModel(updateTime: Int(Date().timeIntervalSince1970))
                // 示例1
                // 关闭 （注：单次运动开启默认进行心率实时监测，不受此开关影响）
                // param.mode = 3
                
                
                // 示例2
                // 持续监测 （比较耗电）
                // param.mode = 5 // 固定5秒（ID206支持固定5秒的持续监测）
                // param.measurementInterval = 5
                
                
                // 示例3
                // 自动监测
                param.mode = 5 // 固定5分钟（ID206支持固定5分钟的自动监测）
                param.measurementInterval = 300
                
                return param
            }else if(sdk.funcTable.syncHeartRateMonitor) {
                return IDOHeartRateModeParamModel(mode: 1,
                                                  hasTimeRange: 1,
                                                  startHour: 8,
                                                  startMinute: 0,
                                                  endHour: 18,
                                                  endMinute: 0,
                                                  measurementInterval: 5)
            }
        case .setVoiceReplyText:
            return IDOVoiceReplyParamModel(flagIsContinue: 0, title: "title1", textContent: "textContent1")
        case .setWatchDialSort:
            return IDOWatchDialSortParamModel(sortItemNumb: 1, pSortItem: [IDOWatchDialSortItem(type: 1, sortNumber: 1, name: "name1")])
        case .setWalkRemindTimes:
            return IDOWalkRemindTimesParamModel(onOff: 1, items: [
                IDOWalkRemindTimesItem(hour: 8, min: 0),
                IDOWalkRemindTimesItem(hour: 12, min: 30)
            ])
        case .setWallpaperDialReply:
            return IDOWallpaperDialReplyV3ParamModel(operate: 0,
                                                     location: 0,
                                                     hideType: 0,
                                                     timeColor: 0x333333,
                                                     widgetType: 2,
                                                     widgetIconColor: 0x232323,
                                                     widgetNumColor: 0x232323)
        case .setUserInfo:
            return IDOUserInfoPramModel(year: 1999, 
                                        monuth: 2,
                                        day: 23,
                                        heigh: 155, 
                                        weigh: 77*100,
                                        gender: 1,
                                        setTime: (Int32)(Date().timeIntervalSince1970))
        case .findDeviceStart:
            return nil
        case .findDeviceStop:
            return nil
        case .photoStart:
            return nil
        case .photoStop:
            return nil
        case .setHand:
            return OtherParamModel(dic: ["isRightHand": false])
        case .setScreenBrightness:
            return IDOScreenBrightnessModel(level: 60,
                                            opera: 1,
                                            mode: 0,
                                            autoAdjustNight: 1,
                                            startHour: 8,
                                            startMinute: 0,
                                            endHour: 23,
                                            endMinute: 59,
                                            nightLevel: 30,
                                            showInterval: 0)
        case .otaStart:
            return nil
        case .setHeartRateInterval:
            return IDOHeartRateIntervalModel(burnFatThreshold: 113,
                                             aerobicThreshold: 132,
                                             limitThreshold: 170,
                                             userMaxHr: 220,
                                             range1: 94,
                                             range2: 113,
                                             range3: 132,
                                             range4: 152,
                                             range5: 170,
                                             minHr: 20,
                                             maxHrRemind: 1,
                                             minHrRemind: 0,
                                             remindStartHour: 0,
                                             remindStartMinute: 0,
                                             remindStopHour: 23,
                                             remindStopMinute: 59)
        case .setCalorieDistanceGoal:
            return IDOMainSportGoalModel(calorie: 600, distance: 300, calorieMin: 130, calorieMax: 666, midHighTimeGoal: 600, walkGoalTime: 5, timeGoalType: 1)
        case .setWalkRemind:
            return IDOWalkRemindModel(onOff: 1, goalStep: 2000, startHour: 14,
                                      startMinute: 0, endHour: 20, endMinute: 0,
                                      repeats: [.monday, .tuesday, .wednesday],
                                      goalTime: 60, notifyFlag: 1, doNotDisturbOnOff: 0,
                                      noDisturbStartHour: 0, noDisturbStartMinute: 0,
                                      noDisturbEndHour: 0, noDisturbEndMinute: 0)
        case .setMenstruation:
            return IDOMenstruationModel(onOff: 1,
                                        menstrualLength: 7,
                                        menstrualCycle: 21,
                                        lastMenstrualYear: 2022,
                                        lastMenstrualMonth: 12,
                                        lastMenstrualDay: 19,
                                        ovulationIntervalDay: 15,
                                        ovulationBeforeDay: 5,
                                        ovulationAfterDay: 5,
                                        notifyFlag: 1,
                                        menstrualReminderOnOff: 1)
        case .factoryReset:
            return nil
        case .reboot:
            return nil
        case .setStressSwitch:
            return IDOStressSwitchParamModel(onOff: 1, startHour: 3, startMinute: 5, endHour: 4, endMinute: 6, remindOnOff: 1, interval: 60, highThreshold: 30, notifyFlag: 1, repeats: [.monday, .tuesday])
        case .setHotStartParam:
            return IDOGpsHotStartParamModel(longitude: 2, latitude: Int(42.6511674 * 1000000) , altitude: Int(-73.754968 * 1000000), tcxoOffset: 0*10)
        case .setDefaultMsgList:
            return IDODefaultMessageConfigParamModel(operate: 1, items: [
                IDODefaultMessageItem(packageName: "com.tencent.xin"),
                IDODefaultMessageItem(packageName: "com.facebook.Facebook")
            ])
        case .setAppletControl:
            return nil
        case .setSportsTypeV3:
            //IDOSport100SortParamModel(operate: <#T##Int#>, nowUserLocation: <#T##Int#>, items: <#T##[Int]#>)
            return nil
        case .setDuringExercise:
            return IDOSettingsDuringExerciseModel(notificationSwitch: 0xAA)
        case .setSimpleHeartRateZone:
            return IDOSimpleHeartRateZoneSettingModel(maxHrValue: 100)
        case .setSportingRemindSetting:
            return IDOSportingRemindSettingModel(
                    sportType: 48, distanceRemind: DistanceRemind(isOpen: true, isMetric: true, goalValOrg: 2000),
                    heartRateRemind: CommonRangeRemind(isOpen: true, maxThreshold: 110, minThreshold: 30),
                    paceRemind: PaceRemind(isOpen: true, isMetric: true, fastThresholdOrg: 60, slowThresholdOrg: 120), stepFreqRemind: CommonRangeRemind(isOpen: true, maxThreshold: 20, minThreshold: 10))
        }
        return nil
    }
    
    private func getCurrentVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let currentVolume = audioSession.outputVolume * 100
            return currentVolume
        } catch {
            print("Failed to get current volume: \(error)")
            return 0.0
        }
    }
}

// MARK: - SetFunctionDetailVC

private class SetFunctionDetailVC: UIViewController {
    private var cmd: SetCmd
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    private lazy var lblParam: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Parameter"
        return v
    }()
    
    private lazy var lblResponse: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Response"
        return v
    }()
    
    private lazy var textParam: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var textResponse: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var btnCall: UIButton = {
        let btn = UIButton.createNormalButton(title: "Send")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.doCall()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    required init(cmd: SetCmd) {
        self.cmd = cmd
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = cmd.title
        view.backgroundColor = .white
        
        view.addSubview(btnCall)
        view.addSubview(lblParam)
        view.addSubview(textParam)
        view.addSubview(lblResponse)
        view.addSubview(textResponse)
        
        btnCall.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        lblParam.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnCall.snp.bottom).offset(15)
        }
        textParam.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblParam.snp.bottom).offset(5)
            make.height.equalTo(160)
        }
        lblResponse.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(textParam.snp.bottom).offset(35)
        }
        textResponse.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblResponse.snp.bottom).offset(5)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        textParam.text = cmd.type.param()?.toJsonString() ?? "none"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewDidDisappear(animated)
    }
    
    private func doCall() {
        cancellable?.cancel()
        cancellable = nil
        textResponse.text = ""
        btnCall.isEnabled = false
        switch cmd.type {
        case .setBleVoice:
            let obj = cmd.type.param() as! IDOBleVoiceParamModel
            cancellable = Cmds.setBleVoice(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setGpsControl:
            let obj = cmd.type.param() as! IDOGpsControlParamModel
            cancellable = Cmds.setGpsControl(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setStressCalibration:
            let obj = cmd.type.param() as! IDOStressCalibrationParamModel
            cancellable = Cmds.setStressCalibration(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHandWashingReminder:
            let obj = cmd.type.param() as! IDOHandWashingReminderParamModel
            cancellable = Cmds.setHandWashingReminder(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSportGoal:
            let obj = cmd.type.param() as! IDOSportGoalParamModel
            cancellable = Cmds.setSportGoal(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWeatherData:
            let obj = cmd.type.param() as! IDOWeatherDataParamModel
            cancellable = Cmds.setWeatherData(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setUnreadAppReminder:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setUnreadAppReminder(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNotificationStatus:
            let obj = cmd.type.param() as! IDONotificationStatusParamModel
            cancellable = Cmds.setNotificationStatus(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setScientificSleepSwitch:
            let obj = cmd.type.param() as! IDOScientificSleepSwitchParamModel
            cancellable = Cmds.setScientificSleepSwitch(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setBpCalibration:
            let obj = cmd.type.param() as! IDOBpCalibrationParamModel
            cancellable = Cmds.setBpCalibration(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setLostFind:
            let obj = cmd.type.param() as! IDOLostFindParamModel
            cancellable = Cmds.setLostFind(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWatchDial:
            let obj = cmd.type.param() as! IDOWatchDialParamModel
            cancellable = Cmds.setWatchDial(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWeatherSwitch:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setWeatherSwitch(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setUnit:
            let obj = cmd.type.param() as! IDOUnitParamModel
            cancellable = Cmds.setUnit(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setFindPhone:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setFindPhone(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setOverFindPhone:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setOverFindPhone(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setOnekeySOS:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setOnekeySOS(open: dic["open"] as! Bool, phoneType: dic["phoneType"] as! Int).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSportModeSelect:
            let obj = cmd.type.param() as! IDOSportModeSelectParamModel
            cancellable = Cmds.setSportModeSelect(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSportModeSort:
            let items = [
                IDOSportModeSortParamModel(index: 1, type: .sportTypeAerobics),
                IDOSportModeSortParamModel(index: 2, type: .sportTypeBMX),
                IDOSportModeSortParamModel(index: 3, type: .sportTypeGym),
                IDOSportModeSortParamModel(index: 4, type: .sportTypeHit)
            ]
            cancellable = Cmds.setSportModeSort(items: items).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setLongSit:
            let obj = cmd.type.param() as! IDOLongSitParamModel
            cancellable = Cmds.setLongSit(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setBodyPowerTurn:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setBodyPowerTurn(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setRRespiRateTurn:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setRRespiRateTurn(open: dic["open"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setV3Noise:
            let obj = cmd.type.param() as! IDOV3NoiseParamModel
            cancellable = Cmds.setV3Noise(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWeatherSunTime:
            let obj = cmd.type.param() as! IDOWeatherSunTimeParamModel
            cancellable = Cmds.setWeatherSunTime(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setShortcut:
            let obj = cmd.type.param() as! IDOShortcutParamModel
            cancellable = Cmds.setShortcut(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNoticeStatusBtPair:
            let obj = cmd.type.param() as! IDOSetNoticeStatusModel
            obj.msgAllSwitch = .on
            obj.notifySwitch = .bleOn
            obj.isOnOther = false
            cancellable = Cmds.setNoticeStatus(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNoticeStatusAllOn:
            let obj = cmd.type.param() as! IDOSetNoticeStatusModel
            obj.msgAllSwitch = .on
            obj.notifySwitch = .settingSubSwitch
            obj.isOnOther = false
            cancellable = Cmds.setNoticeStatus(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNoticeStatusAllOff:
            let obj = cmd.type.param() as! IDOSetNoticeStatusModel
            obj.msgAllSwitch = .off
            obj.notifySwitch = .settingSubSwitch
            cancellable = Cmds.setNoticeStatus(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setTemperatureSwitch:
            let obj = cmd.type.param() as! IDOTemperatureSwitchParamModel
            cancellable = Cmds.setTemperatureSwitch(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSleepPeriod:
            let obj = cmd.type.param() as! IDOSleepPeriodParamModel
            cancellable = Cmds.setSleepPeriod(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setUpHandGesture:
            let obj = cmd.type.param() as! IDOUpHandGestureParamModel
            cancellable = Cmds.setUpHandGesture(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setTakingMedicineReminder:
            let obj = cmd.type.param() as! IDOTakingMedicineReminderParamModel
            cancellable = Cmds.setTakingMedicineReminder(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSpo2Switch:
            let obj = cmd.type.param() as! IDOSpo2SwitchParamModel
            cancellable = Cmds.setSpo2Switch(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWeatherCityName:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setWeatherCityName(cityName: dic["cityName"] as! String).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setAlarm:
            let obj = cmd.type.param() as! IDOAlarmModel
            cancellable = Cmds.setAlarm(alarm: obj).send { [weak self] res in
                self?.btnCall.isEnabled = true
                if case .success(let val) = res {
                    self?.textResponse.text = "\(val?.toJsonString() ?? "")\n\n\n" + "\(printProperties(val) ?? "")"
                } else if case .failure(let err) = res {
                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
            }
            
            
            // 注意：实际场景是 先获取到设备的闹钟列表，再进行修改
            // 1 闹钟需要先获取，再全量更新
//            cancellable = Cmds.getAlarm(flag: 0).send { [weak self] res in
//                if case .success(let obj) = res {
//                    if let alarmModel = obj {
//                        if (alarmModel.items.count > 0) {
//                            let alarmItem = alarmModel.items.first
//                            alarmItem?.alarmID = 1
//                            alarmItem?.isOpen = true
//                            alarmItem?.hour = 17
//                            alarmItem?.minute = 43
//                            alarmItem?.repeats = [.sunday, .saturday, .monday]
//                            alarmItem?.status = .displayed
//                            // 2 修改
//                            self?.cancellable = Cmds.setAlarm(alarm: alarmModel).send { [weak self] res in
//                                self?.btnCall.isEnabled = true
//                                if case .success(let val) = res {
//                                    self?.textResponse.text = "\(val?.toJsonString() ?? "")\n\n\n" + "\(printProperties(val) ?? "")"
//                                } else if case .failure(let err) = res {
//                                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
//                                }
//                            }
//                        }
//                    }
//                }else if case .failure(let err) = res {
//                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
//                }
//                //self?.doPrint(res)
//            }
        case .setFitnessGuidance:
            let obj = cmd.type.param() as! IDOFitnessGuidanceParamModel
            cancellable = Cmds.setFitnessGuidance(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setDisplayMode:
            let obj = cmd.type.param() as! IDODisplayModeParamModel
            cancellable = Cmds.setDisplayMode(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setBpMeasurement:
            let obj = cmd.type.param() as! IDOBpMeasurementParamModel
            cancellable = Cmds.setBpMeasurement(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setMusicOnOff:
            let obj = cmd.type.param() as! IDOMusicOnOffParamModel
            cancellable = Cmds.setMusicOnOff(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSendRunPlan:
            let obj = cmd.type.param() as! IDORunPlanParamModel
            cancellable = Cmds.setSendRunPlan(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWeatherV3:
            let obj = cmd.type.param() as! IDOWeatherV3ParamModel
            cancellable = Cmds.setWeatherV3(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .musicControl:
            let obj = cmd.type.param() as! IDOMusicControlParamModel
            cancellable = Cmds.musicControl(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setMusicOperate:
            let obj = cmd.type.param() as! IDOMusicOpearteParamModel
            cancellable = Cmds.setMusicOperate(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .noticeMessageV3:
            let obj = cmd.type.param() as! IDONoticeMessageParamModel
            cancellable = Cmds.noticeMessageV3(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNoticeMessageState:
            let obj = cmd.type.param() as! IDONoticeMessageStateParamModel
            cancellable = Cmds.setNoticeMessageState(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setNoticeAppName:
            let obj = cmd.type.param() as! IDONoticeMesaageParamModel
            cancellable = Cmds.setNoticeAppName(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWorldTimeV3:
            let items = [
                IDOWorldTimeParamModel(id: 31,
                                       minOffset: 480,
                                       cityName: "北京",
                                       sunriseHour: 7,
                                       sunriseMin: 25,
                                       sunsetHour: 16,
                                       sunsetMin: 49,
                                       longitudeFlag: 1,
                                       longitude: 11641,
                                       latitudeFlag: 1,
                                       latitude: 3990),
                IDOWorldTimeParamModel(id: 148,
                                       minOffset: 0,
                                       cityName: "伦敦",
                                       sunriseHour: 7,
                                       sunriseMin: 57,
                                       sunsetHour: 16,
                                       sunsetMin: 49,
                                       longitudeFlag: 2,
                                       longitude: 13,
                                       latitudeFlag: 1,
                                       latitude: 5151),
                IDOWorldTimeParamModel(id: 197,
                                       minOffset: -300,
                                       cityName: "纽约",
                                       sunriseHour: 7,
                                       sunriseMin: 10,
                                       sunsetHour: 16,
                                       sunsetMin: 28,
                                       longitudeFlag: 2,
                                       longitude: 7401,
                                       latitudeFlag: 1,
                                       latitude: 4071)
            ]
            cancellable = Cmds.setWorldTimeV3(items).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSchedulerReminder:
            let obj = cmd.type.param() as! IDOSchedulerReminderParamModel
            cancellable = Cmds.setSchedulerReminder(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setBpCalControlV3:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setBpCalControlV3(operate: dic["operate"] as! Int,
                                                 filePath: dic["filePath"] as! String).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWatchFaceData:
            //let obj = cmd.type.param() as! IDOWatchFaceParamModel
            // 1. 先获取
            cancellable = Cmds.getWatchListV3().send { [weak self] res in
                // 2. 执行设置
                if case .success(let val) = res {
                    if let watchListModel = val {
                        let obj = watchListModel.items.count > 1 ? watchListModel.items[1] : watchListModel.items[0]
                        let item = IDOWatchFaceParamModel(operate: 1, fileName: obj.name, watchFileSize: obj.size)
                        self?.cancellable = Cmds.setWatchFaceData(item).send { [weak self] res in
                            self?.doPrint(res)
                        }
                    }
                } else if case .failure(let err) = res {
                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
                
            }
        case .setSyncContact:
            let obj = cmd.type.param() as! IDOSyncContactParamModel
            cancellable = Cmds.setSyncContact(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSportParamSort:
            let obj = cmd.type.param() as! IDOSportSortParamModel
            cancellable = Cmds.setSportParamSort(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSport100Sort:
            let obj = cmd.type.param() as! IDOSport100SortParamModel
            cancellable = Cmds.setSport100Sort(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setMainUISortV3:
            let obj = cmd.type.param() as! IDOMainUISortParamModel
            cancellable = Cmds.setMainUISortV3(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHistoricalMenstruation:
            let obj = cmd.type.param() as! IDOHistoricalMenstruationParamModel
            cancellable = Cmds.setHistoricalMenstruation(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setLongCityNameV3:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setLongCityNameV3(cityName: dic["cityName"] as! String).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHeartMode:
            guard let obj = cmd.type.param() else {
                print("需要配置参数")
                return
            }
            if (sdk.funcTable.setSmartHeartRate) {
                let param = obj as! IDOHeartRateModeSmartParamModel
                cancellable = Cmds.setHeartRateModeSmart(param).send { [weak self] res in
                    self?.doPrint(res)
                }
            }else if(sdk.funcTable.syncV3Hr) {
                let param = obj as! IDOHeartModeParamModel
                cancellable = Cmds.setHeartMode(param).send { [weak self] res in
                    self?.doPrint(res)
                }
            }else if(sdk.funcTable.syncHeartRateMonitor) {
                let param = obj as! IDOHeartRateModeParamModel
                cancellable = Cmds.setHeartRateMode(param).send { [weak self] res in
                    self?.doPrint(res)
                }
            }
        case .setVoiceReplyText:
            let obj = cmd.type.param() as! IDOVoiceReplyParamModel
            cancellable = Cmds.setVoiceReplyText(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWatchDialSort:
            let obj = cmd.type.param() as! IDOWatchDialSortParamModel
            cancellable = Cmds.setWatchDialSort(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWalkRemindTimes:
            let obj = cmd.type.param() as! IDOWalkRemindTimesParamModel
            cancellable = Cmds.setWalkRemindTimes(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWallpaperDialReply:
            let obj = cmd.type.param() as! IDOWallpaperDialReplyV3ParamModel
            cancellable = Cmds.setWallpaperDialReply(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setDateTime:
            let obj = cmd.type.param() as! IDODateTimeParamModel
            cancellable = Cmds.setDateTime(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setUserInfo:
            let obj = cmd.type.param() as! IDOUserInfoPramModel
            cancellable = Cmds.setUserInfo(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .findDeviceStart:
            cancellable = Cmds.findDeviceStart().send { [weak self] res in
                self?.doPrint(res)
            }
        case .findDeviceStop:
            cancellable = Cmds.findDeviceStop().send { [weak self] res in
                self?.doPrint(res)
            }
        case .photoStart:
            cancellable = Cmds.photoStart().send { [weak self] res in
                self?.doPrint(res)
            }
        case .photoStop:
            cancellable = Cmds.photoStop().send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHand:
            let dic = (cmd.type.param() as! OtherParamModel).dic!
            cancellable = Cmds.setHand(isRightHand: dic["isRightHand"] as! Bool).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setScreenBrightness:
            let obj = cmd.type.param() as! IDOScreenBrightnessModel
            cancellable = Cmds.setScreenBrightness(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .otaStart:
            cancellable = Cmds.otaStart().send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHeartRateInterval:
            let obj = cmd.type.param() as! IDOHeartRateIntervalModel
            cancellable = Cmds.setHeartRateInterval(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setCalorieDistanceGoal:
            let obj = cmd.type.param() as! IDOMainSportGoalModel
            cancellable = Cmds.setCalorieDistanceGoal(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setWalkRemind:
            let obj = cmd.type.param() as! IDOWalkRemindModel
            cancellable = Cmds.setWalkRemind(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setMenstruation:
            let obj = cmd.type.param() as! IDOMenstruationModel
            cancellable = Cmds.setMenstruation(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .factoryReset:
            cancellable = Cmds.factoryReset().send { [weak self] res in
                self?.doPrint(res)
            }
        case .reboot:
            cancellable = Cmds.reboot().send { [weak self] res in
                self?.doPrint(res)
            }
        case .setStressSwitch:
            let obj = cmd.type.param() as! IDOStressSwitchParamModel
            cancellable = Cmds.setStressSwitch(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setHotStartParam:
            let obj = cmd.type.param() as! IDOGpsHotStartParamModel
            cancellable = Cmds.setHotStartParam(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setDefaultMsgList:
            let obj = cmd.type.param() as! IDODefaultMessageConfigParamModel
            cancellable = Cmds.setDefaultMsgList(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setAppletControl:
            // 步骤1：先获取小程序
            Cmds.setAppleControl(IDOAppletControlModel(operate: 3)).send { [weak self] res in
                guard let self = self else { return }
                if case .success(let val) = res {
                    if let appletItem = val?.infoItem?.first {
                        // 步骤2：启动小程序
                        self.cancellable = Cmds.setAppleControl(IDOAppletControlModel(operate: 1, appName: appletItem.appName)).send { [weak self] res in
                            self?.doPrint(res)
                        }
                    }else {
                        textResponse.text = "Mini Program Not Found"
                    }
                    //textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
                } else if case .failure(let err) = res {
                    textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
            }
        case .setSportsTypeV3:
            // 步骤1: 获取运动列表
            Cmds.getSportTypeV3().send { [weak self] res in
                guard let self = self else { return }
                if case .success(let val) = res {
                    if let item = val {
                        item.sportTypes.shuffle() // 随机排序
                        var items = [IDOSportModeSortParamModel]()
                        var i = 1
                        item.sportTypes.forEach {
                            items.append(IDOSportModeSortParamModel(index: i, type: $0))
                            i += 1
                        }
                        self.cancellable = Cmds.setSportSortV3(IDOSportParamModel(items: items)).send { [weak self] res in
                            self?.doPrint(res)
                        }
                    }else {
                        
                    }
                    //textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
                } else if case .failure(let err) = res {
                    textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
            }
        case .setDuringExercise:
            let obj = cmd.type.param() as! IDOSettingsDuringExerciseModel
            Cmds.setDuringExercise(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSimpleHeartRateZone:
            let obj = cmd.type.param() as! IDOSimpleHeartRateZoneSettingModel
            Cmds.setSimpleHeartRateZone(obj).send { [weak self] res in
                self?.doPrint(res)
            }
        case .setSportingRemindSetting:
            let obj = cmd.type.param() as! IDOSportingRemindSettingModel
            Cmds.setSportingRemindSetting([obj]).send { [weak self] res in
                self?.doPrint(res)
            }
        }
    }
        
    private func doPrint<T>(_ res: Result<T?, CmdError>) {
        btnCall.isEnabled = true
        if case .success(let val) = res {
            if val == nil {
                textResponse.text = "Successful"
            } else if T.self is String.Type {
                textResponse.text = val as? String
            } else if T.self is IDOBaseModel.Type {
                let obj = val as? IDOBaseModel
                textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
            }
        } else if case .failure(let err) = res {
            textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
        }
    }
}
