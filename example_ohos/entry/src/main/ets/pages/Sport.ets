// entry/src/main/ets/pages/SportPage.ets
import { NavStackModel } from "../viewmodel/NavStackModel";
import { SportStatus, SportViewModel } from "../viewmodel/SportViewModel";
import { common } from "@kit.AbilityKit";

@Builder
export function SportPageBuilder(name: string, navInfo: NavStackModel) {
  SportPage()
}

@Component
struct SportPage {
  // 使用 @ObservedObject 链接 ViewModel 实例
  // 当 ViewModel 中 @Published 的属性改变时，UI 会自动重建
  @State private vm: SportViewModel | null = null;

  // 页面即将显示时调用
  aboutToAppear() {
    this.vm = new SportViewModel(getContext(this) as common.UIAbilityContext);
  }

  // 页面即将销毁时调用
  aboutToDisappear() {
    this.vm?.destroy(); // 清理 ViewModel 中的资源，如定时器
  }

  @Builder
  ControlButton(title: string, action: () => void, isEnabled: boolean) {
    Button(title)
      .width(200)
      .height(44)
      .fontSize(16)
      .margin({ top: 15 })
      .enabled(isEnabled)
      .onClick(action);
  }

  build() {
    NavDestination() {
      Column() {
        // 标题
        Text('Sport')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .padding({ top: 20, bottom: 20 });

        // 控制按钮
        // this.ControlButton("Start", () => this.vm?.sportStart(),
        //   this.vm?.exchangeType === SportStatus.Stopped);
        // this.ControlButton("Pause", (): void => this.vm?.sportPause(),
        //   this.vm?.exchangeType === SportStatus.Started || this.vm?.exchangeType === SportStatus.Resumed);
        // this.ControlButton("Resume", (): void => this.vm?.sportResume(), this.vm?.exchangeType === SportStatus.Paused);
        // this.ControlButton("Stop", (): void => this.vm?.sportStop(), this.vm?.exchangeType !== SportStatus.Stopped);

        this.ControlButton("Start", () => this.vm?.sportStart(),
          true);
        this.ControlButton("Pause", (): void => this.vm?.sportPause(),
          true);
        this.ControlButton("Resume", (): void => this.vm?.sportResume(), true);
        this.ControlButton("Stop", (): void => this.vm?.sportStop(), true);

        Text("Current Status: " + SportStatus[this.vm!.exchangeType])
          .fontSize(14)
          .fontColor(Color.Gray)
          .margin({ top: 25 })
          .textAlign(TextAlign.Start)
          .width('90%');

        // // 控制台输出
        // TextArea({ text: this.vm!.consoleLog })
        //   .layoutWeight(1) // 占据剩余空间
        //   .width('90%')
        //   .margin({ top: 10 })
        //   .backgroundColor(0xEDEDED)
        //   .fontSize(13)
        //   .fontColor(Color.Gray)
        //   .enabled(false); // 不可编辑

        Scroll() {
          Text(this.vm?.consoleLog)
            .fontSize(11).fontColor($r('app.color.gray'))
            .width('100%').padding(10).textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .width('90%')
        .backgroundColor($r('app.color.component_bg'))
        .borderRadius(12)
        .border({ width: 1, color: $r('app.color.divider_color') })
      }
      .width('100%')
      .height('100%')
      .width('100%')
      .padding({ top: 20, bottom: 20 })
      .backgroundColor($r('app.color.page_bg'))
    }.title($r('app.string.sport'))
  }
}