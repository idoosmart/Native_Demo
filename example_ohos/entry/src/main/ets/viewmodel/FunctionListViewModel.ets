/**
 * Data model for the Get Function and Set Function list pages.
 * This separates the data from the UI components.
 */
import {
  sdk,
  IDOBleDeviceModel,
  IDOBindStatus,
  IDOBleDelegate,
  IDOBluetoothStateModel,
  IDODeviceStateModel,
  IDOReceiveData,
  IDODeviceStateType,
  ApiEvtType,
  Cmds,
  IDONoticeMessageParamModel,
  IFailureResult,
  CmdError,
  IDOConnectErrorType
} from "protocol_channel";
import BleManager, { AppDelegate } from "../bluetooth/BleManager";
import { Tools } from "../utils/Tools";
import { common } from "@kit.AbilityKit";
import { BluetoothViewModel } from "./BluetoothViewModel";
import { IDOOtaDeviceModel } from "protocol_channel";

/**
 * Defines the structure for a single item in the function lists.
 * Each item has a technical name and a human-readable description.
 *
 * FIX: The 'description' property now holds a Resource object, not a hardcoded string.
 */
export class FunctionInfo {
  name: string;
  description: Resource | string; // <--- The type is now Resource
  evtType: ApiEvtType;

  constructor(evtType: ApiEvtType, name: string, description: Resource | string) { // <--- The constructor now accepts a Resource
    this.name = name;
    this.description = description;
    this.evtType = evtType;
  }
}

/**
 * Provides the list of items for the "Get Function" page.
 * Each description now uses a resource reference ($r) for i18n.
 */
