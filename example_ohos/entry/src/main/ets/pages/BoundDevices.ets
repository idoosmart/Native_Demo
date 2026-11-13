import { IDOBleDeviceModel, sdk } from 'protocol_channel';
import { promptAction } from '@kit.ArkUI';
import { BluetoothViewModel } from '../viewmodel/BluetoothViewModel';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { PAGE_FUNCTION_LIST, PAGE_SCAN } from '../utils/Routers';
import { Tools } from '../utils/Tools';

let storage = LocalStorage.getShared();

/**
 * 已绑定设备首页（对齐 iOS MainPageVC）
 * Bound devices home page (aligned with iOS MainPageVC)
 */
@Entry(storage)
@ComponentV2
struct BoundDevices {
  pageInfos: NavPathStack = new NavPathStack();
  private viewModel: BluetoothViewModel = BluetoothViewModel.getInstance();
  private isUnbinding: boolean = false;

  aboutToAppear(): void {
    this.viewModel.refreshBindDeviceList();
  }

  private openScanPage(): void {
    this.pageInfos.pushPathByName(PAGE_SCAN, new NavStackModel(PAGE_SCAN));
  }

  private openFunctionPage(device: IDOBleDeviceModel): void {
    this.pageInfos.pushPathByName(
      PAGE_FUNCTION_LIST,
      new NavStackModel(PAGE_FUNCTION_LIST, { device: device, autoConnect: true })
    );
  }

  private forceUnbind(device: IDOBleDeviceModel): void {
    if (this.isUnbinding) {
      return;
    }
    const macAddress = device.macAddress ?? '';
    if (macAddress.length === 0) {
      return;
    }
    this.isUnbinding = true;
    promptAction.showToast({ message: 'unbind...' });
    sdk.cmd.unbind(macAddress, true, (rs: boolean) => {
      this.isUnbinding = false;
      if (rs) {
        Tools.getInstance().setBindState(macAddress, false);
        Tools.getInstance().removeBindDevice(macAddress);
        this.viewModel.refreshBindDeviceList();
        sdk.ble.cancelConnect(macAddress, (_success: boolean) => {
        });
        promptAction.showToast({ message: 'unbind successful' });
      } else {
        promptAction.showToast({ message: 'unbind failure' });
      }
    });
  }

  @Builder
  private endSwipeAction(device: IDOBleDeviceModel) {
    Button('解绑 / Unbind')
      .type(ButtonType.Capsule)
      .backgroundColor('#F56C6C')
      .fontColor(Color.White)
      .height('100%')
      .padding({ left: 16, right: 16 })
      .onClick(() => this.forceUnbind(device))
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Row() {
          Text($r('app.string.bound_devices_title'))
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor('#303133')
            .layoutWeight(1)

          Button($r('app.string.add_device_short'))
            .type(ButtonType.Capsule)
            .height(36)
            .fontSize(14)
            .backgroundColor('#409EFF')
            .onClick(() => this.openScanPage())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 12 })

        if (this.viewModel.bluetoothState.bindDeviceList.length === 0) {
          Column({ space: 16 }) {
            Text($r('app.string.bound_devices_empty'))
              .fontSize(15)
              .fontColor('#909399')
            Button($r('app.string.add_device'))
              .type(ButtonType.Capsule)
              .height(44)
              .fontSize(16)
              .backgroundColor('#409EFF')
              .onClick(() => this.openScanPage())
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 12 }) {
            ForEach(this.viewModel.bluetoothState.bindDeviceList, (device: IDOBleDeviceModel) => {
              ListItem() {
                BoundDeviceListItem({ device: device })
              }
              .swipeAction({
                end: {
                  builder: () => {
                    this.endSwipeAction(device)
                  }
                }
              })
              .onClick(() => this.openFunctionPage(device))
            }, (device: IDOBleDeviceModel) => device.macAddress ?? '')
          }
          .layoutWeight(1)
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')
      .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean) => {
        if (isVisible) {
          this.viewModel.refreshBindDeviceList();
        }
      })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
  }
}

@ComponentV2
struct BoundDeviceListItem {
  @Param device: IDOBleDeviceModel | null = null;

  private titleText(): string {
    let name = this.device?.name ?? '';
    const deviceId = this.device?.deviceId ?? 0;
    if (deviceId !== 0) {
      name = `${name}(${deviceId})`;
    }
    return name.length > 0 ? name : (this.device?.macAddress ?? 'unknown');
  }

  build() {
    Column() {
      Text(this.titleText())
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#303133')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(`${this.device?.macAddress ?? 'unknown'} - bound`)
        .fontSize(12)
        .fontColor('#909399')
        .margin({ top: 4 })
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .width('100%')
    .padding({
      top: 12,
      bottom: 12,
      left: 16,
      right: 16
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#E8F4FF')
    .borderRadius(12)
  }
}
