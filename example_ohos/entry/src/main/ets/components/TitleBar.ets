import router from '@ohos.router';
import { ChevronIcon } from './ChevronIcon';

@Component
export struct TitleBar {
  private backText: string | Resource = '';
  private title: string | Resource = '';
  private rightText?: string | Resource;
  private onRightClick?: () => void;

  build() {
    Row() {
      // Back Button
      Row() {
        // Use our new, 100% reliable BackIcon component
        // Use our new, self-drawn ChevronIcon component instead of Image.
        ChevronIcon({
          w: 16, // You can adjust the size
          color: $r('app.color.font_secondary'),
          strokeWidth: 2.5 // You can adjust the thickness
        })

        Text(this.backText)
          .fontSize($r('app.float.font_body'))
          .fontColor($r('sys.color.brand'))
          .margin({ left: 4 })
      }
      .onClick(() => {
        router.back();
      })
      .padding(8)
      .height('100%')
      .justifyContent(FlexAlign.Start)

      // Title
      Text(this.title)
        .fontSize($r('app.float.font_title'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        // A simple trick to center the title when the left part is present
        .margin({ left: -vp2px(24 + 4 + 8) }) // Approximate adjustment

      // Right Action
      Text(this.rightText)
        .fontSize($r('app.float.font_body'))
        .fontColor($r('sys.color.brand')) // Use system brand color
        .visibility(this.rightText ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.onRightClick?.();
        })
        .padding(8)
        .height('100%')
    }
    .width('100%')
    .height(56)
    .padding({
      left: 8, // Adjust padding for a more compact title bar
      right: 8
    })
    .alignItems(VerticalAlign.Center)
    .border({ width: { bottom: 1 }, color: $r('app.color.divider_color') })
    .backgroundColor($r('app.color.component_bg'))
  }
}