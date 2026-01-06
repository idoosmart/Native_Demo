// entry/src/main/ets/viewmodel/MessageNoticeViewModel.ets

export class ToggleItem {
  id: number;
  icon: Resource;
  label: Resource;
  isOn: boolean;

  constructor(id: number, icon: Resource, label: Resource, isOn: boolean) {
    this.id = id;
    this.icon = icon;
    this.label = label;
    this.isOn = isOn;
  }
}

export function getMessageNoticeItems(): ToggleItem[] {
  return [
  // 使用可靠的系统图标
  //   new ToggleItem(1, $r('sys.media.ic_public_call'), $r('app.string.incoming_call'), true),
  //   new ToggleItem(2, $r('sys.media.ic_public_message'), $r('app.string.sms'), true),
  //   new ToggleItem(3, $r('sys.media.ic_public_calendar'), $r('app.string.calendar'), true),
  //   new ToggleItem(4, $r('sys.media.ic_public_email'), $r('app.string.email'), false),
  //   new ToggleItem(5, $r('sys.media.ic_public_call_missed'), $r('app.string.missed_call'), false),
  //   // 注意: 微信没有官方系统图标，我们用一个通用的 "comment" 图标代替
  //   new ToggleItem(6, $r('sys.media.ic_public_comment'), $r('app.string.wechat'), true)
  ];
}