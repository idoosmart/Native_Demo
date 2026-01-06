import {
  ApiEvtType,
  IDODateTimeParamModel,
  IFailureResult,
  ISuccessResult,
  CmdResult,
  IDOCancellable,
  CmdError,
  Cmds,
  sdk,
  IDOSetNoticeStatusModel,
  IDONoticeMsgAllSwitchState,
  IDONoticeNotifySwitchState,
  IDOWatchFaceParamModel,
  CommonRangeRemind,
  DistanceRemind,
  IDOAlarmItem,
  IDOAlarmModel,
  IDOAlarmStatus,
  IDOAlarmType,
  IDOBaseModel,
  IDOBleVoiceParamModel,
  IDOContactItem,
  IDODefaultMessageConfigParamModel,
  IDODefaultMessageItem,
  IDODisplayModeParamModel,
  IDOFitnessGuidanceParamModel,
  IDOGpsHotStartParamModel,
  IDOGpsInfoModelItem,
  IDOHeartModeParamModel,
  IDOHeartRateIntervalModel,
  IDOHistoricalMenstruationParamItem,
  IDOHistoricalMenstruationParamModel,
  IDOItemItem,
  IDOLostFindParamModel,
  IDOMainSportGoalModel,
  IDOMenstruationModel,
  IDOMusicOnOffParamModel,
  IDONoticeMesaageParamItem,
  IDONoticeMesaageParamModel,
  IDONoticeMessageParamModel,
  IDONoticeMessageStateParamModel,
  IDONotificationStatusParamModel,
  IDORunPlanParamModel,
  IDOSchedulerReminderItem,
  IDOSchedulerReminderParamModel,
  IDOScientificSleepSwitchParamModel,
  IDOScreenBrightnessModel,
  IDOSettingsDuringExerciseModel,
  IDOShortcutParamModel,
  IDOSimpleHeartRateZoneSettingModel,
  IDOSleepPeriodParamModel,
  IDOSpo2SwitchParamModel,
  IDOSport100SortParamModel,
  IDOSportGoalParamModel,
  IDOSportingRemindSettingModel,
  IDOSportModeSelectParamModel,
  IDOSportModeSortParamModel,
  IDOSportType,
  IDOStressSwitchParamModel,
  IDOSyncContactParamModel,
  IDOTemperatureSwitchParamModel,
  IDOUnitParamModel,
  IDOUpHandGestureParamModel,
  IDOUserInfoPramModel,
  IDOV3NoiseParamModel,
  IDOWalkRemindModel,
  IDOWatchDialParamModel,
  IDOWatchDialSortItem,
  IDOWatchDialSortParamModel,
  IDOWeatherSunTimeParamModel,
  IDOWeatherV3ParamModel,
  IDOWeek,
  IDOWorldTimeParamModel,
  INoticeMessageStateParamJson,
  IWeatherV3ParamModelJson,
  PaceRemind,
  IDOBleDeviceModel
} from "protocol_channel";
import { IDOActivitySwitchParamModel } from "protocol_channel/src/main/ets/components/model/IDOActivitySwitchModel";
import { IDOAppletControlModel } from "protocol_channel/src/main/ets/components/model/IDOAppControlModel";
import { FunctionInfo } from "./FunctionListViewModel";

@Observed
export class FunctionDataViewModel {
  private funcInfo: FunctionInfo;
  private device: IDOBleDeviceModel | undefined;
  private canceler: IDOCancellable | undefined;
  private rejectFunc: ((reason?: Error | string) => void) | undefined;
  @Track isProcessing: boolean = false;
  @Track paramStr: string = '';
  @Track resStr: string = '';

  constructor(funcInfo: FunctionInfo, device: IDOBleDeviceModel | undefined) {
    this.funcInfo = funcInfo
    this.device = device;
  }

