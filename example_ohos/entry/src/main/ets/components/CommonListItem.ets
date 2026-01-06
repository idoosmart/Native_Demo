// Import the new ChevronIcon component at the top of the file
import { ChevronIcon } from './ChevronIcon';

@Component
export struct CommonListItem {
  private title: string | Resource = '';
  private subtitle?: string | Resource;

  build() {
    ListItem() {
      Row() {
        Column({ space: 2 }) {
          Text(this.title)
            .fontSize($r('app.float.font_body'))
            .fontColor($r('app.color.font_primary'))
          if (this.subtitle) {
            Text(this.subtitle)
              .fontSize($r('app.float.font_caption'))
              .fontColor($r('app.color.font_secondary'))
              .lineHeight(14)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .padding({ right: 10 })

        // // Use our new, self-drawn ChevronIcon component instead of Image.
        // ChevronIcon({
        //   w: 16, // You can adjust the size
        //   color: $r('app.color.font_secondary'),
        //   strokeWidth: 2.5 // You can adjust the thickness
        // })
      }
      .padding({
        top: $r('app.float.item_padding'),
        bottom: $r('app.float.item_padding'),
        left: $r('app.float.page_padding'),
        right: $r('app.float.page_padding')
      })
      .backgroundColor($r('app.color.component_bg'))
    }
  }
}