export function getFunctionList(): FunctionInfo[] {
  const funcList: FunctionInfo[] = [];
  funcList.push(new FunctionInfo(ApiEvtType.GetSnInfo, 'getSn', $r('app.string.get_func_desc_getActivitySwitch')));

  funcList.push(new FunctionInfo(ApiEvtType.GetDeviceInfo, 'getDeviceInfo',
    $r('app.string.get_func_desc_getDeviceInfo')));

  funcList.push(new FunctionInfo(ApiEvtType.GetFuncTable, 'getFunctionTable',
    $r('app.string.get_func_desc_getFunctionTable')));

  if (sdk.funcTable.getNewWatchList) {
    funcList.push(new FunctionInfo(ApiEvtType.GetWatchListV3, 'getWatchListV3', $r('app.string.getWatchListV3')));
  } else {
    funcList.push(new FunctionInfo(ApiEvtType.GetWatchFaceList, 'getWatchListV2', $r('app.string.getWatchListV2')));
  }

  if (sdk.funcTable.getBatteryInfo) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBatteryInfo, 'getBatteryInfo',
      $r('app.string.get_func_desc_getBatteryInfo')));
  }

  if (sdk.funcTable.getDeviceLogState) {
    funcList.push(new FunctionInfo(ApiEvtType.GetDeviceLogState, 'getDeviceLogState',
      $r('app.string.get_func_desc_getDeviceLogState')));
  }

  if (sdk.funcTable.getMenuList) {
    funcList.push(new FunctionInfo(ApiEvtType.GetMenuList, 'getMenuList', $r('app.string.getMenuList')))
  }

  if (sdk.funcTable.reminderAncs) {
    funcList.push(new FunctionInfo(ApiEvtType.GetNoticeStatus, 'getNoticeStatus', $r('app.string.getNoticeStatus')));
  }

  if (sdk.funcTable.syncV3SyncAlarm) {
    funcList.push(new FunctionInfo(ApiEvtType.GetAlarmV3, 'getAlarm', $r('app.string.get_func_desc_getAlarm')));
  }

  if (sdk.funcTable.reminderGetAllContact) {
    funcList.push(new FunctionInfo(ApiEvtType.GetContactReviseTime, 'getContactReviseTime',
      $r('app.string.get_func_desc_getContactReviseTime')));
  }

  if (sdk.funcTable.getWalkReminderV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetWalkRemind, 'getWalkRemind', $r('app.string.getWalkRemind')));
  }

  if (sdk.funcTable.getSetMaxItemsNum) {
    funcList.push(new FunctionInfo(ApiEvtType.GetSupportMaxSetItemsNum, 'getSupportMaxSetItemsNum',
      $r('app.string.getSupportMaxSetItemsNum')));
  }

  if (sdk.funcTable.getScreenBrightnessMain9) {
    funcList.push(new FunctionInfo(ApiEvtType.GetScreenBrightness, 'getScreenBrightness',
      $r('app.string.getScreenBrightness')));
  }

  if (sdk.funcTable.getSupportGetMainSportGoalV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetMainSportGoal, 'getMainSportGoal', $r('app.string.getMainSportGoal')));
  }

  if (sdk.funcTable.getDoNotDisturbMain3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetNotDisturbStatus, 'getNotDisturbStatus',
      $r('app.string.getNotDisturbStatus')));
  }

  if (sdk.funcTable.getUpHandGestureEx) {
    funcList.push(new FunctionInfo(ApiEvtType.GetUpHandGesture, 'getUpHandGesture', $r('app.string.getUpHandGesture')));
  }

  if (sdk.funcTable.getBleAndBtVersion) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBtNotice, 'getBtNotice', $r('app.string.get_func_desc_getBtNotice')));
  }

  if (sdk.funcTable.getFlashLog) {
    funcList.push(new FunctionInfo(ApiEvtType.GetFlashBinInfo, 'getFlashBinInfo', $r('app.string.getFlashBinInfo')));
    funcList.push(new FunctionInfo(ApiEvtType.GetErrorRecord, 'getErrorRecord', $r('app.string.getErrorRecord')));
  }

  if (sdk.funcTable.getActivitySwitch) {
    funcList.push(new FunctionInfo(ApiEvtType.GetActivitySwitch, 'getActivitySwitch',
      $r('app.string.get_func_desc_getActivitySwitch')));
  }

  if (sdk.funcTable.getBtAddrV2) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBtName, 'getBtName', $r('app.string.get_func_desc_getBtName')));
  }

  if (sdk.funcTable.getMtu) {
    funcList.push(new FunctionInfo(ApiEvtType.GetMtuInfo, 'getMtuInfo', $r('app.string.getMtuInfo')));
  }

  if (sdk.funcTable.getHealthSwitchStateSupportV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetAllHealthSwitchState, 'getAllHealthSwitchState',
      $r('app.string.get_func_desc_getAllHealthSwitchState')));
  }

  if (sdk.funcTable.getSupportUpdateGps) {
    funcList.push(new FunctionInfo(ApiEvtType.GetGpsInfo, 'getGpsInfo', $r('app.string.getGpsInfo')));
    funcList.push(new FunctionInfo(ApiEvtType.GetGpsStatus, 'getGpsStatus', $r('app.string.getGpsStatus')));
  }

  if (sdk.funcTable.getDeletableMenuListV2) {
    funcList.push(new FunctionInfo(ApiEvtType.GetUnerasableMeunList, 'getUnerasableMeunList',
      $r('app.string.getUnerasableMeunList')));
  }

  if (sdk.funcTable.setSupportV3Bp) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBpAlgVersion, 'getBpAlgVersion', $r('app.string.getBpAlgVersion')));
  }

  if (sdk.funcTable.getDeviceUpdateState) {
    funcList.push(new FunctionInfo(ApiEvtType.GetUpdateStatus, 'getUpdateStatus', $r('app.string.getUpdateStatus')));
  }

  if (sdk.funcTable.getDownloadLanguage) {
    funcList.push(new FunctionInfo(ApiEvtType.GetDownLanguage, 'getDownloadLanguage',
      $r('app.string.getDownloadLanguage')));
  }

  if (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBleMusicInfo, 'getBleMusicInfo', $r('app.string.getBleMusicInfo')));
  }

  if (sdk.funcTable.getLangLibraryV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetLanguageLibraryDataV3, 'getLanguageLibrary',
      $r('app.string.getLanguageLibrary')));
  }

  if (sdk.funcTable.getSupportGetBleBeepV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBleBeepV3, 'getBleBeep', $r('app.string.getBleBeep')));
  }

  if (sdk.funcTable.getStepDataTypeV2) {
    funcList.push(new FunctionInfo(ApiEvtType.GetStepGoal, 'getStepGoal', $r('app.string.getStepGoal')));
  }

  if (sdk.funcTable.getSupportGetV3DeviceBtConnectPhoneModel) {
    funcList.push(new FunctionInfo(ApiEvtType.GetBtConnectPhoneModel, 'getBtConnectPhoneModel',
      $r('app.string.getBtConnectPhoneModel')));
  }

  if (sdk.funcTable.setScheduleReminder) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSchedulerReminderV3, 'getScheduleReminder',
      $r('app.string.getScheduleReminder')));
  }

  if (sdk.funcTable.getSupportGetUnit) {
    funcList.push(new FunctionInfo(ApiEvtType.GetUnit, 'getUnit', $r('app.string.getUnit')));
  }

  if (sdk.funcTable.setSupportControlMiniProgram) {
    funcList.push(new FunctionInfo(ApiEvtType.SetAppletControl, 'getAppletControl', $r('app.string.getAppletControl')));
  }

  // if (sdk.funcTable.getSupportDeviceOperateAlgFile) {
  //   funcList.push(new FunctionInfo(ApiEvtType.GetAlgFile, 'getAlgFileInfo', $r('app.string.getAlgFileInfo')));
  // }

  if (sdk.funcTable.getSportsTypeV3) {
    funcList.push(new FunctionInfo(ApiEvtType.GetSportTypeV3, 'getSportsTypeV3', $r('app.string.getSportsTypeV3')));
  }

  // NOTE:
  // 因为demo要适配所有设备，此处示例适配多种情况。
  // 当只适配一台设备时，只需处理以下一种即可（根据功能表判断设备使用哪种）。
  if (sdk.funcTable.setSmartHeartRate) {
    if (sdk.funcTable.getSupportGetSmartHeartRate) {
      funcList.push(new FunctionInfo(ApiEvtType.GetHeartRateMode, 'getHeartMode', $r('app.string.getHeartMode')));
    } else {
      // 该设备不支持获取心率模式，需要app自行记录
    }
  } else if (sdk.funcTable.syncV3Hr) {
    funcList.push(new FunctionInfo(ApiEvtType.GetHeartRateMode, 'getHeartMode', $r('app.string.getHeartMode')));
  } else if (sdk.funcTable.getHeartRateModeV2) {
    funcList.push(new FunctionInfo(ApiEvtType.GetHeartRateMode, 'getHeartMode', $r('app.string.getHeartMode')));
  }

  if (sdk.funcTable.getLeftRightHandWearSettings) {
    funcList.push(new FunctionInfo(ApiEvtType.GetLeftRightWearSettings, 'getLeftRightWearSettings',
      'getLeftRightWearSettings'));
  }

  if (sdk.funcTable.supportSimpleHrZoneSetting) {
    funcList.push(new FunctionInfo(ApiEvtType.GetSimpleHeartRateZone, 'getSimpleHeartRateZone',
      'getSimpleHeartRateZone'));
  }

  // if (sdk.funcTable.supportSportingRemindSetting) {
  //   funcList.push(new FunctionInfo(ApiEvtType.SetSportingRemindSetting, 'getSportingRemindSetting',
  //     'getSportingRemindSetting'));
  // }

  if (sdk.funcTable.supportSettingsDuringExercise) {
    funcList.push(new FunctionInfo(ApiEvtType.GetSettingsDuringExercise, 'getSettingsDuringExercise',
      'getSettingsDuringExercise'));
  }

  funcList.sort((a, b) => a.name.localeCompare(b.name));

  return funcList;
}

