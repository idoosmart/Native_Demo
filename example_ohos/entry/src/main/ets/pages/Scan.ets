import { hilog, IDOBleDeviceModel, sdk } from 'protocol_channel';
import { PAGE_FUNCTION_LIST, PAGE_TRANSFER_FILE } from '../utils/Routers';
import { BluetoothState, BluetoothViewModel } from '../viewmodel/BluetoothViewModel';
import { NavStackModel } from '../viewmodel/NavStackModel';

let storage = LocalStorage.getShared()

// 主应用组件
@Entry(storage)
@ComponentV2
struct BluetoothScanner {
  pageInfos: NavPathStack = new NavPathStack();
  private viewModel: BluetoothViewModel = BluetoothViewModel.getInstance();

  aboutToAppear(): void {
    console.debug("扫描页显示")
  }

  aboutToDisappear(): void {
    this.viewModel.stopScan();
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        // 状态指示器
        StatusIndicator({ state: this.viewModel.bluetoothState })
          .margin({
            bottom: 16,
            left: 16,
            right: 16
          })

        // 错误提示
        if (this.viewModel.bluetoothState.errorMessage) {
          Row() {
            Text(this.viewModel.bluetoothState.errorMessage)
              .fontSize(16)
              .fontColor('#F56C6C')
              .margin({ right: 8 })

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

        // 控制按钮
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

        // 已绑定设备列表标题
        if (this.viewModel.bluetoothState. bindDeviceList.length > 0) {
          Row() {
            Text(`绑定的设备`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#303133')
          }
          .padding({ left: 16, right: 16, bottom: 8 })
          .width('100%')

          // 绑定设备列表
          List({ space: 12 }) {
            ForEach(this.viewModel.bluetoothState.bindDeviceList, (device: IDOBleDeviceModel) => {
              ListItem() {
                DeviceListItem({ device: device })
              }.onClick(() => {
                this.viewModel.stopScan();
                this.pageInfos.pushPathByName(PAGE_FUNCTION_LIST,
                  new NavStackModel(PAGE_FUNCTION_LIST, { device: device,autoConnect:true}));
              })
            }, (device: IDOBleDeviceModel) => device.macAddress)
          }
        }

        // ota设备列表标题
        if (this.viewModel.bluetoothState.otaDeviceList.length > 0) {
          Row() {
            Text(`以下 ${this.viewModel.bluetoothState.otaDeviceList.length} 个设备在 OTA 中`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#303133')
          }
          .padding({ left: 16, right: 16, bottom: 8 })
          .width('100%')

          // ota设备列表
          List({ space: 12 }) {
            ForEach(this.viewModel.bluetoothState.otaDeviceList, (device: IDOBleDeviceModel) => {
              ListItem() {
                DeviceListItem({ device: device })
              }.onClick(() => {
                this.viewModel.stopScan();
                sdk.bridge.markOtaMode(device.macAddress ?? "", "", device.platform,
                  device.deviceId,device.otaMacAddress ?? device.macAddress ?? "", (success: boolean) => {
                    this.pageInfos.pushPathByName(PAGE_TRANSFER_FILE, new NavStackModel(PAGE_TRANSFER_FILE, {
                      device: device
                    }))
                  });
              })
            }, (device: IDOBleDeviceModel) => device.macAddress)
          }
        }

        // 设备列表标题
        Row() {
          Text(`扫描到 ${this.viewModel.bluetoothState.deviceList.length} 个设备`)
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

        // 设备列表
        List({ space: 12 }) {
          ForEach(this.viewModel.bluetoothState.deviceList, (device: IDOBleDeviceModel) => {
            ListItem() {
              DeviceListItem({ device: device })
            }.onClick(() => {
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
    }
  }
}


// 设备列表项组件
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
        .fontColor(this.device?.rssi ?? 0 > -70 ? '#67C23A' : (this.device?.rssi ?? 0 > -85 ? '#E6A23C' : '#F56C6C'))
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

// 状态指示器组件
@ComponentV2
struct StatusIndicator {
  @Param state: BluetoothState | null = null;

  build() {
    Column() {
      // 状态消息
      Text(this.state?.statusMessage)
        .fontSize(18)
        .fontColor(this.state?.hasPermission ? '#67C23A' : '#F56C6C')
        .margin({ bottom: 8 })

      // 权限和蓝牙状态指示
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
