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
  PAGE_MESSAGE_NOTICE_S
} from '../utils/Routers';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { Tool } from 'protocol_channel/src/main/ets/pigeon_generate/Tools.g';
import { Tools } from '../utils/Tools';
import { common } from '@kit.AbilityKit';
import { BluetoothViewModel } from '../viewmodel/BluetoothViewModel';

@Builder
export function FunctionPageBuilder(name: string, navInfo: NavStackModel) {
  FunctionPage({ device: navInfo.param?.device, autoConnect: navInfo.param?.autoConnect })
}

@ComponentV2
struct FunctionPage {
  @Param device: IDOBleDeviceModel | null = null;
  @Param autoConnect: boolean = false;
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
    ActionSheet.show({
      title: '',
      message: '',
      sheets: [
        {
          title: $r('app.string.app_log'), action: () => {
          console.info('Action: Share App log');
        }
        },
        {
          title: $r('app.string.ble_log'), action: () => {
          console.info('Action: Share Ble log');
        }
        },
        {
          title: $r('app.string.device_log'), action: () => {
          console.info('Action: Share Device log');
        }
        }
      ],
      cancel: () => {
        console.info('ActionSheet canceled');
      }
    })
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