/**
 * Provides the list of items for the "Set Function" page.
 * Each description now uses a resource reference ($r) for i18n.
 */
export function setFunctionList(): FunctionInfo[] {
  const funcList: FunctionInfo[] = [];
  // --- 无需功能表判断，总是显示的函数 ---
  funcList.push(new FunctionInfo(ApiEvtType.FactoryReset, 'factoryReset', $r('app.string.factoryReset')));
  funcList.push(new FunctionInfo(ApiEvtType.PhotoStart, 'photoStart', $r('app.string.photoStart')));
  funcList.push(new FunctionInfo(ApiEvtType.PhotoStop, 'photoStop', $r('app.string.photoStop')));
  funcList.push(new FunctionInfo(ApiEvtType.Reboot, 'reboot', $r('app.string.reboot')));
  funcList.push(new FunctionInfo(ApiEvtType.SetTime, 'setDateTime', $r('app.string.setDateTime')));
  funcList.push(new FunctionInfo(ApiEvtType.SetUserInfo, 'setUserInfo', $r('app.string.setUserInfo')));
  funcList.push(new FunctionInfo(ApiEvtType.SetDefaultMsgList, 'setDefaultMsgList', $r('app.string.setDefaultMsgList')));
  funcList.push(new FunctionInfo(ApiEvtType.SetWeatherSunTime, 'setWeatherSunTime', $r('app.string.setWeatherSunTime')));
  funcList.push(new FunctionInfo(ApiEvtType.SetShortcut, 'setShortcut', $r('app.string.setShortcut')));
  funcList.push(new FunctionInfo(ApiEvtType.SetSleepPeriod, 'setSleepPeriod', $r('app.string.setSleepPeriod')));
  funcList.push(new FunctionInfo(ApiEvtType.SetDisplayMode, 'setDisplayMode', $r('app.string.setDisplayMode')));
  funcList.push(new FunctionInfo(ApiEvtType.SetNoticeAppName, 'setNoticeAppName', $r('app.string.setNoticeAppName')));
  funcList.push(new FunctionInfo(ApiEvtType.SetHand, 'setHand', $r('app.string.setHand')));
  funcList.push(new FunctionInfo(ApiEvtType.SetHotStartParam, 'setHotStartParam', $r('app.string.setHotStartParam')));
  funcList.push(new FunctionInfo(ApiEvtType.SetSportGoal, 'setSportGoal', $r('app.string.setSportGoal')));
  funcList.push(new FunctionInfo(ApiEvtType.SetWatchDial, 'setWatchDial', $r('app.string.setWatchDial')));
  funcList.push(new FunctionInfo(ApiEvtType.SetOverFindPhone, 'setOverFindPhone', $r('app.string.setOverFindPhone')));
  funcList.push(new FunctionInfo(ApiEvtType.SetUnit, 'setUnit', $r('app.string.setUnit')));

  // --- 需要根据功能表 (funcTable) 判断的函数 ---

  if (sdk.funcTable.getFindDevice) {
    funcList.push(new FunctionInfo(ApiEvtType.FindDeviceStart, 'findDeviceStart', $r('app.string.findDeviceStart')));
    funcList.push(new FunctionInfo(ApiEvtType.FindDeviceStop, 'findDeviceStop', $r('app.string.findDeviceStop')));
  }

  if (sdk.funcTable.getSupportV3LongCityName) {
    funcList.push(new FunctionInfo(ApiEvtType.SetLongCityNameV3, 'setLongCityNameV3', $r('app.string.setLongCityNameV3')));
  }

  if (sdk.funcTable.getNotifyMsgV3) {
    funcList.push(new FunctionInfo(ApiEvtType.NoticeMessageV3, 'noticeMessageV3', $r('app.string.noticeMessageV3')));
  }

  if (sdk.funcTable.setWeatherCity) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWeatherCityName, 'setWeatherCityName', $r('app.string.setWeatherCityName')));
  }

  if (sdk.funcTable.setSetPhoneVoice) {
    funcList.push(new FunctionInfo(ApiEvtType.SetBleVoice, 'setBleVoice', $r('app.string.setBleVoice')));
  }

  if (sdk.funcTable.reminderAncs) {
    funcList.push(new FunctionInfo(ApiEvtType.SetNotificationCenter, 'setNoticeStatus(BT Pair)', $r('app.string.setNoticeStatusBtPair')));
    funcList.push(new FunctionInfo(ApiEvtType.SetNotificationCenter, 'setNoticeStatus(Fully open)', $r('app.string.setNoticeStatusAllOn')));
    funcList.push(new FunctionInfo(ApiEvtType.SetNotificationCenter, 'setNoticeStatus(Fully closed)', $r('app.string.setNoticeStatusAllOff')));
  }

  if (sdk.funcTable.setPressureData) {
    funcList.push(new FunctionInfo(ApiEvtType.SetStressSwitch, 'setStressSwitch', $r('app.string.setStressSwitch')));
  }

  // NOTE: 因为demo要适配所有设备，此处示例适配多种情况。
  // 当只适配一台设备时，只需处理以下一种即可（根据功能表判断设备使用哪种）。
  if (sdk.funcTable.setSmartHeartRate || sdk.funcTable.syncV3Hr || sdk.funcTable.syncHeartRateMonitor) {
    funcList.push(new FunctionInfo(ApiEvtType.SetHeartMode, 'setHeartMode', $r('app.string.setHeartMode')));
  }

  if (sdk.funcTable.syncHeartRate) {
    funcList.push(new FunctionInfo(ApiEvtType.SetHeartRateInterval, 'setHeartRateInterval', $r('app.string.setHeartRateInterval')));
  }

  if (sdk.funcTable.setScreenBrightness5Level || sdk.funcTable.setScreenBrightness3Level || sdk.funcTable.setNightAutoBrightness) {
    funcList.push(new FunctionInfo(ApiEvtType.SetScreenBrightness, 'setScreenBrightness', $r('app.string.setScreenBrightness')));
  }

  if (sdk.funcTable.setSetUnreadAppReminder) {
    funcList.push(new FunctionInfo(ApiEvtType.SetUnreadAppReminder, 'setUnreadAppReminder', $r('app.string.setUnreadAppReminder')));
  }

  if (sdk.funcTable.setMsgAllSwitch) {
    funcList.push(new FunctionInfo(ApiEvtType.SetNotificationStatus, 'setNotificationStatus', $r('app.string.setNotificationStatus')));
  }

  if (sdk.funcTable.setScientificSleepSwitch) {
    funcList.push(new FunctionInfo(ApiEvtType.SetScientificSleepSwitch, 'setScientificSleepSwitch', $r('app.string.setScientificSleepSwitch')));
  }

  if (sdk.funcTable.syncV3BodyPower) {
    funcList.push(new FunctionInfo(ApiEvtType.SetBodyPowerTurn, 'setBodyPowerTurn', $r('app.string.setBodyPowerTurn')));
  }

  if (sdk.funcTable.setRespirationRate) {
    funcList.push(new FunctionInfo(ApiEvtType.SetRRespiRateTurn, 'setRRespiRateTurn', $r('app.string.setRRespiRateTurn')));
  }

  if (sdk.funcTable.syncV3Noise) {
    funcList.push(new FunctionInfo(ApiEvtType.SetV3Noise, 'setV3Noise', $r('app.string.setV3Noise')));
  }

  if (sdk.funcTable.setTemperatureSwitchSupport) {
    funcList.push(new FunctionInfo(ApiEvtType.SetTemperatureSwitch, 'setTemperatureSwitch', $r('app.string.setTemperatureSwitch')));
  }

  if (sdk.funcTable.getUpHandGesture) {
    funcList.push(new FunctionInfo(ApiEvtType.SetUpHandGesture, 'setUpHandGesture', $r('app.string.setUpHandGesture')));
  }

  if (sdk.funcTable.setSpo2Data) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSpo2Switch, 'setSpo2Switch', $r('app.string.setSpo2Switch')));
  }

  if (sdk.funcTable.syncV3SyncAlarm) {
    funcList.push(new FunctionInfo(ApiEvtType.SetAlarm, 'setAlarm', $r('app.string.setAlarm')));
  }

  if (sdk.funcTable.setSetFitnessGuidance) {
    funcList.push(new FunctionInfo(ApiEvtType.SetFitnessGuidance, 'setFitnessGuidance', $r('app.string.setFitnessGuidance')));
  }

  if (sdk.funcTable.setBleControlMusic) {
    funcList.push(new FunctionInfo(ApiEvtType.SetMusicOnOff, 'setMusicOnOff', $r('app.string.setMusicOnOff')));
    //funcList.push(new FunctionInfo(ApiEvtType.MusicControl, 'musicControl', $r('app.string.musicControl')));
  }

  if (sdk.funcTable.setSupportSportPlan) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSendRunPlan, 'setSendRunPlan', $r('app.string.setSendRunPlan')));
  }

  if (sdk.funcTable.setSetV3Weather) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWeatherV3, 'setWeatherV3', $r('app.string.setWeatherV3')));
    funcList.push(new FunctionInfo(ApiEvtType.SetWeatherSwitch, 'setWeatherSwitch', $r('app.string.setWeatherSwitch')));
  }

  if (sdk.funcTable.setSetNotificationStatus) {
    funcList.push(new FunctionInfo(ApiEvtType.SetNoticeMessageState, 'setNoticeMessageState', $r('app.string.setNoticeMessageState')));
  }

  if (sdk.funcTable.setSetV3WorldTime) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWorldTimeV3, 'setWorldTimeV3', $r('app.string.setWorldTimeV3')));
  }

  if (sdk.funcTable.setScheduleReminder) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSchedulerReminderV3, 'setSchedulerReminder', $r('app.string.setSchedulerReminder')));
  }

  if (sdk.funcTable.getMultiDial) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWatchFaceData, 'setWatchFaceData', $r('app.string.setWatchFaceData')));
  }

  if (sdk.funcTable.setSyncContact && sdk.funcTable.reminderCallContact) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSyncContact, 'setSyncContact', $r('app.string.setSyncContact')));
  }

  if (sdk.funcTable.getSportsTypeV3) {
    funcList.push(new FunctionInfo(ApiEvtType.Set100SportSortV3, 'setSport100Sort', $r('app.string.setSport100Sort')));
    funcList.push(new FunctionInfo(ApiEvtType.SetSportSortV3, 'setSportsTypeV3', $r('app.string.setSportsTypeV3')));
  }

  if (sdk.funcTable.setHistoryMenstrual) {
    funcList.push(new FunctionInfo(ApiEvtType.GetHistoricalMenstruation, 'setHistoricalMenstruation', $r('app.string.setHistoricalMenstruation')));
  }

  if (sdk.funcTable.setWatchDialSort) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWatchDialSort, 'setWatchDialSort', $r('app.string.setWatchDialSort')));
  }

  if (sdk.funcTable.setWalkReminder) {
    funcList.push(new FunctionInfo(ApiEvtType.SetWalkRemind, 'setWalkRemind', $r('app.string.setWalkRemind')));
  }

  if (sdk.funcTable.setMenstruation) {
    funcList.push(new FunctionInfo(ApiEvtType.SetMenstruation, 'setMenstruation', $r('app.string.setMenstruation')));
  }

  if (sdk.funcTable.getSupportGetMainSportGoalV3 && sdk.funcTable.setCalorieGoal && sdk.funcTable.getSupportSetGetTimeGoalTypeV2) {
    funcList.push(new FunctionInfo(ApiEvtType.SetCalorieDistanceGoal, 'setCalorieDistanceGoal', $r('app.string.setCalorieDistanceGoal')));
  }

  if (sdk.funcTable.supportSetAntilost) {
    funcList.push(new FunctionInfo(ApiEvtType.SetLostFind, 'setLostFind', $r('app.string.setLostFind')));
  }

  if (sdk.funcTable.getFindPhone) {
    funcList.push(new FunctionInfo(ApiEvtType.SetFindPhone, 'setFindPhone', $r('app.string.setFindPhone')));
  }

  if (sdk.funcTable.supportSetOnetouchCalling) {
    funcList.push(new FunctionInfo(ApiEvtType.SetOnekeySOS, 'setOnekeySOS', $r('app.string.setOnekeySOS')));
  }

  if (sdk.funcTable.syncTimeLine) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSportModeSelect, 'setSportModeSelect', $r('app.string.setSportModeSelect')));
  }

  if (sdk.funcTable.setSportModeSort) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSportModeSort, 'setSportModeSort', $r('app.string.setSportModeSort')));
  }

  if (sdk.funcTable.setSupportControlMiniProgram) {
    funcList.push(new FunctionInfo(ApiEvtType.SetAppletControl, 'setAppletControl', $r('app.string.setAppletControl')));
  }

  if (sdk.funcTable.supportSettingsDuringExercise) {
    funcList.push(new FunctionInfo(ApiEvtType.SetDuringExercise, 'setDuringExercise', 'setDuringExercise'));
  }

  if (sdk.funcTable.supportSimpleHrZoneSetting) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSimpleHeartRateZone, 'setSimpleHeartRateZone', 'setSimpleHeartRateZone'));
  }

  if (sdk.funcTable.supportSportingRemindSetting) {
    funcList.push(new FunctionInfo(ApiEvtType.SetSportingRemindSetting, 'setSportingRemindSetting', 'setSportingRemindSetting'));
  }

  if(sdk.funcTable.setActivitySwitch){
    funcList.push(new FunctionInfo(ApiEvtType.SetActivitySwitch, 'setActivitySwitch', 'setActivitySwitch'));
  }

  funcList.sort((a, b) => a.name.localeCompare(b.name));
  return funcList;
}


