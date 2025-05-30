//
//  SyncDataVC.swift
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

class SportVC: UIViewController {
    private let disposeBag = DisposeBag()
    private var disposeTimer = DisposeBag()
    private var baseModel: IDOExchangeBaseModel?
    private var duration = 0
    private var calories = 0
    private var distance = 0
    private var gpsSignal = 0x00
    private var isSportEnd = false
    @objc dynamic private var exchangeType: SportStatus = .stopped
    lazy var locationMgr = LocationManager.shared
    lazy var btnSportStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStart()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportPause: UIButton = {
        let btn = UIButton.createNormalButton(title: "Pause")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportPause()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportResume: UIButton = {
        let btn = UIButton.createNormalButton(title: "Resume")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportResume()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStop()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var lblState: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        return v
    }()
    
    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .lightGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sport"
        view.backgroundColor = .white
        
        view.addSubview(btnSportStart)
        view.addSubview(btnSportPause)
        view.addSubview(btnSportResume)
        view.addSubview(btnSportStop)
        view.addSubview(lblState)
        view.addSubview(textConsole)
        
        btnSportStart.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        btnSportPause.snp.makeConstraints { make in
            make.size.equalTo(btnSportStart)
            make.centerX.equalTo(btnSportStart)
            make.top.equalTo(btnSportStart.snp.bottom).offset(25)
        }
        
        btnSportResume.snp.makeConstraints { make in
            make.size.equalTo(btnSportStart)
            make.centerX.equalTo(btnSportStart)
            make.top.equalTo(btnSportPause.snp.bottom).offset(25)
        }
        
        btnSportStop.snp.makeConstraints { make in
            make.size.equalTo(btnSportStart)
            make.centerX.equalTo(btnSportStart)
            make.top.equalTo(btnSportResume.snp.bottom).offset(25)
        }
        
        lblState.snp.makeConstraints { make in
            make.top.equalTo(btnSportStop.snp.bottom).offset(25)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        textConsole.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblState.snp.bottom)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalTo(0)
            }
        }
        
        sdk.dataExchange.addExchange(delegate: self)
        
        self.rx.observeWeakly(Int.self, "exchangeType").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
    }
}

extension SportVC {
    
    private func refreshState() {
        
        // !!!: 设备主动发起的运动，暂时不支持与app状态联动，忽略状态刷新
        if (baseModel == nil) {
            print("ignore")
            stopTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = true
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = false
            return
        }
        
        switch exchangeType {
        case .stopped:
            print("end")
            stopTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = true
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = false
        case .started:
            print("start")
            startTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = true
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = true
        case .paused:
            print("pause")
            stopTimer()
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = true
            btnSportStop.isEnabled = true
        case .resumed:
            print("resume")
            startTimer()
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = true
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = true
        default:
            break
        }
    }
    
    private func _sportStart() {
        
        func doit() {
            SVProgressHUD.show()
            let currentDate = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: currentDate)
            let hour = calendar.component(.hour, from: currentDate)
            let minute = calendar.component(.minute, from: currentDate)
            let second = calendar.component(.second, from: currentDate)
            
            // sportType: https://idoosmart.github.io/Native_GitBook/en/doc/enum/IDOSportType.html
            let baseModel = IDOExchangeBaseModel(
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                sportType: 0x32 // Outdoor cycling
            )
            self.baseModel = baseModel
            let obj = IDOAppStartExchangeModel(
                baseModel: baseModel,
                forceStart: 1
            )
            sdk.dataExchange.appExec(model: obj)
        }
        
