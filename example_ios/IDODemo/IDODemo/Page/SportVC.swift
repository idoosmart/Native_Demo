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
    // 0 停止， 1 启动， 2 暂停
    @objc dynamic private var exchangeType = 0
    lazy var btnSportStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start Sport")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStart()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportPause: UIButton = {
        let btn = UIButton.createNormalButton(title: "Pause Sport")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportPause()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportResume: UIButton = {
        let btn = UIButton.createNormalButton(title: "Resume Sport")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportResume()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "End Sport")
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
        // 0 停止， 1 启动， 2 暂停
        switch exchangeType {
        case 0:
            btnSportStart.isEnabled = true
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = false
        case 1:
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = true
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = true
        case 2:
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = true
            btnSportStop.isEnabled = true
        default:
            break
        }
    }
    
    private func _sportStart() {
        let currentDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: currentDate)
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        let second = calendar.component(.second, from: currentDate)
        
        let baseModel = IDOExchangeBaseModel(
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            sportType: 48
        )
        self.baseModel = baseModel
        let obj = IDOAppStartExchangeModel(
            baseModel: baseModel,
            forceStart: 1
        )
        sdk.dataExchange.appExec(.appStart(obj))
        print("start")
        textConsole.text = ""
        exchangeType = 1
    }
    
    private func _sportPause() {
        guard baseModel != nil else { return }
        let obj = IDOAppPauseExchangeModel(baseModel: baseModel)
        sdk.dataExchange.appExec(.appPause(obj))
        print("pause")
        exchangeType = 2
    }
    
    private func _sportResume() {
        guard baseModel != nil else { return }
        sdk.dataExchange.appExec(.appRestore(IDOAppRestoreExchangeModel(baseModel: baseModel)))
        print("resume")
        exchangeType = 1
    }
    
    private func _sportStop() {
        guard baseModel != nil else { return }
        let obj = IDOAppEndExchangeModel(
            baseModel: baseModel,
            duration: 10,
            calories: 10,
            distance: 10,
            isSave: 1
        )
        sdk.dataExchange.appExec(.appEnd(obj))
        disposeTimer = DisposeBag()
        print("end")
        textConsole.text = ""
        exchangeType = 0
    }
    
    private func exchangeData() {
        guard baseModel != nil else {
            return
        }
        if (sdk.dataExchange.supportV3ActivityExchange) {
            let obj = IDOAppIngV3ExchangeModel(baseModel: baseModel, version: 2, signal: 0, distance: distance, speed: 0, duration: duration, calories: calories)
            sdk.dataExchange.appExec(IDOAppExecType.appIngV3(obj))
        } else {
            let obj = IDOAppIngExchangeModel(baseModel: baseModel, duration: duration, calories: calories, distance: distance, status: 0)
            sdk.dataExchange.appExec(IDOAppExecType.appIng(obj))
        }
    }
    
    private func exchangeCompleteData() {
            sdk.dataExchange.getLastActivityData()
    }
    
    private func exchangeV3HrData() {
        if (sdk.dataExchange.supportV3ActivityExchange) {
            sdk.dataExchange.getActivityHrData()
        }
    }
        
}


extension SportVC: IDOExchangeDataDelegate {
    func appListenBleExec(type: IDOBleExecType) {
        switch type {
        case .bleStart(let obj):
            let model = IDOBleStartReplyExchangeModel(baseModel: obj?.baseModel, operate: obj?.operate, retCode: 0)
            sdk.dataExchange.appReplyExec(.bleStartReply(model))
        case .bleIng(let obj):
            let model = IDOBleIngReplyExchangeModel(baseModel: obj?.baseModel, distance: obj?.distance)
            sdk.dataExchange.appReplyExec(.bleIngReply(model))
        case .bleEnd(let obj):
            let model = IDOBleEndReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(.bleEndReply(model))
        case .blePause(let obj):
            let model = IDOBlePauseReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(.blePauseReply(model))
        case .bleRestore(let obj):
            let model = IDOBleRestoreReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(.bleRestoreReply(model))
        case .bleOperatePlan(_):
            break
        case .appBlePause(let obj):
            let model = IDOAppBlePauseReplyExchangeModel(baseModel: obj?.baseModel, errCode: 0)
            sdk.dataExchange.appReplyExec(.appBlePauseReply(model))
        case .appBleRestore(let obj):
            let model = IDOBleRestoreReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(.bleRestoreReply(model))
        case .appBleEnd(let obj):
            let model = IDOAppBleEndReplyExchangeModel(baseModel: baseModel,
                                                       errCode: 0,
                                                       duration: obj?.duration,
                                                       calories: obj?.calories,
                                                       distance: obj?.distance)
            sdk.dataExchange.appReplyExec(.appBleEndReply(model))
        @unknown default:
            fatalError()
        }
    }
    
    func appListenAppExec(type: IDOBleReplyType) {
        switch type {
        case .appStartReply(let obj):
            print("sport started now : \(String(describing: obj))")
            //* - 0:成功; 1:设备已经进入运动模式失败;
            //* - 2:设备电量低失败;3:手环正在充电
            //* - 4:正在使用Alexa 5:通话中
            guard obj?.retCode == 0 else {
                textConsole.text = "sport failed to launch, because of \(String(describing: obj?.retCode))"
                return
            }
            textConsole.text = "sport launched successfully"
            disposeTimer = DisposeBag()
            Observable<Int>.interval(.seconds(Constant.intervalExchangeData), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] value in
                    self?.exchangeData()
                })
                .disposed(by: disposeTimer)
            
            Observable<Int>.interval(.seconds(Constant.intervalExchangeCompleteData), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] value in
                    self?.exchangeCompleteData()
                })
                .disposed(by: disposeTimer)
            
            Observable<Int>.interval(.seconds(Constant.intervalExchangeHrData), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] value in
                    self?.exchangeV3HrData()
                })
                .disposed(by: disposeTimer)

        case .appEndReply(let obj):
            print("reply for app's end reply: \(String(describing: obj))")
        case .appIngReply(let obj):
            print("data of sport from device: \(String(describing: obj))")
        case .appPauseReply(let obj):
            print("reply for app's pause cmd: \(String(describing: obj))")
        case .appRestoreReply(let obj):
            print("reply for app's restore cmd: \(String(describing: obj))")
        case .appIngV3Reply(let obj):
            print("v3 data of sport from device: \(String(describing: obj))")
        case .appOperatePlanReply(let obj):
            print("reply for app's operate plan cmd: \(String(describing: obj))")
        case .appActivityDataReply(let obj):
            print("appActivityDataReply: ${type.model}")
            duration = max(duration, obj?.durations ?? 0)
            calories = max(calories, obj?.calories ?? 0)
            distance = max(distance, obj?.distance ?? 0)
        case .appActivityHrReply(let obj):
            print("appActivityHrReply: \(String(describing: obj))")
        case .appActivityGpsReply(let obj):
            print("appActivityGpsReply: \(String(describing: obj))")
        @unknown default:
            fatalError()
        }
    }
    
    func exchangeV2Data(model: IDOExchangeV2Model) {
        
    }
    
    func exchangeV3Data(model: IDOExchangeV3Model) {
        
    }
    
    
}
