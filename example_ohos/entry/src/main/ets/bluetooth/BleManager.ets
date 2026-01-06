import {
  IDOBleDelegate,
  IDOBleDeviceModel,
  IDOBluetoothStateModel,
  IDOBridgeDelegate,
  IDODeviceNotificationModel,
  IDODeviceStateModel,
  IDOOtaDeviceModel,
  IDOReceiveData,
  IDOStatusNotification
} from 'protocol_channel';

import { Tools } from '../utils/Tools';

/**
 * app端业务用来处理对应的事件，根据需要监听对应的对调
 */
export class AppDelegate {
  listenStatusNotification?: (status: IDOStatusNotification) => void
  listenWaitingOtaDevice?: (otaDevice: IDOOtaDeviceModel) => void
  listenDeviceNotification?: (model: IDODeviceNotificationModel) => void
  scanResult?: (list: IDOBleDeviceModel[] | null) => void
  bluetoothState?: (state: IDOBluetoothStateModel) => void
  deviceState?: (state: IDODeviceStateModel) => void
}

class BleManager {
  // 私有属性
  private mBleState: IDODeviceStateModel | null = null;
  private delegates: AppDelegate[] = [];

  // 获取连接状态
  getConnectState(): IDODeviceStateModel | null {
    return this.mBleState;
  }

  // 注册委托
  registerBleDelegate(delegate: AppDelegate): void {
    if (!this.delegates.includes(delegate)) {
      this.delegates.push(delegate);
    }
  }

  // 注销委托
  unregisterBleDelegate(delegate: AppDelegate): void {
    const index = this.delegates.indexOf(delegate);
    if (index !== -1) {
      this.delegates.splice(index, 1);
    }
  }

  public  idoBridgeImpl: IDOBridgeDelegate = {
    listenStatusNotification: (status: IDOStatusNotification): void => {
      console.debug("listenStatusNotification: " + status)
      this.delegates.forEach((delegate) => {
        if (delegate.listenStatusNotification != null) {
          delegate.listenStatusNotification(status)
        }
      });
    },
    listenDeviceNotification: (model: IDODeviceNotificationModel): void => {
      console.debug("listenDeviceNotification: " + model)
      this.delegates.forEach((delegate) => {
        if (delegate.listenDeviceNotification != null) {
          delegate.listenDeviceNotification(model)
        }
      });

    },
    checkDeviceBindState: (macAddress: string): boolean => {
      //app端缓存的该设备的绑定状态，由 app 提供
      let isBind = Tools.getInstance().getBindState(macAddress);
      console.debug("checkDeviceBindState: " + macAddress + ", isBind: " + isBind)
      return isBind;
    },
    listenWaitingOtaDevice: (otaDevice: IDOOtaDeviceModel): void => {
      console.debug("listenWaitingOtaDevice: " + otaDevice)
      this.delegates.forEach((delegate) => {
        if (delegate.listenWaitingOtaDevice != null) {
          delegate.listenWaitingOtaDevice(otaDevice)
        }
      });

    }
  }
  // 内部委托实现
  public  bleDelegateImp: IDOBleDelegate = {
    // writeState: (state) => {
    //   this.delegates.forEach(it => it.writeState?.(state));
    // },
    receiveData: (data: IDOReceiveData) => {
    } /*this.receiveData(data)*/,

    scanResult: (list: IDOBleDeviceModel[] | null) => this.scanResult(list),

    bluetoothState: (state: IDOBluetoothStateModel) => this.bluetoothState(state),

    deviceState: (state: IDODeviceStateModel) => this.deviceState(state)
  };

  /**
   * 搜索设备结果回调
   * @param list 搜索到的设备模型数组，或在无设备时为 null
   */
  scanResult(list: IDOBleDeviceModel[] | null): void {
    this.delegates.forEach(it => {
      if (it.scanResult != null) {
        it.scanResult(list)
      }
    });
  }

  /**
   * 蓝牙状态变化回调
   * @param state 当前的蓝牙状态模型
   */
  bluetoothState(state: IDOBluetoothStateModel): void {
    this.delegates.forEach(it => {
      if (it.bluetoothState != null) {
        it.bluetoothState(state)
      }
    });
  }

  /**
   * 设备连接状态变化回调
   * @param state 当前的设备状态模型
   */
  deviceState(state: IDODeviceStateModel): void {
    this.mBleState = state;
    this.delegates.forEach(it => {
      if (it.deviceState != null) {
        it.deviceState(state)
      }
    });
  }

  private static instance: BleManager;

  private constructor() {
  }

  public static getInstance(): BleManager {
    if (!BleManager.instance) {
      BleManager.instance = new BleManager();
    }
    return BleManager.instance;
  }
}

// 导出单例访问点
export default BleManager.getInstance();