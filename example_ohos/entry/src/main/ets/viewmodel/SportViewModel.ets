// 从 ArkUI 框架中导入 UI 提示框能力
import { promptAction } from '@kit.ArkUI';

// 导入模拟 SDK 或真实 SDK 的所有必要模块
// 注意：为了让 instanceof 生效，这些导入的必须是 class，而不是 interface
import {
  sdk,
  IDOExchangeDataDelegate,
  IDOExchangeBaseModel,
  IDOAppStartExchangeModel,
  IDOAppEndExchangeModel,
  IDOAppStartReplyExchangeModel,
  IDOAppEndReplyExchangeModel,
  IDOAppActivityDataV3ExchangeModel,
  IDOExchangeV2Model,
  IDOExchangeV3Model,
  IDOBleStartExchangeModel,
  IDOBleIngExchangeModel,
  IDOBleEndExchangeModel,
  IDOBlePauseExchangeModel,
  IDOBleRestoreExchangeModel,
  IDOAppBlePauseExchangeModel,
  IDOAppBleRestoreExchangeModel,
  IDOAppBleEndExchangeModel,
  IDOAppRestoreExchangeModel,
  IDOAppPauseExchangeModel,
  IDOAppIngV3ExchangeModel,
  IDOAppIngExchangeModel,
  IDOBleStartReplyExchangeModel,
  IDOBleIngReplyExchangeModel,
  IDOBleEndReplyExchangeModel,
  IDOBlePauseReplyExchangeModel,
  IDOBleRestoreReplyExchangeModel,
  IDOAppBlePauseReplyExchangeModel,
  IDOAppRestoreReplyExchangeModel,
  IDOAppBleEndReplyExchangeModel,
  IDOAppPauseReplyExchangeModel,
  IDOAppBleRestoreReplyExchangeModel
} from 'protocol_channel'; // 路径指向您的SDK模块
import { locationManager } from '@kit.MDMKit';
import { LocationManager } from '../utils/LocationManager';
import { common } from '@kit.AbilityKit';


const INTERVAL_EXCHANGE_DATA = 2000;
const INTERVAL_EXCHANGE_COMPLETE_DATA = 40000;
const INTERVAL_EXCHANGE_HR_DATA = 30000;

export enum SportStatus {
  Stopped,
  Started,
  Paused,
  Resumed
}

/**
 * Sport 页面的 ViewModel（视图模型）
 *
 * - 使用 @Observed 装饰器标记，使其成为一个可观察对象。
 *   这意味着它的所有属性的变更都能被UI层自动感知并触发界面刷新。
 *
 * - 实现了 IDOExchangeDataDelegate 接口，作为数据交换的代理，
 *   负责处理所有来自蓝牙设备的通信回调。
 *
 * - 封装了页面的所有业务逻辑和状态，使得UI层（View）可以保持纯粹的声明式渲染。
 */
@Observed
export class SportViewModel implements IDOExchangeDataDelegate {
  // =================================================================
  // MARK: - UI交互回调 (UI Interaction Callbacks)
  // =================================================================

  /**
   * @description 用于向UI层发送显示消息的请求。
   *              由View层在 aboutToAppear 中注入具体的实现（如显示Toast）。
   *              约定：传入非空字符串时显示消息，传入空字符串或特殊指令时可用于隐藏提示。
   */
  public showMessageCallback: (message: string) => void = () => {
  };
  // =================================================================
  // MARK: - 状态属性 (State Properties)
  // =================================================================

  /** @description 当前的运动状态，直接绑定到UI，控制按钮的可用性等。 */
  @Track public exchangeType: SportStatus = SportStatus.Stopped;
  /** @description 显示在界面上的日志信息，用于调试和状态展示。 */
  @Track public consoleLog: string = "欢迎！请点击 '开始' 来启动运动。";
  /** @description 存储当前运动的基础信息（如开始时间），在多次通信中使用。 */
  private baseModel: IDOExchangeBaseModel | null = null;
  /** @description 当前运动持续时间（秒）。 */
  private duration: number = 0;
  /** @description 当前运动消耗的卡路里。 */
  private calories: number = 0;
  /** @description 当前运动的距离（米）。 */
  private distance: number = 0;
  private gpsSignal: number = 0;
  /** @description 标记运动是否已由App端发起结束，用于处理最后的数据同步。 */
  private isSportEnd: boolean = false;
  /** @description 存储所有定时器的ID，以便在不需要时（如暂停、停止、页面销毁）进行清除。 */
  private timers: number[] = [];

