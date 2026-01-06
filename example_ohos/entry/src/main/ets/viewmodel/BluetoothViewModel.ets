// 状态管理类
import {
  IDOBleDelegate,
  IDOBleDeviceModel,
  IDOBluetoothStateModel,
  IDODeviceNotificationModel,
  IDODeviceStateModel,
  IDOOtaDeviceModel,
  IDOReceiveData,
  IDOStatusNotification
} from 'protocol_channel';
import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { bluetooth } from '@kit.ConnectivityKit';
import { sdk } from 'protocol_channel';
import BleManager, { AppDelegate } from '../bluetooth/BleManager';
import { Tools } from '../utils/Tools';

export class BluetoothViewModel {
  private static instance: BluetoothViewModel;
  // 使用@State管理应用状态
  bluetoothState: BluetoothState = new BluetoothState();
  // 蓝牙服务实例
  private bluetoothService: BluetoothService = BluetoothService.getInstance(this.bluetoothState);

  private constructor() {
  }

  static getInstance(): BluetoothViewModel {
    if (!BluetoothViewModel.instance) {
      BluetoothViewModel.instance = new BluetoothViewModel();
    }
    return BluetoothViewModel.instance;
  }

  // 初始化应用
  async init() {
    // 检查权限
    await this.bluetoothService.checkBluetoothPermission();

    // 如果有权限，检查蓝牙状态
    if (this.bluetoothState.hasPermission) {
      await this.bluetoothService.checkBluetoothState();
      this.bluetoothState.updateStatus('准备就绪');
    } else {
      this.bluetoothState.updateStatus('需要蓝牙权限');
    }
    this.refreshBindDeviceList();
  }

  refreshBindDeviceList() {
    let devices = Tools.getInstance().getBindDevices();
    console.info("绑定设备列表：" + devices.length)
    devices?.forEach((d) => {
      console.info("device = " + d.macAddress);
    })
    this.bluetoothState.updateBindDeviceList(devices);
  }

  // 请求权限
  async requestPermission(context: Context) {
    await this.bluetoothService.requestBluetoothPermission(context);
    if (this.bluetoothState.hasPermission) {
      await this.bluetoothService.checkBluetoothState();
      this.bluetoothState.updateStatus('准备就绪');
    }
  }

  // 开始扫描
  async startScan(context: Context) {
    await this.bluetoothService.startScan(context);
  }

  // 停止扫描
  async stopScan() {
    await this.bluetoothService.stopScan();
  }

  // 获取设备名称
  getDeviceName(device: IDOBleDeviceModel): string {
    return device.name || `未知设备 (${device.macAddress})`;
  }

  // 清除错误信息
  clearError() {
    this.bluetoothState.errorMessage = '';
  }
}

@ObservedV2
export class BluetoothState {
  // 权限状态
  @Trace hasPermission: boolean = false;
  // 蓝牙状态
  @Trace bluetoothEnabled: boolean = false;
  // 扫描状态
  @Trace isScanning: boolean = false;
  // 设备列表
  @Trace deviceList: IDOBleDeviceModel[] = [];
  // 状态消息
  @Trace statusMessage: string = '正在检查权限...';
  // 错误信息
  @Trace errorMessage: string = '';
  //ota中的设备
  @Trace otaDeviceList: IDOBleDeviceModel[] = [];
  //app 绑定的设备列表
  @Trace bindDeviceList: IDOBleDeviceModel[] = [];

  // 更新设备列表
  updateDeviceList(devices: IDOBleDeviceModel[]) {
    this.deviceList = [...devices];
  }

  //绑定的设备列表
  updateBindDeviceList(devices: IDOBleDeviceModel[]) {
    this.bindDeviceList = [...devices];
  }

  updateOtaDeviceList(devices: IDOBleDeviceModel[]) {
    this.otaDeviceList = devices;
  }

  // 更新状态消息
  updateStatus(message: string) {
    this.statusMessage = message;
  }

  // 设置错误信息
  setError(message: string) {
    this.errorMessage = message;
  }
}

// 蓝牙服务类
class BluetoothService {
  private static instance: BluetoothService;
  private state: BluetoothState;
  private atManager: abilityAccessCtrl.AtManager;
  private bluetoothPermission: Permissions = 'ohos.permission.USE_BLUETOOTH';
  private isScanning: boolean = false;
  private scanDevices: Map<string, IDOBleDeviceModel> = new Map();
  private otaDevices: IDOBleDeviceModel[] = [];

  private constructor(state: BluetoothState) {
    this.state = state;
    this.atManager = abilityAccessCtrl.createAtManager();
  }

