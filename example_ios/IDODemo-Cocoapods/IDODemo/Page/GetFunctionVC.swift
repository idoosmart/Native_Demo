//
//  GetFunctionVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class GetFunctionVC: UIViewController {
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    private lazy var items: [GetCmd] = [
        GetCmd(type: .getDeviceInfo, title: "getDeviceInfo", desc: L10n.getDeviceInfo),
        GetCmd(type: .getFunctionTable, title: "getFunctionTable", desc: L10n.getFunctionTable),
        GetCmd(type: .getUnreadAppReminder, title: "getUnreadAppReminder", desc: L10n.getUnreadAppReminder),
        GetCmd(type: .getWatchDialInfo, title: "getWatchDialInfo", desc: L10n.getWatchDialInfo),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Get Function"
        view.backgroundColor = .white
        
        // !!!: 部分接口需根据功能表判定后调用（sdk兼容所有设备，功能表不支持的请勿调用）
        
        // 内部全量测试专用（客户使用需保持此值为false）
        let innerTest = false
        
        if (innerTest || sdk.funcTable.getNewWatchList) {
            items.append(GetCmd(type: .getWatchListV3, title: "getWatchListV3", desc: L10n.getWatchListV3))
        } else {
            items.append(GetCmd(type: .getWatchListV2, title: "getWatchListV2", desc: L10n.getWatchListV2))
        }

        if (innerTest || sdk.funcTable.getBatteryInfo) {
            items.append(GetCmd(type: .getBatteryInfo, title: "getBatteryInfo", desc: L10n.getBatteryInfo))
        }
        if (innerTest || sdk.funcTable.getDeviceLogState) {
            items.append(GetCmd(type: .getDeviceLogState, title: "getDeviceLogState", desc: L10n.getDeviceLogState))
        }
        if (innerTest || sdk.funcTable.getMenuList) {
            items.append(GetCmd(type: .getMenuList, title: "getMenuList", desc: L10n.getMenuList))
        }
        if (innerTest || sdk.funcTable.reminderAncs) {
            items.append(GetCmd(type: .getNoticeStatus, title: "getNoticeStatus", desc: L10n.getNoticeStatus))
        }
        if (innerTest || sdk.funcTable.syncV3SyncAlarm) {
            items.append(GetCmd(type: .getAlarm, title: "getAlarm", desc: L10n.getAlarm))
        }

        if (innerTest || sdk.funcTable.reminderGetAllContact) {
            items.append(GetCmd(type: .getContactReviseTime, title: "getContactReviseTime", desc: L10n.getContactReviseTime))
        }

        if (innerTest || sdk.funcTable.getWalkReminderV3) {
            items.append(GetCmd(type: .getWalkRemind, title: "getWalkRemind", desc: L10n.getWalkRemind))
        }

        if (innerTest || sdk.funcTable.getSetMaxItemsNum) {
            items.append(GetCmd(type: .getSupportMaxSetItemsNum, title: "getSupportMaxSetItemsNum", desc: L10n.getSupportMaxSetItemsNum))
        }

        if (innerTest || sdk.funcTable.getScreenBrightnessMain9) {
            items.append(GetCmd(type: .getScreenBrightness, title: "getScreenBrightness", desc: L10n.getScreenBrightness))
        }

        if (innerTest || sdk.funcTable.getSupportGetMainSportGoalV3) {
            items.append(GetCmd(type: .getMainSportGoal, title: "getMainSportGoal", desc: L10n.getMainSportGoal))
        }

        if (innerTest || sdk.funcTable.getDoNotDisturbMain3) {
            items.append(GetCmd(type: .getNotDisturbStatus, title: "getNotDisturbStatus", desc: L10n.getNotDisturbStatus))
        }

        if (innerTest || sdk.funcTable.getUpHandGestureEx) {
            items.append(GetCmd(type: .getUpHandGesture, title: "getUpHandGesture", desc: L10n.getUpHandGesture))
        }

        if (innerTest || sdk.funcTable.getBleAndBtVersion) {
            items.append(GetCmd(type: .getBtNotice, title: "getBtNotice", desc: L10n.getBtNotice))
        }

        if (innerTest || sdk.funcTable.getFlashLog) {
            items.append(GetCmd(type: .getFlashBinInfo, title: "getFlashBinInfo", desc: L10n.getFlashBinInfo))
        }

        if (innerTest || sdk.funcTable.getActivitySwitch) {
            items.append(GetCmd(type: .getActivitySwitch, title: "getActivitySwitch", desc: L10n.getActivitySwitch))
        }

        if (innerTest || sdk.funcTable.getBtAddrV2) {
            items.append(GetCmd(type: .getBtName, title: "getBtName", desc: L10n.getBtName))
        }
        if (innerTest || sdk.funcTable.getMtu) {
            items.append(GetCmd(type: .getMtuInfo, title: "getMtuInfo", desc: L10n.getMtuInfo))
        }
        if (innerTest || sdk.funcTable.getHealthSwitchStateSupportV3) {
            items.append(GetCmd(type: .getAllHealthSwitchState, title: "getAllHealthSwitchState", desc: L10n.getAllHealthSwitchState))
        }

        // if (innerTest || sdk.funcTable.getRealtimeData) {
        //     items.append(GetCmd(type: .getLiveData, title: "getLiveData", desc: L10n.getLiveData)) // 已废弃
        // }
        if (innerTest || sdk.funcTable.getFlashLog) {
            items.append(GetCmd(type: .getErrorRecord, title: "getErrorRecord", desc: L10n.getErrorRecord))
        }
        if (innerTest || sdk.funcTable.getSupportUpdateGps) {
            items.append(GetCmd(type: .getGpsInfo, title: "getGpsInfo", desc: L10n.getGpsInfo))
        }
        // if (innerTest || sdk.funcTable.getVersionInfo) {
        //     items.append(GetCmd(type: .getVersionInfo, title: "getVersionInfo", desc: L10n.getVersionInfo))
        // }
        if (innerTest || sdk.funcTable.getSupportUpdateGps) {
            items.append(GetCmd(type: .getGpsStatus, title: "getGpsStatus", desc: L10n.getGpsStatus))
        }
        if (innerTest || sdk.funcTable.getDeletableMenuListV2) {
            items.append(GetCmd(type: .getUnerasableMeunList, title: "getUnerasableMeunList", desc: L10n.getUnerasableMeunList))
        }
        if (innerTest || sdk.funcTable.setSupportV3Bp) {
            items.append(GetCmd(type: .getBpAlgVersion, title: "getBpAlgVersion", desc: L10n.getBpAlgVersion))
        }
        if (innerTest || sdk.funcTable.getDeviceUpdateState) {
            items.append(GetCmd(type: .getUpdateStatus, title: "getUpdateStatus", desc: L10n.getUpdateStatus))
        }
        if (innerTest || sdk.funcTable.getDownloadLanguage) {
            items.append(GetCmd(type: .getDownloadLanguage, title: "getDownloadLanguage", desc: L10n.getDownloadLanguage))
        }
        if (innerTest || (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3)) {
            items.append(GetCmd(type: .getBleMusicInfo, title: "getBleMusicInfo", desc: L10n.getBleMusicInfo))
        }
        if (innerTest || sdk.funcTable.getLangLibraryV3) {
            items.append(GetCmd(type: .getLanguageLibrary, title: "getLanguageLibrary", desc: L10n.getLanguageLibrary))
        }
        if (innerTest || sdk.funcTable.getSupportGetBleBeepV3) {
            items.append(GetCmd(type: .getBleBeep, title: "getBleBeep", desc: L10n.getBleBeep))
        }
        if (innerTest || sdk.funcTable.getStepDataTypeV2) {
            items.append(GetCmd(type: .getStepGoal, title: "getStepGoal", desc: L10n.getStepGoal))
        }
        if (innerTest || sdk.funcTable.getSupportGetV3DeviceBtConnectPhoneModel) {
            items.append(GetCmd(type: .getBtConnectPhoneModel, title: "getBtConnectPhoneModel", desc: L10n.getBtConnectPhoneModel))
        }

        if (innerTest || sdk.funcTable.setScheduleReminder) {
            items.append(GetCmd(type: .setScheduleReminder, title: "getScheduleReminder", desc: L10n.getScheduleReminder))
        }

        if (innerTest || sdk.funcTable.getSupportGetUnit) {
            items.append(GetCmd(type: .getUnit, title: "getUnit", desc: L10n.getUnit))
        }

        if (innerTest || sdk.funcTable.setSupportControlMiniProgram) {
            items.append(GetCmd(type: .getAppletControl, title: "getAppletControl", desc: L10n.getAppletControl))
        }

        if (innerTest || sdk.funcTable.getSupportDeviceOperateAlgFile) {
            items.append(GetCmd(type: .getAlgFile, title: "getAlgFileInfo", desc: L10n.getAlgFileInfo))
            items.append(GetCmd(type: .requestAlgFile, title: "requestAlgFile", desc: L10n.requestAlgFile))
        }

        // NOTE:
        // 因为demo要适配所有设备，此处示例适配多种情况。
        // 当只适配一台设备时，只需处理以下一种即可（根据功能表判断设备使用哪种）。
        if (sdk.funcTable.setSmartHeartRate) {
            if (sdk.funcTable.getSupportGetSmartHeartRate) {
                //https://idoosmart.github.io/Native_GitBook/en/doc/set/IDOSetHeartRateModeSmart.html?h=setHeartRateModeSmart
                print("getSupportGetSmartHeartRate")
                items.append(GetCmd(type: .getHeartMode, title: "getHeartMode", desc: L10n.getHeartMode))
            } else {
                // !!!: - 该设备不支持获取心率模式，需要app自行记录
                print("该设备不支持获取心率模式，需要app自行记录")
            }
        } else if (sdk.funcTable.syncV3Hr) {
            // https://idoosmart.github.io/Native_GitBook/en/doc/set/IDOSetHeartMode.html
            print("syncV3Hr")
            items.append(GetCmd(type: .getHeartMode, title: "getHeartMode", desc: L10n.getHeartMode))
        } else if (sdk.funcTable.getHeartRateModeV2) {
            // https://idoosmart.github.io/Native_GitBook/en/doc/get/IDOGetHeartRateMode.html
            print("getHeartRateModeV2")
            items.append(GetCmd(type: .getHeartMode, title: "getHeartMode", desc: L10n.getHeartMode))
        }
        
        
        //items.append(GetCmd(type: .getHidInfo, title: "getHidInfo", desc: "Get HID Information event number")) // 未启用
        //items.append(GetCmd(type: .getWatchDialId, title: "getWatchDialId", desc: "Get watch ID event number")) // 未启用
        //items.append(GetCmd(type: .getHotStartParam, title: "getHotStartParam", desc: "Get Hot Start Parameters event number")) // 未启用
        //items.append(GetCmd(type: .getDeviceName, title: "getDeviceName", desc: "Get device name event number")) // 已废弃
        //items.append(GetCmd(type: .getStressVal, title: "getStressVal", desc: "Get stress value event number"))
        //items.append(GetCmd(type: .getHabitInfo, title: "getHabitInfo", desc: "Get User Habit Information in V3")) // 未启用
        
        items = items.sorted { $0.title < $1.title }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
            make.left.right.equalTo(0)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension GetFunctionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .black
        cell.textLabel?.textAlignment = .left
        cell.detailTextLabel?.textAlignment = .left
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.numberOfLines = 2
        let cmd = items[indexPath.row]
        cell.textLabel?.text = cmd.title
        cell.detailTextLabel?.text = cmd.desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = items[indexPath.row]
        let vc = GetFunctionDetailVC(cmd: cmd)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - CmdType

struct OtherParamModel: IDOBaseModel {
    
    let dic: Dictionary<String, Any>?
    
    private enum CodingKeys: String, CodingKey {
            case indexPath
            case locationInText
        }
    
    init(dic: Dictionary<String, Any>) {
        self.dic = dic
    }
    
    init(from decoder: Decoder) throws {
        dic = nil
    }
    
    func encode(to encoder: Encoder) throws {
        
    }
    
    func toJsonString() -> String? {
        guard let aDic = dic else { return nil }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: aDic, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error converting dictionary to JSON string: \(error.localizedDescription)")
        }
        return nil
    }
}