  private locationMgr: LocationManager | null = null;
  private abilityContext: common.UIAbilityContext;

  // =================================================================
  // MARK: - 生命周期 (Lifecycle)
  // =================================================================

  constructor(context: common.UIAbilityContext) {
    this.abilityContext = context;
    this.locationMgr = LocationManager.getInstance(this.abilityContext)
    sdk.dataExchange.addExchange(this);
    this.appendToConsole("视图模型已初始化并注册到SDK。");
  }

  /**
   * 销毁方法。
   * 在UI页面即将销毁时由外部调用，用于清理定时器等长期运行的资源，防止内存泄漏。
   */
  public destroy(): void {
    this.stopTimers();
    this.appendToConsole("视图模型已销毁，所有定时器已清除。");
  }

  // =================================================================
  // MARK: - 公共操作方法 (Public Actions) - 由UI层调用
  // =================================================================

  /**
   * 开始运动。
   */
  public sportStart(): void {
    this.consoleLog = '';
    this.appendToConsole("正在尝试开始运动...");
    // 【解耦】通过回调请求UI显示提示
    this.showMessageCallback('正在启动运动...');

    const currentDate = new Date();
    // 创建本次运动的基础模型
    const baseModel = new IDOExchangeBaseModel(currentDate.getDate(),
      currentDate.getHours(),
      currentDate.getMinutes(),
      currentDate.getSeconds(),
      0x32,
    )
    this.baseModel = baseModel;
    // 创建并发送“App开始运动”的指令对象
    const obj = new IDOAppStartExchangeModel(baseModel, 0, 0, 1, 0, 0, 0); // forceStart: 1
    sdk.dataExchange.appExec(obj);
    this.exchangeType = SportStatus.Started;
  }

  /**
   * 暂停运动。
   */
  public sportPause(): void {
    if (!this.baseModel) {
      return;
    } // 如果没有在运动中，则不执行任何操作
    this.appendToConsole("正在暂停运动...");

    const obj = new IDOAppPauseExchangeModel(this.baseModel)
    // 实际应发送
    sdk.dataExchange.appExec(obj); // 模拟发送

    // 更新UI状态并停止数据同步定时器
    this.exchangeType = SportStatus.Paused;
    this.stopTimers();
  }

  /**
   * 恢复运动。
   */
  public sportResume(): void {
    if (!this.baseModel) {
      return;
    }
    this.appendToConsole("正在恢复运动...");

    const obj = new IDOAppRestoreExchangeModel(this.baseModel)
    // 实际应发送 IDOAppRestoreExchangeModel
    sdk.dataExchange.appExec(obj); // 模拟发送

    // 更新UI状态并重新启动数据同步定时器
    this.exchangeType = SportStatus.Resumed;
    this.startTimers();
  }

  /**
   * 停止运动。
   */
  public sportStop(): void {
    if (!this.baseModel) {
      return;
    }
    this.appendToConsole("正在停止运动...");

    // 创建并发送“App结束运动”的指令对象，包含本次运动的总结数据
    const obj = new IDOAppEndExchangeModel(this.baseModel, this.duration, this.calories, this.distance, 1); // isSave: 1
    sdk.dataExchange.appExec(obj);
  }

  // =================================================================
  // MARK: - 私有辅助方法 (Private Helper Methods)
  // =================================================================

  /**
   * 在控制台日志的顶部追加一条新消息。
   * @param message 要记录的消息。
   */
  private appendToConsole(message: string): void {
    const time = new Date().toLocaleTimeString();
    // 新日志加在最前面，实现滚动效果
    this.consoleLog = `[${time}] ${message}\n${this.consoleLog}`;
  }

