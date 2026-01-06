// entry/src/main/ets/pages/FunctionTestPage.ets
import { IDOBleDeviceModel } from "protocol_channel";
import { FunctionDataViewModel } from "../viewmodel/FunctionDataViewModel";
import { NavParam, NavStackModel } from "../viewmodel/NavStackModel";

@Builder
export function FunctionTestPageBuilder(title: string, navInfo: NavStackModel) {
  FunctionTestPage({
    params: navInfo.param,
    viewModel: navInfo.param?.funcInfo != null ? new FunctionDataViewModel(navInfo.param?.funcInfo, navInfo.param?.device) : null
  })
}

@Component
struct FunctionTestPage {
  private params: NavParam | null = null;
  @State private viewModel: FunctionDataViewModel | null = null;

  aboutToAppear() {
    if (this.params && this.viewModel) {
      this.viewModel.paramStr = this.params.initialParams ?? '{}';
    }
  }

  async onSend() {
    if (!this.viewModel) {
      return;
    }

    // 清空上次的结果
    this.viewModel.resStr = '';

    try {
      await this.viewModel.send();
    } catch (e) {
      console.error('发送失败:', e);
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 顶部固定内容区
        Column({ space: 20 }) {
          Button($r('app.string.send'))
            .width('90%')
            .height(48)
            .type(ButtonType.Capsule)
            .backgroundColor($r('app.color.primary_action_blue'))
            .margin({ top: 20 })
            .enabled(this.viewModel ? !this.viewModel.isProcessing : false)
            .onClick(() => this.onSend())

          Column({ space: 8 }) {
            Text($r('app.string.parameter'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)

            TextArea({ text: this.viewModel?.paramStr })
              .enabled(false)
              .height(150)
              .backgroundColor($r('app.color.component_bg'))
              .borderRadius(12)
              .onChange(val => {
                if (this.viewModel) {
                  this.viewModel.paramStr = val;
                }
              })
          }
          .width('90%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')

        // Response区域 - 使用Scroll组件包裹，支持滚动
        Column({ space: 8 }) {
          Text($r('app.string.response'))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('90%')
            .margin({ top: 20 })

          // 使用Scroll组件实现滚动
          Scroll() {
            Text(this.viewModel?.resStr ?? '')
              .width('100%')
              .padding(12)
              .backgroundColor($r('app.color.component_bg'))
              .borderRadius(12)
              .fontSize(14)
              .lineHeight(20)
              .textAlign(TextAlign.Start)
          }
          .width('90%')
          .layoutWeight(1) // 占据剩余空间
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.TopStart)
        }
        .width('100%')
        .layoutWeight(1) // 让Response区域占据剩余空间
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 20 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_bg'))
    }
    .title(this.params?.functionName ?? '测试')
    .onWillDisappear(() => {
      this.viewModel?.cancel();
    })
  }
}