fileprivate struct GetCmd {
    let type: CmdType
    let title: String
    let desc: String
    let isSupported: Bool
    
    init(type: CmdType, title: String, desc: String, isSupported: Bool = false) {
        self.title = title
        self.desc = desc
        self.type = type
        self.isSupported = isSupported
    }
}

fileprivate enum CmdType: CaseIterable { // 可以获取枚举的case 数量
    /// 获取设备信息
    /// Get Device Information
    case getDeviceInfo
    /// 获取功能表
    /// Get Function Table
    case getFunctionTable
    /// 获取bt蓝牙名称
    /// Get bt bluetooth name
     case getBtName
    /// 获得实时数据
    /// Get Real-time Data event number
     case getLiveData
    /// 获取错误记录
    /// Get error record
     case getErrorRecord
    /// 获取HID信息
    /// Get HID Information event number
     case getHidInfo
    /// 获取gps信息
    /// Get GPS Information event number
     case getGpsInfo
    /// 获取版本信息
    /// Get version information event number
     case getVersionInfo
    /// 获取mtu信息
    /// Get MTU Information event number
     case getMtuInfo
    /// 获取所有的健康监测开关
    /// Get event number for all health monitoring switches
     case getAllHealthSwitchState
    /// 获取gps状态
    /// Get GPS Status event number
     case getGpsStatus
    /// 获取固件不可删除的快捷应用列表
    /// Get non-deletable menu list in firmware event number
     case getUnerasableMeunList
    /// 运动模式自动识别开关获取
    /// Get event number for activity switch
     case getActivitySwitch
    /// 获取红点提醒开关
    /// Get unread app reminder switch event number
     case getUnreadAppReminder
    /// 获取字库信息
    /// Get Font Library Information event number
     case getFlashBinInfo
    /// 查询bt配对开关、连接、a2dp连接、hfp连接状态(仅支持带bt蓝牙的设备)
    /// Query BT pairing switch, connection, A2DP connection, HFP connection status (Only Supported on devices with BT Bluetooth) event number
     case getBtNotice
    /// 获取抬腕数据
    /// Get wrist up gesture data event number
     case getUpHandGesture
    /// 获取表盘id
    /// Get watch ID event number
     case getWatchDialId
    /// 获取勿扰模式状态
    /// Get Do Not Disturb mode status event number
     case getNotDisturbStatus
    /// 获取设置的卡路里/距离/中高运动时长 主界面
    /// Get Set Calorie/Distance/Mid-High Sport Time Goal event number
     case getMainSportGoal
    /// 获取血压算法三级版本号信息事件号
    /// Get blood pressure algorithm version information event number
     case getBpAlgVersion
    /// 获取屏幕亮度
    /// Get screen brightness event number
     case getScreenBrightness
    /// 获取热启动参数
    /// Get Hot Start Parameters event number
     case getHotStartParam
    /// 获取固件支持的详情最大设置数量
    /// Get maximum number of settings supported by firmware event number
     case getSupportMaxSetItemsNum
    /// 获取走动提醒
    /// Get walk reminder event number
     case getWalkRemind
    /// 获取全天步数目标
    /// Get daily step goal event number
     case getStepGoal
    /// 获取手表名字
    /// Get device name event number
     case getDeviceName
    /// 获取固件本地保存联系人文件修改时间
    /// Get firmware local contact file modification time event number
     case getContactReviseTime
    /// 获取设备升级状态
    /// Get device update status event number
     case getUpdateStatus
    /// 获取压力值
    /// Get stress value event number
     case getStressVal
    /// 获取电池信息
    /// Get battery information event number
     case getBatteryInfo
    /// 获取设备的日志状态
    /// Get device log state event number
     case getDeviceLogState
    /// 获取下载语言支持
    /// Get Download Language Support
     case getDownloadLanguage
    /// 获取设备支持的列表
    /// Get Supported Menu List
     case getMenuList
    /// 获取通知中心开关
    /// Get notification center status event number
     case getNoticeStatus
    /// app获取ble的闹钟
    /// Getting Alarms for V3APP Devices
     case getAlarm
    /// 获取用户习惯信息
    /// Get User Habit Information in V3
     case getHabitInfo
    /// 获取固件的歌曲名和文件夹
    /// Get Firmware Song Names and Folders
     case getBleMusicInfo
    /// 获取屏幕信息
    /// Get Screen Information
     case getWatchDialInfo
    /// 获取表盘列表 v3
    /// Getting watch face list for V3 (New)
     case getWatchListV3
    /// 获取表盘列表 v2
    /// Get Watch Face List in V2
     case getWatchListV2
    /// 获取语言库列表
    /// Get Language Library List
     case getLanguageLibrary
    /// 获取固件本地提示音文件信息
    /// Getting firmware local beep file information for V3
     case getBleBeep
    /// 获取BT连接手机型号
    /// Get BT connected mobile phone model
     case getBtConnectPhoneModel
    /// 获取日程提醒
    case setScheduleReminder
    /// 获取单位
    case getUnit
    /// 获取小程序信息
    case getAppletControl
    ///  获取固件算法文件信息（ACC/GPS）
    case getAlgFile
    ///  请求固件算法文件信息（ACC/GPS）
    case requestAlgFile
    ///  心率模式
    case getHeartMode
    
}

