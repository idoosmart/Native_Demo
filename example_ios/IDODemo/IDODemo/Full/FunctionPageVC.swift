//
//  FunctionPageVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/25.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel


class FunctionPageVC: UIViewController {
    private var isBinded = false
    private var isConnected = false
    private var _deviceState: IDODeviceStateModel?
    private var _bleState: IDOBluetoothStateModel?
    private let disposeBag = DisposeBag()
    var deviceModel: IDODeviceModel?
    var bleState: IDOBluetoothStateModel? {
        get { return _bleState }
        set {
            _bleState = newValue
        }
    }
    var deviceState: IDODeviceStateModel? {
        get { return _deviceState }
        set {
            _deviceState = newValue
            onDeviceStateChanged()
        }
    }
    
    private lazy var items = [
        Word.deviceConnect,
        Word.deviceDisconnect,
        Word.deviceBind,
        Word.deviceUnbind,
        Word.getFunction,
        Word.setFunction,
        Word.syncData,
        Word.transFile,
        Word.epoUpgrade,
        Word.sport,
        Word.alexa,
        Word.testOC,
        Word.testBleChannel,
        Word.exportLog
    ]
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    private lazy var lblDeviceInfo: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.numberOfLines = 0
        v.font = .systemFont(ofSize: 13)
        v.textAlignment = .left
        return v
    }()
    private lazy var lblConnectState: UILabel = {
        let v = UILabel()
        v.textColor = .gray
        v.numberOfLines = 0
        v.font = .systemFont(ofSize: 13)
        v.textAlignment = .left
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Function"
        view.backgroundColor = .white
        
        view.addSubview(lblDeviceInfo)
        view.addSubview(lblConnectState)
        view.addSubview(tableView)
        
        if let device = deviceModel {
            lblDeviceInfo.text = "Current Device: \(device.name ?? "-")\nMac Address\(device.macAddress ?? "-")\nRSSI: \(device.rssi)"
        }
        
        lblDeviceInfo.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            } else {
                make.top.equalTo(0)
            }
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        lblConnectState.snp.makeConstraints { make in
            make.left.right.equalTo(lblDeviceInfo)
            make.top.equalTo(lblDeviceInfo.snp.bottom)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(lblConnectState.snp.bottom).offset(2)
            make.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        _ = NotificationCenter.default.rx.notification(Notify.onSdkStatusChanged).subscribe(onNext: { [weak self] notification in
            if notification.object != nil, let status = notification.object as? IDOStatusNotification {
                print(status.rawValue)
                switch status {
                case .protocolConnectCompleted:
                    break
                case .functionTableUpdateCompleted:
                    break
                case .deviceInfoUpdateCompleted:
                    break
                case .deviceInfoFwVersionCompleted:
                    break
                case .unbindOnAuthCodeError:
                    break
                case .unbindOnBindStateError:
                    SVProgressHUD.dismiss()
                    self?.tableView.reloadData()
                    break
                case .fastSyncCompleted:
                    SVProgressHUD.dismiss()
                    self?.tableView.reloadData()
                    break
                case .fastSyncFailed:
                    break
                case .deviceInfoBtAddressUpdateCompleted:
                    break
                case .macAddressError:
                    break
                case .syncHealthDataIng:
                    break
                case .syncHealthDataCompleted:
                    break
                @unknown default:
                    break
                }
            }
        }).disposed(by: disposeBag)
        
        _ = NotificationCenter.default.rx.notification(Notify.onBleDeviceStateChanged).subscribe(onNext: { [weak self] notification in
            guard let self = self else { return }
            if let stateModel = notification.object as? IDODeviceStateModel {
                print("\(stateModel.state)")
                switch stateModel.state {
                case .disconnected:
                    if (self.isViewLoaded) {
                        if (stateModel.errorState == .pairFail) {
                            // 配对异常提示去忽略设备
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Tips", message: "配对异常，需要手动忽略设备（设置-蓝牙-找到设备-\"!\")-忽略此设备\nPairing is abnormal, you need to manually ignore the device (Settings-Bluetooth-Find Device-\"!\")-Ignore this device", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                                guard let self = self else { return }
                                self.navigationController?.popToRootViewController(animated: true)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            if (sdk.device.platform != 98) {
                                SVProgressHUD.showInfo(withStatus: "连接已断开")
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    break
                case .connecting:
                    break
                case .connected:
                    break
                case .disconnecting:
                    break
                @unknown default:
                    break
                }
            }
        }).disposed(by: disposeBag)
        
        _ = NotificationCenter.default.rx.notification(Notify.onBleStateChanged).subscribe(onNext: { [weak self] notification in
            if notification.object != nil, let status = notification.object as? IDOBluetoothStateType {
                guard let self = self else { return }
                print("\(status)")
                switch status {
                case .unknown:
                    break
                case .resetting:
                    break
                case .unsupported:
                    break
                case .unauthorized:
                    break
                case .poweredOff:
                    if (self.isViewLoaded) {
                        SVProgressHUD.showInfo(withStatus: "蓝牙已关闭")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    break
                case .poweredOn:
                    break
                @unknown default:
                    break
                }
            }
        }).disposed(by: disposeBag)
        
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
        print("Disconnect Device")
        sdk.ble.cancelConnect(macAddress: deviceModel?.macAddress) { _ in }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FunctionPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .default, reuseIdentifier: _cellID)
        let name = items[indexPath.row]
        let canEnable = canEnable(name)
        cell.accessoryType = canPush(name) ? .disclosureIndicator : .none
        cell.selectionStyle = canEnable ? .default : .none
        cell.textLabel?.textColor = canEnable ? .black : .gray
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = items[indexPath.row]
        guard canEnable(name) else { return }
        if (!canPush(name)) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        switch name {
        case Word.deviceConnect:
            SVProgressHUD.show()
            sdk.ble.connect(device: deviceModel)
            break
        case Word.deviceDisconnect:
            SVProgressHUD.show()
            sdk.ble.cancelConnect(macAddress: deviceModel?.macAddress) { _ in
                SVProgressHUD.dismiss()
            }
            break
        case Word.deviceBind:
            bind()
            break
        case Word.deviceUnbind:
            unbind()
            break
        case Word.setFunction:
            navigationController?.pushViewController(SetFunctionVC(), animated: true)
            break
        case Word.getFunction:
            navigationController?.pushViewController(GetFunctionVC(), animated: true)
            break
        case Word.syncData:
            navigationController?.pushViewController(SyncDataVC(), animated: true)
            break
        case Word.alexa:
            navigationController?.pushViewController(AlexaPageVC(), animated: true)
            break
        case Word.transFile:
            navigationController?.pushViewController(TransferFileVC(), animated: true)
            break
        case Word.epoUpgrade:
            navigationController?.pushViewController(EpoVC(), animated: true)
            break
        case Word.sport:
            navigationController?.pushViewController(SportVC(), animated: true)
            break
        case Word.testBleChannel:
            if (sdk.device.deviceId == 859) {
                let vc = TestBleChannelVC()
                vc.deviceModel = deviceModel
                navigationController?.pushViewController(vc, animated: true)
            }else {
                print("不支持 / not support")
            }
        case Word.testOC:
            let test = TestOC()
            test.testCommand()
            break
        case Word.exportLog:
            doExportLog()
            break
        default: break
        }
    }
}

// MARK: -

extension FunctionPageVC {
    
    private func onDeviceStateChanged() {
        guard let deviceModel = self.deviceModel else { return }
        guard let deviceState = deviceState else { return }
        
        if deviceState.state == .connected, deviceState.macAddress != nil, deviceState.macAddress!.count > 0 {
            if(deviceModel.isOta) {
                // 设备处理ota模式时，需要进入到升级页
                SVProgressHUD.dismiss()
                _otaMode()
                return
            }
            let isBinded = UserDefaults.standard.isBind(deviceModel.macAddress ?? "")
            self.isConnected = true
            self.isBinded = isBinded
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        } else if deviceState.state == .disconnected {
            self.isConnected = false
            print("disconnected")
            self.tableView.reloadData()
        }
        self.lblConnectState.text = "Connect State:\(deviceState.state )"
    }
    
    private func onBleStateChanged() {
        guard let bleState = self.bleState else { return }
        print("ble state:\(bleState.type)");
    }
    
    private func canEnable(_ funName: String) -> Bool {
        switch funName {
        case Word.deviceConnect:
            return !isConnected
        case Word.deviceDisconnect:
            return isConnected
        case Word.deviceBind:
            return isConnected && !isBinded
        case Word.deviceUnbind:
            return isConnected && isBinded
        case Word.setFunction:
            return isConnected && isBinded
        case Word.getFunction:
            return isConnected && isBinded
        case Word.syncData:
            return isConnected && isBinded
        case Word.alexa:
            return isConnected && isBinded
        case Word.transFile:
            return isConnected && isBinded
        case Word.epoUpgrade:
            return isConnected && isBinded
        case Word.sport:
            return isConnected && isBinded
        case Word.testOC:
            return isConnected && isBinded
        case Word.exportLog:
            return isConnected && isBinded
        case Word.testBleChannel:
            return isConnected && isBinded
        default:
            break
        }
        return false
    }
    
    private func canPush(_ funName: String) -> Bool {
        return !(funName == Word.deviceConnect || funName == Word.deviceDisconnect
                 || funName == Word.deviceBind || funName == Word.deviceUnbind
                 || funName == Word.testOC || funName == Word.exportLog
                 || funName == Word.testBleChannel)
    }
    
    private func bind() {
        SVProgressHUD.show(withStatus: "binding...")
        let macAddress = self.deviceModel!.macAddress!
        sdk.cmd.bind(osVersion: 15) { devInfo in
            print("on bind get device info - battLevel: \(devInfo.battLevel)")
        } onFuncTable: { ft in
            print("on bind get function table - alexaSetEasyOperateV3: \(ft.alexaSetEasyOperateV3)")
        } completion: { [weak self] status in
            SVProgressHUD.dismiss()
            switch status {
            case .failed:
                self?.isBinded = false
                UserDefaults.standard.setBind(macAddress, isBind: false)
                print("\(status)")
                SVProgressHUD.showError(withStatus: "bind failure")
            case .successful:
                self?.isBinded = true
                print("\(status)")
                SVProgressHUD.showSuccess(withStatus: "bind successful")
                print("end bind get device info - battLevel: \(sdk.device.battLevel)")
                print("end bind get function table - alexaSetEasyOperateV3: \(sdk.funcTable.alexaSetEasyOperateV3)")
                UserDefaults.standard.setBind(macAddress, isBind: true)
            case .binded:
                self?.isBinded = true
                UserDefaults.standard.setBind(macAddress, isBind: true)
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
            case .timeout:
                print("\(status)")
            case .agreeDeleteDeviceData:
                print("\(status)")
            case .denyDeleteDeviceData:
                print("\(status)")
            case .timeoutOnNewAccount:
                print("\(status)")
            case .needConfirmByApp:
                print("\(status)")
                let delay = DispatchTime.now() + 1.0
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    Cmds.sendBindResult(isSuccess: true).send {[weak self] rs in
                        if case .success(_) = rs {
                            print("success:")
                            self?.isBinded = true
                            SVProgressHUD.showSuccess(withStatus: "绑定成功")
                            UserDefaults.standard.setBind(macAddress, isBind: true)
                            sdk.cmd.appMarkBindResult(success: true)
                        }else {
                            print("failure")
                            //SVProgressHUD.showSuccess(withStatus: "绑定失败")
                            UserDefaults.standard.setBind(macAddress, isBind: false)
                            sdk.cmd.appMarkBindResult(success: false)
                        }
                        self?.tableView.reloadData()
                    }
                }
            }
            self?.tableView.reloadData()
        }
    }
    
    private func unbind() {
        SVProgressHUD.show(withStatus: "unbind...")
        let macAddress = sdk.device.macAddressFull // self.deviceModel!.macAddress!
        sdk.cmd.unbind(macAddress: macAddress, isForceRemove: true, completion: { [weak self] rs in
            self?.isBinded = !rs
            self?.tableView.reloadData()
            if rs {
                SVProgressHUD.showSuccess(withStatus: "unbind successful")
            } else {
                SVProgressHUD.showError(withStatus: "unbind failure")
            }
            UserDefaults.standard.setBind(macAddress, isBind: false)
            UserDefaults.standard.synchronize()
        })
    }
    
    private func _otaMode() {
        let alert = UIAlertController(title: "OTA Mode", message: "当前设备处理OTA模式，现在去升级？/ The current device handles OTA mode, upgrade now?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let vc = TransferFileDetailVC(cmd: .ota)
            navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
