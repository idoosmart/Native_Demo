import geoLocationManager from '@ohos.geoLocationManager';
import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';

// 定义一个回调函数类型，用于接收位置信息
// Define a callback type for receiving location info
type LocationCallback = (locationData: geoLocationManager.Location) => void;
// 定义一个回调函数类型，用于接收卫星信息
// Define a callback type for receiving satellite info
type SatelliteStatusCallback = (status: geoLocationManager.SatelliteStatusInfo) => void;

export class LocationManager {
  private static instance: LocationManager;
  private locationRequest: geoLocationManager.LocationRequest;
  private locationCallback: LocationCallback | null = null;
  private abilityContext: common.UIAbilityContext;
  private totalDistance: number = 0.0; // 总距离，单位：米 / Total distance, unit: meters
  private previousLocation?: geoLocationManager.Location; // 上一个位置点 / Previous location point

  // 私有构造函数，确保只能通过 getInstance 创建实例
  // Private constructor, ensures instances are only created through getInstance
  private constructor(context: common.UIAbilityContext) {
    this.abilityContext = context;
    // 配置定位请求参数
    // Configure the location request parameters
    this.locationRequest = {
      priority: geoLocationManager.LocationRequestPriority.ACCURACY, // 优先选择精度高 / Prefer high accuracy
      timeInterval: 5000, // 5秒更新一次 / 5-second update interval
      distanceInterval: 3, // 移动3米更新一次 / Update once every 3 meters of movement
    };
  }

  // 单例模式的公共访问方法
  // Public accessor for the singleton
  public static getInstance(context: common.UIAbilityContext): LocationManager {
    if (!LocationManager.instance) {
      LocationManager.instance = new LocationManager(context);
    }
    // 每次获取实例时重置距离和上个位置点，以开始新的追踪
    // Reset the distance and previous point each time the instance is fetched, to start new tracking
    LocationManager.instance.resetDistance();
    return LocationManager.instance;
  }

