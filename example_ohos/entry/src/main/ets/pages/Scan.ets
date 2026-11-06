import { IDOBleDeviceModel, sdk } from 'protocol_channel';
import { PAGE_FUNCTION_LIST, PAGE_TRANSFER_FILE } from '../utils/Routers';
import { BluetoothState, BluetoothViewModel } from '../viewmodel/BluetoothViewModel';
import { NavStackModel } from '../viewmodel/NavStackModel';

/**
 * 添加设备 / 扫描页（对齐 iOS ScanPageVC）
 */
@Builder
export function ScanPageBuilder(name: string, navInfo: NavStackModel) {
  ScanPage()
}

@ComponentV2
struct ScanPage {
  private viewModel: BluetoothViewModel = BluetoothViewModel.getInstance();
  private pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    this.viewModel.startScan(getContext(this));
  }

  aboutToDisappear(): void {
    this.viewModel.stopScan();
  }

  private reloadScan(): void {
    this.viewModel.stopScan().then(() => {
      this.viewModel.startScan(getContext(this));
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          StatusIndicator({ state: this.viewModel.bluetoothState })
            .margin({
              bottom: 16,
              left: 16,
              right: 16,
              top: 8
            })

          if (this.viewModel.bluetoothState.errorMessage) {
            Row() {
              Text(this.viewModel.bluetoothState.errorMessage)
                .fontSize(16)
                .fontColor('#F56C6C')
                .margin({ right: 8 })
                .layoutWeight(1)

              Button('关闭')
                .type(ButtonType.Capsule)
                .width(60)
                .height(32)
                .fontSize(14)
                .backgroundColor('#F56C6C')
                .onClick(() => this.viewModel.clearError())
            }
            .padding(12)
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .backgroundColor('#FFF6F6')
            .borderRadius(8)
            .margin({ left: 16, right: 16, bottom: 16 })
          }

          Row({ space: 16 }) {
            if (!this.viewModel.bluetoothState.hasPermission) {
              Button('申请权限')
                .width('100%')
                .height(50)
                .fontSize(18)
                .backgroundColor('#409EFF')
                .onClick(() => this.viewModel.requestPermission(getContext(this)))
            } else if (this.viewModel.bluetoothState.isScanning) {
              Button('停止扫描')
                .width('100%')
                .height(50)
                .fontSize(18)
                .backgroundColor('#F56C6C')
                .onClick(() => this.viewModel.stopScan())
            } else {
              Button('开始扫描')
                .width('100%')
                .height(50)
                .fontSize(18)
                .backgroundColor('#67C23A')
                .onClick(() => this.viewModel.startScan(getContext(this)))
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })

          if (this.viewModel.bluetoothState.otaDeviceList.length > 0) {
            Row() {
              Text(`以下 ${this.viewModel.bluetoothState.otaDeviceList.length} 个设备在 OTA 中`)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#303133')
            }
            .padding({ left: 16, right: 16, bottom: 8 })
            .width('100%')

            List({ space: 12 }) {
              ForEach(this.viewModel.bluetoothState.otaDeviceList, (device: IDOBleDeviceModel) => {
                ListItem() {
                  DeviceListItem({ device: device })
                }.onClick(() => {
                  this.viewModel.stopScan();
                  sdk.bridge.markOtaMode(device.macAddress ?? '', '', device.platform,
                    device.deviceId, device.otaMacAddress ?? device.macAddress ?? '', (_success: boolean) => {
                      this.pageInfos.pushPathByName(PAGE_TRANSFER_FILE, new NavStackModel(PAGE_TRANSFER_FILE, {
                        device: device
                      }))
                    });
                })
              }, (device: IDOBleDeviceModel) => device.macAddress)
            }
            .width('100%')
            .padding({ left: 16, right: 16, bottom: 8 })
          }

          Row() {
            Text(`扫描结果 / Scan · ${this.viewModel.bluetoothState.deviceList.length}`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#303133')

            Blank()

            if (this.viewModel.bluetoothState.isScanning) {
              LoadingProgress()
                .color(Color.Blue)
                .width(24)
                .height(24)
            }
          }
          .padding({ left: 16, right: 16, bottom: 8 })
          .width('100%')

          List({ space: 12 }) {
            ForEach(this.viewModel.bluetoothState.deviceList, (device: IDOBleDeviceModel) => {
              ListItem() {
                DeviceListItem({ device: device })
              }.onClick(() => {
                if (device.isOta && device.deviceId === 0) {
                  return;
                }
                this.viewModel.stopScan();
                this.pageInfos.pushPathByName(PAGE_FUNCTION_LIST,
                  new NavStackModel(PAGE_FUNCTION_LIST, { device: device }));
              })
            }, (device: IDOBleDeviceModel) => device.macAddress)
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: 16, right: 16 })
          .divider({ strokeWidth: 1, color: '#EBEEF5' })
        }
        .width('100%')
        .height('100%')

        Button('刷新')
          .type(ButtonType.Circle)
          .width(64)
          .height(64)
          .fontSize(14)
          .backgroundColor('#409EFF')
          .margin({ right: 20, bottom: 30 })
          .onClick(() => this.reloadScan())
      }
      .width('100%')
      .height('100%')
    }
    .title($r('app.string.add_device'))
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onShown(() => {
      if (!this.viewModel.bluetoothState.isScanning) {
        this.viewModel.startScan(getContext(this));
      }
    })
    .onHidden(() => {
      this.viewModel.stopScan();
    })
  }
}

@ComponentV2
struct DeviceListItem {
  @Param device: IDOBleDeviceModel | null = null;

  build() {
    Row() {
      Column() {
        Text(`${this.device?.name} (${this.device?.deviceId})`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#303133')

        Text(`mac: ${this.device?.macAddress}`)
          .fontSize(14)
          .fontColor('#909399')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(`${this.device?.rssi} dBm`)
        .fontSize(16)
        .fontColor((this.device?.rssi ?? 0) > -70 ? '#67C23A' :
          ((this.device?.rssi ?? 0) > -85 ? '#E6A23C' : '#F56C6C'))
        .margin({ left: 10 })
    }
    .padding({
      top: 6,
      bottom: 6,
      left: 16,
      right: 16
    })
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
  }
}

@ComponentV2
struct StatusIndicator {
  @Param state: BluetoothState | null = null;

  build() {
    Column() {
      Text(this.state?.statusMessage)
        .fontSize(18)
        .fontColor(this.state?.hasPermission ? '#67C23A' : '#F56C6C')
        .margin({ bottom: 8 })

      Row({ space: 20 }) {
        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill(this.state?.hasPermission ? '#67C23A' : '#F56C6C')
            .margin({ right: 8 })
          Text('权限')
            .fontSize(14)
            .fontColor('#606266')
        }

        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill(this.state?.bluetoothEnabled ? '#67C23A' : '#F56C6C')
            .margin({ right: 8 })
          Text('蓝牙')
            .fontSize(14)
            .fontColor('#606266')
        }

        Row() {
          Circle()
            .width(12)
            .height(12)
            .fill(this.state?.isScanning ? '#67C23A' : '#F56C6C')
            .margin({ right: 8 })
          Text('扫描')
            .fontSize(14)
            .fontColor('#606266')
        }
      }
    }
    .padding(16)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
  }
}
