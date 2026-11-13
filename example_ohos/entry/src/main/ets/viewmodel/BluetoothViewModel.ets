// 状态管理类
// State management class
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
  // Use @State to manage app state
  bluetoothState: BluetoothState = new BluetoothState();
  // 蓝牙服务实例
  // Bluetooth service instance
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
  // Initialize the app
  async init() {
    // 检查权限
    // Check permissions
    await this.bluetoothService.checkBluetoothPermission();

    // 如果有权限，检查蓝牙状态
    // If permission is granted, check the Bluetooth state
    if (this.bluetoothState.hasPermission) {
      await this.bluetoothService.checkBluetoothState();
      this.bluetoothState.updateStatus('准备就绪 / Ready');
    } else {
      this.bluetoothState.updateStatus('需要蓝牙权限 / Bluetooth permission required');
    }
    this.refreshBindDeviceList();
  }

  refreshBindDeviceList() {
    let devices = Tools.getInstance().getBindDevices();
    console.info("绑定设备列表： / Bound device list:" + devices.length)
    devices?.forEach((d) => {
      console.info("device = " + d.macAddress);
    })
    this.bluetoothState.updateBindDeviceList(devices);
  }

  // 请求权限
  // Request permission
  async requestPermission(context: Context) {
    await this.bluetoothService.requestBluetoothPermission(context);
    if (this.bluetoothState.hasPermission) {
      await this.bluetoothService.checkBluetoothState();
      this.bluetoothState.updateStatus('准备就绪 / Ready');
    }
  }

  // 开始扫描
  // Start scan
  async startScan(context: Context) {
    await this.bluetoothService.startScan(context);
  }

  // 停止扫描
  // Stop scan
  async stopScan() {
    await this.bluetoothService.stopScan();
  }

  // 获取设备名称
  // Get the device name
  getDeviceName(device: IDOBleDeviceModel): string {
    return device.name || `未知设备 / Unknown device (${device.macAddress})`;
  }

  // 清除错误信息
  // Clear the error message
  clearError() {
    this.bluetoothState.errorMessage = '';
  }
}

@ObservedV2
export class BluetoothState {
  // 权限状态
  // Permission state
  @Trace hasPermission: boolean = false;
  // 蓝牙状态
  // Bluetooth state
  @Trace bluetoothEnabled: boolean = false;
  // 扫描状态
  // Scan state
  @Trace isScanning: boolean = false;
  // 设备列表
  // Device list
  @Trace deviceList: IDOBleDeviceModel[] = [];
  // 状态消息
  // Status message
  @Trace statusMessage: string = '正在检查权限 / Checking permission...';
  // 错误信息
  // Error message
  @Trace errorMessage: string = '';
  //ota中的设备
  //ota devices
  @Trace otaDeviceList: IDOBleDeviceModel[] = [];
  //app 绑定的设备列表
  //app bound device list
  @Trace bindDeviceList: IDOBleDeviceModel[] = [];

  // 更新设备列表
  // Update the device list
  updateDeviceList(devices: IDOBleDeviceModel[]) {
    this.deviceList = [...devices];
  }

  //绑定的设备列表
  //Bound device list
  updateBindDeviceList(devices: IDOBleDeviceModel[]) {
    this.bindDeviceList = [...devices];
  }

  updateOtaDeviceList(devices: IDOBleDeviceModel[]) {
    this.otaDeviceList = devices;
  }

  // 更新状态消息
  // Update the status message
  updateStatus(message: string) {
    this.statusMessage = message;
  }

  // 设置错误信息
  // Set the error message
  setError(message: string) {
    this.errorMessage = message;
  }
}