@ObservedV2
export class DeviceState {
  @Trace connectState: IDODeviceStateType = IDODeviceStateType.DISCONNECTED;
  @Trace errorState: IDOConnectErrorType = IDOConnectErrorType.NONE;
  @Trace isBind: boolean = false;
  @Trace setFunctionList: FunctionInfo[] = []
  @Trace getFunctionList: FunctionInfo[] = []
  @Trace isOta: boolean = false;
  @Trace isConnected: boolean = false;
  @Trace isDoing: boolean = false;

  updateDoingStatus(isDoing: boolean) {
    this.isDoing = isDoing;
  }

  updateOtaStatus(isOta: boolean) {
    this.isOta = isOta;
  }

  updateBindState(bind: boolean) {
    this.isBind = bind;
  }

  updateConnectState(state: IDODeviceStateType) {
    this.connectState = state;
    this.isConnected = this.connectState == IDODeviceStateType.CONNECTED
  }

  updateConnectErrorState(state: IDOConnectErrorType) {
    this.errorState = state;
  }

  getConnectStateDes(): Resource {
    if (this.isOta) {
      return $r('app.string.device_ota');
    }
    if (this.errorState == IDOConnectErrorType.DEVICEALREADYBINDANDNOTSUPPORTREBIND) {
      return $r('app.string.not_support_rebind');
    } else if (this.errorState == IDOConnectErrorType.DEVICEHASBEENRESET) {
      return $r('app.string.device_has_reset')
    }
    switch (this.connectState) {
      case IDODeviceStateType.DISCONNECTING:
        return $r('app.string.connect_state_disconnecting');
      case IDODeviceStateType.DISCONNECTED:
        return $r('app.string.connect_state_disconnected');
      case IDODeviceStateType.CONNECTING:
        return $r('app.string.connect_state_connecting');
      case IDODeviceStateType.CONNECTED:
        return $r('app.string.connect_state_connected');
    }
  }
}

