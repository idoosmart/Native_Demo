//
//  XYCentralManager.swift
//  XYCBCentralManager
//
//  Created by macvivi on 2020/12/30.
//

import UIKit
import CoreBluetooth

typealias ErrorClosure = (Error?)->Void
typealias DataClosure = (Data?,Error?)->Void
typealias VoidCompletion = () -> Void

class XYCentralManager: NSObject {

    //创建单例
    //Create the singleton
    static let shared = XYCentralManager()
    
    //调用startScan方法后，己经搜索到的信息通过这个属性可以获得
    //After calling startScan, the information found so far is available through this property
    var scanInfoArray: [ScanInfo] {
        XYCBBase.shared.scanInfoArr
    }
    
    var scanInfoListSorted: [ScanInfo] {
        XYCBBase.shared.scanInfoArr.sorted { $0.rssi.intValue > $1.rssi.intValue }
    }
    
    //MARK: 开始扫描 / Start scanning
    func startScan(findPeripheral: @escaping (CBPeripheral) -> Void) {
        XYCBBase.shared.startScan { (peripheral) in
            findPeripheral(peripheral)
        }
    }
    
    func stopScan() {
        XYCBBase.shared.stopScan()
    }
    
    //MARK: 连接 / Connect
    //在连接成功，并且发现了外设的所有特征后才给出连接成功的回调
    //The connected callback fires only after the connection succeeds and all peripheral characteristics have been discovered
    //连接成功后如果断开，会自动重连。除非调用disConnect方法，调用disConnect方法后不会自动重连了
    //If the connection drops after connecting, it reconnects automatically, unless disConnect is called; after calling disConnect there is no auto-reconnect
    func connect(peripheral: CBPeripheral, completions: @escaping (Bool,Error?) -> Void) {
        XYCBBase.shared.connect(peripheral: peripheral) { (isConnect, error) in
            completions(isConnect,error)
        }
    }
    
    func disConnect(peripheral: CBPeripheral, completions: @escaping () -> Void) {
        XYCBBase.shared.disConnect(peripheral, completion: completions)
    }
    
    //MARK: mtu: 最大传输单元 / maximum transmission unit
    //maximum transmission unit
    //一包数据最多发多少个字节，如果超过mtu,框架会做自动分包发送的处理。
    //Maximum bytes per packet; if the data exceeds the mtu, the framework automatically splits it into packets.
    //默认设置为peripheral.maximumWriteValueLength，正常情况下mtu是不需要手动设置的，框架已经给你处理好了
    //Defaults to peripheral.maximumWriteValueLength; normally the mtu does not need to be set manually, the framework handles it for you
    //除非是外设的蓝牙模块不规范，mtu设为peripheral.maximumWriteValueLength时，发大一点的数据出现问题才需要手动设置
    //Only set it manually if the peripheral's Bluetooth module is non-standard and sending larger data fails when mtu is set to peripheral.maximumWriteValueLength
    var mtu: Int {
        set {
            XYCBBase.shared.mtu = newValue
        }
        get {
            XYCBBase.shared.mtu
        }
    }
    
    //MARK: 写 / Write
    //errorClosure:如果传回nil说明数据写成功，否则会传回错误的原因
    //errorClosure: nil means the data was written successfully, otherwise it carries the error reason
    func write(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data, errorClosure: ErrorClosure?){
        XYCBBase.shared.write(peripheral: peripheral, characteristic: characteristic, data: data, errorClosure: errorClosure)
    }
    
    //MARK: 写无回复 / Write without response
    func writeWithoutResponse(peripheral: CBPeripheral, characteristic: CBCharacteristic, data: Data){
        XYCBBase.shared.writeWithoutResponse(peripheral: peripheral, characteristic: characteristic, data: data)
    }

    //MARK: 订阅通知 / Subscribe to notifications
    //参数errorClosure:当errorClosure传回的参数为nil时表示订阅成功，否则Error参数会传回订阅失败的原因
    //Parameter errorClosure: when the parameter passed to errorClosure is nil the subscription succeeded, otherwise the Error parameter carries the reason the subscription failed
    //参数notifyClosure: notifyClosure的参数会传回收到的数据Data,当收到通知时notifyClosure会被调用
    //Parameter notifyClosure: notifyClosure receives the incoming Data, and notifyClosure is called whenever a notification is received
    func subscribeNotify(peripheral: CBPeripheral, characteristic: CBCharacteristic, errorClosure: ErrorClosure?, notifyClosure: @escaping DataClosure){
        XYCBBase.shared.subscribeNotify(peripheral: peripheral, characteristic: characteristic, errorClosure: errorClosure, notifyClosure: notifyClosure)
    }
    
    //MARK: 读 / Read
    //callBack会传回read到的数据
    //callBack returns the data that was read
    func read(peripheral: CBPeripheral, characteristic: CBCharacteristic, callBack: @escaping DataClosure){
        XYCBBase.shared.read(peripheral: peripheral, characteristic: characteristic, callBack: callBack)
    }
    



}
