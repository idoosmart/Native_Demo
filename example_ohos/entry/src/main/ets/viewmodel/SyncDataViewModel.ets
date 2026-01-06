import { sdk, IDOSyncDataType, } from "protocol_channel";

@Observed
export class SyncDataViewModel {
  private rejectFunc: ((reason?: Error | string) => void) | undefined;
  @Track progress: number = 0.0;
  @Track resStr: string = '';
  @Track isProcessing: boolean = false;

  async syncAll(): Promise<void> {
    this.progress = 0;
    this.resStr = '';
    this.isProcessing = true;
    this.resStr += `[${new Date().toLocaleTimeString()}] 开始同步数据...\n`;
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      sdk.syncData.startSync((progress) => {
        this.progress = progress;
      }, (type: IDOSyncDataType, jsonStr: string, errorCode: number) => {
        if (errorCode === 0) {
          this.resStr += `[${new Date().toLocaleTimeString()}] Sync type:${type}\n ${jsonStr}\n`
        } else {
          this.resStr += `[${new Date().toLocaleTimeString()}] Sync type:${type}\n Error code:${errorCode}\n`
        }
      }, (errorCode: number) => {
        this.isProcessing = false;
        if (errorCode === 0) {
          this.resStr += `[${new Date().toLocaleTimeString()}] Sync done\n`;
          resolve();
        } else {
          this.resStr += `[${new Date().toLocaleTimeString()}] Sync failure, error:${errorCode}\n`;
          reject();
        }
      });
    });
  }

  async syncWith(types: IDOSyncDataType[]): Promise<void> {
    this.progress = 0;
    this.resStr = '';
    this.isProcessing = true;
    this.resStr += `[${new Date().toLocaleTimeString()}] 开始同步数据...\n`;
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      sdk.syncData.startSyncCustom(
        types,
        (type: IDOSyncDataType, jsonStr: string, errorCode: number) => {
          if (errorCode === 0) {
            this.resStr += `Sync type:${type}\n ${jsonStr}\n`
          } else {
            this.resStr += `Sync type:${type}\n Error code:${errorCode}\n`
          }
        }, (errorCode: number) => {
        this.isProcessing = false;
        if (errorCode === 0) {
          this.resStr += "Sync done\n";
          resolve();
        } else {
          this.resStr += `Sync failure, error:${errorCode}\n`;
          reject();
        }
      });
    });
  }

  stop() {
    sdk.syncData.stopSync();
    if (this.rejectFunc) {
      this.rejectFunc('Operation stoped by user');
      this.rejectFunc = undefined;
    }
    this.isProcessing = false;
    this.resStr += `[${new Date().toLocaleTimeString()}] 停止同步数据。\n`;
  }
}