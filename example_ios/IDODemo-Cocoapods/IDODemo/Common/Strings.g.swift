// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Bluetooth is off
  internal static let bleOff = L10n.tr("Localizable", "ble_off", fallback: "Bluetooth is off")
  /// Incoming call reminder
  internal static let callRemind = L10n.tr("Localizable", "call_remind", fallback: "Incoming call reminder")
  /// Cancel
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Cancel")
  /// Start Epo Upgrade
  internal static let epoStart = L10n.tr("Localizable", "epo_start", fallback: "Start Epo Upgrade")
  /// Stop Epo Upgrade
  internal static let epoStop = L10n.tr("Localizable", "epo_stop", fallback: "Stop Epo Upgrade")
  /// The app is exiting, do you want to continue?
  internal static let exitApp = L10n.tr("Localizable", "exit_app", fallback: "The app is exiting, do you want to continue?")
  /// Factory reset
  internal static let factoryReset = L10n.tr("Localizable", "factoryReset", fallback: "Factory reset")
  /// Fast config failed, need to reconnect
  internal static let fastconfigFail = L10n.tr("Localizable", "fastconfig_fail", fallback: "Fast config failed, need to reconnect")
  /// fetch failed
  internal static let fetchFail = L10n.tr("Localizable", "fetch_fail", fallback: "fetch failed")
  /// Control find device start
  internal static let findDeviceStart = L10n.tr("Localizable", "findDeviceStart", fallback: "Control find device start")
  /// Control find device stop
  internal static let findDeviceStop = L10n.tr("Localizable", "findDeviceStop", fallback: "Control find device stop")
  /// Get event number for activity switch
  internal static let getActivitySwitch = L10n.tr("Localizable", "getActivitySwitch", fallback: "Get event number for activity switch")
  /// App gets the alarm of ble
  internal static let getAlarm = L10n.tr("Localizable", "getAlarm", fallback: "App gets the alarm of ble")
  /// Get firmware algorithm file information (ACC/GPS)
  internal static let getAlgFileInfo = L10n.tr("Localizable", "getAlgFileInfo", fallback: "Get firmware algorithm file information (ACC/GPS)")
  /// Get event number for all health monitoring switches
  internal static let getAllHealthSwitchState = L10n.tr("Localizable", "getAllHealthSwitchState", fallback: "Get event number for all health monitoring switches")
  /// Operation of applet information (obtain, start, delete)
  internal static let getAppletControl = L10n.tr("Localizable", "getAppletControl", fallback: "Operation of applet information (obtain, start, delete)")
  /// Get battery information event number
  internal static let getBatteryInfo = L10n.tr("Localizable", "getBatteryInfo", fallback: "Get battery information event number")
  /// Getting firmware local beep file information for V3
  internal static let getBleBeep = L10n.tr("Localizable", "getBleBeep", fallback: "Getting firmware local beep file information for V3")
  /// Get Firmware Song Names and Folders
  internal static let getBleMusicInfo = L10n.tr("Localizable", "getBleMusicInfo", fallback: "Get Firmware Song Names and Folders")
  /// Get blood pressure algorithm version information event number
  internal static let getBpAlgVersion = L10n.tr("Localizable", "getBpAlgVersion", fallback: "Get blood pressure algorithm version information event number")
  /// Get BT connected phone model
  internal static let getBtConnectPhoneModel = L10n.tr("Localizable", "getBtConnectPhoneModel", fallback: "Get BT connected phone model")
  /// Get bt bluetooth name
  internal static let getBtName = L10n.tr("Localizable", "getBtName", fallback: "Get bt bluetooth name")
  /// Query BT pairing switch, connection, A2DP connection, HFP connection status (Only Supported on devices with BT Bluetooth) event number
  internal static let getBtNotice = L10n.tr("Localizable", "getBtNotice", fallback: "Query BT pairing switch, connection, A2DP connection, HFP connection status (Only Supported on devices with BT Bluetooth) event number")
  /// Get firmware local contact file modification time event number
  internal static let getContactReviseTime = L10n.tr("Localizable", "getContactReviseTime", fallback: "Get firmware local contact file modification time event number")
  /// Get device information
  internal static let getDeviceInfo = L10n.tr("Localizable", "getDeviceInfo", fallback: "Get device information")
  /// Get device log state event number
  internal static let getDeviceLogState = L10n.tr("Localizable", "getDeviceLogState", fallback: "Get device log state event number")
  /// Get Download Language Support
  internal static let getDownloadLanguage = L10n.tr("Localizable", "getDownloadLanguage", fallback: "Get Download Language Support")
  /// Get error record
  internal static let getErrorRecord = L10n.tr("Localizable", "getErrorRecord", fallback: "Get error record")
  /// Get Font Library Information event number
  internal static let getFlashBinInfo = L10n.tr("Localizable", "getFlashBinInfo", fallback: "Get Font Library Information event number")
  /// Get function table information
  internal static let getFunctionTable = L10n.tr("Localizable", "getFunctionTable", fallback: "Get function table information")
  /// Get GPS Information event number
  internal static let getGpsInfo = L10n.tr("Localizable", "getGpsInfo", fallback: "Get GPS Information event number")
  /// Get GPS Status event number
  internal static let getGpsStatus = L10n.tr("Localizable", "getGpsStatus", fallback: "Get GPS Status event number")
  /// Get heart rate mode
  internal static let getHeartMode = L10n.tr("Localizable", "getHeartMode", fallback: "Get heart rate mode")
  /// Get Language Library List
  internal static let getLanguageLibrary = L10n.tr("Localizable", "getLanguageLibrary", fallback: "Get Language Library List")
  /// Get Set Calorie/Distance/Mid-High Sport Time Goal event number
  internal static let getMainSportGoal = L10n.tr("Localizable", "getMainSportGoal", fallback: "Get Set Calorie/Distance/Mid-High Sport Time Goal event number")
  /// Get Supported Menu List
  internal static let getMenuList = L10n.tr("Localizable", "getMenuList", fallback: "Get Supported Menu List")
  /// Get MTU Information event number
  internal static let getMtuInfo = L10n.tr("Localizable", "getMtuInfo", fallback: "Get MTU Information event number")
  /// Get Do Not Disturb mode status event number
  internal static let getNotDisturbStatus = L10n.tr("Localizable", "getNotDisturbStatus", fallback: "Get Do Not Disturb mode status event number")
  /// Get notification center status event number
  internal static let getNoticeStatus = L10n.tr("Localizable", "getNoticeStatus", fallback: "Get notification center status event number")
  /// Get schedule reminder
  internal static let getScheduleReminder = L10n.tr("Localizable", "getScheduleReminder", fallback: "Get schedule reminder")
  /// Get screen brightness event number
  internal static let getScreenBrightness = L10n.tr("Localizable", "getScreenBrightness", fallback: "Get screen brightness event number")
  /// Get sports list
  internal static let getSportsTypeV3 = L10n.tr("Localizable", "getSportsTypeV3", fallback: "Get sports list")
  /// Get daily step goal event number
  internal static let getStepGoal = L10n.tr("Localizable", "getStepGoal", fallback: "Get daily step goal event number")
  /// Get maximum number of settings supported by firmware event number
  internal static let getSupportMaxSetItemsNum = L10n.tr("Localizable", "getSupportMaxSetItemsNum", fallback: "Get maximum number of settings supported by firmware event number")
  /// Get non-deletable menu list in firmware event number
  internal static let getUnerasableMeunList = L10n.tr("Localizable", "getUnerasableMeunList", fallback: "Get non-deletable menu list in firmware event number")
  /// Get Unit event number
  internal static let getUnit = L10n.tr("Localizable", "getUnit", fallback: "Get Unit event number")
  /// Get unread app reminder switch event number
  internal static let getUnreadAppReminder = L10n.tr("Localizable", "getUnreadAppReminder", fallback: "Get unread app reminder switch event number")
  /// Get device update status event number
  internal static let getUpdateStatus = L10n.tr("Localizable", "getUpdateStatus", fallback: "Get device update status event number")
  /// Get wrist up gesture data event number
  internal static let getUpHandGesture = L10n.tr("Localizable", "getUpHandGesture", fallback: "Get wrist up gesture data event number")
  /// Get walk reminder event number
  internal static let getWalkRemind = L10n.tr("Localizable", "getWalkRemind", fallback: "Get walk reminder event number")
  /// Get Screen Information
  internal static let getWatchDialInfo = L10n.tr("Localizable", "getWatchDialInfo", fallback: "Get Screen Information")
  /// Getting watch face list for V2
  internal static let getWatchListV2 = L10n.tr("Localizable", "getWatchListV2", fallback: "Getting watch face list for V2")
  /// Getting watch face list for V3 (New)
  internal static let getWatchListV3 = L10n.tr("Localizable", "getWatchListV3", fallback: "Getting watch face list for V3 (New)")
  /// Main switch
  internal static let mainSwitch = L10n.tr("Localizable", "main_switch", fallback: "Main switch")
  /// Music control event number
  internal static let musicControl = L10n.tr("Localizable", "musicControl", fallback: "Music control event number")
  /// Pairing is abnormal, you need to manually ignore the device (Settings-Bluetooth-Find Device-"!")-Ignore this device
  internal static let needIgnorePair = L10n.tr("Localizable", "need_ignore_pair", fallback: "Pairing is abnormal, you need to manually ignore the device (Settings-Bluetooth-Find Device-\"!\")-Ignore this device")
  /// This device does not support
  internal static let nonsupport = L10n.tr("Localizable", "nonsupport", fallback: "This device does not support")
  /// Notification message reminder event number
  internal static let noticeMessageV3 = L10n.tr("Localizable", "noticeMessageV3", fallback: "Notification message reminder event number")
  /// allowed
  internal static let notifyAllowed = L10n.tr("Localizable", "notify_allowed", fallback: "allowed")
  /// disabled
  internal static let notifyDisabled = L10n.tr("Localizable", "notify_disabled", fallback: "disabled")
  /// Notify settings
  internal static let notifySettings = L10n.tr("Localizable", "notify_settings", fallback: "Notify settings")
  /// silent
  internal static let notifySilent = L10n.tr("Localizable", "notify_silent", fallback: "silent")
  /// On fast config...
  internal static let onFastconfig = L10n.tr("Localizable", "on_fastconfig", fallback: "On fast config...")
  /// Start taking photos (app -> ble)
  internal static let photoStart = L10n.tr("Localizable", "photoStart", fallback: "Start taking photos (app -> ble)")
  /// Stop taking photos (app -> ble)
  internal static let photoStop = L10n.tr("Localizable", "photoStop", fallback: "Stop taking photos (app -> ble)")
  /// Reboot device
  internal static let reboot = L10n.tr("Localizable", "reboot", fallback: "Reboot device")
  /// Refresh
  internal static let refresh = L10n.tr("Localizable", "refresh", fallback: "Refresh")
  /// Request firmware algorithm file information (ACC/GPS)
  internal static let requestAlgFile = L10n.tr("Localizable", "requestAlgFile", fallback: "Request firmware algorithm file information (ACC/GPS)")
  /// Getting Alarms for V3APP Devices
  internal static let setAlarm = L10n.tr("Localizable", "setAlarm", fallback: "Getting Alarms for V3APP Devices")
  /// Operation of applet information (obtain, start, delete)
  internal static let setAppletControl = L10n.tr("Localizable", "setAppletControl", fallback: "Operation of applet information (obtain, start, delete)")
  /// Set phone volume for device event number
  internal static let setBleVoice = L10n.tr("Localizable", "setBleVoice", fallback: "Set phone volume for device event number")
  /// Set body power switch event number
  internal static let setBodyPowerTurn = L10n.tr("Localizable", "setBodyPowerTurn", fallback: "Set body power switch event number")
  /// Set calorie and distance goal (Set daily three rings)
  internal static let setCalorieDistanceGoal = L10n.tr("Localizable", "setCalorieDistanceGoal", fallback: "Set calorie and distance goal (Set daily three rings)")
  /// Set Time
  internal static let setDateTime = L10n.tr("Localizable", "setDateTime", fallback: "Set Time")
  /// Set the default messaging app list
  internal static let setDefaultMsgList = L10n.tr("Localizable", "setDefaultMsgList", fallback: "Set the default messaging app list")
  /// Display mode event number
  internal static let setDisplayMode = L10n.tr("Localizable", "setDisplayMode", fallback: "Display mode event number")
  /// Set Find Phone
  internal static let setFindPhone = L10n.tr("Localizable", "setFindPhone", fallback: "Set Find Phone")
  /// Fitness Guidance Event
  internal static let setFitnessGuidance = L10n.tr("Localizable", "setFitnessGuidance", fallback: "Fitness Guidance Event")
  /// Set left or right hand
  internal static let setHand = L10n.tr("Localizable", "setHand", fallback: "Set left or right hand")
  /// Set heart rate mode
  internal static let setHeartMode = L10n.tr("Localizable", "setHeartMode", fallback: "Set heart rate mode")
  /// Set heart rate interval
  internal static let setHeartRateInterval = L10n.tr("Localizable", "setHeartRateInterval", fallback: "Set heart rate interval")
  /// Menstrual historical data delivery event number
  internal static let setHistoricalMenstruation = L10n.tr("Localizable", "setHistoricalMenstruation", fallback: "Menstrual historical data delivery event number")
  /// Set hot start parameters
  internal static let setHotStartParam = L10n.tr("Localizable", "setHotStartParam", fallback: "Set hot start parameters")
  /// V3 Setting the Name of a Sports City event number
  internal static let setLongCityNameV3 = L10n.tr("Localizable", "setLongCityNameV3", fallback: "V3 Setting the Name of a Sports City event number")
  /// Set Lost Find Event
  internal static let setLostFind = L10n.tr("Localizable", "setLostFind", fallback: "Set Lost Find Event")
  /// Set menstruation
  internal static let setMenstruation = L10n.tr("Localizable", "setMenstruation", fallback: "Set menstruation")
  /// Set Music On/Off Event
  internal static let setMusicOnOff = L10n.tr("Localizable", "setMusicOnOff", fallback: "Set Music On/Off Event")
  /// V3 dynamic notification message event number
  internal static let setNoticeAppName = L10n.tr("Localizable", "setNoticeAppName", fallback: "V3 dynamic notification message event number")
  /// Setting Notification Status for a Single App
  internal static let setNoticeMessageState = L10n.tr("Localizable", "setNoticeMessageState", fallback: "Setting Notification Status for a Single App")
  /// Set Notification Center Event (Fully closed)
  internal static let setNoticeStatusAllOff = L10n.tr("Localizable", "setNoticeStatusAllOff", fallback: "Set Notification Center Event (Fully closed)")
  /// Set Notification Center Event (Fully open)
  internal static let setNoticeStatusAllOn = L10n.tr("Localizable", "setNoticeStatusAllOn", fallback: "Set Notification Center Event (Fully open)")
  /// Notification app status setting event
  internal static let setNotificationStatus = L10n.tr("Localizable", "setNotificationStatus", fallback: "Notification app status setting event")
  /// Set the one-touch calling event number
  internal static let setOnekeySOS = L10n.tr("Localizable", "setOnekeySOS", fallback: "Set the one-touch calling event number")
  /// Stop Find Phone
  internal static let setOverFindPhone = L10n.tr("Localizable", "setOverFindPhone", fallback: "Stop Find Phone")
  /// Respiration rate switch setting event
  internal static let setRRespiRateTurn = L10n.tr("Localizable", "setRRespiRateTurn", fallback: "Respiration rate switch setting event")
  /// Schedule Reminder
  internal static let setSchedulerReminder = L10n.tr("Localizable", "setSchedulerReminder", fallback: "Schedule Reminder")
  /// Scientific sleep switch setting event
  internal static let setScientificSleepSwitch = L10n.tr("Localizable", "setScientificSleepSwitch", fallback: "Scientific sleep switch setting event")
  /// Set screen brightness
  internal static let setScreenBrightness = L10n.tr("Localizable", "setScreenBrightness", fallback: "Set screen brightness")
  /// App issued running plan (exercise plan) event number
  internal static let setSendRunPlan = L10n.tr("Localizable", "setSendRunPlan", fallback: "App issued running plan (exercise plan) event number")
  /// Set shortcut
  internal static let setShortcut = L10n.tr("Localizable", "setShortcut", fallback: "Set shortcut")
  /// Set sleep period event
  internal static let setSleepPeriod = L10n.tr("Localizable", "setSleepPeriod", fallback: "Set sleep period event")
  /// Set SpO2 switch event
  internal static let setSpo2Switch = L10n.tr("Localizable", "setSpo2Switch", fallback: "Set SpO2 switch event")
  /// Set and Query 100 Sports Sorting
  internal static let setSport100Sort = L10n.tr("Localizable", "setSport100Sort", fallback: "Set and Query 100 Sports Sorting")
  /// Set exercise goal event
  internal static let setSportGoal = L10n.tr("Localizable", "setSportGoal", fallback: "Set exercise goal event")
  /// Set sport mode select event number
  internal static let setSportModeSelect = L10n.tr("Localizable", "setSportModeSelect", fallback: "Set sport mode select event number")
  /// Set Sport Mode Sorting
  internal static let setSportModeSort = L10n.tr("Localizable", "setSportModeSort", fallback: "Set Sport Mode Sorting")
  /// Modify the sports list (sort/delete/add)
  internal static let setSportsTypeV3 = L10n.tr("Localizable", "setSportsTypeV3", fallback: "Modify the sports list (sort/delete/add)")
  /// Set stress switch
  internal static let setStressSwitch = L10n.tr("Localizable", "setStressSwitch", fallback: "Set stress switch")
  /// Synchronization Protocol Bluetooth Call Common Contacts
  internal static let setSyncContact = L10n.tr("Localizable", "setSyncContact", fallback: "Synchronization Protocol Bluetooth Call Common Contacts")
  /// Set Night-time Temperature Switch Event Code
  internal static let setTemperatureSwitch = L10n.tr("Localizable", "setTemperatureSwitch", fallback: "Set Night-time Temperature Switch Event Code")
  /// Set Unit event number
  internal static let setUnit = L10n.tr("Localizable", "setUnit", fallback: "Set Unit event number")
  /// Unread message reminder switch event number
  internal static let setUnreadAppReminder = L10n.tr("Localizable", "setUnreadAppReminder", fallback: "Unread message reminder switch event number")
  /// Raise-to-wake gesture event number
  internal static let setUpHandGesture = L10n.tr("Localizable", "setUpHandGesture", fallback: "Raise-to-wake gesture event number")
  /// Set user information
  internal static let setUserInfo = L10n.tr("Localizable", "setUserInfo", fallback: "Set user information")
  /// Set Environmental Noise Volume On/Off and Threshold Event
  internal static let setV3Noise = L10n.tr("Localizable", "setV3Noise", fallback: "Set Environmental Noise Volume On/Off and Threshold Event")
  /// Set walk reminder
  internal static let setWalkRemind = L10n.tr("Localizable", "setWalkRemind", fallback: "Set walk reminder")
  /// Set watch face event number
  internal static let setWatchDial = L10n.tr("Localizable", "setWatchDial", fallback: "Set watch face event number")
  /// Set watch dial sort event
  internal static let setWatchDialSort = L10n.tr("Localizable", "setWatchDialSort", fallback: "Set watch dial sort event")
  /// Set Watch Face
  internal static let setWatchFaceData = L10n.tr("Localizable", "setWatchFaceData", fallback: "Set Watch Face")
  /// Set weather city name event number
  internal static let setWeatherCityName = L10n.tr("Localizable", "setWeatherCityName", fallback: "Set weather city name event number")
  /// Set sunrise and sunset time event number
  internal static let setWeatherSunTime = L10n.tr("Localizable", "setWeatherSunTime", fallback: "Set sunrise and sunset time event number")
  /// Set weather switch event number
  internal static let setWeatherSwitch = L10n.tr("Localizable", "setWeatherSwitch", fallback: "Set weather switch event number")
  /// Send the v3 weather protocol event number under v3
  internal static let setWeatherV3 = L10n.tr("Localizable", "setWeatherV3", fallback: "Send the v3 weather protocol event number under v3")
  /// v3 set v3 world time
  internal static let setWorldTimeV3 = L10n.tr("Localizable", "setWorldTimeV3", fallback: "v3 set v3 world time")
  /// Note: For iOS 13 and above, you need to turn on [Share System Notifications] in the phone system.
  internal static let systemNotifyTips = L10n.tr("Localizable", "system_notify_tips", fallback: "Note: For iOS 13 and above, you need to turn on [Share System Notifications] in the phone system.")
  internal static let setEditSportScreenV3 = L10n.tr("Localizable", "setEditSportScreenV3", fallback: "v3 edit sport screene")
    
    
    
    
    

}

extension String {
    public var i18n: String {
        L10n.tr("Localizable", self, fallback: "")
    }
    
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    public static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
