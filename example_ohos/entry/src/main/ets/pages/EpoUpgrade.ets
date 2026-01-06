// entry/src/main/ets/pages/EpoUpgradePage.ets
import { IDOBleDeviceModel } from 'protocol_channel';
import { EpoUpgradeViewModel } from '../viewmodel/EpoUpgradeViewModel';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { common } from '@kit.AbilityKit';

@Builder
export function EpoUpgradePageBuilder(name: string, navInfo: NavStackModel) {
  EpoUpgradePage({ device: navInfo.param?.device })
}

@Component
struct EpoUpgradePage {
  device: IDOBleDeviceModel | null = null;
  @State private viewModel: EpoUpgradeViewModel | null = null;

  aboutToAppear(): void {
    console.info("on aboutToAppear")
    this.viewModel = new EpoUpgradeViewModel(getContext(this) as common.UIAbilityContext);
  }

  aboutToDisappear() {
    console.info("on aboutToDisappear")
    this.viewModel?.stop();
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button('Update')
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
            this.viewModel?.startInstall(true);
          }).enabled(!this.viewModel?.isProcessing)
        Button($r('app.string.stop'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.secondary_action_blue'))
          .onClick(() => {
            this.viewModel?.stop();
          }).enabled(this.viewModel?.isProcessing)
        Scroll() {
          Text("testetasofas3\n"+this.viewModel?.resStr2)
            .fontSize(11).fontColor($r('app.color.gray'))
            .width('100%').padding(10).textAlign(TextAlign.Start)
        }
        .layoutWeight(1)
        .width('90%')
        .backgroundColor($r('app.color.component_bg'))
        .borderRadius(12)
        .border({ width: 1, color: $r('app.color.divider_color') })
      }
      .width('100%').padding({ top: 20, bottom: 20 }).backgroundColor($r('app.color.page_bg'))
    }.title($r('app.string.epo_upgrade'))
  }
}