  async send(): Promise<void> {
    this.isProcessing = true;
    this.resStr = ''; // 清空上一次的结果
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      this.doSend(resolve, reject);
    });
  }

  async cancel() {
    if (this.canceler) {
      this.canceler.cancel();

      if (this.rejectFunc) {
        this.rejectFunc('Operation cancelled by user');
        this.rejectFunc = undefined;
      }

      this.canceler = undefined;
      this.isProcessing = false;
      this.resStr = 'Operation cancelled.';
    }
  }

  private async doSend(resolve: (value: void | PromiseLike<void>) => void, reject: (reason?: Error | string) => void) {
    // handleResponse - instanceof 版本
    const handleResponse = <T>(rs: CmdResult<T, CmdError>) => {
      this.canceler = undefined;
      this.isProcessing = false;
      if (rs.success) {
        const value = rs.value;

        // 使用 instanceof 进行类型安全检查
        if (value instanceof IDOBaseModel) {
          this.resStr = value.toJsonString();
        } else if (value !== null && typeof value !== 'undefined') {
          if (typeof value === 'object') {
            this.resStr = JSON.stringify(value, null, 2);
          } else {
            this.resStr = String(value);
          }
        } else {
          this.resStr = 'Success';
        }
        resolve();
      } else {
        const err = rs as IFailureResult<CmdError>;
        this.resStr = `code: ${err.error.code} msg: ${err.error.message}`;
        reject(err.error.message);
      }
    };

    switch (this.funcInfo.evtType) {

      // =================================================================
      // ------ Get Functions (共 41 项) -----
      // =================================================================

      case ApiEvtType.GetSnInfo: {
        this.canceler = Cmds.getSn(handleResponse);
        break;
      }
      case ApiEvtType.GetDeviceInfo: {
        this.resStr = sdk.device.printProperties() ?? ""
        this.isProcessing = false
        resolve()
        break;
      }
      case ApiEvtType.GetFuncTable: {
        this.resStr = sdk.funcTable.printProperties() ?? ""
        this.isProcessing = false
        resolve()
        break;
      }
      case ApiEvtType.GetWatchListV3: {
        this.canceler = Cmds.getWatchListV3(handleResponse);
        break;
      }
      case ApiEvtType.GetWatchFaceList: { // fallback for getWatchListV2
        this.canceler = Cmds.getWatchListV2(handleResponse);
        break;
      }
      case ApiEvtType.GetBatteryInfo: {
        this.canceler = Cmds.getBatteryInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetDeviceLogState: {
        this.canceler = Cmds.getDeviceLogState(handleResponse);
        break;
      }
      case ApiEvtType.GetMenuList: {
        this.canceler = Cmds.getMenuList(handleResponse);
        break;
      }
      case ApiEvtType.GetNoticeStatus: {
        this.canceler = Cmds.getNoticeStatus(handleResponse);
        break;
      }
      case ApiEvtType.GetAlarmV3: {
        this.canceler = Cmds.getAlarm(0, handleResponse);
        break;
      }
      case ApiEvtType.GetContactReviseTime: {
        this.canceler = Cmds.getContactReviseTime(handleResponse);
        break;
      }
      case ApiEvtType.GetWalkRemind: {
        this.canceler = Cmds.getWalkRemind(handleResponse);
        break;
      }
      case ApiEvtType.GetSupportMaxSetItemsNum: {
        this.canceler = Cmds.getSupportMaxSetItemsNum(handleResponse);
        break;
      }
      case ApiEvtType.GetScreenBrightness: {
        this.canceler = Cmds.getScreenBrightness(handleResponse);
        break;
      }
      case ApiEvtType.GetMainSportGoal: {
        this.canceler = Cmds.getMainSportGoal(1, handleResponse);
        break;
      }
      case ApiEvtType.GetNotDisturbStatus: {
        this.canceler = Cmds.getNotDisturbStatus(handleResponse);
        break;
      }
      case ApiEvtType.GetUpHandGesture: {
        this.canceler = Cmds.getUpHandGesture(handleResponse);
        break;
      }
      case ApiEvtType.GetBtNotice: {
        this.canceler = Cmds.getBtNotice(handleResponse);
        break;
      }
      case ApiEvtType.GetFlashBinInfo: {
        this.canceler = Cmds.getFlashBinInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetErrorRecord: {
        this.canceler = Cmds.getErrorRecord(1, handleResponse);
        break;
      }
      case ApiEvtType.GetActivitySwitch: {
        this.canceler = Cmds.getActivitySwitch(handleResponse);
        break;
      }
      case ApiEvtType.GetBtName: {
        this.canceler = Cmds.getBtName(handleResponse);
        break;
      }
      case ApiEvtType.GetMtuInfo: {
        this.canceler = Cmds.getMtuInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetAllHealthSwitchState: {
        this.canceler = Cmds.getAllHealthSwitchState(handleResponse);
        break;
      }
      case ApiEvtType.GetGpsInfo: {
        this.canceler = Cmds.getGpsInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetGpsStatus: {
        this.canceler = Cmds.getGpsStatus(handleResponse);
        break;
      }
      case ApiEvtType.GetUnerasableMeunList: {
        this.canceler = Cmds.getUnerasableMeunList(handleResponse);
        break;
      }
      case ApiEvtType.GetBpAlgVersion: {
        this.canceler = Cmds.getBpAlgVersion(handleResponse);
        break;
      }
      case ApiEvtType.GetUpdateStatus: {
        this.canceler = Cmds.getUpdateStatus(handleResponse);
        break;
      }
      case ApiEvtType.GetDownLanguage: {
        this.canceler = Cmds.getDownloadLanguage(handleResponse);
        break;
      }
      case ApiEvtType.GetBleMusicInfo: {
        this.canceler = Cmds.getBleMusicInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetLanguageLibraryDataV3: {
        this.canceler = Cmds.getLanguageLibrary(handleResponse);
        break;
      }
      case ApiEvtType.GetBleBeepV3: {
        this.canceler = Cmds.getBleBeep(handleResponse);
        break;
      }
      case ApiEvtType.GetStepGoal: {
        this.canceler = Cmds.getStepGoal(handleResponse);
        break;
      }
      case ApiEvtType.GetBtConnectPhoneModel: {
        this.canceler = Cmds.getBtConnectPhoneModel(handleResponse);
        break;
      }
      case ApiEvtType.GetUnit: {
        this.canceler = Cmds.getUnit(handleResponse);
        break;
      }
      case ApiEvtType.SetAppletControl: {
        let appletControl = new IDOAppletControlModel(3);
        this.canceler = Cmds.setAppletControl(appletControl, handleResponse);
        break;
      }
      case ApiEvtType.GetAlgFile: {
        this.canceler = Cmds.getAlgFileInfo(handleResponse);
        break;
      }
    // case ApiEvtType.RequestAlgFile: {
    //   // TODO: 请填充请求算法文件的参数, 例如文件名
    //   const param = { fileName: "example.alg" };
    //   this.canceler = Cmds.requestAlgFile(param, handleResponse);
    //   break;
    // }
      case ApiEvtType.GetSportTypeV3: {
        this.canceler = Cmds.getSportTypeV3(handleResponse);
        break;
      }
      case ApiEvtType.GetUserInfo: {
        this.canceler = Cmds.getUserInfo(handleResponse);
        break;
      }
      case ApiEvtType.GetHeartRateMode: {
        if (sdk.funcTable.setSmartHeartRate) {
          if (sdk.funcTable.getSupportGetSmartHeartRate) {
            let param = new IDOHeartModeParamModel(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            this.canceler = Cmds.setHeartMode(param, handleResponse)
          }else {
            // !!!: - 该设备不支持获取心率模式，需要app自行记录
            this.resStr = "该设备不支持获取心率模式，需要app自行记录\n\nThe device does not support the heart rate acquisition mode, and the app needs to record it by itself"
          }
        }else if(sdk.funcTable.syncV3Hr) {
          let param = new IDOHeartModeParamModel(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
          this.canceler = Cmds.setHeartMode(param, handleResponse)
        }else if(sdk.funcTable.getHeartRateModeV2) {
          this.canceler = Cmds.getHeartRateMode(handleResponse)
        }
        break;
      }
      case ApiEvtType.GetLeftRightWearSettings: {
        this.canceler = Cmds.getLeftRightWearSettings(handleResponse);
        break;
      }
      case ApiEvtType.GetSimpleHeartRateZone: {
        this.canceler = Cmds.getSimpleHeartRateZone(handleResponse);
        break;
      }
    // case ApiEvtType.GetSportingRemindSetting: {
    //   this.canceler = Cmds.getSportingRemindSetting([5], handleResponse);
    //   break;
    // }
      case ApiEvtType.GetSettingsDuringExercise: {
        this.canceler = Cmds.getSettingsDuringExercise(handleResponse);
        break;
      }

    // =================================================================
    // ------ Set Functions (共 54 项) -----
    // =================================================================

      case ApiEvtType.FactoryReset: {
        this.canceler = Cmds.factoryReset(handleResponse);
        break;
      }
      case ApiEvtType.PhotoStart: {
        this.canceler = Cmds.photoStart(handleResponse);
        break;
      }
      case ApiEvtType.PhotoStop: {
        this.canceler = Cmds.photoStop(handleResponse);
        break;
      }
      case ApiEvtType.Reboot: {
        this.canceler = Cmds.reboot(handleResponse);
        break;
      }
      case ApiEvtType.SetTime: {
        const currentDate = new Date();
        const param = new IDODateTimeParamModel(
          currentDate.getFullYear(),
          currentDate.getMonth() + 1,
          currentDate.getDate(),
          currentDate.getHours(),
          currentDate.getMinutes(),
          currentDate.getSeconds(),
          (currentDate.getDay() === 0 ? 6 : currentDate.getDay() - 1),
          8
        );
        this.canceler = Cmds.setDateTime(param, handleResponse);
        break;
      }
      case ApiEvtType.SetUserInfo: {
        const param = IDOUserInfoPramModel.fromJson({ year: 1990, month: 1, day: 1, height: 175, weight: 70, gender: 1 })
        this.canceler = Cmds.setUserInfo(param, handleResponse);
        break;
      }
      case ApiEvtType.SetDefaultMsgList: {
        const param = new IDODefaultMessageConfigParamModel(1, [
          new IDODefaultMessageItem("com.tencent.xin"),
          new IDODefaultMessageItem("com.facebook.Facebook")
        ])
        this.canceler = Cmds.setDefaultMsgList(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWeatherSunTime: {
        let param = IDOWeatherSunTimeParamModel.fromJson({ sunrise_hour: 6, sunrise_min: 0, sunset_hour: 18, sunset_min: 30 })
        this.canceler = Cmds.setWeatherSunTime(param, handleResponse);
        break;
      }
      case ApiEvtType.SetShortcut: {
        const param = new IDOShortcutParamModel(2)
        this.canceler = Cmds.setShortcut(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSleepPeriod: {
        const param = IDOSleepPeriodParamModel.fromJson({on_off: 1, start_hour: 22, start_minute: 0, end_hour: 7, end_minute: 30 })
        this.canceler = Cmds.setSleepPeriod(param, handleResponse);
        break;
      }
      case ApiEvtType.SetDisplayMode: {
        const param = new IDODisplayModeParamModel(1);
        this.canceler = Cmds.setDisplayMode(param, handleResponse);
        break;
      }
      case ApiEvtType.SetNoticeAppName: {
        const param = IDONoticeMesaageParamModel.fromJson({os_platform: 2,
          evt_type: 1,
          notify_type: 1,
          msg_ID: 1,
          app_items_len: 1,
          contact: "zhangsan",
          phone_number: "xxx333",
          msg_data: "msg data",
          items: [
            IDONoticeMesaageParamItem.fromJson({language: 1, name: "中文"}),
            IDONoticeMesaageParamItem.fromJson({language: 2, name: "en"})
          ]})
        this.canceler = Cmds.setNoticeAppName(param, handleResponse);
        break;
      }
      case ApiEvtType.SetHand: {
        this.canceler = Cmds.setHand(true, handleResponse);
        break;
      }
      case ApiEvtType.SetHotStartParam: {
        const param = IDOGpsHotStartParamModel.fromJson({ longitude: 2, latitude: 42.6511674 * 1000000, altitude: -73.754968 * 1000000, tcxo_offset: 0*10 });
        this.canceler = Cmds.setHotStartParam(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSportGoal: {
        const param = new IDOSportGoalParamModel(2000, 15, 1);
        this.canceler = Cmds.setSportGoal(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWatchDial: {
        const param = IDOWatchDialParamModel.fromJson({ dial_id: 1 });
        this.canceler = Cmds.setWatchDial(param, handleResponse);
        break;
      }
      case ApiEvtType.SetOverFindPhone: {
        this.canceler = Cmds.setOverFindPhone(true, handleResponse);
        break;
      }
      case ApiEvtType.SetUnit: {
        const param = new IDOUnitParamModel(1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1);
        this.canceler = Cmds.setUnit(param, handleResponse);
        break;
      }
      case ApiEvtType.FindDeviceStart: {
        this.canceler = Cmds.findDeviceStart(handleResponse);
        break;
      }
      case ApiEvtType.FindDeviceStop: {
        this.canceler = Cmds.findDeviceStop(handleResponse);
        break;
      }
      case ApiEvtType.SetLongCityNameV3: {
        this.canceler = Cmds.setLongCityNameV3('Shenzhen', handleResponse);
        break;
      }
      case ApiEvtType.NoticeMessageV3: {
        const param = IDONoticeMessageParamModel.fromJson({evt_type: 1,
          msg_id: 3,
          support_answering: false,
          support_mute: false,
          support_hang_up: false,
          contact: "xx001",
          phone_number: "xx003",
          data_text: "data text1"});
        this.canceler = Cmds.noticeMessageV3(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWeatherCityName: {
        this.canceler = Cmds.setWeatherCityName('Beijing', handleResponse);
        break;
      }
      case ApiEvtType.SetBleVoice: {
        // TODO: 获取当前手机系统音量
        const curSysVolume = 50;
        const param = IDOBleVoiceParamModel.fromJson({total_voice: 100 , now_voice: curSysVolume});
        this.canceler = Cmds.setBleVoice(param, handleResponse);
        break;
      }
      case ApiEvtType.SetNotificationCenter: {
        let param = IDOSetNoticeStatusModel.createAllOffModel()
        if (this.funcInfo.name.includes('Pair')) {
          param.msgAllSwitch = IDONoticeMsgAllSwitchState.ON
          param.notifySwitch = IDONoticeNotifySwitchState.BLE_ON
          param.isOnOther = false
          sdk.ble.setBtPair(this.device);
        }else if (this.funcInfo.name.includes('open')) {
          param = IDOSetNoticeStatusModel.createDefaultModel()
          param.msgAllSwitch = IDONoticeMsgAllSwitchState.ON
          param.notifySwitch = IDONoticeNotifySwitchState.SETTING_SUB_SWITCH
          param.isOnOther = false
        }else if (this.funcInfo.name.includes('closed')) {
          param.msgAllSwitch = IDONoticeMsgAllSwitchState.OFF
          param.notifySwitch = IDONoticeNotifySwitchState.SETTING_SUB_SWITCH
        }
        this.canceler = Cmds.setNoticeStatus(param, handleResponse);
        break;
      }
      case ApiEvtType.SetStressSwitch: {
        const param = new IDOStressSwitchParamModel(1, 3, 5, 4, 6, 1, 60,  30,  1, 1,  [IDOWeek.Monday, IDOWeek.Tuesday]);
        this.canceler = Cmds.setStressSwitch(param, handleResponse);
        break;
      }
      case ApiEvtType.SetHeartMode: {
        if (sdk.funcTable.setSmartHeartRate) {
          if (sdk.funcTable.getSupportGetSmartHeartRate) {
            this.canceler = Cmds.getSmartHeartRateMode(handleResponse);
          }else if(sdk.funcTable.syncV3Hr) {
            let param = new IDOHeartModeParamModel(0, 0,0,0,0,0,0,0,0,0,0,0,0)
            this.canceler = Cmds.setHeartMode(param, handleResponse);
          }else if(sdk.funcTable.getHeartRateModeV2) {
            this.canceler = Cmds.getHeartRateMode(handleResponse);
          }
        } else {
          resolve()
        }
        break;
      }
      case ApiEvtType.SetHeartRateInterval: {
        const param = IDOHeartRateIntervalModel.fromJson({
          burn_fat_threshold: 113,
          aerobic_threshold: 132,
          limit_threshold: 170,
          user_max_hr: 220,
          range1: 94,
          range2: 113,
          range3: 132,
          range4: 152,
          range5: 170,
          min_hr: 20,
          max_hr_remind: 1,
          min_hr_remind: 0,
          remind_start_hour: 0,
          remind_start_minute: 0,
          remind_stop_hour: 23,
          remind_stop_minute: 59
        });
        this.canceler = Cmds.setHeartRateInterval(param, handleResponse);
        break;
      }
      case ApiEvtType.SetScreenBrightness: {
        const param = IDOScreenBrightnessModel.fromJson({
          level: 60,
          opera: 1,
          mode: 0,
          auto_adjust_night: 1,
          start_hour: 8,
          start_minute: 0,
          end_hour: 23,
          end_minute: 59,
          night_level: 30,
          show_interval: 0
        });
        this.canceler = Cmds.setScreenBrightness(param, handleResponse);
        break;
      }
      case ApiEvtType.SetUnreadAppReminder: {
        this.canceler = Cmds.setUnreadAppReminder(true, handleResponse);
        break;
      }
      case ApiEvtType.SetNotificationStatus: {
        this.canceler = Cmds.setNotificationStatus(new IDONotificationStatusParamModel(1), handleResponse);
        break;
      }
      case ApiEvtType.SetScientificSleepSwitch: {
        const param = IDOScientificSleepSwitchParamModel.fromJson({
          mode: 1,
          start_hour: 23,
          start_minute: 0,
          end_hour: 9,
          end_minute: 0
        })
        this.paramStr = param.toJsonString()
        this.canceler = Cmds.setScientificSleepSwitch(param, handleResponse);
        break;
      }
      case ApiEvtType.SetBodyPowerTurn: {
        this.canceler = Cmds.setBodyPowerTurn(true, handleResponse);
        break;
      }
      case ApiEvtType.SetRRespiRateTurn: {
        this.canceler = Cmds.setRRespiRateTurn(true, handleResponse);
        break;
      }
      case ApiEvtType.SetV3Noise: {
        const param = IDOV3NoiseParamModel.fromJson({
          mode: 1,
          start_hour: 15,
          start_minute: 0,
          end_hour: 20,
          end_minute: 0,
          high_noise_on_off: 1,
          high_noise_value: 100
        });
        this.canceler = Cmds.setV3Noise(param, handleResponse);
        break;
      }
      case ApiEvtType.SetTemperatureSwitch: {
        const param = IDOTemperatureSwitchParamModel.fromJson({
          mode: 1,
          start_hour: 19,
          start_minute: 0,
          end_hour: 23,
          end_minute: 0,
          unit: 1
        });
        this.canceler = Cmds.setTemperatureSwitch(param, handleResponse);
        break;
      }
      case ApiEvtType.SetUpHandGesture: {
        const param = IDOUpHandGestureParamModel.fromJson({
          on_off: 0, show_second: 5, has_time_range: 1, start_hour: 8, start_minute: 0, end_hour: 18, end_minute: 0
        });
        this.canceler = Cmds.setUpHandGesture(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSpo2Switch: {
        const param = IDOSpo2SwitchParamModel.fromJson({
          on_off: 1,
          start_hour: 14,
          start_minute: 0,
          end_hour: 20,
          end_minute: 0,
          low_spo2_on_off: 1,
          low_spo2_value: 20,
          notify_flag: 1
        }) as IDOSpo2SwitchParamModel;
        this.canceler = Cmds.setSpo2Switch(param, handleResponse);
        break;
      }
      case ApiEvtType.SetAlarm: {
        let maxCount = sdk.funcTable.alarmCount;
        let items: IDOAlarmItem[] = [];
        for (let idx = 0; idx < maxCount; idx++) {
          let alarmID = idx + 1;
          let futureDate = new Date();
          futureDate.setMinutes(futureDate.getMinutes() + alarmID);
          let hour = futureDate.getHours();
          let minute = futureDate.getMinutes();
          let alarmItem = new IDOAlarmItem(alarmID, 1, hour,
            minute, `Alarm-${alarmID}`,
            [IDOWeek.Monday, IDOWeek.Tuesday, IDOWeek.Wednesday, IDOWeek.Thursday, IDOWeek.Friday, IDOWeek.Saturday, IDOWeek.Sunday],
            true, 0, 1, IDOAlarmStatus.Displayed, 0, IDOAlarmType.Other
          );
          items.push(alarmItem);
        }
        this.canceler = Cmds.setAlarm(new IDOAlarmModel(items), handleResponse);
        break;
      }
      case ApiEvtType.SetFitnessGuidance: {
        const param = new IDOFitnessGuidanceParamModel(1, 9, 0,18, 0, 1, 1,
          new Set<IDOWeek>([IDOWeek.Monday, IDOWeek.Tuesday, IDOWeek.Wednesday, IDOWeek.Thursday, IDOWeek.Friday, IDOWeek.Saturday, IDOWeek.Sunday]), 5000)
        this.canceler = Cmds.setFitnessGuidance(param, handleResponse);
        break;
      }
      case ApiEvtType.SetMusicOnOff: {
        const param = new IDOMusicOnOffParamModel(1, 1);
        this.canceler = Cmds.setMusicOnOff(param, handleResponse);
        break;
      }
      // case ApiEvtType.MusicControl: {
      //   // TODO: 填充音乐控制参数
      //   const param = { type: 0 }; // 0:播放, 1:暂停, 2:上一首...
      //   this.canceler = Cmds.musicControl(param, handleResponse);
      //   break;
      // }
      case ApiEvtType.SetSendRunPlan: {
        let item1 =  new IDOItemItem(1, 200, 110, 80)
        let item2 = new IDOItemItem(1, 500, 110, 80)
        let gpsInfo = new IDOGpsInfoModelItem(1, 2, [item1, item2])
        const param = new IDORunPlanParamModel(1,1,1,2023,11,23,14,0,0,0,[gpsInfo]);
        this.canceler = Cmds.setSendRunPlan(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWeatherV3: {
        const json: IWeatherV3ParamModelJson = {
          month: 11,
          day: 29,
          hour: 16,
          min: 30,
          sec: 0,
          week: 1,
          weather_type: 1,
          today_tmp: 19 + 100,
          today_max_temp: 33 + 100,
          today_min_temp: 15 + 100,
          city_name: "shenzhen",
          air_quality: 7,
          precipitation_probability: 40,
          humidity: 32,
          today_uv_intensity: 10,
          wind_speed: 5,
          wind_force: 5,
          sunrise_hour: 5,
          sunrise_min: 37,
          sunset_hour: 18,
          sunset_min: 49,
          sunrise_item_num: 3,
          air_grade_item: "big",
          hours_weather_items: [
            { weather_type: 7, temperature: 8 + 100, probability: 40 }
          ],
          future_items: [
            { weather_type: 6, max_temp: 33 + 100, min_temp: 8 + 100 }
          ],
          sunrise_item: [
            { sunrise_hour: 5, sunrise_min: 35, sunset_hour: 15, sunset_min: 35 },
            { sunrise_hour: 6, sunrise_min: 36, sunset_hour: 16, sunset_min: 36 },
            { sunrise_hour: 7, sunrise_min: 37, sunset_hour: 17, sunset_min: 37 }
          ],
          aqi_future_item: [23, 24, 25, 26, 27],
          aqi_history_item: [51, 52, 53, 54, 55, 56]
        };
        const param = IDOWeatherV3ParamModel.fromJson(json);
        this.canceler = Cmds.setWeatherV3(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWeatherSwitch: {
        this.canceler = Cmds.setWeatherSwitch(true, handleResponse);
        break;
      }
      case ApiEvtType.SetNoticeMessageState: {
        const json: INoticeMessageStateParamJson = {
          operat: 1,
          all_on_off: 1,
          all_send_num: 0,
          now_send_index: 0,
          items: [
            { evt_type: 15704, notify_state: 1, pic_flag: 1 },
            { evt_type: 3678, notify_state: 1, pic_flag: 1 },
          ]
        }
        const param = IDONoticeMessageStateParamModel.fromJson(json);
        this.canceler = Cmds.setNoticeMessageState(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWorldTimeV3: {
        const param = [
          IDOWorldTimeParamModel.fromJson({
            id: 31,
            min_offset: 480,
            city_name: "北京",
            sunrise_hour: 7,
            sunrise_min: 25,
            sunset_hour: 16,
            sunset_min: 49,
            longitude_flag: 1,
            longitude: 11641,
            latitude_flag: 1,
            latitude: 3990
          }),
          IDOWorldTimeParamModel.fromJson({
            id: 148,
            min_offset: 480,
            city_name: "伦敦",
            sunrise_hour: 7,
            sunrise_min: 25,
            sunset_hour: 16,
            sunset_min: 49,
            longitude_flag: 1,
            longitude: 11641,
            latitude_flag: 1,
            latitude: 3990
          }),
          IDOWorldTimeParamModel.fromJson({
            id: 197,
            min_offset: -300,
            city_name: "纽约",
            sunrise_hour: 7,
            sunrise_min: 25,
            sunset_hour: 16,
            sunset_min: 49,
            longitude_flag: 1,
            longitude: 11641,
            latitude_flag: 1,
            latitude: 3990
          })
        ];
        this.canceler = Cmds.setWorldTimeV3(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSchedulerReminderV3: {
        const item = IDOSchedulerReminderItem.fromJson({
          id: 1,
          year: 2024,
          mon: 11,
          day: 26,
          hour: 8,
          min: 0,
          sec: 0,
          repeat_type: 1,
          remind_on_off: 1,
          state: 2,
          title: "title1",
          note: "note1"
        });
        const  param = new IDOSchedulerReminderParamModel(3, [item])
        this.canceler = Cmds.setSchedulerReminder(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWatchFaceData: {
        const param = IDOWatchFaceParamModel.fromJson({operate: 1, file_name: "filename1", watch_file_size: 430});
        this.canceler = Cmds.setWatchFaceData(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSyncContact: {
        const param = new IDOSyncContactParamModel(2, [
          new IDOContactItem( "xx659",  "zhangsan1"),
          new IDOContactItem( "xx660",  "zhangsan2"),
          new IDOContactItem( "xx661",  "zhangsan3")
        ]);
        this.canceler = Cmds.setSyncContact(param, handleResponse);
        break;
      }
      case ApiEvtType.Set100SportSortV3: {
        const param = new IDOSport100SortParamModel(2, 2, [2, 3, 50, 198, 20, 32]);
        this.canceler = Cmds.setSport100Sort(param, handleResponse);
        break;
      }
      // case ApiEvtType.SetSportSortV3: {
      //   // TODO: 填充V3运动类型参数
      //   const param = { /* ... */ };
      //   this.canceler = Cmds.setSportSortV3(param, handleResponse);
      //   break;
      // }
      case ApiEvtType.GetHistoricalMenstruation: {
        const param = new IDOHistoricalMenstruationParamModel(7, 29, [
          new IDOHistoricalMenstruationParamItem(2023, 8, 1, 7, 30, 14, 5, 5),
          new IDOHistoricalMenstruationParamItem(2023, 9, 1, 7, 30, 14, 5, 5),
          new IDOHistoricalMenstruationParamItem(2023, 10, 1, 7, 30, 14, 5, 5)
        ]);;
        this.canceler = Cmds.setHistoricalMenstruation(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWatchDialSort: {
        const param = new IDOWatchDialSortParamModel([new IDOWatchDialSortItem(1, 1, "name1")]);
        this.canceler = Cmds.setWatchDialSort(param, handleResponse);
        break;
      }
      case ApiEvtType.SetWalkRemind: {
        const param = new IDOWalkRemindModel(1, 2000, 14, 0,  20, 0,
          [IDOWeek.Monday, IDOWeek.Tuesday, IDOWeek.Wednesday], 60, 1, 0, 0,  0, 0,  0);
        this.canceler = Cmds.setWalkRemind(param, handleResponse);
        break;
      }
      case ApiEvtType.SetMenstruation: {
        const param = IDOMenstruationModel.fromJson({on_off: 1,
          menstrual_length: 7,
          menstrual_cycle: 21,
          last_menstrual_year: 2022,
          last_menstrual_month: 12,
          last_menstrual_day: 19,
          ovulation_interval_day: 15,
          ovulation_before_day: 5,
          ovulation_after_day: 5,
          notify_flag: 1,
          menstrual_reminder_on_off: 1});
        this.canceler = Cmds.setMenstruation(param, handleResponse);
        break;
      }
      case ApiEvtType.SetCalorieDistanceGoal: {
        const param = IDOMainSportGoalModel.fromJson({
          calorie: 600, distance: 300, calorie_min: 130, calorie_max: 666, mid_high_time_goal: 600, walk_goal_time: 5, time_goal_type: 1
        });
        this.canceler = Cmds.setCalorieDistanceGoal(param, handleResponse);
        break;
      }
      case ApiEvtType.SetLostFind: {
        const param = new IDOLostFindParamModel(1);
        this.canceler = Cmds.setLostFind(param, handleResponse);
        break;
      }
      case ApiEvtType.SetFindPhone: {
        this.canceler = Cmds.setFindPhone(true, handleResponse);
        break;
      }
      case ApiEvtType.SetOnekeySOS: {
        this.canceler = Cmds.setOnekeySOS(true, 324234, handleResponse);
        break;
      }
      case ApiEvtType.SetSportModeSelect: {
        const param = new IDOSportModeSelectParamModel( 10,  4,  10,  19,  10,
          false,  false,  false,  false,  false,  false,  false,  false, false,  false,
          false,  false,  false,  false,  false,
          false,  false,  false,
          false,  false,  false,
          false,  false,  false,  false,
          false,  false,  false,  false,
          false,  false,  false);
        this.canceler = Cmds.setSportModeSelect(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSportModeSort: {
        let items = [
          new IDOSportModeSortParamModel( 1,  IDOSportType.SportTypeAerobics),
          new IDOSportModeSortParamModel( 2,  IDOSportType.SportTypeBMX),
          new IDOSportModeSortParamModel( 3,  IDOSportType.SportTypeGym),
          new IDOSportModeSortParamModel( 4,  IDOSportType.SportTypeHit)
        ]
        this.canceler = Cmds.setSportModeSort(items, handleResponse);
        break;
      }
      case ApiEvtType.SetAppletControl: {
        // 步骤1：先获取小程序
        Cmds.setAppletControl(new IDOAppletControlModel(3), (rs) => {
          if (rs.success) {
            const value = rs.value;
            if (value != null && value.infoItem.length > 0) {
              // 步骤2：启动小程序
              Cmds.setAppletControl(new IDOAppletControlModel(1, value.infoItem[0].appName), (res) => {
                if (res.success) {
                  this.resStr = res.value?.toJsonString() ?? "";
                  resolve();
                } else {
                  const err = res as IFailureResult<CmdError>
                  this.resStr = `code: ${err.error.code} msg: ${err.error.message}`;
                  reject(this.resStr);
                }
              })
            }else {
              this.resStr = "Mini Program Not Found"
              reject(this.resStr);
            }
          } else {
            const err = rs as IFailureResult<CmdError>;
            this.resStr = `code: ${err.error.code} msg: ${err.error.message}`;
            reject(this.resStr);
          }
        })
        break;
      }
      case ApiEvtType.SetDuringExercise: {
        const param = new IDOSettingsDuringExerciseModel(0xAA);
        this.canceler = Cmds.setDuringExercise(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSimpleHeartRateZone: {
        const param = new IDOSimpleHeartRateZoneSettingModel(100);
        this.canceler = Cmds.setSimpleHeartRateZone(param, handleResponse);
        break;
      }
      case ApiEvtType.SetSportingRemindSetting: {
        const param = new IDOSportingRemindSettingModel(
          48,  new DistanceRemind( true,  true,  2000),
          new CommonRangeRemind( true,  110,  30),
          new PaceRemind( true,  true,  60,  120),
          new CommonRangeRemind( true,  20,  10));
        this.canceler = Cmds.setSportingRemindSetting([param], handleResponse);
        break;
      }
      case ApiEvtType.SetActivitySwitch:{
        const param = new IDOActivitySwitchParamModel(1,0,1,1,1,1,1,1,1)
        this.canceler = Cmds.setActivitySwitch(param,handleResponse)
        break
      }

      default: {
        const str = `"未找到 ${this.funcInfo.name} 的实现，需在 FunctionDataViewModel -> doSend(..) 补充"`;
        console.debug(str);
        this.canceler = undefined;
        this.isProcessing = false;
        this.resStr = str;
        reject(str);
      }
    }
  }
}