  /**
   * 启动所有用于数据同步的定时器。
   */
  private startTimers(): void {
    this.appendToConsole("定时器已启动。");
    this.stopTimers(); // 先清除所有旧的定时器，防止重复

    // 定时器1: 同步简要运动数据
    const dataTimer = setInterval(() => {
      if (this.exchangeType === SportStatus.Started || this.exchangeType === SportStatus.Resumed) {
        this.exchangeData();
      }
    }, INTERVAL_EXCHANGE_DATA);
    this.timers.push(dataTimer);

    // 定时器2: 同步完整的运动小结数据
    const completeTimer = setInterval(() => {
      if (this.exchangeType === SportStatus.Started || this.exchangeType === SportStatus.Resumed) {
        this.appendToConsole("请求同步完整运动报告...");
        sdk.dataExchange.getLastActivityData();
      }
    }, INTERVAL_EXCHANGE_COMPLETE_DATA);
    this.timers.push(completeTimer);

    // 定时器3: 同步V3版本的运动心率数据
    const hrTimer = setInterval(() => {
      if (this.exchangeType === SportStatus.Started || this.exchangeType === SportStatus.Resumed) {
        if (sdk.dataExchange.supportV3ActivityExchange) {
          this.appendToConsole("请求同步心率数据...");
          sdk.dataExchange.getActivityHrData()
        }
      }
    }, INTERVAL_EXCHANGE_HR_DATA);
    this.timers.push(hrTimer);
  }

  /**
   * 停止并清除所有正在运行的定时器。
   */
  private stopTimers(): void {
    if (this.timers.length > 0) {
      this.appendToConsole("定时器已停止。");
      this.timers.forEach(timerId => clearInterval(timerId));
      this.timers = []; // 清空数组
    }
  }

  /// Synchronize brief sports data for app display
  /// Sync every 2 seconds
  private exchangeData() {
    if (this.baseModel == null) {
      return;
    }
    if (sdk.dataExchange.supportV3ActivityExchange) {
      let obj = new IDOAppIngV3ExchangeModel(this.baseModel, 2, this.gpsSignal,  this.distance, 0,  this.duration, this.calories)
      sdk.dataExchange.appExec(obj)
    } else {
      let obj = new IDOAppIngExchangeModel(this.baseModel, this.duration, this.calories, this.distance, 0)
      sdk.dataExchange.appExec(obj)
    }
  }

  // =================================================================
  // MARK: - IDOExchangeDataDelegate 接口实现
  // =================================================================

  /**
   * 监听【App执行指令后，设备的回应】。
   * @param model 从SDK收到的回复数据模型实例。
   */
  public appListenAppExec(model: object): void {
    this.appendToConsole(`收到App指令的回复: ${JSON.stringify(model)}`);

    if (model instanceof IDOAppStartReplyExchangeModel) {
      // 【解耦】请求UI移除加载提示，这里用空字符串作为信号
      this.showMessageCallback('');
      if (model.retCode === 0) { // 0 代表成功
        this.appendToConsole("运动成功启动！");
        this.exchangeType = SportStatus.Started;
        this.startTimers();
        // 成功开始后，重置运动数据
        this.duration = 0;
        this.calories = 0;
        this.distance = 0;
        this.locationMgr?.startLocationUpdates((locationData) => {
          this.distance = this.locationMgr!.getTotalDistance();
          this.gpsSignal = locationData.accuracy;
          console.debug(`"this.distance:${this.distance} this.gpsSignal:${this.gpsSignal}"`)
        })
      } else {
        this.appendToConsole(`运动启动失败，错误码: ${model.retCode}。`);
        // 【解耦】请求UI显示错误信息
        this.showMessageCallback(`运动启动失败，错误码: ${model.retCode}`);
        this.baseModel = null; // 启动失败，清除基础模型
      }
    } else if (model instanceof IDOAppEndReplyExchangeModel) {
      this.appendToConsole("收到结束运动的确认。运动会话已完成。");
      this.exchangeType = SportStatus.Stopped;
      this.baseModel = null;
      this.stopTimers();
      this.isSportEnd = true; // 标记运动已结束
      // 结束后，主动获取最后的心率和运动总结数据
      sdk.dataExchange.getActivityHrData();
      sdk.dataExchange.getLastActivityData();
    }else if (model instanceof IDOAppPauseReplyExchangeModel) {
      let obj = model as IDOAppPauseReplyExchangeModel
      console.debug("reply for app's pause cmd: "+obj)
      this.exchangeType = SportStatus.Paused
    }
    else if (model instanceof IDOAppRestoreReplyExchangeModel) {
      let obj = model as IDOAppRestoreReplyExchangeModel
      console.debug("reply for app's restore cmd: "+obj)
      this.exchangeType = SportStatus.Resumed
    } else if (model instanceof IDOAppActivityDataV3ExchangeModel) {
      this.appendToConsole(`收到运动数据更新: ${JSON.stringify(model)}`);
      // 更新本地数据，取最大值以防数据回滚
      this.duration = Math.max(this.duration, model.durations ?? 0);
      this.calories = Math.max(this.calories, model.calories ?? 0);
      this.distance = Math.max(this.distance, model.distance ?? 0);
      // 如果这是在标记运动结束后收到的数据，说明是最终的总结数据
      if (this.isSportEnd) {
        this.isSportEnd = false; // 重置标记
        this.appendToConsole("最终运动数据已收到。任务完成！");
      }
    }
  }

