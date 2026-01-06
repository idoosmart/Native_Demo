// entry/src/main/ets/pages/StaticMessageNoticePage.ets
import { SettingToggleItem } from '../components/SettingToggleItem';
import { PowerIcon } from '../components/PowerIcon';
import { getMessageNoticeItems, ToggleItem } from '../viewmodel/MessageNoticeViewModel';
import { NavStackModel } from '../viewmodel/NavStackModel';

@Builder
export function StaticMessageNoticePageBuilder(name: string, navInfo: NavStackModel) {
  StaticMessageNoticePage()
}

@Component
struct StaticMessageNoticePage {
  @State isMainSwitchOn: boolean = true;
  @State toggleItems: ToggleItem[] = getMessageNoticeItems();

  updateToggleItemState(itemId: number, newState: boolean) {
    const index = this.toggleItems.findIndex(item => item.id === itemId);
    if (index !== -1) {
      this.toggleItems[index].isOn = newState;
    }
  }

  build() {
    NavDestination() {
      List({ space: 12 }) {
        // ListItem() {
        //   Text($r('app.string.message_notice_note'))
        //     .fontSize(12)
        //     .fontColor($r('app.color.font_secondary'))
        //     .padding({
        //       top: 8,
        //       bottom: 8,
        //       left: 16,
        //       right: 16
        //     })
        //     .width('100%')
        // }

        ListItemGroup() {
          ListItem() {
            SettingToggleItem({
              label: $r('app.string.main_switch'),
              isOn: this.isMainSwitchOn,
              onChange: (newState: boolean) => {
                this.isMainSwitchOn = newState;
              }
            }) {
              PowerIcon({ color: $r('app.color.font_primary') })
            }
          }.padding(0).backgroundColor($r('app.color.component_bg'))
        }.borderRadius(16)

        ListItemGroup() {
          ForEach(this.toggleItems, (item: ToggleItem) => {
            ListItem() {
              SettingToggleItem({
                label: item.label, isOn: item.isOn, onChange: (newState: boolean) => {
                  this.updateToggleItemState(item.id, newState);
                }
              }) {
                Image(item.icon).width(28).height(28).fillColor($r('app.color.font_primary'))
              }
            }.padding(0).backgroundColor($r('app.color.component_bg'))
          }, (item: ToggleItem) => item.id.toString())
        }.borderRadius(16)
        .divider({ strokeWidth: 0.5, color: $r('app.color.divider_color'), startMargin: 52 })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        top: 12,
        left: 12,
        right: 12,
        bottom: 12
      })
      .backgroundColor($r('app.color.page_bg'))
    }.title($r('app.string.message_notice'))
  }
}