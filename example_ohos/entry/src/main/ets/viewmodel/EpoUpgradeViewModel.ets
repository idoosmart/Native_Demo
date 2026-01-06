import {
  IDOEpoManager,
  IDOEpoManagerDelegate,
  IDOEpoUpgradeStatus,
  IDOOtaGpsInfo
} from "protocol_channel";
import { LocationManager } from "../utils/LocationManager";
import geoLocationManager from '@ohos.geoLocationManager';
import common from '@ohos.app.ability.common';
import { process } from '@kit.ArkTS';
import { runOnMainThread } from "protocol_channel/src/main/ets/components/protocol_sdk/ThreadUtil";

@Observed
export class EpoUpgradeViewModel implements IDOEpoManagerDelegate {
  private locationMgr: LocationManager | null = null;
  private abilityContext: common.UIAbilityContext;
  @Track longitude: number = 0;
  @Track latitude: number = 0;
  @Track altitude: number = 0;
  @Track isLocating: boolean = false;
  @Track status: IDOEpoUpgradeStatus = IDOEpoUpgradeStatus.idle;
  @Track downProgress: number = 0.0;
  @Track sendProgress: number = 0.0;
  @Track resStr2: string = '';
  @Track isProcessing: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.abilityContext = context;
    this.locationMgr = LocationManager.getInstance(this.abilityContext)
    IDOEpoManager.shared.enableAutoUpgrade = true;
    IDOEpoManager.shared.delegateGetGps = this;
    IDOEpoManager.shared.listenEpoUpgrade(
      (status) => {
        this.status = status;
        this.resStr2 += `\n[${new Date().toLocaleTimeString()}] status:${status}`;
        console.debug(this.resStr2)
      }, (downProgress) => {
      this.downProgress = downProgress;
      this.resStr2 += `\n[${new Date().toLocaleTimeString()}] down progress:${downProgress}`;
      console.debug(this.resStr2)
    }, (sendProgress) => {
      this.sendProgress = sendProgress;
      this.resStr2 += `\n[${new Date().toLocaleTimeString()}] send progress:${sendProgress}`;
      console.debug(this.resStr2)
    }, (errorCode) => {
      this.isProcessing = false;
      this.resStr2 += `\n[${new Date().toLocaleTimeString()}] complete:${errorCode === 0 ? "success" : "failure"} errCode:${errorCode}`;
      console.debug(this.resStr2)
    });
  }

  // 接收位置信息的回调函数
  private onLocationReceived = (locationData: geoLocationManager.Location) => {
    this.longitude = locationData.longitude;
    this.latitude = locationData.latitude;
    this.altitude = locationData.altitude;
  };

  public startInstall(isForce: boolean = false, retryCount: number = 3): void {
    this.locationMgr?.startLocationUpdates(this.onLocationReceived);
    this.isProcessing = true;
    IDOEpoManager.shared.willStartInstall(isForce, retryCount);
  }

  /**
   * 停止升级任务。
   *
   * 注：只支持下载中和发送中的任务，不支持正在升级的任务。
   */
  public stop(): void {
    this.isProcessing = false;
    IDOEpoManager.shared.stop();
    if (this.isLocating) {
      this.locationMgr?.stopLocationUpdates();
    }
  }

  /// 更新gps，设置热启动参数加速手表定位
  getAppGpsInfo(): IDOOtaGpsInfo | null {
    if (this.longitude > 0 && this.latitude > 0) {
      console.debug(`getAppGpsInfo - longitude: ${this.longitude}, altitude: ${this.altitude}`)
      return new IDOOtaGpsInfo(this.longitude, this.latitude, this.altitude);
    }
    return null;
  }
}