export class DeviceStateViewModel {
  private static instance: DeviceStateViewModel;
  deviceState: DeviceState = new DeviceState();
  private device?: IDOBleDeviceModel

  private constructor() {
    BleManager.registerBleDelegate(this.bleDelegateImp)
  }

  static getInstance(): DeviceStateViewModel {
    if (!DeviceStateViewModel.instance) {
      DeviceStateViewModel.instance = new DeviceStateViewModel();
    }
    return DeviceStateViewModel.instance;
  }

  async setDevice(device: IDOBleDeviceModel) {
    if (this.device != null && this.device?.macAddress != device.macAddress) {
      await this.disconnect(this.device)
    }
    this.device = device;
  }

  // 内部委托实现
  private bleDelegateImp: AppDelegate = {
    deviceState: (state: IDODeviceStateModel) => {
      console.info("deviceState change, connect state: " + state.state + ", error: " + state.errorState + ", isOta: " +
      sdk.ble.getCurrentBleDevice().isOta);
      this.deviceState.updateOtaStatus(sdk.ble.getCurrentBleDevice().isOta);
      this.deviceState.updateConnectState(state.state);
      this.deviceState.updateConnectErrorState(state.errorState);
      if (state.state == IDODeviceStateType.CONNECTED || state.state == IDODeviceStateType.DISCONNECTED) {
        let isBind = Tools.getInstance().getBindState(state.macAddress!!)
        this.deviceState.updateBindState(isBind);
        this.deviceState.updateDoingStatus(false)
      }
    },
    listenWaitingOtaDevice: (device: IDOOtaDeviceModel) => {
      console.info("deviceState device in ota: "+device)
      this.deviceState.updateOtaStatus(sdk.ble.getCurrentBleDevice().isOta);
    }
  };

