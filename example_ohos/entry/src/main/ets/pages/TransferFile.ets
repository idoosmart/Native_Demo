// entry/src/main/ets/pages/TransferFilePage.ets
import { CommonListItem } from '../components/CommonListItem';
import { PAGE_TRANSFER_FILE_DETAIL, PAGE_WATCH_FACE_DETAIL } from '../utils/Routers';
import { IDOBleDeviceModel } from 'protocol_channel';
import { NavStackModel, NavParam } from '../viewmodel/NavStackModel';
import { IDOTransType } from 'protocol_channel/src/main/ets/components/protocol_sdk/impl/FileTransferImpl';

@Builder
export function TransferFilePageBuilder(name: string, navInfo: NavStackModel) {
  TransferFilePage({ device: navInfo.param?.device })
}

@ComponentV2
struct TransferFilePage {
  @Param device: IDOBleDeviceModel | null = null;
  private pageInfos: NavPathStack | null = null;

  build() {
    NavDestination() {
      List({ space: 1 }) {
        CommonListItem({ title: $r('app.string.upload_contacts'), subtitle: 'Upload contacts' })
          .onClick(() => {
            this.pageInfos?.pushPathByName(PAGE_TRANSFER_FILE_DETAIL,
              new NavStackModel(PAGE_TRANSFER_FILE_DETAIL, {
                navTitle: $r('app.string.upload_contacts'),
                transType: IDOTransType.ml
              }));
          })
        CommonListItem({ title: 'Upload music', subtitle: 'Upload music' })
          .onClick(() => {
            this.pageInfos?.pushPathByName(PAGE_TRANSFER_FILE_DETAIL,
              new NavStackModel(PAGE_TRANSFER_FILE_DETAIL, {
                navTitle: 'Upload music',
                transType: IDOTransType.mp3
              }));
          })
        // CommonListItem({ title: 'Upload wallpaper', subtitle: 'Upload wallpaper' })
        //   .onClick(() => {
        //     this.pageInfos?.pushPathByName(PAGE_TRANSFER_FILE_DETAIL,
        //       new NavStackModel(PAGE_TRANSFER_FILE_DETAIL, {
        //         navTitle: 'Upload wallpaper',
        //         transType: IDOTransType.wallpaperZ
        //       }));
        //   })
        CommonListItem({ title: $r('app.string.firmware_upgrade'), subtitle: 'Firmware upgrade' })
          .onClick(() => {
            //this.pageInfos?.pushPathByName(PAGE_FIRMWARE_UPGRADE, new NavStackModel(PAGE_FIRMWARE_UPGRADE));
            this.pageInfos?.pushPathByName(PAGE_TRANSFER_FILE_DETAIL,
              new NavStackModel(PAGE_TRANSFER_FILE_DETAIL, {
                navTitle: $r('app.string.firmware_upgrade'),
                transType: IDOTransType.fw
              }));
          })
        CommonListItem({ title: $r('app.string.watch_face_upgrade'), subtitle: 'Watch face upgrade' })
          .onClick(() => {
            this.pageInfos?.pushPathByName(PAGE_WATCH_FACE_DETAIL, new NavStackModel(PAGE_WATCH_FACE_DETAIL));
          })
      }
      .backgroundColor($r('app.color.page_bg')).padding({ top: 12 })
    }.onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    }).title($r('app.string.transfer_file'))
  }
}