  /**
   * 监听【设备主动发起的事件】。
   * @param model 从SDK收到的设备主动上报的数据模型实例。
   */
  public appListenBleExec(model: object): void {
    this.appendToConsole(`收到设备主动事件: ${JSON.stringify(model)}`);

    // 严格遵循Swift代码逻辑，对设备主动发起的运动状态变化进行响应
    if (model instanceof IDOBleStartExchangeModel) {
      let obj = model as IDOBleStartExchangeModel
      let sendModel = new IDOBleStartReplyExchangeModel(obj.baseModel, obj.operate, 0)
      // !!!: 暂时不支持设备启动运动和app联动
      // this.baseModel = obj.baseModel
      this.exchangeType = SportStatus.Started;
      sdk.dataExchange.appReplyExec(sendModel)
    }else if (model instanceof  IDOBleIngExchangeModel) {
      let obj = model as IDOBleIngExchangeModel
      let sendModel = new IDOBleIngReplyExchangeModel(obj.baseModel, obj.distance ?? 0)
      sdk.dataExchange.appReplyExec(sendModel)
    } else if (model instanceof IDOBleEndExchangeModel) {
      let obj = model as IDOBleEndExchangeModel
      let sendModel = new IDOBleEndReplyExchangeModel(obj.baseModel, 0)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Stopped;
    } else if (model instanceof IDOBlePauseExchangeModel) {
      let obj = model as IDOBlePauseExchangeModel
      let sendModel = new IDOBlePauseReplyExchangeModel(obj.baseModel, 0)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Paused;
    } else if (model instanceof IDOBleRestoreExchangeModel) {
      let obj = model as IDOBleRestoreExchangeModel
      let sendModel = new IDOBleRestoreReplyExchangeModel(obj.baseModel, 0)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Resumed;
    } else if (model instanceof IDOAppBlePauseExchangeModel) {
      let obj = model as IDOAppBlePauseExchangeModel
      let sendModel = new IDOAppBlePauseReplyExchangeModel(obj.baseModel, 0)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Paused;
    } else if (model instanceof IDOAppBleRestoreExchangeModel) {
      let obj = model as IDOAppBleRestoreExchangeModel
      let sendModel = new IDOAppBleRestoreReplyExchangeModel(obj?.baseModel, 0)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Resumed;
    } else if (model instanceof IDOAppBleEndExchangeModel) {
      let obj = model as IDOAppBleEndExchangeModel
      let sendModel = new IDOAppBleEndReplyExchangeModel(this.baseModel!, 0, obj.duration, obj.calories, obj.distance)
      sdk.dataExchange.appReplyExec(sendModel)
      this.exchangeType = SportStatus.Stopped;
      sdk.dataExchange.getActivityHrData()
      sdk.dataExchange.getLastActivityData()
      this.isSportEnd = true
    }
  }

  /**
   * 监听V2版本的通用数据交换。
   */
  public exchangeV2Data(model: IDOExchangeV2Model): void {
    this.appendToConsole(`收到 V2 数据: ${JSON.stringify(model)}`);
    // 当前未实现具体逻辑
  }

  /**
   * 监听V3版本的通用数据交换。
   */
  public exchangeV3Data(model: IDOExchangeV3Model): void {
    this.appendToConsole(`收到 V3 数据: ${JSON.stringify(model)}`);
    // 当前未实现具体逻辑
  }
}