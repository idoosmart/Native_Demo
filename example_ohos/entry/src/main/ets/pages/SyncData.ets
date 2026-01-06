// entry/src/main/ets/pages/SyncDataPage.ets
import { NavStackModel } from "../viewmodel/NavStackModel";
import { SyncDataViewModel } from "../viewmodel/SyncDataViewModel";

@Builder
export function SyncDataPageBuilder(name: string, navInfo: NavStackModel) {
  SyncDataPage()
}

@Component
struct SyncDataPage {
  @State private viewModel: SyncDataViewModel | null = null;
  @State logText: string = '';

  aboutToAppear(): void {
    console.info("on aboutToAppear")
    this.viewModel = new SyncDataViewModel();
  }

  aboutToDisappear() {
    console.info("on aboutToDisappear")
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button($r('app.string.start_sync_data'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
            this.viewModel?.syncAll();
          }).enabled(this.viewModel?.isProcessing == false)
        Button($r('app.string.stop_sync_data'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.secondary_action_blue'))
          .onClick(() => {
            this.viewModel?.stop();
          }).enabled(this.viewModel?.isProcessing)
        if (this.viewModel != null && this.viewModel?.progress > 0) {
          Text(`progress: ${this.viewModel?.progress}%`).enabled(false)
        }
        Scroll() {
          Text(this.viewModel?.resStr ?? "").width('100%').padding(10).textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .width('90%')
        .backgroundColor($r('app.color.component_bg'))
        .borderRadius(12)
        .border({ width: 1, color: $r('app.color.divider_color') })
      }
      .width('100%').padding({ top: 20, bottom: 20 }).backgroundColor($r('app.color.page_bg'))
    }.title($r('app.string.sync_data'))
  }
}