  async connect(device: IDOBleDeviceModel | null) {
    console.info("connect");
    this.deviceState.updateDoingStatus(true)
    this.deviceState.updateConnectState(IDODeviceStateType.CONNECTING)
    sdk.ble.connect(device);
  }

  async autoConnect(device: IDOBleDeviceModel | null) {
    console.info("autoConnect");
    this.deviceState.updateDoingStatus(true)
    this.deviceState.updateConnectState(IDODeviceStateType.CONNECTING)
    sdk.ble.autoConnect(device);
  }

  async disconnect(device: IDOBleDeviceModel | null) {
    console.info("disconnect");
    this.deviceState.updateDoingStatus(true)
    this.deviceState.updateConnectState(IDODeviceStateType.DISCONNECTING)
    sdk.ble.cancelConnect(device?.macAddress ?? null, (success) => {
      console.info("disconnect result:" + success)
    });
  }

  async bind() {
    console.info("isBind");
    this.deviceState.updateDoingStatus(true)
    sdk.cmd.bind(1, (deviceInfo) => {
      console.info("绑定成功，设备信息：" + deviceInfo)
    }, (funcTable) => {
      console.info("绑定成功，功能表：" + funcTable)
    }, (status) => {
      console.info("绑定结果 status：" + status)
      this.deviceState.updateDoingStatus(false)
      if (status == IDOBindStatus.successful || status === IDOBindStatus.binded) {
        console.info("绑定成功")
        this.deviceState.updateBindState(true)
        Tools.getInstance().setBindState(sdk.device.macAddressFull, true)
        Tools.getInstance().setBindDevice(this.device!);
      } else {
        console.info("绑定失败")
        this.deviceState.updateBindState(false)
        Tools.getInstance().setBindState(sdk.device.macAddressFull, false)
      }
    })
  }