extension CmdType {
    func param() -> IDOBaseModel? {
        switch self {
        case .getMainSportGoal:
            return OtherParamModel(dic: ["timeGoalType": 1])
        case .getLiveData:
            return OtherParamModel(dic: ["flag": 1])
        case .getErrorRecord:
            return OtherParamModel(dic: ["type": 0])
        case .getAlarm:
            return OtherParamModel(dic: ["flag": 0])
        case .setScheduleReminder:
            return IDOSchedulerReminderParamModel(operate: 3, items: [])
        case .getAppletControl:
            return IDOAppletControlModel(operate: 3)
        case .getHeartMode:
            if(sdk.funcTable.syncV3Hr) {
                return IDOHeartModeParamModel(updateTime: 0) // 0 是获取
            }
            return nil
        default:
            return nil
        }
    }
    
}

// MARK: - GetFunctionDetailVC

private class GetFunctionDetailVC: UIViewController {
    private var cmd: GetCmd
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    private lazy var lblParam: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Parameter"
        return v
    }()
    
    private lazy var lblResponse: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Response"
        return v
    }()
    
    private lazy var textParam: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var textResponse: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var btnCall: UIButton = {
        let btn = UIButton.createNormalButton(title: "Send")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.doCall()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    required init(cmd: GetCmd) {
        self.cmd = cmd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册监听 设备传输文件到app任务
        sdk.transfer.registerDeviceTranFileToApp { [weak self] task in
            self?.deviceTransFileToApp(task)
        }
        
        title = cmd.title
        view.backgroundColor = .white
        
        view.addSubview(btnCall)
        view.addSubview(lblParam)
        view.addSubview(textParam)
        view.addSubview(lblResponse)
        view.addSubview(textResponse)
        
        btnCall.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        lblParam.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnCall.snp.bottom).offset(15)
        }
        textParam.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblParam.snp.bottom).offset(5)
            make.height.equalTo(160)
        }
        lblResponse.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(textParam.snp.bottom).offset(35)
        }
        textResponse.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblResponse.snp.bottom).offset(5)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        textParam.text = cmd.type.param()?.toJsonString() ?? "none"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewDidDisappear(animated)
    }
    
    deinit {
        sdk.transfer.unregisterDeviceTranFileToApp()
    }
    
    private func doCall() {
        cancellable?.cancel()
        cancellable = nil
        textResponse.text = ""
        btnCall.isEnabled = false
        switch cmd.type {
        case .getBtName:
            cancellable = Cmds.getBtName().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getLiveData:
            let flag = (cmd.type.param() as! OtherParamModel).dic!["flag"] as! Int
            cancellable = Cmds.getLiveData(flag: flag).send { [weak self] res in
                self?.doPrint(res)
            }
        case .getErrorRecord:
            let type = (cmd.type.param() as! OtherParamModel).dic!["type"] as! Int
            cancellable = Cmds.getErrorRecord(type: type).send { [weak self] res in
                self?.doPrint(res)
            }
        case .getHidInfo:
            cancellable = Cmds.getHidInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getGpsInfo:
            cancellable = Cmds.getGpsInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getVersionInfo:
            cancellable = Cmds.getVersionInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getMtuInfo:
            cancellable = Cmds.getMtuInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getAllHealthSwitchState:
            cancellable = Cmds.getAllHealthSwitchState().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getGpsStatus:
            cancellable = Cmds.getGpsStatus().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getUnerasableMeunList:
            cancellable = Cmds.getUnerasableMeunList().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getActivitySwitch:
            cancellable = Cmds.getActivitySwitch().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getUnreadAppReminder:
            cancellable = Cmds.getUnreadAppReminder().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getFlashBinInfo:
            cancellable = Cmds.getFlashBinInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getBtNotice:
            cancellable = Cmds.getBtNotice().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getUpHandGesture:
            cancellable = Cmds.getUpHandGesture().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getWatchDialId:
            cancellable = Cmds.getWatchDialId().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getNotDisturbStatus:
            cancellable = Cmds.getNotDisturbStatus().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getMainSportGoal:
            let timeGoalType = (cmd.type.param() as! OtherParamModel).dic!["timeGoalType"] as! Int
            cancellable = Cmds.getMainSportGoal(timeGoalType: timeGoalType).send { [weak self] res in
                self?.doPrint(res)
            }
        case .getBpAlgVersion:
            cancellable = Cmds.getBpAlgVersion().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getScreenBrightness:
            cancellable = Cmds.getScreenBrightness().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getHotStartParam:
            cancellable = Cmds.getHotStartParam().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getSupportMaxSetItemsNum:
            cancellable = Cmds.getSupportMaxSetItemsNum().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getWalkRemind:
            cancellable = Cmds.getWalkRemind().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getStepGoal:
            cancellable = Cmds.getStepGoal().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getDeviceName:
            cancellable = Cmds.getDeviceName().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getContactReviseTime:
            cancellable = Cmds.getContactReviseTime().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getUpdateStatus:
            cancellable = Cmds.getUpdateStatus().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getStressVal:
            cancellable = Cmds.getStressVal().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getBatteryInfo:
            cancellable = Cmds.getBatteryInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getDeviceLogState:
            cancellable = Cmds.getDeviceLogState().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getDownloadLanguage:
            cancellable = Cmds.getDownloadLanguage().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getMenuList:
            cancellable = Cmds.getMenuList().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getNoticeStatus:
            cancellable = Cmds.getNoticeStatus().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getAlarm:
            let flag = (cmd.type.param() as! OtherParamModel).dic!["flag"] as! Int
            cancellable = Cmds.getAlarm(flag: flag, priority: .high).send { [weak self] res in
                self?.btnCall.isEnabled = true
                if case .success(let obj) = res {
                    self?.textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
                }else if case .failure(let err) = res {
                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
                //self?.doPrint(res)
            }
        case .getHabitInfo:
            cancellable = Cmds.getHabitInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getBleMusicInfo:
            cancellable = Cmds.getBleMusicInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getWatchDialInfo:
            cancellable = Cmds.getWatchDialInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getWatchListV3:
            cancellable = Cmds.getWatchListV3().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getWatchListV2:
            cancellable = Cmds.getWatchListV2().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getLanguageLibrary:
            cancellable = Cmds.getLanguageLibrary().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getBleBeep:
            cancellable = Cmds.getBleBeep().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getDeviceInfo:
            btnCall.isEnabled = true
            textResponse.text = sdk.device.printProperties()
            break
        case .getFunctionTable:
            btnCall.isEnabled = true
            textResponse.text = sdk.funcTable.printProperties()
            break
        case .getBtConnectPhoneModel:
            cancellable = Cmds.getBtConnectPhoneModel().send { [weak self] res in
                self?.doPrint(res)
            }
        case .setScheduleReminder:
            let param = cmd.type.param() as! IDOSchedulerReminderParamModel
            cancellable = Cmds.setSchedulerReminder(param).send { [weak self] res in
                self?.doPrint(res)
            }
        case .getUnit:
            cancellable = Cmds.getUnit().send { [weak self] res in
                self?.doPrint(res)
            }
        case .getAppletControl:
            let param = cmd.type.param() as! IDOAppletControlModel
            cancellable = Cmds.setAppleControl(param).send { [weak self] res in
                self?.doPrint(res)
            }
        case .getAlgFile:
            cancellable = Cmds.getAlgFileInfo().send { [weak self] res in
                self?.doPrint(res)
            }
        case .requestAlgFile:
            cancellable = Cmds.getAlgFileInfo().send { [weak self] res in
                self?.doPrint(res)
                if case .success(let val) = res {
                    guard let item = val?.items?.filter({ $0.totalQuantity > 0 }).first else {
                        SVProgressHUD.show(withStatus: "无可获取的文件 / There is no file to request download")
                        return
                    }
                    self?.cancellable = Cmds.rquestAlgFile(type: item.type).send { [weak self] res in
                        self?.doPrint(res)
                    }
                }else if case .failure(let err) = res {
                    self?.textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
                }
            }
            
        case .getHeartMode:
            guard let obj = cmd.type.param() else {
                print("需要配置参数")
                return
            }
            if (sdk.funcTable.setSmartHeartRate) {
                if (sdk.funcTable.getSupportGetSmartHeartRate) {
                    let param = IDOHeartModeParamModel(updateTime: 0)
                    cancellable = Cmds.setHeartMode(param).send { [weak self] res in
                        self?.doPrint(res)
                    }
                }
            }else if(sdk.funcTable.syncV3Hr) {
                let param = cmd.type.param() as! IDOHeartModeParamModel
                cancellable = Cmds.setHeartMode(param).send { [weak self] res in
                    self?.doPrint(res)
                }
            }else if(sdk.funcTable.getHeartRateModeV2) {
                cancellable = Cmds.getHeartRateMode().send { [weak self] res in
                    self?.doPrint(res)
                }
            }
        }
        
    }
    
    private func doPrint<T>(_ res: Result<T?, CmdError>) {
        btnCall.isEnabled = true
        if case .success(let val) = res {
            if T.self is String.Type {
                textResponse.text = val as? String
            }else if T.self is IDOBaseModel.Type {
                let obj = val as? IDOBaseModel
                textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
            }
        }else if case .failure(let err) = res {
            textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
        }
    }
    
    private func deviceTransFileToApp(_ task: IDODeviceFileToAppTask) {
        let txt = "\n\n收到设备传输文件 名称：\(task.deviceTransItem.fileName) 大小：\(task.deviceTransItem.fileSize) 到App"
        print(txt)
        textResponse.text += "\n\(txt)"
        // 接收设备传输文件到app
        task.acceptReceiveFile { [weak self] progress in
            let s = "接收进度：\(progress * 100)%"
            print(s)
            self?.textResponse.text += "\n\(s)"
        } onComplete: { [weak self] isCompleted, receiveFilePath in
            let s = "接收结果：\(isCompleted) filePath:\(receiveFilePath ?? "")"
            print(s)
            self?.textResponse.text += "\n\(s)"
        }
        
        /*
        // 注：接收中 可随时终止接收
        // 终止接收文件
        task.stopReceiveFile { rs in
            print("已终止接收文件\(task.deviceTransItem.fileName)")
        }
         */
    }
}

