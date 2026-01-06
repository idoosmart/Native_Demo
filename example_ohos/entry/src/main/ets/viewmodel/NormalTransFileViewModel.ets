import {
  CmdError,
  Cmds,
  IDOCancellable,
  IDOTransBaseModel,
  IDOTransMusicModel,
  IDOTransNormalModel,
  IDOTransStatus,
  IDOTransType,
  IFailureResult,
  sdk
} from "protocol_channel";
import {
  IDOMusicItem,
  IDOMusicOperateParamModel as IDOMusicOperateParamModel
} from "protocol_channel/src/main/ets/components/model/IDOMusicOpearteParamModel";
import { Tools } from "../utils/Tools";

import fs from '@ohos.file.fs';
import hilog from '@ohos.hilog';
import { abilityAccessCtrl, common, Permissions } from "@kit.AbilityKit";

const LOG_TAG = 'PermissionManager';

@Observed
export class NormalTransFileViewModel {
  private rejectFunc: ((reason?: Error | string) => void) | undefined;
  private abilityContext: common.UIAbilityContext;
  private transType: IDOTransType = IDOTransType.ml;
  private filePath: string = '';
  private fileName: string = ''
  private canceler: IDOCancellable | null = null;
  @Track progress: number = 0.0;
  @Track resStr: string = '';
  @Track isProcessing: boolean = false;

  constructor(context: common.UIAbilityContext) {
    this.abilityContext = context
  }

  async send(transType: IDOTransType, filePath: string, fileName: string = 'tmp'): Promise<void> {
    this.transType = transType;
    this.filePath = filePath;
    this.fileName = fileName;
    this.progress = 0;
    this.resStr = '';
    this.isProcessing = true;
    this.resStr += `[${new Date().toLocaleTimeString()}] 开始发送文件...\n`;

    const newFilePath = await Tools.getInstance().copyFileToAppCache(this.abilityContext,filePath)
    if (newFilePath == null) {
      console.error("文件操作失败");
      return
    }

    this.filePath = newFilePath;

    if (this.transType === IDOTransType.mp3) {
      return this.music();
    } else {
      return this.other();
    }
  }

  cancel() {
    if (this.canceler) {
      this.canceler.cancel();
      this.canceler = null;
    }
    if (this.rejectFunc) {
      this.rejectFunc('Operation stoped by user');
      this.rejectFunc = undefined;
    }
    this.isProcessing = false;
    this.resStr += `[${new Date().toLocaleTimeString()}] 停止发送文件。\n`;
  }

  private async music(): Promise<void> {
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      // 示例代码（固定了musicId 1)
      let fileSize = Tools.getInstance().getFileSize(this.filePath)
      const musicItem = new IDOMusicItem(1, fileSize, "m1.mp3", "singer1");
      // 1、先删除设备上的该音乐（如果存在）
      const param = new IDOMusicOperateParamModel(1, 0, musicItem, null);
      const fileItem =
        new IDOTransMusicModel(this.filePath, musicItem.musicName, 0, musicItem.musicID, musicItem.singerName)
      Cmds.setMusicOperate(param, (rs) => {
        if (rs.success) {
          // 2、创建音乐
          const param = new IDOMusicOperateParamModel(2, 0, musicItem, null,);
          Cmds.setMusicOperate(param, (rs) => {
            if (rs.success) {
              this.doSend([fileItem], true, resolve);
            } else {
              const err = rs as IFailureResult<CmdError>
              console.debug(err.error.message);
              this.isProcessing = false;
              this.resStr += `result: ${err.error.message}`;
              reject();
            }
          })
        } else {
          const err = rs as IFailureResult<CmdError>
          console.debug(err.error.message);
          this.isProcessing = false;
          this.resStr += `result: ${err.error.message}`;
          reject();
        }
      });
    });
  }

  private async other(): Promise<void> {
    const fileItem = new IDOTransNormalModel(this.transType, this.filePath, this.fileName);
    return new Promise((resolve, reject) => {
      this.rejectFunc = reject;
      this.doSend([fileItem], true, resolve);
    });
  }

  private async doSend(fileItems: IDOTransBaseModel[], cancelPrevTranTask: boolean,
    resolve: (value: void | PromiseLike<void>) => void) {
    this.canceler = sdk.transfer.transferFiles(fileItems, cancelPrevTranTask,
      (currentIndex, totalCount, currentProgress, totalProgress) => {
        this.progress = totalProgress;
        let txt = `${new Date().toLocaleTimeString()} index: ${currentIndex + 1}/${totalCount} `
          + `${(currentProgress * 100).toFixed(2)}% / ${(totalProgress * 100).toFixed(2)}%\n`
        console.debug("progress "+txt);
        this.resStr += txt;
      }, (currentIndex, status, errorCode, finishingTime) => {
        console.debug(`trans currentIndex: ${currentIndex}, status: ${status}, errorCode: ${errorCode}`);
        if (status != IDOTransStatus.finished || errorCode != 0) {
          this.resStr += `${new Date().toLocaleTimeString()} failure, currentIndex:${currentIndex} errorCode:${errorCode}\n`;
        }
      }, (results: boolean[]) => {
        console.debug(`trans rs: ${results}`);
        this.isProcessing = false;
        this.resStr += `${new Date().toLocaleTimeString()} result: ${results}`;
        resolve()
      });
  }
}