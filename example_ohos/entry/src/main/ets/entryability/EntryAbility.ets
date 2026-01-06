import { GeneratedPluginRegistrant } from '@ohos/flutter_module';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import {
  sdk,
  IDOLogType,
  IDOBridgeDelegate,
  IDOStatusNotification,
  IDOOtaDeviceModel,
  IDODeviceNotificationModel,
  IDOBleDelegate,
  IDOBleDeviceModel,
  IDOBluetoothStateModel,
  IDODeviceStateModel,
  IDOReceiveData
} from 'protocol_channel';
import window from '@ohos.window';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { preferences } from '@kit.ArkData';
import { abilityAccessCtrl, PermissionRequestResult, Permissions, UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import BleManager from '../bluetooth/BleManager';
import { BluetoothViewModel } from '../viewmodel/BluetoothViewModel';
import {
  cleanupMainThreadHandler,
  initMainThreadHandler
} from 'protocol_channel/src/main/ets/components/protocol_sdk/ThreadUtil';

const permissions: Permissions[] = ['ohos.permission.ACCESS_BLUETOOTH'];

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    super.onCreate(want, launchParam)
    console.info("EntryAbility--onCreate")
    this.initSDK();
    initMainThreadHandler();
    BluetoothViewModel.getInstance().init();
  }


  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    let context: Context = this.context;
    loadPreferences(context).then(() => {
    })
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    // requestPermissionsFromUser会判断权限的授权状态来决定是否唤起弹窗
    atManager.requestPermissionsFromUser(context, permissions).then((data: PermissionRequestResult) => {
      let grantStatus: number[] = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          break;
        } else {
          // 用户拒绝授权，提示用户必须授权才能访问当前页面的功能，并引导用户到系统设置中打开相应的权限
          return;
        }
      }
      // 授权成功
    }).catch((err: BusinessError) => {
      console.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    })
    windowStage.loadContent('pages/Scan', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onDestroy(): void {
    console.info('Ability onDestroy');
    cleanupMainThreadHandler();
  }

  initSDK() {
    console.info("EntryAbility--initSDK, versionSdk = "+sdk.info.versionSdk+", buildTime = "+sdk.info.updateTime);
    sdk.init(this.context, (flutterEngine) => {
      GeneratedPluginRegistrant.registerWith(flutterEngine)
    })
    sdk.ble.addBleDelegate(BleManager.bleDelegateImp);
    sdk.bridge.setupBridge(BleManager.idoBridgeImpl, IDOLogType.debug)
  }
}

export let myPreferences: preferences.Preferences | null = null;

async function loadPreferences(context: Context) {
  try {
    // 获取Preferences实例，文件名为"my_app_settings"
    // 注意：这里的 context 可以通过 Ability 或 AbilityStage 的实例获取，例如 this.context
    // 如果你在组件中，可能需要通过参数传递或者从AbilityLifecycleCallbacks获取
    myPreferences = await preferences.getPreferences(context, 'my_app_settings');
    console.log('Preferences loaded successfully');
  } catch (err) {
    console.error('Failed to load preferences:', err);
  }
}
