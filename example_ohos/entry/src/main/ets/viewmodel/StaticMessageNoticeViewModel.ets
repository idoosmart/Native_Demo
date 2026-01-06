// entry/src/main/ets/viewmodel/MessageNoticeViewModel.ets
import {
  Cmds,
  IDONoticeCallSwitchState,
  IDONoticeMsgAllSwitchState,
  IDONoticeNotifySwitchState,
  IDOSetNoticeStatusModel
} from "protocol_channel";
import { util } from "@kit.ArkTS";
import { Cmd } from "protocol_channel/src/main/ets/pigeon_generate/Cmd.g";

export class ToggleItem {
  id: string;
  icon: Resource | string;
  label: Resource | string;
  isOn: boolean;

  constructor(id: string, icon: Resource | string, label: Resource | string, isOn: boolean) {
    this.id = id;
    this.icon = icon;
    this.label = label;
    this.isOn = isOn;
  }
}

export class StaticMessageNoticeViewModel {
  private statusModel?: IDOSetNoticeStatusModel | null;
  @Track systemApps: ToggleItem[] = [];
  @Track thirdPartyApps: ToggleItem[] = [];
  @Track isOnCallSwitch: boolean = false
  @Track allSwitch: boolean = false
  @Track resStr: string = '';
  @Track isProcessing: boolean = false;

  async fetchData(): Promise<void> {
    this.isProcessing = true;
    return new Promise((resolve, reject) => {
      Cmds.getNoticeStatus((rs) => {
        if (rs.success) {
          this.statusModel = rs.value
          this.systemApps = [];
          this.thirdPartyApps = [];
          this.isOnCallSwitch = false
          this.allSwitch = false

          if (rs.value == null) {
            this.isProcessing = false;
            resolve();
            return;
          }

          this.isOnCallSwitch = rs.value!.callSwitch === IDONoticeCallSwitchState.ON;
          this.allSwitch = rs.value!.msgAllSwitch === IDONoticeMsgAllSwitchState.ON;

          this.systemApps = [
            new ToggleItem(util.generateRandomUUID(true), '',
              $r('app.string.sms'), this.statusModel!.isOnSms),
            new ToggleItem(util.generateRandomUUID(true), '',
              $r('app.string.calendar'), this.statusModel!.isOnCalendar),
            new ToggleItem(util.generateRandomUUID(true), '',
              $r('app.string.email'), this.statusModel!.isOnEmail),
            new ToggleItem(util.generateRandomUUID(true), '',
              $r('app.string.missed_call'), this.statusModel!.isOnDidNotCall)
          ];

          this.thirdPartyApps = [
            new ToggleItem(util.generateRandomUUID(true), '',
              $r('app.string.wechat'), this.statusModel!.isOnSms),
            new ToggleItem(util.generateRandomUUID(true), '',
              'qq', this.statusModel!.isOnQq),
            new ToggleItem(util.generateRandomUUID(true), '',
              'Facebook', this.statusModel!.isOnFaceBook),
            new ToggleItem(util.generateRandomUUID(true), '',
              'X', this.statusModel!.isOnTwitter)
          ];
          this.isProcessing = false;
          resolve();
        } else {
          this.isProcessing = false;
          reject();
        }
      });
    });
  }

  async updateMsgSwitch(): Promise<void> {
    this.isProcessing = true;
    return new Promise((resolve, reject) => {
      if (this.statusModel == null) {
        this.isProcessing = false;
        reject();
        return;
      }
      this.statusModel!.callSwitch = this.isOnCallSwitch ? IDONoticeCallSwitchState.ON : IDONoticeCallSwitchState.OFF;
      this.statusModel!.msgAllSwitch = this.allSwitch ? IDONoticeMsgAllSwitchState.ON : IDONoticeMsgAllSwitchState.OFF;
      this.statusModel!.notifySwitch =
        this.allSwitch ? IDONoticeNotifySwitchState.SETTING_SUB_SWITCH : IDONoticeNotifySwitchState.BLE_OFF;
      Cmds.setNoticeStatus(this.statusModel!, (rs) => {
        this.isProcessing = false;
        if (rs.success) {
          resolve();
        } else {
          reject();
        }
      })
    });
  }
}
