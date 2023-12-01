//
//  DetailVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class DetailPageVC2: UIViewController {
    private let disposeBag = DisposeBag()
    
    var deviceModel: IDODeviceModel?
    private var bleState: IDOBluetoothStateModel?
    private var _deviceState: IDODeviceStateModel?
    var deviceState: IDODeviceStateModel? {
        get { return _deviceState }
        set {
            _deviceState = newValue
            onDeviceStateChanged()
        }
    }
    
    lazy var lblConnectState: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 13)
        return lbl
    }()

    lazy var btnConnect: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("connect", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            guard let deviceModel = self?.deviceModel else { return }
            sdk.ble.connect(device: deviceModel)
        }).disposed(by: disposeBag)
        return btn
    }()

    lazy var btnCancelConnect: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("cancelConnect", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            sdk.ble.cancelConnect(macAddress: self?.deviceModel?.macAddress, completion: { rs in
                print("call cancelConnect rs:\(rs)")
            })
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnAlexa: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("alexa", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.pushViewController(AlexaPageVC(), animated: true)
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnBind: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("bind", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            SVProgressHUD.show(withStatus: "绑定中...")
            sdk.cmd.bind(osVersion: 15) { devInfo in
                print("1获取到设备信息 - battLevel: \(devInfo.battLevel)")
            } onFuncTable: { ft in
                print("1获取到功能表 - alexaSetEasyOperateV3: \(ft.alexaSetEasyOperateV3)")
            } completion: { status in
                SVProgressHUD.dismiss()
                switch status {
                case .failed:
                    print("\(status)")
                    SVProgressHUD.showError(withStatus: "绑定失败")
                case .successful:
                    print("\(status)")
                    SVProgressHUD.showSuccess(withStatus: "绑定成功")
                    print("2获取到设备信息 - battLevel: \(sdk.device.battLevel)")
                    print("2获取到功能表 - alexaSetEasyOperateV3: \(sdk.funcTable.alexaSetEasyOperateV3)")
                case .binded:
                    print("\(status)")
                case .needAuth:
                    print("\(status)")
                case .refusedBind:
                    print("\(status)")
                case .wrongDevice:
                    print("\(status)")
                case .authCodeCheckFailed:
                    print("\(status)")
                case .canceled:
                    print("\(status)")
                case .failedOnGetFunctionTable:
                    print("\(status)")
                case .failedOnGetDeviceInfo:
                    print("\(status)")
                @unknown default:
                    fatalError()
                }
            }
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnUnbind: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("解绑", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            SVProgressHUD.show(withStatus: "解绑中...")
            sdk.cmd.unbind(macAddress: self.deviceModel!.macAddress!, isForceRemove: true, completion: { rs in
                if rs {
                    SVProgressHUD.showSuccess(withStatus: "解绑成功")
                } else {
                    SVProgressHUD.showError(withStatus: "解绑失败")
                }
            })
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnTranser: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("文件传输", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._testTransFile()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSyncData: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("数据同步", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._testSyncData()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSyncStop: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("停止同步", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._testSyncStop()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnDeviceLog: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("设备日志", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._testDeviceLog()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportStart: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("运动开始", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStart()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportPause: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("运动暂停", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportPause()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportResume: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("运动恢复", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportResume()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportStop: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("运动停止", for: .normal)
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStop()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = deviceModel?.name ?? "未知设备"
        view.backgroundColor = .white
        
       
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        view.addSubview(btnConnect)
        view.addSubview(btnCancelConnect)
        view.addSubview(lblConnectState)
        view.addSubview(btnBind)
        view.addSubview(btnUnbind)
        view.addSubview(btnAlexa)
        view.addSubview(btnTranser)
        view.addSubview(btnSyncData)
        view.addSubview(btnSyncStop)
        view.addSubview(btnDeviceLog)
        view.addSubview(btnSportStart)
        view.addSubview(btnSportStop)
        
        btnConnect.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.height.equalTo(44)
            make.top.equalTo(100)
        }
        btnCancelConnect.snp.makeConstraints { make in
            make.centerX.equalTo(btnConnect)
            make.height.equalTo(btnConnect)
            make.top.equalTo(btnConnect.snp.bottom).offset(12)
        }
        lblConnectState.snp.makeConstraints { make in
            make.centerX.equalTo(btnConnect)
            make.top.equalTo(btnCancelConnect.snp.bottom).offset(12)
        }
        btnBind.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.height.equalTo(36)
            make.top.equalTo(lblConnectState.snp.bottom).offset(100)
        }
        btnUnbind.snp.makeConstraints { make in
            make.centerY.equalTo(btnBind)
            make.height.equalTo(btnBind)
            make.left.equalTo(btnBind.snp.right).offset(30)
        }
        btnAlexa.snp.makeConstraints { make in
            make.height.equalTo(btnBind)
            make.left.equalTo(btnBind)
            make.top.equalTo(btnBind.snp.bottom).offset(20)
        }
        btnTranser.snp.makeConstraints { make in
            make.centerY.equalTo(btnAlexa)
            make.left.equalTo(btnAlexa.snp.right).offset(30)
        }
        
        btnSyncData.snp.makeConstraints { make in
            make.height.equalTo(btnAlexa)
            make.left.equalTo(btnAlexa)
            make.top.equalTo(btnAlexa.snp.bottom).offset(20)
        }
        btnSyncStop.snp.makeConstraints { make in
            make.centerY.equalTo(btnSyncData)
            make.left.equalTo(btnSyncData.snp.right).offset(30)
        }
        
        btnSportStart.snp.makeConstraints { make in
            make.height.equalTo(btnSyncData)
            make.left.equalTo(btnSyncData)
            make.top.equalTo(btnSyncData.snp.bottom).offset(20)
        }
        
        btnSportStop.snp.makeConstraints { make in
            make.centerY.equalTo(btnSportStart)
            make.left.equalTo(btnSportStart.snp.right).offset(30)
        }
        
        btnDeviceLog.snp.makeConstraints { make in
            make.height.equalTo(btnSportStart)
            make.left.equalTo(btnSportStart)
            make.top.equalTo(btnSportStart.snp.bottom).offset(20)
        }
    }
    
    private func onDeviceStateChanged() {
        guard let deviceModel = self.deviceModel else { return }
        guard let deviceState = deviceState else { return }
        if deviceState.state == .connected, deviceState.macAddress != nil, deviceState.macAddress!.count > 0 {
            print("begin markConnectedDevice")
            let uniqueId = deviceModel.macAddress != nil ? deviceModel.macAddress! : deviceModel.uuid ?? ""
            sdk.bridge.markConnectedDevice(uniqueId: uniqueId, otaType: .none, isBinded: false, deviceName: deviceModel.name) { rs in
                print("end markConnectedDevice rs:\(rs)")
            }
        } else if deviceState.state == .disconnected {
            print("begin markDisconnectedDevice")
            sdk.bridge.markDisconnectedDevice(macAddress: self.deviceModel?.macAddress, uuid: self.deviceModel?.uuid) { rs in
                print("end markDisconnectedDevice rs:\(rs)")
            }
        }
        self.lblConnectState.text = "\(String(describing: deviceState.state))"
    }
    
    private func _testSyncData() {
        sdk.syncData.startSync { progress in
            print("sync data progress:\(progress)")
        } funcData: { type, jsonStr, errorCode in
            print("sync data type:\(type) jsonStr:\(jsonStr) errCode:\(errorCode)")
        } funcCompleted: { errorCode in
            print("sync data done errCode:\(errorCode)")
        }
    }
    
    private func _testSyncStop() {
        sdk.syncData.stopSync()
    }
    
    private func _testDeviceLog() {
        // [.reboot, .battery, .general]
        sdk.deviceLog.startGet(types: [.general], timeOut: 60) { progress in
            // progress
        } completion: { rs in
            print("设备日志获取 rs=\(rs)")
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
        let obj = IDOAppStartExchangeModel(
            baseModel: baseModel,
            forceStart: 1
        )
        sdk.dataExchange.appExec(.appStart(obj))
    }
    
    private func _sportPause() {
        sdk.dataExchange.getLastActivityData()
    }
    
    private func _sportResume() {}
    
    private func _sportStop() {
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
        let obj = IDOAppEndExchangeModel(
            baseModel: baseModel,
            duration: 10,
            calories: 10,
            distance: 10,
            isSave: 1
        )
        sdk.dataExchange.appExec(.appEnd(obj))
    }
    
    private func _testTransFile() {
        _mp3()
    }
    
    private func _mp3() {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        guard let dir = dir else {
            print("无法获取 Document 目录路径")
            return
        }
        
        let dialPath = "\(dir)/files_trans/dial"
        let imgPath = "\(dir)/files_trans/imgs"
        let mp3Path = "\(dir)/files_trans/mp3"

        let items = [
            IDOTransMusicModel(filePath: "\(mp3Path)/1.mp3", fileName: "mp3_1", musicId: 1),
            IDOTransMusicModel(filePath: "\(mp3Path)/2.mp3", fileName: "mp3_2", musicId: 2),
            IDOTransMusicModel(filePath: "\(mp3Path)/3.mp3", fileName: "mp3_3", musicId: 3)
        ]
        
        if !sdk.funcTable.getSupportV3BleMusic {
            SVProgressHUD.showError(withStatus: "设备不支持上传音乐")
            return
        }
        
        if !FileManager().fileExists(atPath: items.first!.filePath) {
            SVProgressHUD.showError(withStatus: "文件不存在")
            return
        }
        
        SVProgressHUD.showProgress(0, status: "传输中...")
        // print("传输的文件：\(items.first?.filePath)")
        _ = sdk.transfer.transferFiles(fileItems: items, cancelPrevTranTask: true) { currentIndex, totalCount, _, totalProgress in
            SVProgressHUD.showProgress(totalProgress, status: "传输中（\(currentIndex + 1)/\(totalCount)）... ")
            // print("传输中(\(currentIndex + 1)/\(totalCount)...")
        } transStatus: { _, status, errorCode, _ in
            if status != .finished || errorCode != 0 {
                // SVProgressHUD.showError(withStatus: "传输失败\(String(describing: errorCode))")
                print("传输失败:\(errorCode)")
            }
        } completion: { rs in
            print("传输结束: \(rs)")
            if rs.last! {
                SVProgressHUD.showSuccess(withStatus: "传输成功")
            } else {
                SVProgressHUD.showError(withStatus: "传输失败")
            }
        }
    }
}
