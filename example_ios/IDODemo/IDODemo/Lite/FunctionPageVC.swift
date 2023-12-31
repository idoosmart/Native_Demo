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
        Word.alexa
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
        })
    }
    
    deinit {
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
        let canEnable = canEnable(name)
        if (!canEnable) {
            //tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            return
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
        bleMgr.subscribeNotify(peripheral: notifyTuple.0, characteristic: notifyTuple.1) { (error) in
            if error != nil {
                printXY(error, obj: self, line: #line)
            }
        } notifyClosure: { (data, error) in
            if (data != nil) {
                //print("subscribeNotify receiveData:\(data!.hexadecimal())")
                // 将数据发送给协议库处理（!!!重要）
                sdk.bridge.receiveDataFromBle(data: data!, macAddress: nil)
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
        default:
            break
        }
        return false
    }
    
    private func canPush(_ funName: String) -> Bool {
        return !(funName == Word.deviceConnect || funName == Word.deviceDisconnect
                 || funName == Word.deviceBind || funName == Word.deviceUnbind)
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
            @unknown default:
                fatalError()
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
}