  /**
   * 检查并请求定位权限
   * Check and request the location permission
   */
  private async checkAndRequestPermissions(): Promise<boolean> {
    const permissions: Permissions[] = ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION'];
    const atManager = abilityAccessCtrl.createAtManager();

    try {
      // 检查高精度定位权限
      // Check the precise location permission
      let grantStatus =
        await atManager.checkAccessToken(this.abilityContext.applicationInfo.accessTokenId, permissions[0]);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.log('定位权限已授予 / Location permission granted');
        return true;
      }

      // 若未授权，则向用户请求权限
      // If not granted, request the permission from the user
      const result = await atManager.requestPermissionsFromUser(this.abilityContext, permissions);
      if (result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.log('定位权限请求成功 / Location permission request succeeded');
        return true;
      } else {
        console.error('定位权限请求失败 / Location permission request failed');
        return false;
      }
    } catch (err) {
      console.error('权限检查或请求异常 / Permission check or request error:', JSON.stringify(err));
      return false;
    }
  }

  /**
   * 启动实时定位
   * Start real-time location
   * @param callback 用于接收位置信息的回调函数 / Callback for receiving location info
   */
  public async startLocationUpdates(callback: LocationCallback): Promise<void> {
    if (!callback) {
      console.error('未提供回调函数 / No callback provided');
      return;
    }

    const hasPermission = await this.checkAndRequestPermissions();
    if (!hasPermission) {
      console.error('无法启动定位，因为没有必要的权限 / Cannot start location, required permission missing');
      return;
    }

    const isLocationEnabled = await geoLocationManager.isLocationEnabled();
    if (!isLocationEnabled) {
      console.warn('定位服务未开启，请在系统设置中打开 / Location service is off, please enable it in system settings');
      // 这里可以引导用户去设置
      // The user could be guided to settings here
      return;
    }

    this.locationCallback = callback;
    try {
      // 注册位置更新监听器
      // Register the location update listener
      geoLocationManager.on('locationChange', this.locationRequest, this.onLocationChange);
      console.log('实时定位已启动 / Real-time location started');
      this.startSatelliteStatusUpdates(this.onSatelliteStatusChange)
    } catch (err) {
      console.error('启动定位失败 / Failed to start location:', JSON.stringify(err));
    }
  }

  /**
   * 停止实时定位
   * Stop real-time location
   */
  public stopLocationUpdates(): void {
    if (this.onLocationChange) { // 检查回调函数本身是否存在 / Check that the callback itself exists
      try {
        // 取消位置更新监听器
        // Unregister the location update listener
        geoLocationManager.off('locationChange', this.onLocationChange);
        this.locationCallback = null; // 清空外部传入的回调 / Clear the externally provided callback
        this.stopSatelliteStatusUpdates(this.onSatelliteStatusChange)
        console.log('实时定位已停止 / Real-time location stopped');
      } catch (err) {
        console.error('停止定位失败 / Failed to stop location:', JSON.stringify(err));
      }
    }
  }

  /**
   * 启动对GNSS卫星状态的监听
   * Start listening to GNSS satellite status
   * @param callback 用于接收卫星状态信息的回调函数 / Callback for receiving satellite status info
   */
  private startSatelliteStatusUpdates(callback: SatelliteStatusCallback): void {
    if (!callback) {
      console.error('未提供卫星状态回调函数 / No satellite status callback provided');
      return;
    }
    try {
      // 订阅 'satelliteStatusChange' 事件
      // Subscribe to the 'satelliteStatusChange' event
      geoLocationManager.on('satelliteStatusChange', callback);
      console.log('GNSS卫星状态监听已启动 / GNSS satellite status listening started');
    } catch (err) {
      console.error('启动GNSS卫星状态监听失败 / Failed to start GNSS satellite status listening:', JSON.stringify(err));
    }
  }

  /**
   * 停止对GNSS卫星状态的监听
   * Stop listening to GNSS satellite status
   * @param callback 之前用于订阅的回调函数 / The callback previously used to subscribe
   */
  private stopSatelliteStatusUpdates(callback: SatelliteStatusCallback): void {
    if (!callback) {
      console.error('停止监听时必须提供原始的回调函数 / The original callback must be provided when stopping listening');
      return;
    }
    try {
      // 取消订阅 'satelliteStatusChange' 事件
      // Unsubscribe from the 'satelliteStatusChange' event
      geoLocationManager.off('satelliteStatusChange', callback);
      console.log('GNSS卫星状态监听已停止 / GNSS satellite status listening stopped');
    } catch (err) {
      console.error('停止GNSS卫星状态监听失败 / Failed to stop GNSS satellite status listening:', JSON.stringify(err));
    }
  }

  /**
   * 获取累计的总距离
   * Get the accumulated total distance
   * @returns number 总距离（米） / Total distance (meters)
   */
  public getTotalDistance(): number {
    return this.totalDistance;
  }

  /**
   * 重置距离计算器
   * Reset the distance calculator
   */
  private resetDistance(): void {
    this.totalDistance = 0.0;
    this.previousLocation = undefined;
    console.log('距离计算器已重置 / Distance calculator reset');
  }

  public gpsSignal(): number {
    return this.previousLocation?.accuracy ?? 0;
  }

  /**
   * 位置信息更新时的回调处理函数
   * Callback handler for location updates
   * (这是获取距离的核心逻辑所在)
   * (This is where the core distance logic lives)
   */
  private onLocationChange = (newLocation: geoLocationManager.Location) => {
    if (!newLocation) {
      return;
    }

    // --- 距离计算逻辑 ---
    // --- Distance calculation logic ---
    // 检查是否存在上一个位置点
    // Check whether a previous location point exists
    if (this.previousLocation) {
      try {
        // 【核心修正】调用我们自己实现的 Haversine 计算方法
        // [Core fix] Call our own Haversine calculation method
        const distance = this.calculateDistance(this.previousLocation, newLocation);

        // 累加到总距离
        // Add to the total distance
        this.totalDistance += distance;
        console.log(`本次移动距离: ${distance.toFixed(2)}米, 总距离: ${this.totalDistance.toFixed(2)}米 / Distance moved this time: ${distance.toFixed(2)} m, total distance: ${this.totalDistance.toFixed(2)} m`);
      } catch (err) {
        console.error('计算距离时发生异常 / Error while calculating distance:', JSON.stringify(err));
      }
    }

    // 更新上一个位置点为当前点，为下一次计算做准备
    // Set the previous point to the current one, ready for the next calculation
    this.previousLocation = newLocation;
    // --- 距离计算逻辑结束 ---
    // --- End of distance calculation logic ---

    // 调用外部传入的回调函数，将新位置信息传递出去
    // Call the externally provided callback to pass on the new location
    if (this.locationCallback) {
      this.locationCallback(newLocation);
      console.log(`获取到新位置: 经度=${newLocation.longitude}, 纬度=${newLocation.latitude}, 精度=${newLocation.accuracy}米 / New location: longitude=${newLocation.longitude}, latitude=${newLocation.latitude}, accuracy=${newLocation.accuracy} m`);
    }
  };
  // 这是处理卫星信号的回调函数
  // This is the callback that handles satellite signals
  private onSatelliteStatusChange = (status: geoLocationManager.SatelliteStatusInfo) => {
    // 'status' 对象就是我们需要的信号信息
    // 'status' object is the signal info we need
    const totalSatellites = status.satellitesNumber;
    let infoText = `可见卫星总数 / Visible satellites: ${totalSatellites}\n`;
    infoText += '--- 详细信息 / Details ---\n';

    for (let i = 0; i < totalSatellites; i++) {
      const id = status.satelliteIds[i];
      // carrierToNoiseDensitys 就是信噪比，信号强度的关键指标
      // carrierToNoiseDensitys is the carrier-to-noise ratio, the key indicator of signal strength
      const cno = status.carrierToNoiseDensitys[i];
      const altitude = status.altitudes[i]; // 仰角 / Elevation angle
      const azimuth = status.azimuths[i]; // 方位角 / Azimuth

      infoText += `卫星ID: ${id}, 信号强度(C/N₀) / Satellite ID: ${id}, signal strength (C/N₀): ${cno.toFixed(2)} dB-Hz\n`;
    }

    console.info(infoText);
  }

  /**
   * 使用 Haversine 公式计算两个地理坐标点之间的距离（单位：米）
   * Calculate the distance between two geographic coordinates using the Haversine formula (unit: meters)
   * @param loc1 第一个位置点 / The first location point
   * @param loc2 第二个位置点 / The second location point
   * @returns 返回两个点之间的距离（米） / The distance between the two points (meters)
   */
  private calculateDistance(loc1: geoLocationManager.Location, loc2: geoLocationManager.Location): number {
    const R = 6371e3; // 地球平均半径，单位：米 / Mean Earth radius, unit: meters
    const lat1 = loc1.latitude * Math.PI / 180; // 将角度转换为弧度 / Convert degrees to radians
    const lat2 = loc2.latitude * Math.PI / 180;
    const deltaLat = (loc2.latitude - loc1.latitude) * Math.PI / 180;
    const deltaLon = (loc2.longitude - loc1.longitude) * Math.PI / 180;

    const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
      Math.cos(lat1) * Math.cos(lat2) *
      Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const distance = R * c; // 最终距离 / Final distance
    return distance;
  }
}