  async unbind() {
    console.info("unbind");
    this.deviceState.updateDoingStatus(false)
    sdk.cmd.unbind(this.device!.macAddress, true, () => {
      Tools.getInstance().setBindState(this.device!.macAddress ?? "", false)
      Tools.getInstance().removeBindDevice(this.device!.macAddress ?? "")
      BluetoothViewModel.getInstance().refreshBindDeviceList();
      sdk.ble.cancelConnect(sdk.device.macAddressFull, (success: boolean) => {

      })
      this.deviceState.updateDoingStatus(false)
    })
  }

  async sendNotificationMsg(context: common.UIAbilityContext): Promise<boolean> {
    const MAX_ATTEMPTS = 10; // 最大尝试次数
    const RETRY_DELAY = 5000; // 重试间隔（毫秒）

    // 使用 for 循环进行重试
    for (let attempt = 1; attempt <= MAX_ATTEMPTS; attempt++) {
      console.info(`[Notification] Attempt ${attempt}/${MAX_ATTEMPTS}: Sending notification...`);
      const isSuccess = await Tools.getInstance().publishNotification(attempt, "Msg title", "Msg content", "", context);
      if (isSuccess) {
        console.info(`[Notification] sendNotificationMsg successful on attempt ${attempt}.`);
        const param = IDONoticeMessageParamModel.fromJson({evt_type: 1,
                msg_id: 3,
                support_answering: false,
                support_mute: false,
                support_hang_up: false,
                contact: "xx00"+attempt,
                phone_number: "33003"+attempt,
                data_text: "data text"+attempt});
        Cmds.noticeMessageV3(param, (res) => {
          if (res.success) {
            const value = res.value;
            console.debug("sendNotificationMsg successful "+value?.toJsonString())
          } else {
            const err = res as IFailureResult<CmdError>;
            console.debug(`sendNotificationMsg err code: ${err.error.code} msg: ${err.error.message}`);
          }
        });
      } else {
        // 如果失败，打印失败日志
        console.error(`[Notification] sendNotificationMsg failed on attempt ${attempt}.`);
      }
      // 如果不是最后一次尝试，则等待3秒后再进行下一次循环
      if (attempt < MAX_ATTEMPTS) {
        console.log(`[Notification] Will retry in ${RETRY_DELAY / 1000} seconds...`);
        await this.delay(RETRY_DELAY);
      }
    }

    // 如果循环10次后仍然失败，打印最终失败信息并返回 false
    console.error(`[Notification] sendNotificationMsg failed after ${MAX_ATTEMPTS} attempts.`);
    return false;
  }

  private async delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // async sendNotificationMsg(context: common.UIAbilityContext) {
  //
  //   let rs = await Tools.getInstance().publishNotification(1, "Msg title", "Msg content", "", context)
  //   if (rs) {
  //     // const param = IDONoticeMessageParamModel.fromJson({evt_type: 1,
  //     //   msg_id: 3,
  //     //   support_answering: false,
  //     //   support_mute: false,
  //     //   support_hang_up: false,
  //     //   contact: "xx001",
  //     //   phone_number: "xx003",
  //     //   data_text: "data text1"});
  //     // Cmds.noticeMessageV3(param, (res) => {
  //     //   if (res.success) {
  //     //     const value = res.value;
  //     //     console.debug("sendNotificationMsg successful "+value?.toJsonString())
  //     //   } else {
  //     //     const err = res as IFailureResult<CmdError>;
  //     //     console.debug(`sendNotificationMsg err code: ${err.error.code} msg: ${err.error.message}`);
  //     //   }
  //     // });
  //     console.info("sendNotificationMsg successful")
  //   }else {
  //     console.error("sendNotificationMsg failed")
  //   }
  //
  // }
}