        guard locationMgr.checkLocationAuthorization() else {
            locationMgr.didChangeAuthorization = { [weak self] status in
                if status == .authorizedWhenInUse || status == .authorizedAlways  {
                    doit()
                }
                self?.locationMgr.didChangeAuthorization = nil
            }
            return
        }
        doit()
    }
    
    private func _sportPause() {
        guard let baseModel = baseModel else { return }
        let obj = IDOAppPauseExchangeModel(baseModel: baseModel)
        sdk.dataExchange.appExec(model: obj)
    }
    
    private func _sportResume() {
        guard let baseModel = baseModel else { return }
        let obj = IDOAppRestoreExchangeModel(baseModel: baseModel)
        sdk.dataExchange.appExec(model: obj)
    }
    
    private func _sportStop() {
        guard baseModel != nil else { return }
        let obj = IDOAppEndExchangeModel(
            baseModel: baseModel,
            duration: duration,
            calories: calories,
            distance: distance,
            isSave: 1
        )
        sdk.dataExchange.appExec(model: obj)
    }
    
    /// Synchronize brief sports data for app display
    /// Sync every 2 seconds
    private func exchangeData() {
        guard baseModel != nil else {
            return
        }
        if (sdk.dataExchange.supportV3ActivityExchange) {
            let obj = IDOAppIngV3ExchangeModel(baseModel: baseModel, version: 2, signal: gpsSignal, distance: distance, speed: 0, duration: duration, calories: calories)
            sdk.dataExchange.appExec(model: obj)
        } else {
            let obj = IDOAppIngExchangeModel(baseModel: baseModel, duration: duration, calories: calories, distance: distance, status: 0)
            sdk.dataExchange.appExec(model: obj)
        }
    }
    
    /// Synchronize complete data once
    /// Sync every 40 seconds
    private func exchangeCompleteData() {
        sdk.dataExchange.getLastActivityData()
    }
    
    /// Sync exercise heart rate data
    /// Sync every 30 seconds
    private func exchangeV3HrData() {
        if (sdk.dataExchange.supportV3ActivityExchange) {
            sdk.dataExchange.getActivityHrData()
        }
    }
    
    private func startTimer() {
        textConsole.text = "sport launched successfully"
        disposeTimer = DisposeBag()
        Observable<Int>.interval(.seconds(Constant.intervalExchangeData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeData()
            })
            .disposed(by: disposeTimer)
        
        Observable<Int>.interval(.seconds(Constant.intervalExchangeCompleteData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeCompleteData()
            })
            .disposed(by: disposeTimer)
        
        Observable<Int>.interval(.seconds(Constant.intervalExchangeHrData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeV3HrData()
            })
            .disposed(by: disposeTimer)
    }
    
    private func stopTimer() {
        disposeTimer = DisposeBag()
    }
    
}


extension SportVC: IDOExchangeDataOCDelegate {
    
