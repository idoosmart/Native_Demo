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
import CoreBluetooth


class FunctionPageVC: UIViewController {
    private var isBinded = false
    private var isConnected = false
    var deviceModel: ScanInfo?
    private let disposeBag = DisposeBag()
    //var service: CBService?
    
    private lazy var items = [
        Word.deviceConnect,
        Word.deviceDisconnect,
        Word.deviceBind,
        Word.deviceUnbind,
        Word.getFunction,
        Word.setFunction,
        Word.syncData,
        Word.transFile,
        Word.sport,
        Word.alexa,
        Word.testOC,
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
            lblDeviceInfo.text = "Current Device: \(device.peripheralName ?? "-")\nRSSI: \(device.rssi)"
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
                print(status)
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
                    self?._disconnect()
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
    }
    
    deinit {
        print("\(String(describing: type(of: self))) deinit")
        print("Disconnect Device")
        guard let peripheral = deviceModel?.peripheral else { return }
        bleMgr.disConnect(peripheral: peripheral) {  }
        sdk.bridge.markDisconnectedDevice(macAddress: nil, uuid: deviceModel?.uuid) { _ in  }
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
            connectDevice()
            break
        case Word.deviceDisconnect:
            SVProgressHUD.show()
            bleMgr.disConnect(peripheral: deviceModel!.peripheral) { [weak self] in
                self?.isConnected = false
                self?.tableView.reloadData()
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
        case Word.sport:
            navigationController?.pushViewController(SportVC(), animated: true)
            break
        case Word.testOC:
            let test = TestOC()
            test.testCommand()
            test.testSync()
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
    
    // 连接设备
    private func connectDevice() {
        SVProgressHUD.show()
        bleMgr.connect(peripheral: deviceModel!.peripheral) { [weak self] res, err in
            print("bleMgr.connect res:\(res) err:\(String(describing: err))")
            guard let self = self else {
                return
            }
            if (res) {
                self.testReadData() // 注册数据接收
                let otaType = sdk.bridge.checkOtaType(peripheral: deviceModel!.peripheral, advertisementData: deviceModel!.advertisementData)
                if (otaType != .none) {
                    // 设备处理ota模式时，需要进入到升级页
                    SVProgressHUD.dismiss()
                    _otaMode()
                    return
                }
                
                let uniqueId = self.deviceModel!.uuid
                let isBinded = UserDefaults.standard.isBind(uniqueId)
                self.isBinded = isBinded
                
                // 标记协议库已连接（!!!重要）
                sdk.bridge.markConnectedDevice(uniqueId: self.deviceModel!.uuid,
                                               otaType: .none,
                                               isBinded: isBinded,
                                               deviceName: self.deviceModel?.peripheralName) { [weak self] rs in
                    SVProgressHUD.dismiss()
                    self?.isConnected = rs
                    self?.isBinded = isBinded
                    self?.tableView.reloadData()
                    if (!rs) {
                        SVProgressHUD.showError(withStatus: "Connect Failure")
                    }
                }
            }else {
                SVProgressHUD.showError(withStatus: "Connect Failure")
            }
            self.lblConnectState.text = "Connect State:\(self.deviceModel?.peripheral.state ?? .disconnected)"
        }
    }
    
    private func testReadData(){
        guard let peripheral = deviceModel?.peripheral else { return }
        guard let notifyTuple =  peripheral.notifyCharacteristic() else { return }
        bleMgr.subscribeNotify(peripheral: notifyTuple.0, characteristic: notifyTuple.1) { [weak self] (error) in
            guard let self = self else {
                return
            }
            if error != nil {
                printXY(error ?? "", obj: self, line: #line)
            }
        } notifyClosure: { (data, error) in
            if var data = data, data.count > 0 {
                //print("subscribeNotify receiveData:\(data!.hexadecimal())")
                
                // 将数据发送给协议库处理（!!!重要）
                sdk.bridge.receiveDataFromBle(data: data, macAddress: nil)
            }
        }
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
        case Word.sport:
            return isConnected && isBinded
        case Word.testOC:
            return isConnected && isBinded
        case Word.exportLog:
            return isConnected && isBinded
        default:
            break
        }
        return false
    }
    
    private func canPush(_ funName: String) -> Bool {
        return !(funName == Word.deviceConnect || funName == Word.deviceDisconnect
                 || funName == Word.deviceBind || funName == Word.deviceUnbind
                 || funName == Word.testOC || funName == Word.exportLog)
    }
    
    private func bind() {
        SVProgressHUD.show(withStatus: "binding...")
        let macAddress = sdk.device.macAddressFull
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
            self?.tableView.reloadData()
        }
    }
    
    private func unbind() {
        SVProgressHUD.show(withStatus: "unbind...")
        let macAddress = sdk.device.macAddressFull
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
    
    private func _disconnect() {
        print("begin markDisconnectedDevice")
        sdk.bridge.markDisconnectedDevice(macAddress: nil, uuid: self.deviceModel?.uuid) { [weak self] rs in
            print("end markDisconnectedDevice rs:\(rs)")
            self?.isConnected = !rs
            SVProgressHUD.dismiss()
            self?.tableView.reloadData()
        }
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


//// MARK: - ota模式判定
//
//extension FunctionPageVC {
//    
//    private func _parseData(scanInfo: ScanInfo?) -> BleDeviceModeInfo? {
//        let modeInfo = BleDeviceModeInfo()
//        let manufacturerData = self.deviceModel!.advertisementData["kCBAdvDataManufacturerData"] as? Data
//        guard let data = manufacturerData, data.count >= 16 else {
//            return nil
//        }
//        let platform = Int(data[15])
//        let dfuMode = Int(data[14])
//        let version = Int(data[8])
//        modeInfo.platform = platform
//        modeInfo.deviceId = Int(data[0]) | Int(data[1]) << 8
//        if (version == 3 && dfuMode == 1 && (platform == 98 || platform == 99)) {
//            modeInfo.isInDfu = true
//            modeInfo.isOta = true
//        }else {
//            // TODO: 其它设备升级状态判定
//        }
//        return modeInfo
//    }
//    
//}
//
//private class BleDeviceModeInfo {
//    
//    var deviceId: Int = 0
//    var platform: Int = -1
//    var isOta: Bool = false
//    var isTlwOta: Bool = false
//    var isInDfu: Bool = false
//    
//}
