// entry/src/main/ets/pages/WatchFace.ets
import { IDOBleDeviceModel, IDOTransType, IDOWatchItem, IDOWatchListModel } from 'protocol_channel';
import { NavStackModel } from '../viewmodel/NavStackModel';
import { WatchFaceViewModel } from '../viewmodel/WatchFaceViewModel';
import { common } from '@kit.AbilityKit';
import { PickerOption } from './TransferFileDetail';
import { Tools } from '../utils/Tools';
import { FilePicker } from '../utils/FilePicker';
import { promptAction } from '@kit.ArkUI';

@Builder
export function WatchFaceDetailPageBuilder(name: string, navInfo: NavStackModel) {
  WatchFaceDetailPage()
}

@Component
struct WatchFaceDetailPage {
  @State private viewModel: WatchFaceViewModel | null = null;
  private abilityContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 用于显示最终选择结果的URI
  // Used to display the final selection result URI
  @State selectedUri: string = '';
  @State fileName: string = '';
  // 定义弹窗中要显示的选项
  // Define the options to show in the dialog
  private pickerOption: PickerOption = { label: 'fw', suffixes: ['.fw', '.zip', '.bin'] };

  private async doSelectFile() {
    try {
      // 步骤 a: 检查并请求权限
      // Step a: check and request permission
      const hasPermission = await Tools.getInstance().checkAndRequestReadMediaPermissions(this.abilityContext);

      if (hasPermission) {
        // 步骤 b: 权限通过，打开文件选择器
        // Step b: permission granted, open the file picker
        const uri: string = await FilePicker.select({ fileSuffixes: this.pickerOption!.suffixes });
        // 步骤 c: 成功回调，更新UI状态
        // Step c: success callback, update the UI state
        this.selectedUri = uri;
        promptAction.showToast({ message: '文件已选择！ / File selected!' });
      } else {
        // 步骤 d: 权限被拒绝，提示用户
        // Step d: permission denied, notify the user
        promptAction.showToast({ message: '您已拒绝文件读取权限，无法选择文件。 / You denied the file read permission, cannot select a file.' });
      }
    } catch (error) {
      // 步骤 e: 捕获错误 (例如用户取消了文件选择器)
      // Step e: catch errors (for example the user cancelled the file picker)
      const errorMessage: string = (error instanceof Error) ? error.message : '未知错误 / Unknown error';
      if (errorMessage.includes('cancel')) { // 根据FilePicker的实现判断是否是用户取消 / Decide whether the user cancelled, based on the FilePicker implementation
        console.info('File selection was cancelled by user.');
      } else {
        promptAction.showToast({ message: `操作失败 / Operation failed: ${errorMessage}` });
      }
    }
  }

  private onRemove(name: string) {
    promptAction.showDialog({
      title: '确认卸载 / Confirm uninstall',
      message: `您确定要卸载: ${name} 吗？ / Are you sure you want to uninstall: ${name}?`,
      buttons: [
        {
          text: '取消 / Cancel',
          color: '#333333'
        },
        {
          text: '确定 / OK',
          color: '#FF0000'
        }
      ]
    }).then(dialogResult => {
      if (dialogResult.index === 1) {
        this.viewModel?.uninstall(name);
        console.log('用户确认卸载。 / User confirmed the uninstall.');
      } else {
        console.log('用户取消了卸载。 / User cancelled the uninstall.');
      }
    }).catch(() => {
      console.error('显示对话框失败 / Failed to show the dialog');
    })
  }

  aboutToAppear(): void {
    this.viewModel = new WatchFaceViewModel(this.abilityContext)
  }

  build() {
    NavDestination() {
      Column({ space: 20 }) {

        List({ space: 10 }) {
          // ForEach 用于遍历数据源，为每个数据项创建一个 ListItem
          // ForEach iterates over the data source, creating for each data item one ListItem
          ForEach(
            this.viewModel?.watchList,
            (item: IDOWatchItem) => {
              ListItem() {
                // 使用 Row 实现水平布局
                // Use Row for a horizontal layout
                Row() {
                  // 左侧：表盘信息（名称和大小）
                  // Left: watch face info (name and size)
                  Column({ space: 5 }) {
                    Text(item.name)
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.viewModel?.checkNowShowWatchName(item.name) ? Color.Blue : Color.Black)
                    Text(`${(item.size / 1024).toFixed(2)} KB`) // 将大小格式化为带单位的字符串 / Format the size as a string with a unit
                      .fontSize(12)
                      .fontColor($r('app.color.gray')) // 使用次要颜色 / Use the secondary color
                  }
                  .alignItems(HorizontalAlign.Start) // 列内元素左对齐 / Left-align the elements in the column
                  .layoutWeight(1) // 占据所有剩余空间，将删除按钮推到最右边 / Take all remaining space, pushing the delete button to the far right

                  // 右侧：删除按钮
                  // Right: delete button
                  Button('Uninstall')
                    .type(ButtonType.Capsule)
                    .width(120)
                    .height(40)
                    .backgroundColor(Color.Red) // 设置按钮背景为红色 / Set the button background to red
                    .fontColor(Color.White)
                    .onClick(() => {
                    this.onRemove(item.name);
                  }).enabled(!this.viewModel?.isProcessing)
                }
                .width('100%')
                .padding({ left: 16, right: 8, top: 12, bottom: 12 })
              }
            },
            (item: IDOWatchItem) => item.name // 为每个列表项提供一个唯一的key，有助于提高性能 / Provide a unique key for each list item, which helps performance
          )
        }
        .layoutWeight(1) // 使列表占据剩余的大部分空间 / Let the list take most of the remaining space
        .width('90%')
        .backgroundColor($r('app.color.component_bg'))
        .borderRadius(12)
        .divider({ strokeWidth: 1, color: $r('app.color.divider_color'), startMargin: 15, endMargin: 15 })

        Button($r('app.string.refresh'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
            this.viewModel?.getWatchList();
          }).enabled(!this.viewModel?.isProcessing)

        Button('Select File')
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
            this.doSelectFile();
          }).enabled(!this.viewModel?.isProcessing)

        Scroll() {
          Text('file: ' + this.selectedUri)
            .fontSize(12).fontColor($r('app.color.gray'))
            .width('100%')
            .padding(10).textAlign(TextAlign.Start);
        }
        // 这是一个基本的文本输入框
        // This is a basic text input box
        TextInput({ placeholder: '请输入表盘名称 / Enter the watch face name...' })
          .width('90%')
          .height(44)
          .placeholderFont({ size: 16, weight: FontWeight.Lighter })
          .fontSize(16)
          .fontColor(Color.Black)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
            this.fileName = value;
          });

        Button($r('app.string.watch_face_add'))
          .width('90%')
          .height(48)
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.primary_action_blue'))
          .onClick(() => {
            this.viewModel?.install(IDOTransType.iwfLz, this.selectedUri, this.fileName);
          }).enabled(!this.viewModel?.isProcessing)

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
    }.title('Watch face')
  }
}