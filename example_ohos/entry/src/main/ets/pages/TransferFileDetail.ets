// entry/src/main/ets/pages/TransferFileDetail.ets
import { IDOBleDeviceModel } from 'protocol_channel';
import { IDOTransType } from 'protocol_channel/src/main/ets/components/protocol_sdk/impl/FileTransferImpl';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { Font, promptAction } from '@kit.ArkUI';
import { NormalTransFileViewModel } from '../viewmodel/NormalTransFileViewModel';
import { common } from '@kit.AbilityKit';
import { Tools } from '../utils/Tools';
import { FilePicker } from '../utils/FilePicker';

export interface PickerOption {
  label: string;
  suffixes: string[];
}

@Builder
export function TransferFileDetailPageBuilder(name: string, navInfo: NavStackModel) {
  TransferFileDetailPage({
    device: navInfo.param?.device,
    title: navInfo.param?.navTitle,
    transType: navInfo.param?.transType
  })
}

@Component
struct TransferFileDetailPage {
  @State private viewModel?: NormalTransFileViewModel | null = null;
  device: IDOBleDeviceModel | null = null;
  transType: IDOTransType | null = null;
  // @State logText: string = '';
  @State title: string | Resource = '';
  // 用于显示最终选择结果的URI
  @State selectedUri: string = '';
  // 定义弹窗中要显示的选项
  private pickerOption: PickerOption | null = null;
  private abilityContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  private async doSelectFile() {
    try {
      // 步骤 a: 检查并请求权限
      const hasPermission = await Tools.getInstance().checkAndRequestReadMediaPermissions(this.abilityContext);

      if (hasPermission) {
        // 步骤 b: 权限通过，打开文件选择器
        const uri: string = await FilePicker.select({ fileSuffixes: this.pickerOption!.suffixes });
        // 步骤 c: 成功回调，更新UI状态
        this.selectedUri = uri;
        promptAction.showToast({ message: '文件已选择！' });
      } else {
        // 步骤 d: 权限被拒绝，提示用户
        promptAction.showToast({ message: '您已拒绝文件读取权限，无法选择文件。' });
      }
    } catch (error) {
      // 步骤 e: 捕获错误 (例如用户取消了文件选择器)
      const errorMessage: string = (error instanceof Error) ? error.message : '未知错误';
      if (errorMessage.includes('cancel')) { // 根据FilePicker的实现判断是否是用户取消
        console.info('File selection was cancelled by user.');
      } else {
        promptAction.showToast({ message: `操作失败: ${errorMessage}` });
      }
    }
  }

  aboutToAppear(): void {
    this.viewModel = new NormalTransFileViewModel(this.abilityContext);
    if (this.transType === IDOTransType.ml) {
      this.pickerOption = { label: 'ml', suffixes: ['.json'] }
    } else if (this.transType === IDOTransType.fw) {
      this.pickerOption = { label: 'fw', suffixes: ['.fw', '.zip', '.bin'] }
    } else if (this.transType === IDOTransType.wallpaperZ) {
      this.pickerOption = { label: 'wallpaperZ', suffixes: ['.png'] }
    } else if (this.transType === IDOTransType.mp3) {
      this.pickerOption = { label: 'mp3', suffixes: ['.mp3'] }
    } else {
      this.pickerOption = { label: 'other', suffixes: ['.*'] }
    }
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Button('Select File')
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
              this.doSelectFile();
          })
        Text('支持: ' + this.pickerOption?.suffixes).fontSize(12).fontColor($r('app.color.red'))
          .width('100%').padding(10).textAlign(TextAlign.End);
        Scroll() {
          Text('file: ' + this.selectedUri).width('100%').padding(10).textAlign(TextAlign.Start);
        }

        Button($r('app.string.send'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .enabled((this.selectedUri != null && this.viewModel?.isProcessing === false))
          .onClick(() => {
            if (this.transType === IDOTransType.wallpaperZ) {
              this.viewModel?.send(this.transType!, this.selectedUri, "wallpaper.z")
            } else {
              this.viewModel?.send(this.transType!, this.selectedUri)
            }
          })
        Button($r('app.string.stop'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.secondary_action_blue'))
          .enabled(this.viewModel?.isProcessing === true)
          .onClick(() => {
            this.viewModel?.cancel();
          })
        Scroll() {
          Text(this.viewModel?.resStr)
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
    }.title(this.title)
  }
}