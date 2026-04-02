import { CommonListItem } from '../components/CommonListItem';
import { Cmds, IDOBleDeviceModel, sdk } from 'protocol_channel';
import { DeviceStateViewModel } from '../viewmodel/FunctionListViewModel';
import {
  PAGE_GET_FUNCTION_LIST,
  PAGE_SET_FUNCTION_LIST,
  PAGE_SYNC_DATA,
  PAGE_TRANSFER_FILE,
  PAGE_MESSAGE_NOTICE,
  PAGE_SPORT,
  PAGE_EPO_UPGRADE,
  PAGE_MESSAGE_NOTICE_S,
  PAGE_MUSIC_PLAYER
} from '../utils/Routers';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { Tool } from 'protocol_channel/src/main/ets/pigeon_generate/Tools.g';
import { Tools } from '../utils/Tools';
import { common } from '@kit.AbilityKit';
import { BluetoothViewModel } from '../viewmodel/BluetoothViewModel';
import { IDODeviceLogType } from 'protocol_channel/src/main/ets/components/protocol_sdk/impl/DeviceLogImpl';
import { promptAction } from '@kit.ArkUI';
import { BusinessError, zlib } from '@kit.BasicServicesKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { systemShare } from '@kit.ShareKit';
import fs from '@ohos.file.fs';

@Builder
export function FunctionPageBuilder(name: string, navInfo: NavStackModel) {
  FunctionPage({ device: navInfo.param?.device, autoConnect: navInfo.param?.autoConnect })
}

@ObservedV2
class FunctionPageState {
  @Trace isShareLogSheetShown: boolean = false;
}