// 蓝牙服务类
// Bluetooth service class
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
  // Check Bluetooth permission
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
      this.state.setError(`检查权限失败 / Permission check failed: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 申请蓝牙权限
  // Request Bluetooth permission
  async requestBluetoothPermission(context: Context): Promise<boolean> {
    try {
      this.state.updateStatus('正在申请权限 / Requesting permission...');
      const result = await this.atManager.requestPermissionsFromUser(
        context,
        [this.bluetoothPermission]
      );
      this.state.hasPermission = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
      return this.state.hasPermission;
    } catch (error) {
      this.state.setError(`申请权限失败 / Permission request failed: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 检查蓝牙状态
  // Check Bluetooth state
  async checkBluetoothState(): Promise<boolean> {
    try {
      const state = await bluetooth.getState();
      this.state.bluetoothEnabled = state === bluetooth.BluetoothState.STATE_ON;
      return this.state.bluetoothEnabled;
    } catch (error) {
      this.state.setError(`检查蓝牙状态失败 / Bluetooth state check failed: ${(error as BusinessError).message}`);
      return false;
    }
  }

  // 内部委托实现
  // Internal delegate implementation
  private bleDelegateImp: AppDelegate = {
    scanResult: (list: IDOBleDeviceModel[] | null): void => this.onScanResult(list),
    listenDeviceNotification:(model: IDODeviceNotificationModel):void=>this.onReceiveDeviceNotificationEvent(model)
  };

  onReceiveDeviceNotificationEvent(model: IDODeviceNotificationModel) {
    console.info("收到手表事件通知 / Received watch event notification:" + model.dataType);
  }

  onScanResult(devices: IDOBleDeviceModel[] | null) {
    console.info("扫描结果： / Scan result:" + devices)
    if (devices == null || devices.length == 0) {
      return;
    }
    for (let device of devices) {
      const mac = device.macAddress ?? '';
      if (mac.length === 0) {
        continue;
      }
      // 已绑定设备：刷新快照，不进入添加设备扫描列表（对齐 iOS ScanPageVC.applyScanResult）
      // Bound device: refresh the snapshot, do not add it to the add-device scan list (aligned with iOS ScanPageVC.applyScanResult)
      if (Tools.getInstance().getBindState(mac)) {
        Tools.getInstance().setBindDevice(device);
        this.state.updateBindDeviceList(Tools.getInstance().getBindDevices());
        continue;
      }
      if (device.isOta) {
        console.info("设备正在 ota 中： / Device is in OTA:" + device.macAddress)
      }
      if (!this.scanDevices.has(mac)) {
        this.scanDevices.set(mac, device);
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
  // Start scanning for devices
  async startScan(context: Context): Promise<void> {
    if (this.isScanning) {
      return;
    }

    try {
      // 确保有权限
      // Make sure we have permission
      if (!this.state.hasPermission) {
        const hasPermission = await this.requestBluetoothPermission(context);
        if (!hasPermission) {
          this.state.updateStatus('需要蓝牙权限才能扫描 / Bluetooth permission is required to scan');
          return;
        }
      }

      // 确保蓝牙已开启
      // Make sure Bluetooth is on
      if (!this.state.bluetoothEnabled) {
        const enabled = await this.checkBluetoothState();
        if (!enabled) {
          this.state.updateStatus('请先开启蓝牙 / Please turn on Bluetooth first');
          return;
        }
      }

      // 重置设备列表
      // Reset the device list
      this.scanDevices.clear();
      this.otaDevices = [];
      this.state.updateDeviceList([]);
      this.state.updateOtaDeviceList([]);
      this.isScanning = true;
      this.state.isScanning = true;
      this.state.updateStatus('正在扫描设备 / Scanning for devices...');
      BleManager.unregisterBleDelegate(this.bleDelegateImp);
      BleManager.registerBleDelegate(this.bleDelegateImp);
      sdk.ble.startScan(null, (devices: IDOBleDeviceModel[] | null) => {
      });
      this.state.updateStatus('扫描中 / Scanning...');

      // 设置超时自动停止
      // Set a timeout to stop automatically
      setTimeout(async () => {
        if (this.isScanning) {
          await this.stopScan();
          this.state.updateStatus('扫描完成 / Scan done');
        }
      }, 30000);

    } catch (error) {
      this.isScanning = false;
      this.state.isScanning = false;
      this.state.setError(`开始扫描失败 / Failed to start scan: ${(error as BusinessError).message}`);
    }
  }

  // 停止扫描
  // Stop scan
  async stopScan(): Promise<void> {
    if (!this.isScanning) {
      return;
    }

    try {
      sdk.ble.stopScan();
      this.isScanning = false;
      this.state.isScanning = false;
      this.state.updateStatus('扫描已停止 / Scan stopped');
    } catch (error) {
      this.state.setError(`停止扫描失败 / Failed to stop scan: ${(error as BusinessError).message}`);
    }
  }
}