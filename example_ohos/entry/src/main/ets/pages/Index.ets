import common from '@ohos.app.ability.common';
import { IDOBleDeviceModel } from 'protocol_channel';

let storage = LocalStorage.getShared()
const EVENT_BACK_PRESS = 'EVENT_BACK_PRESS'
const DOMAIN = 1
const TAG = "Index"

@ObservedV2
class ScanState {
  @Trace devices: IDOBleDeviceModel[] = [];
}

@Entry(storage)
@ComponentV2
struct Index {
  private context = getContext(this) as common.UIAbilityContext
  scanState: ScanState = new ScanState();
  scroller: Scroller = new Scroller();

  build() {
    Column({ space: 30 }) { // 外部的 Column 容器
      Button("tartScan")
        .width('80%')
        .onClick(() => {
        })
      Scroll(this.scroller) {
        Column() {
          ForEach(this.scanState.devices, (item: IDOBleDeviceModel) => {
            Row() {
              Text('deviceId: ' + item.deviceId + '\n' + 'deviceName: ' + item.name + '\n' +
                'rssi: ' + item.rssi + '\n' + 'mac: ' + item.macAddress)
                .width('70%')
                .height(100)
                .backgroundColor(0xFFFFFF)
                .borderRadius(15)
                .fontSize(16)
                .textAlign(TextAlign.JUSTIFY)
                .margin(10)

              Button('connect')
                .width('20%')
                .margin(10)
                .onClick(() => {
                })
            }
            .backgroundColor(0xFFFFFF)
            .borderRadius(15)
            .margin(10)
          });

        }.width('100%')
      }
      .margin({ top: 5 })
      .height('55%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.On)
      .scrollBarColor(Color.White)
      .scrollBarWidth(10)
      .friction(0.6)
      .edgeEffect(EdgeEffect.None)
      .onWillScroll((xOffset: number, yOffset: number) => {
        console.info(xOffset + ' ' + yOffset);
      })
    }
    .width('100%') // 确保 Column 容器占据整个屏幕宽度
    .height('100%') // 确保 Column 容器占据整个屏幕高度
    .alignItems(HorizontalAlign.Center) // 在 Column 的交叉轴（水平方向）上居中
  }

  onBackPress(): boolean {
    this.context.eventHub.emit(EVENT_BACK_PRESS)
    return true
  }
}