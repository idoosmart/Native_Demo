// LoadingDialog.ets
import promptAction from '@ohos.promptAction';

@Component
export struct LoadingDialog {
  // 弹窗控制器
  private controller: CustomDialogController | null = null;
  // 提示文字
  private message: string = '加载中...';
  // 是否显示百分比
  private showPercentage: boolean = false;
  // 当前进度
  @State progressValue: number = 0;
  // 旋转动画
  @State rotateAngle: number = 0;

  // 构造函数
  constructor(controller: CustomDialogController, message?: string, showPercentage?: boolean) {
    super();
    this.controller = controller;
    if (message) {
      this.message = message;
    }
    if (showPercentage !== undefined) {
      this.showPercentage = showPercentage;
    }
  }

  // 显示弹窗时启动动画
  aboutToAppear() {
    this.startRotation();
  }

  // 启动旋转动画
  private startRotation() {
    setInterval(() => {
      this.rotateAngle = (this.rotateAngle + 10) % 360;
    }, 50);
  }

  // 更新进度
  public updateProgress(value: number) {
    if (value < 0) {
      value = 0;
    }
    if (value > 100) {
      value = 100;
    }
    this.progressValue = value;

    // 进度完成时自动关闭
    if (value === 100) {
      setTimeout(() => {
        this.controller?.close();
        promptAction.showToast({ message: '加载完成' });
      }, 500);
    }
  }

  // 构建UI
  build() {
    Column() {
      // 旋转图标
      LoadingProgress()
        .color(Color.Blue)
        .width(24)
        .height(24)

      // 提示文字
      Text(this.message)
        .fontSize(18)
        .fontColor('#333333')
        .margin({ bottom: this.showPercentage ? 15 : 0 })

      // 进度条
      if (this.showPercentage) {
        Row() {
          Progress({
            value: this.progressValue,
            total: 100,
            style: ProgressStyle.Linear
          })
            .width(200)
            .height(6)
            .color('#4A90E2')

          Text(`${this.progressValue}%`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 10 })
        }
        .margin({ top: 5 })
      }
    }
    .padding(30)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .width(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// 加载弹框管理器
export class LoadingManager {
  private static controller: CustomDialogController | null = null;

  // 显示加载弹框
  static showLoading(message: string = '加载中...', showPercentage: boolean = false) {
    if (LoadingManager.controller != null) {
      LoadingManager.controller?.close();
    }

    LoadingManager.controller = new CustomDialogController({
      builder: LoadingDialog({
        controller: LoadingManager.controller!,
        message: message,
        showPercentage: showPercentage
      }),
      cancel: () => {
      },
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    });

    LoadingManager.controller.open();
  }

  // 隐藏加载弹框
  static hideLoading() {
    if (LoadingManager.controller) {
      LoadingManager.controller.close();
      LoadingManager.controller = null;
    }
  }
  //
  // // 更新进度
  // static updateProgress(value: number) {
  //   if (LoadingManager.controller && LoadingManager.controller?.isOpen()) {
  //     // 通过控制器获取builder实例并更新进度
  //     const dialog = LoadingManager.controller?.builder as LoadingDialog;
  //     dialog?.updateProgress(value);
  //   }
  // }
}