  public static getInstance(state: BluetoothState): BluetoothService {
    if (!BluetoothService.instance) {
      BluetoothService.instance = new BluetoothService(state);
    }
    return BluetoothService.instance;
  }

  // 检查蓝牙权限
  async checkBluetoothPermission(): Promise<boolean> {
    try {
      let bundleInfo: bundleManager.BundleInfo =
        await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      let tokenID: number = appInfo.accessTokenId;
      const status = await this.atManager.checkAccessToken(tokenID, this.bluetoothPermission);
      this.state.hasPermission = status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      return this.state.hasPermission;
    } catch (error) {
      this.state.setError(`检查权限失败: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 申请蓝牙权限
  async requestBluetoothPermission(context: Context): Promise<boolean> {
    try {
      this.state.updateStatus('正在申请权限...');
      const result = await this.atManager.requestPermissionsFromUser(
        context,
        [this.bluetoothPermission]
      );
      this.state.hasPermission = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      return this.state.hasPermission;
    } catch (error) {
      this.state.setError(`申请权限失败: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 检查蓝牙状态
  async checkBluetoothState(): Promise<boolean> {
    try {
      const state = await bluetooth.getState();
      this.state.bluetoothEnabled = state === bluetooth.BluetoothState.STATE_ON;
      return this.state.bluetoothEnabled;
    } catch (error) {
      this.state.setError(`检查蓝牙状态失败: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 内部委托实现
  private bleDelegateImp: AppDelegate = {
    scanResult: (list: IDOBleDeviceModel[] | null): void => this.onScanResult(list),
    listenDeviceNotification:(model: IDODeviceNotificationModel):void=>this.onReceiveDeviceNotificationEvent(model)
  };

  onReceiveDeviceNotificationEvent(model: IDODeviceNotificationModel) {
    console.info("收到手表事件通知:" + model.dataType);
  }

  onScanResult(devices: IDOBleDeviceModel[] | null) {
    console.info("扫描结果：" + devices)
    if (devices == null || devices.length == 0) {
      return;
    }
    for (let device of devices) {
      if (device.isOta) {
        console.info("设备正在 ota 中：" + device.macAddress)
      }
      if (!this.scanDevices.has(device.macAddress!!)) {
        this.scanDevices.set(device.macAddress!!, device);
        let arr = Array.from(this.scanDevices.values()).sort((a, b) => {
          return Math.abs(a.rssi) - Math.abs(b.rssi)
        });
        if (device.isOta) {
          this.otaDevices.push(device);
          this.state.updateOtaDeviceList(this.otaDevices);
        } else {
          this.state.updateDeviceList(arr);
        }

      }
    }

  }

  // 开始扫描设备
  async startScan(context: Context): Promise<void> {
    if (this.isScanning) {
      return;
    }

    try {
      // 确保有权限
      if (!this.state.hasPermission) {
        const hasPermission = await this.requestBluetoothPermission(context);
        if (!hasPermission) {
          this.state.updateStatus('需要蓝牙权限才能扫描');
          return;
        }
      }

      // 确保蓝牙已开启
      if (!this.state.bluetoothEnabled) {
        const enabled = await this.checkBluetoothState();
        if (!enabled) {
          this.state.updateStatus('请先开启蓝牙');
          return;
        }
      }

      // 重置设备列表
      this.scanDevices.clear();
      this.otaDevices = [];
      this.state.updateDeviceList([]);
      this.state.updateOtaDeviceList([]);
      this.isScanning = true;
      this.state.isScanning = true;
      this.state.updateStatus('正在扫描设备...');
      BleManager.unregisterBleDelegate(this.bleDelegateImp);
      BleManager.registerBleDelegate(this.bleDelegateImp);
      sdk.ble.startScan(null, (devices: IDOBleDeviceModel[] | null) => {
      });
      this.state.updateStatus('扫描中...');

      // 设置超时自动停止
      setTimeout(async () => {
        if (this.isScanning) {
          await this.stopScan();
          this.state.updateStatus('扫描完成');
        }
      }, 30000);

    } catch (error) {
      this.isScanning = false;
      this.state.isScanning = false;
      this.state.setError(`开始扫描失败: ${(error as BusinessError).message}`);
    }
  }

  // 停止扫描
  async stopScan(): Promise<void> {
    if (!this.isScanning) {
      return;
    }

    try {
      sdk.ble.stopScan();
      this.isScanning = false;
      this.state.isScanning = false;
      this.state.updateStatus('扫描已停止');
    } catch (error) {
      this.state.setError(`停止扫描失败: ${(error as BusinessError).message}`);
    }
  }
}