import { RemoteNotificationExtensionAbility, pushCommon, RemoteNotificationExtensionContext } from '@kit.PushKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CmdError, Cmds, IDONoticeMessageParamModel, IFailureResult, sdk } from 'protocol_channel';

const DOMAIN = 0x0000;

// 远程推送能力扩展（仅对自身app有用） ，作用：
// 当您的应用通过华为推送服务（HMS Push）接收到一条推送时，在系统将这条推送消息显示在通知栏之前，给您一个“拦截”并“加工”这条推送内容的机会。
// 需要远程推送，暂未测试
export default class EntryRemoteNotification extends RemoteNotificationExtensionAbility {

  async onReceiveMessage(remoteNotificationInfo: pushCommon.RemoteNotificationInfo):
    Promise<pushCommon.RemoteNotificationContent> {
    hilog.info(DOMAIN, 'testTag', 'remoteNotificationInfo: %{public}s', JSON.stringify(remoteNotificationInfo));
    if (sdk.state.isConnected) {
      // sdk.ble.getBluetoothState((state) => {
      //   hilog.info(DOMAIN, 'testTag', 'state: %{public}s', JSON.stringify(state));
      //   const param = IDONoticeMessageParamModel.fromJson({evt_type: 1,
      //     msg_id: remoteNotificationInfo.id,
      //     support_answering: false,
      //     support_mute: false,
      //     support_hang_up: false,
      //     contact: "xx00"+attempt,
      //     phone_number: "33003"+remoteNotificationInfo.title,
      //     data_text: "data text"+attempt});
      //   Cmds.noticeMessageV3(param, (res) => {
      //     if (res.success) {
      //       const value = res.value;
      //       console.debug("sendNotificationMsg successful "+value?.toJsonString())
      //     } else {
      //       const err = res as IFailureResult<CmdError>;
      //       console.debug(`sendNotificationMsg err code: ${err.error.code} msg: ${err.error.message}`);
      //     }
      //   });
      // });
    }
    await Promise.resolve();
    return {
      title: 'Default replace title.',
      text: 'Default replace text.',
      badgeNumber: 1,
      wantAgent: {
        abilityName: 'DemoAbility',
        parameters: {
          key: 'Default value'
        }
      }
    };
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', 'RemoteNotificationExtAbility onDestroy.');
  }

}