import {
  CmdError,
  Cmds,
  IDOCancellable,
  IDOTransBaseModel,
  IDOTransNormalModel,
  IDOTransStatus,
  IDOTransType,
  IDOWatchFaceParamModel,
  IDOWatchItem,
  IDOWatchListModel,
  IFailureResult,
  sdk
} from "protocol_channel";
import { Tools } from "../utils/Tools";
import { common } from "@kit.AbilityKit";

@Observed
export class WatchFaceViewModel {
  private rejectFunc: ((reason?: Error | string) => void) | undefined;
  private canceler: IDOCancellable | null = null;
  private abilityContext: common.UIAbilityContext;
  @Track progress: number = 0.0;
  @Track resStr: string = '';
  @Track isProcessing: boolean = false;
  @Track currentWatchFaceListModel?: IDOWatchListModel | null;
  @Track watchList: IDOWatchItem[] = []

  constructor(context: common.UIAbilityContext) {
    this.abilityContext = context
  }

  async getWatchList(): Promise<IDOWatchListModel | null> {
    this.isProcessing = true;
    const rs = await this.doGetWatchList();
    this.isProcessing = false;
    return rs
  }

  checkInstalled(watchName: string): boolean {
    const rs = this.currentWatchFaceListModel?.items.find((item) => item.name == watchName)
    return rs != undefined;
  }

  checkNowShowWatchName(watchName: string): boolean {
    return this.currentWatchFaceListModel?.nowShowWatchName == watchName;
  }

  async install(transType: IDOTransType, filePath: string, fileName: string): Promise<void> {
    this.progress = 0;
    this.resStr = '';
    this.isProcessing = true;
    this.resStr += `[${new Date().toLocaleTimeString()}] 开始发送...\n`;
    return new Promise(async (resolve, reject) => {
      this.rejectFunc = reject;
      let newFilePath = await Tools.getInstance().copyFileToAppCache(this.abilityContext, filePath)
      if (newFilePath != null) {
        const item = new IDOTransNormalModel(transType, newFilePath, fileName, 0);
        this.doSend([item], true, resolve);
      }else {
        console.error("file copy fail");
        reject();
      }
    });
  }

  async uninstall(fileName: string): Promise<void> {
    this.resStr = '';
    this.isProcessing = true;
    const param = new IDOWatchFaceParamModel(2, fileName, 0);
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      Cmds.setWatchFaceData(param, async (rs) => {
        if (rs.success) {
          await this.doGetWatchList();
          this.isProcessing = false;
          resolve();
        } else {
          this.isProcessing = false;
          const err = rs as IFailureResult<CmdError>
          console.debug(err.error.message);
          reject();
        }
      });
    });
  }

  stop() {
    if (this.canceler) {
      this.canceler.cancel();
      this.canceler = null;
    }
    if (this.rejectFunc) {
      this.rejectFunc('Operation stoped by user');
      this.rejectFunc = undefined;
    }
    this.isProcessing = false;
    this.resStr += `[${new Date().toLocaleTimeString()}] 停止发送。\n`;
  }

  private async doGetWatchList(): Promise<IDOWatchListModel | null> {
    return new Promise((resolve, reject) => {
      Cmds.getWatchListV3((rs) => {
        if (rs.success) {
          this.currentWatchFaceListModel = rs.value;
          this.watchList = rs.value?.items ?? [];
          resolve(this.currentWatchFaceListModel);
        } else {
          reject();
        }
      })
    });
  }

  private async doSend(fileItems: IDOTransBaseModel[], cancelPrevTranTask: boolean,
    resolve: (value: void | PromiseLike<void>) => void) {
    this.canceler = sdk.transfer.transferFiles(fileItems, true,
      (currentIndex, totalCount, currentProgress, totalProgress) => {
        let txt = `[${new Date().toLocaleTimeString()}] index: ${currentIndex + 1}/${totalCount} `
          + `${(currentProgress * 100).toFixed(2)}% / ${(totalProgress * 100).toFixed(2)}%\n`
        this.resStr += txt;
      }, (currentIndex, status, errorCode, finishingTime) => {
        if (status != IDOTransStatus.finished || errorCode != 0) {
          this.resStr += `[${new Date().toLocaleTimeString()}] failure, currentIndex:${currentIndex} errorCode:${errorCode}\n`;
        }
      }, (results: boolean[]) => {
        this.isProcessing = false;
        this.resStr += `[${new Date().toLocaleTimeString()}] result: ${results}`;
        resolve()
      });
  }

  private checkCapacityFull(willInstallBytes: number): boolean {
    if (this.currentWatchFaceListModel != null) {
      return false;
    }
    let showFullAlertFalse = false
    let invalidCloudCount =
      this.currentWatchFaceListModel!.cloudWatchNum <= this.currentWatchFaceListModel!.userCloudWatchNum

    if (!sdk.funcTable.setWatchCapacitySizeDisplay) {
      showFullAlertFalse = invalidCloudCount
    } else {
      let invalidCapacity = (this.currentWatchFaceListModel!.userWatchCapacitySize + willInstallBytes) >
      this.currentWatchFaceListModel!.watchCapacitySize;
      showFullAlertFalse = invalidCloudCount || invalidCapacity;
    }
    return !showFullAlertFalse
  }

}