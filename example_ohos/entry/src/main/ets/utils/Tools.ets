import fs from '@ohos.file.fs';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { abilityAccessCtrl, common, bundleManager, Permissions, PermissionRequestResult } from '@kit.AbilityKit';
import { myPreferences } from '../entryability/EntryAbility';
import { notificationManager } from '@kit.NotificationKit';
import { IDOBleDeviceModel } from 'protocol_channel';
import { ArrayList } from '@kit.ArkTS';


export class Tools {
  private static instance: Tools;
  private atManager = abilityAccessCtrl.createAtManager();
  private keyBindState = "bindState_"
  private keyBindDevices = "keyBindDevices"

  // 私有构造函数，确保只能通过 getInstance 创建实例
  private constructor() {
  }

  // 单例模式的公共访问方法
  public static getInstance(): Tools {
    if (!Tools.instance) {
      Tools.instance = new Tools();
    }
    return Tools.instance;
  }

  /**
   * 获取指定文件的大小（字节）
   * @param path 文件完整路径
   */
  public getFileSize(path: string): number {
    let fileStat = fs.statSync(path); // 同步方式获取文件状态
    return fileStat.size; // 单位是字节
  }

  public async requestNotificationPermission(context: common.UIAbilityContext): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const permission: Permissions = 'ohos.permission.ACCESS_NOTIFICATION_POLICY';
    // 获取当前应用的accessTokenId
    const bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    const tokenID: number = appInfo.accessTokenId;
    try {
      // 检查应用是否已被授予该权限
      const status = await atManager.checkAccessToken(tokenID, permission);
      if (status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        console.log('Notification permission has been granted.');
        return true;
      } else {
        // 如果未授权，则向用户发起请求
        const data: PermissionRequestResult = await atManager.requestPermissionsFromUser(context, [permission]);
        if (data.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
          console.log('Notification permission granted successfully.');
          return true;
        } else {
          console.log('Notification permission was denied.');
          return false;
        }
      }
    } catch (err) {
      console.error(`Failed to request notification permission: ${JSON.stringify(err)}`);
      return false;
    }
  }

  public async publishNotification(id: number, title: string, text: string, additionalText: string, context: common.UIAbilityContext) : Promise<boolean> {
    const notificationRequest: notificationManager.NotificationRequest = {
      id: id, // 每个通知需要一个唯一的ID
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: title,
          text: text,
          additionalText: additionalText
        }
      }
    };

    try {
      await notificationManager.publish(notificationRequest);
      console.log('Notification published successfully.');
      return true
    } catch (err) {
      console.error(`Failed to publish notification: ${JSON.stringify(err)}`);
      return false
    }
  }

  /**
   * 检查并请求读取媒体文件的权限.
   * @param context UIAbility 的上下文.
   * @returns Promise<boolean> - 用户是否授予了权限.
   */
  public async checkAndRequestReadMediaPermissions(context: common.UIAbilityContext): Promise<boolean> {
    let LOG_TAG = 'requestReadPermission'
    let filePermission: Permissions = 'ohos.permission.READ_MEDIA';
    // 获取当前应用的accessTokenId
    const bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    const tokenID: number = appInfo.accessTokenId;

    try {
      // 2. 检查当前权限状态
      const grantStatus = await this.atManager.checkAccessToken(tokenID, filePermission);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        hilog.info(0x0000, LOG_TAG, 'Read media permission has already been granted.');
        return true; // 权限已被授予
      }

      // 3. 如果未授予，则向用户发起请求
      hilog.info(0x0000, LOG_TAG, 'Requesting read media permission from user...');
      const result = await this.atManager.requestPermissionsFromUser(context, [filePermission]);
      const authResult = result.authResults[0];

      if (authResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        hilog.info(0x0000, LOG_TAG, 'User granted the read media permission.');
        return true; // 用户刚刚授予了权限
      } else {
        hilog.warn(0x0000, LOG_TAG, 'User denied the read media permission.');
        return false; // 用户拒绝了权限
      }
    } catch (err) {
      const error = err as Error;
      hilog.error(0x0000, LOG_TAG, `Failed to request permission: ${error.message}`);
      return false; // 发生错误
    }
  }


  /**
   * 检查并请求指定权限.
   * @param context UIAbility 的上下文.
   * @param permissions 需要的权限.
   * @param sendRequest 是否在未授权时发送请求.
   * @returns Promise<boolean> - 用户是否授予了权限.
   */
  public async checkAndRequestPermissionsWith(context: common.UIAbilityContext, permissions: Permissions, sendRequest: boolean): Promise<boolean> {
    let LOG_TAG = 'checkAndRequestPermissions'
    // 获取当前应用的accessTokenId
    const bundleInfo: bundleManager.BundleInfo =
      await bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
    const appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
    const tokenID: number = appInfo.accessTokenId;

    try {
      // 2. 检查当前权限状态
      const grantStatus = await this.atManager.checkAccessToken(tokenID, permissions);

      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        hilog.info(0x0000, LOG_TAG, permissions+' permission has already been granted.');
        return true; // 权限已被授予
      }

      // 不需要发送请求，直接返回
      if (!sendRequest) {
        return false;
      }

      // 3. 如果未授予，则向用户发起请求
      hilog.info(0x0000, LOG_TAG, 'Requesting permission from user...');
      const result = await this.atManager.requestPermissionsFromUser(context, [permissions]);
      const authResult = result.authResults[0];

      if (authResult === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        hilog.info(0x0000, LOG_TAG, 'User granted the  permission.');
        return true; // 用户刚刚授予了权限
      } else {
        hilog.warn(0x0000, LOG_TAG, 'User denied the  permission.');
        return false; // 用户拒绝了权限
      }
    } catch (err) {
      const error = err as Error;
      hilog.error(0x0000, LOG_TAG, `Failed to request permission: ${error.message}`);
      return false; // 发生错误
    }
  }


  /**
   * 将一个外部 URI 指向的文件复制到应用的沙箱缓存目录中.
   * 这是连接原生文件系统和 Flutter 的推荐桥梁方法.
   *
   * @param context UIAbility 的上下文，用于获取沙箱路径.
   * @param sourceUri 文件的源 URI (例如 'file://docs/storage/.../a.json').
   * @returns Promise<string | null> - 成功则返回沙箱内的文件路径 (string), 失败则返回 null.
   */
  async copyFileToAppCache(context: common.UIAbilityContext, sourceUri: string): Promise<string | null> {
    const LOG_TAG = 'FileBridge'; // 定义一个日志标签，方便过滤

    try {
      // 1. 获取应用的专属缓存目录路径. 这是存放临时文件的标准位置.
      const tempDir: string = context.tempDir;
      hilog.info(0x0000, LOG_TAG, 'App temp directory is: %{public}s', tempDir);

      // 检查并创建目录
      if (!await fs.access(tempDir)) {
        hilog.info(0x000, LOG_TAG, 'create dir :'+tempDir);
        await fs.mkdir(tempDir)
      }else {
        hilog.info(0x000, LOG_TAG, 'exists dir :'+tempDir);
      }

      // 2. 从源 URI 中解析出原始文件名.
      const fileName = sourceUri.substring(sourceUri.lastIndexOf('/') + 1);
      if (!fileName) {
        hilog.error(0x0000, LOG_TAG, 'Could not extract file name from URI: %{public}s', sourceUri);
        return null;
      }

      // 3. 构造目标文件的完整路径 (缓存目录 + tmp_文件名).
      const destinationPath = `${tempDir}/tmp_${fileName}`;
      hilog.info(0x0000, LOG_TAG, 'Destination path in sandbox will be: %{public}s', destinationPath);

      // Open the file using its URI to get a file descriptor (fd)
      let sourceFile = await fs.open(sourceUri, fs.OpenMode.READ_ONLY);

      // Get file stats to determine its size
      const sourceStat: fs.Stat = await fs.stat(sourceFile.fd);
      const size: number = sourceStat.size;

      hilog.info(0x0000, LOG_TAG, 'file size: %{public}d', size);

      // let hasPermission = await this.checkAndRequestReadMediaPermissions(context);
      //
      // if (hasPermission) {
      //   hilog.info(0x0000, LOG_TAG, 'hasPermission: '+hasPermission);
      // }

      // 复制方法失败,返回错误码2 ,应该是权限问题,暂时调整为手动写文件
      // // 4. 【核心步骤】执行复制操作.
      // //    fs.copyFile 是一个强大的 API，它可以直接将 URI 作为源进行复制.
      // await fs.copyFile(sourceUri, destinationPath);

      // 4. 复制文件
      // --- 手动读取源文件 ---
      const stat = await fs.stat(sourceFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(sourceFile.fd, buffer); // 将文件内容读入 buffer
      hilog.info(0x0000, LOG_TAG, 'Source file read into buffer successfully.');

      // --- 手动写入目标文件 ---
      let destFile = await fs.open(destinationPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      await fs.write(destFile.fd, buffer); // 将 buffer 内容写入新文件
      hilog.info(0x0000, LOG_TAG, 'Buffer written to destination file successfully!');

      // 5. 将这个 Flutter 可以直接使用的沙箱路径返回.
      return destinationPath;

    } catch (err) {
      hilog.error(0x0000, LOG_TAG, 'Failed to copy file. Err:'+err);
      return null;
    }
  }

  getBindState(macAddress: string): boolean {
    let key = this.keyBindState+"#"+macAddress;
    let rs = (myPreferences?.getSync(key, false) as boolean) ?? false
    console.debug("myPreferences: "+myPreferences)
    console.debug("call getBindState rs: " + rs)
    return rs
  }

  setBindState(macAddress: string, isBind: boolean) {
    let key = this.keyBindState+"#"+macAddress;
    console.debug("myPreferences: "+myPreferences)
    console.debug("call setBindState macAddress: "+macAddress+", isBind: " + isBind)
    myPreferences?.putSync(key, isBind);
    myPreferences?.flushSync()
  }


  setBindDevice(device: IDOBleDeviceModel) {
    let devices = this.getBindDevices();
    devices.push(device);
    let json = JSON.stringify(devices)
    console.info("setBindDevice: "+json);
    myPreferences?.putSync(this.keyBindDevices, json)
    myPreferences?.flushSync();
  }

  getBindDevices(): IDOBleDeviceModel[] {
    let rs = (myPreferences?.getSync(this.keyBindDevices, null) as string | null) ?? ""
    if (rs == null || rs.length == 0) {
      return [];
    }
    console.info("getBindDevices: "+rs)
    let devices = JSON.parse(rs) as IDOBleDeviceModel[];
    console.info("getBindDevices, devices = "+devices.length)
    return devices;
  }

  removeBindDevice(mac: string) {
    let devices = this.getBindDevices();
    if (devices.length==0) {
      return;
    }

    let newList = new ArrayList<IDOBleDeviceModel>();
    for (let i = 0; i < devices.length; i++) {
      let device = devices[i];
      if (device.macAddress == mac) {
        continue;
      }
      newList.add(device);
    }
    myPreferences?.putSync(this.keyBindDevices, JSON.stringify(newList.convertToArray()))
    myPreferences?.flushSync();
  }
}