@ComponentV2
struct FunctionPage {
  @Param device: IDOBleDeviceModel | null = null;
  @Param autoConnect: boolean = false;
  private uiState: FunctionPageState = new FunctionPageState();
  private viewModel: DeviceStateViewModel = DeviceStateViewModel.getInstance();
  private abilityContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    if (this.device == null) {
      this.pageInfos.pop()
      return;
    }
    this.viewModel.setDevice(this.device!)
  }

  showShareLogSheet() {
    this.uiState.isShareLogSheetShown = true;
  }

  private shareAppLog(): void {
    console.info('Action: Share App log');
    this.uiState.isShareLogSheetShown = false;
    sdk.tool.exportLog((zipFilePath) => {
      void this.shareExportedPath(zipFilePath, 'app_log', '应用日志');
    });
  }

  private shareBleLog(): void {
    console.info('Action: Share Ble log');
    this.uiState.isShareLogSheetShown = false;
    sdk.ble.exportLog((path) => {
      void this.shareExportedPath(path, 'ble_log', '蓝牙日志');
    });
  }

  private shareDeviceLog(): void {
    console.info('Action: Share Device log');
    this.uiState.isShareLogSheetShown = false;
    promptAction.showToast({ message: '开始导出设备日志，请稍候' });
    sdk.deviceLog.startGet(
      [IDODeviceLogType.general],
      60,
      (progress: number) => {
        console.info(`进度 ${progress}% `);
      },
      (success: boolean) => {
        console.info(`操作完成，结果: ${success}`);
        if (!success) {
          promptAction.showToast({ message: '设备日志导出失败' });
          return;
        }
        void this.shareDeviceLogZip(sdk.deviceLog.logDirPath);
      }
    );
  }

  @Builder
  private shareLogSheetBuilder() {
    Column({ space: 10 }) {
      Text('分享日志')
        .width('100%')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .textAlign(TextAlign.Start)
        .padding({ bottom: 8 })

      Button($r('app.string.app_log'))
        .width('100%')
        .height(60)
        .type(ButtonType.Normal)
        .fontSize(17)
        .fontColor('#182431')
        .backgroundColor('#F3F5F7')
        .borderRadius(16)
        .onClick(() => this.shareAppLog())

      Button($r('app.string.ble_log'))
        .width('100%')
        .height(60)
        .type(ButtonType.Normal)
        .fontSize(17)
        .fontColor('#182431')
        .backgroundColor('#F3F5F7')
        .borderRadius(16)
        .onClick(() => this.shareBleLog())

      Button($r('app.string.device_log'))
        .width('100%')
        .height(60)
        .type(ButtonType.Normal)
        .fontSize(17)
        .fontColor('#182431')
        .backgroundColor('#F3F5F7')
        .borderRadius(16)
        .onClick(() => this.shareDeviceLog())

      Button('取消')
        .width('100%')
        .height(60)
        .type(ButtonType.Normal)
        .fontSize(17)
        .fontColor('#5B6670')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .border({ width: 1, color: '#DCE2E8' })
        .margin({ top: 4 })
        .onClick(() => {
          this.uiState.isShareLogSheetShown = false;
        })
    }
    .width('100%')
    .padding({ top: 8, left: 16, right: 16, bottom: 24 })
  }

  private async shareExportedPath(path: string | null | undefined, defaultName: string, description: string): Promise<void> {
    if (!path || path.length === 0) {
      promptAction.showToast({ message: `${description}不存在，无法分享` });
      return;
    }

    try {
      const stat = fs.statSync(path);
      const isDirectory = stat.isDirectory();
      const fileName = path.substring(path.lastIndexOf('/') + 1) || defaultName;
      const utdType = isDirectory
        ? utd.UniformDataType.DIRECTORY
        : this.getFileUtdType(path);

      const shareData = new systemShare.SharedData({
        utd: utdType,
        uri: fileUri.getUriFromPath(path),
        title: fileName,
        description: `${description}分享`
      });

      const controller = new systemShare.ShareController(shareData);
      await controller.show(this.abilityContext, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DETAIL
      });
      console.info(`Share panel opened for ${path}`);
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Share failed, code=${err.code}, message=${err.message}`);
      promptAction.showToast({ message: `分享失败: ${err.message ?? '未知错误'}` });
    }
  }

  private async shareDeviceLogZip(logDirPath: string | null | undefined): Promise<void> {
    if (!logDirPath || logDirPath.length === 0) {
      promptAction.showToast({ message: '设备日志目录不存在，无法压缩分享' });
      return;
    }

    try {
      promptAction.showToast({ message: '设备日志导出完成，开始打包 zip' });
      const zipPath = await this.compressDirectoryToZip(logDirPath, 'device_log');
      await this.shareExportedPath(zipPath, 'device_log.zip', '设备日志');
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Compress device log failed, code=${err.code}, message=${err.message}`);
      promptAction.showToast({ message: `设备日志打包失败: ${err.message ?? '未知错误'}` });
    }
  }

  private async compressDirectoryToZip(dirPath: string, fileNamePrefix: string): Promise<string> {
    const files = this.collectFilesRecursively(dirPath);
    if (files.length === 0) {
      throw new Error('日志目录为空');
    }

    const shareDir = `${this.abilityContext.cacheDir}/shared_logs`;
    if (!fs.accessSync(shareDir)) {
      fs.mkdirSync(shareDir, true);
    }

    const zipPath = `${shareDir}/${fileNamePrefix}_${Date.now()}.zip`;
    if (fs.accessSync(zipPath)) {
      fs.unlinkSync(zipPath);
    }

    await zlib.compressFiles(files, zipPath, {
      level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION
    });
    return zipPath;
  }

  private collectFilesRecursively(dirPath: string): string[] {
    const result: string[] = [];
    const childNames = fs.listFileSync(dirPath);
    for (let i = 0; i < childNames.length; i++) {
      const childPath = `${dirPath}/${childNames[i]}`;
      const stat = fs.statSync(childPath);
      if (stat.isDirectory()) {
        result.push(...this.collectFilesRecursively(childPath));
      } else if (stat.isFile()) {
        result.push(childPath);
      }
    }
    return result;
  }

  private getFileUtdType(path: string): string {
    const fileName = path.substring(path.lastIndexOf('/') + 1);
    const dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex === fileName.length - 1) {
      return utd.UniformDataType.FILE;
    }

    const fileExt = fileName.substring(dotIndex);
    return utd.getUniformDataTypeByFilenameExtension(fileExt, utd.UniformDataType.FILE);
  }

  navigateTo(url: string) {
    this.pageInfos.pushPathByName(url, new NavStackModel(url, {
      device: this.device
    }))
  }

  onDeviceConnect() {
    if (this.autoConnect) {
      this.viewModel.autoConnect(this.device)
    } else {
      this.viewModel.connect(this.device);
    }
  }

  onDeviceDisconnect() {
    this.viewModel.disconnect(this.device);
  }

  onDeviceBind() {
    this.viewModel.bind();
  }

  onDeviceUnbind() {
    this.viewModel.unbind();
  }

  build() {
    NavDestination() {
      Column() {
        List({ space: 12 }) {
          // --- Section 1: Device Info ---
          ListItemGroup() {
            ListItem() {
              Column({ space: 4 }) {
                Text($r('app.string.current_device', this.device?.name)).fontSize(14)
                Text($r('app.string.mac_address', this.device?.macAddress)).fontSize(14)
                Row() {
                  Text($r('app.string.connect_state', this.viewModel.deviceState.getConnectStateDes()))
                    .fontSize(14).fontColor(this.viewModel.deviceState.isConnected ? '#00ff00' : '#ff0000')
                  Blank()
                  if (this.viewModel.deviceState.isDoing) {
                    LoadingProgress()
                      .color(Color.Blue)
                      .width(16)
                      .height(16)
                  }
                }
                .padding({ top: 8 })
                .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding({
                top: 12,
                bottom: 12,
                left: 16,
                right: 16
              })
            }
          }
          .backgroundColor($r('app.color.component_bg'))
          .borderRadius(16)

          // --- Section 2: Device Actions ---
          ListItemGroup() {
            if (!this.viewModel.deviceState.isConnected) {
              ListItem() {
                Text($r('app.string.device_connect')).fontSize(16).padding(16)
              }.width('100%').align(Alignment.Start)
              .onClick(() => this.onDeviceConnect())
            }
            if (this.viewModel.deviceState.isConnected) {
              ListItem() {
                Text($r('app.string.device_disconnect')).fontSize(16).padding(16)
              }.width('100%').align(Alignment.Start)
              .onClick(() => this.onDeviceDisconnect())
            }

            if (this.viewModel.deviceState.isConnected && !this.viewModel.deviceState.isBind) {
              ListItem() {
                Text($r('app.string.device_bind')).fontSize(16).padding(16)
              }.width('100%').align(Alignment.Start)
              .onClick(() => this.onDeviceBind())
            }

            if (this.viewModel.deviceState.isConnected && this.viewModel.deviceState.isBind) {
              ListItem() {
                Text($r('app.string.device_unbind')).fontSize(16).padding(16)
              }.width('100%').align(Alignment.Start)
              .onClick(() => this.onDeviceUnbind())
            }
            if (this.viewModel.deviceState.isOta) {
              ListItem() {
                Text($r('app.string.go_ota')).fontSize(16).padding(16)
              }.width('100%').align(Alignment.Start)
              .onClick(() => {
                //思澈平台 ota 需要传入设备的虚拟 mac ，这里从 ble 模块当前设备获取 otaMacAddress，该 mac 地址在蓝牙库中检测到设备处于 ota 状态后赋值
                let bleDevice = sdk.ble.getCurrentBleDevice();
                sdk.bridge.markOtaMode(bleDevice?.macAddress ?? "", "",
                  bleDevice?.platform ?? 0, bleDevice?.deviceId ?? 0, sdk.ble.getCurrentBleDevice().otaMacAddress,
                  (success: boolean) => {
                    this.pageInfos.pushPathByName(PAGE_TRANSFER_FILE, new NavStackModel(PAGE_TRANSFER_FILE, {
                      device: bleDevice
                    }))
                  })
              })
            }
          }
          .backgroundColor($r('app.color.component_bg'))
          .borderRadius(16)
          .divider({
            strokeWidth: $r('app.float.divider_height'),
            color: $r('app.color.divider_color'),
            startMargin: 16,
            endMargin: 16
          })

          // --- Section 3: Feature Navigation ---
          if (this.viewModel.deviceState.isConnected && this.viewModel.deviceState.isBind) {
            ListItemGroup() {
              CommonListItem({ title: $r('app.string.get_function') })
                .onClick(() => {
                  this.navigateTo(PAGE_GET_FUNCTION_LIST);
                })
              CommonListItem({ title: $r('app.string.set_function') })
                .onClick(() => {
                  this.navigateTo(PAGE_SET_FUNCTION_LIST);
                })
              CommonListItem({ title: $r('app.string.sync_data') })
                .onClick(() => {
                  this.navigateTo(PAGE_SYNC_DATA);
                })
              CommonListItem({ title: $r('app.string.transfer_file') })
                .onClick(() => {
                  this.navigateTo(PAGE_TRANSFER_FILE);
                })
              CommonListItem({ title: $r('app.string.epo_upgrade') })
                .onClick(() => {
                  this.navigateTo(PAGE_EPO_UPGRADE);
                })
              CommonListItem({ title: $r('app.string.sport') })
                .onClick(() => {
                  this.navigateTo(PAGE_SPORT);
                })
              CommonListItem({ title: '音乐控制' })
                .onClick(() => {
                  this.navigateTo(PAGE_MUSIC_PLAYER);
                })
              if (sdk.funcTable.reminderMessageIcon) {
                CommonListItem({ title: $r('app.string.message_notice') })
                  .onClick(() => {
                    this.navigateTo(PAGE_MESSAGE_NOTICE);
                  })
              } else {
                CommonListItem({ title: $r('app.string.message_notice') })
                  .onClick(() => {
                    this.navigateTo(PAGE_MESSAGE_NOTICE_S);
                  })
              }
              CommonListItem({ title: 'Other test' })
                .onClick(async () => {
                  let rs = await Tools.getInstance().requestNotificationPermission(this.abilityContext)
                  if (rs) {
                    await this.viewModel.sendNotificationMsg(this.abilityContext)
                  }
                })

            }
            .backgroundColor($r('app.color.component_bg'))
            .borderRadius(16)
            .divider({
              strokeWidth: $r('app.float.divider_height'),
              color: $r('app.color.divider_color'),
              startMargin: 16
            })
          }

        }
        .width('100%')
        .layoutWeight(1)
        .padding({
          top: 12,
          left: 12,
          right: 12,
          bottom: 12
        }).alignListItem(ListItemAlign.Start)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_bg'))
      .bindSheet(this.uiState.isShareLogSheetShown, this.shareLogSheetBuilder(), {
        showClose: false,
        dragBar: true,
        height: 360,
        backgroundColor: '#FFFFFF',
        onDisappear: () => {
          this.uiState.isShareLogSheetShown = false;
        }
      })
    }.onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    }).title('功能页面').menus([
      {
        'value': "", 'icon': 'resources/base/media/menu_more.svg', action: () => {
        this.showShareLogSheet();
      }
      },
    ])

  }
}