    /// ble发起运动 app监听ble
    /// - Parameter model: 监听ble执行数据实体
    /// ```
    /// 数据实体包括：
    /// ble设备发送交换运动数据开始 IDOBleStartExchangeModel
    /// ble设备交换运动数据过程中 IDOBleIngExchangeModel
    /// ble设备发送交换运动数据结束 IDOBleEndExchangeModel
    /// ble设备发送交换运动数据暂停 IDOBlePauseExchangeModel
    /// ble设备发送交换运动数据恢复 IDOBleRestoreExchangeModel
    /// ble设备操作运动计划 IDOBleOperatePlanExchangeModel
    /// app发起运动 app监听ble
    /// ble设备发送交换运动数据暂停 IDOAppBlePauseExchangeModel
    /// ble设备发送交换运动数据恢复 IDOAppBleRestoreExchangeModel
    /// ble设备发送交换运动数据结束 IDOAppBleEndExchangeModel
    func appListenBleExec(model: NSObject) {
        if (model is IDOBleStartExchangeModel) {
            guard let obj = model as? IDOBleStartExchangeModel else {
                print("异常：数据为空")
                return
            }
            let sendModel = IDOBleStartReplyExchangeModel(baseModel: obj.baseModel, operate: obj.operate, retCode: 0)
            // !!!: 暂时不支持设备启动运动和app联动
            //baseModel = obj.baseModel
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .started
        }
        else if (model is IDOBleIngExchangeModel) {
            let obj = model as? IDOBleIngExchangeModel
            let sendModel = IDOBleIngReplyExchangeModel(baseModel: obj?.baseModel, distance: obj?.distance ?? 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
        }
        else if (model is IDOBleEndExchangeModel) {
            let obj = model as? IDOBleEndExchangeModel
            let sendModel = IDOBleEndReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .stopped
        }
        else if (model is IDOBlePauseExchangeModel) {
            let obj = model as? IDOBlePauseExchangeModel
            let sendModel = IDOBlePauseReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .paused
        }
        else if (model is IDOBleRestoreExchangeModel) {
            let obj = model as? IDOBleRestoreExchangeModel
            let sendModel = IDOBleRestoreReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .resumed
        }
        else if (model is IDOAppBlePauseExchangeModel) {
            let obj = model as? IDOAppBlePauseExchangeModel
            let sendModel = IDOAppBlePauseReplyExchangeModel(baseModel: obj?.baseModel, errCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .paused
        }
        else if (model is IDOAppBleRestoreExchangeModel) {
            let obj = model as? IDOAppBleRestoreExchangeModel
            let sendModel = IDOAppRestoreReplyExchangeModel(baseModel: obj?.baseModel, errCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .resumed
        }
        else if (model is IDOAppBleEndExchangeModel) {
            guard let obj = model as? IDOAppBleEndExchangeModel else {
                print("异常：数据为空")
                return
            }
            let sendModel = IDOAppBleEndReplyExchangeModel(baseModel: baseModel,
                                                           errCode: 0,
                                                           duration: obj.duration,
                                                           calories: obj.calories,
                                                           distance: obj.distance)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .stopped
            sdk.dataExchange.getActivityHrData()
            sdk.dataExchange.getLastActivityData()
            isSportEnd = true
        }
    }
    
    func appListenAppExec(model: NSObject) {
        
        /// app执行响应
        /// - Parameter model: 监听app执行Ble响应实体
        /// ```
        /// 响应实体包括：
        /// app 开始发起运动 ble回复 IDOAppStartReplyExchangeModel
        /// app 发起运动结束 ble回复 IDOAppEndReplyExchangeModel
        /// app 交换运动数据 ble回复 IDOAppIngReplyExchangeModel
        /// app 交换运动数据暂停 ble回复 IDOAppPauseReplyExchangeModel
        /// app 交换运动数据恢复 ble回复 IDOAppRestoreReplyExchangeModel
        /// app v3交换运动数据 ble回复 IDOAppIngV3ReplyExchangeModel
        /// app 操作运动计划 ble回复 IDOAppOperatePlanReplyExchangeModel
        /// app 获取v3多运动一次活动数据 ble回复 IDOAppActivityDataV3ExchangeModel
        /// app 获取v3多运动一次心率数据 ble回复 IDOAppHrDataExchangeModel
        /// app 获取v3多运动一次GPS数据 ble回复 IDOAppGpsDataExchangeModel
        
        if (model is IDOAppStartReplyExchangeModel) {
            let obj = model as? IDOAppStartReplyExchangeModel
            print("sport started now : \(String(describing: obj))")
            SVProgressHUD.dismiss()
            //* - 0:成功; 1:设备已经进入运动模式失败;
            //* - 2:设备电量低失败;3:手环正在充电
            //* - 4:正在使用Alexa 5:通话中
            guard obj?.retCode == 0 else {
                textConsole.text = "sport failed to launch, because of \(String(describing: obj?.retCode))"
                return
            }
            exchangeType = .started
            locationMgr.locationUpdateBlock = { [weak self] locations in
                guard let self = self else { return }
                self.distance = Int(self.locationMgr.totalDistance)
                self.gpsSignal = locations.first?.gpsSignal() ?? 0x00
                print("self.locationMgr.totalDistance:\(self.locationMgr.totalDistance) self.distance:\(self.distance) self.gpsSignal:\(self.gpsSignal)")
            }
            locationMgr.startUpdatingLocation()
        }
        else if (model is IDOAppEndReplyExchangeModel) {
            let obj = model as? IDOAppEndReplyExchangeModel
            print("reply for app's end reply: \(String(describing: obj))")
            exchangeType = .stopped
            baseModel = nil
            sdk.dataExchange.getActivityHrData()
            sdk.dataExchange.getLastActivityData()
            isSportEnd = true
        }
        else if (model is IDOAppIngReplyExchangeModel) {
            let obj = model as? IDOAppIngReplyExchangeModel
            print("data of sport from device: \(String(describing: obj))")
        }
        else if (model is IDOAppPauseReplyExchangeModel) {
            let obj = model as? IDOAppPauseReplyExchangeModel
            print("reply for app's pause cmd: \(String(describing: obj))")
            exchangeType = .paused
        }
        else if (model is IDOAppRestoreReplyExchangeModel) {
            let obj = model as? IDOAppRestoreReplyExchangeModel
            print("reply for app's restore cmd: \(String(describing: obj))")
            exchangeType = .resumed
        }
        else if (model is IDOAppIngV3ReplyExchangeModel) {
            let obj = model as? IDOAppIngV3ReplyExchangeModel
            print("v3 data of sport from device: \(String(describing: obj))")
        }
        else if (model is IDOAppOperatePlanReplyExchangeModel) {
            let obj = model as? IDOAppOperatePlanReplyExchangeModel
            print("reply for app's operate plan cmd: \(String(describing: obj))")
        }
        else if (model is IDOAppActivityDataV3ExchangeModel) {
            let obj = model as? IDOAppActivityDataV3ExchangeModel
            print("appActivityDataReply: \(String(describing: obj))")
            duration = max(duration, obj?.durations ?? 0)
            calories = max(calories, obj?.calories ?? 0)
            distance = max(distance, obj?.distance ?? 0)
            if (isSportEnd) {
                isSportEnd = false
                // TODO: 运动任务结束
                print("运动任务结束!! / Sports mission completed!!")
            }
        }
        else if (model is IDOAppHrDataExchangeModel) {
            let obj = model as? IDOAppHrDataExchangeModel
            print("appActivityHrReply: \(String(describing: obj))")
        }
        else if (model is IDOAppGpsDataExchangeModel) {
            let obj = model as? IDOAppGpsDataExchangeModel
            print("appActivityGpsReply: \(String(describing: obj))")
        }
    }
    
    func exchangeV2Data(model: IDOExchangeV2Model) {
        print("exchangeV2Data: \(model)")
    }
    
    func exchangeV3Data(model: IDOExchangeV3Model) {
        print("exchangeV3Data: \(model)")
    }
    
    
}


@objc
private enum SportStatus: Int {
    case stopped, started, paused, resumed
}
