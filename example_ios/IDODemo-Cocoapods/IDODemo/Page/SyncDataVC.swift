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

class SyncDataVC: UIViewController {
    private let disposeBag = DisposeBag()
    @objc dynamic private var isSyncing = false
    
    private lazy var btnStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start Sync Data")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.startSync()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop Sync Data")
        btn.isEnabled = false
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.stopSync()
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
        
        title = "Sync data"
        view.backgroundColor = .white
        
        view.addSubview(btnStart)
        view.addSubview(btnStop)
        view.addSubview(lblState)
        view.addSubview(textConsole)
        
        btnStart.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        btnStop.snp.makeConstraints { make in
            make.size.equalTo(btnStart)
            make.centerX.equalTo(btnStart)
            make.top.equalTo(btnStart.snp.bottom).offset(25)
        }
        
        lblState.snp.makeConstraints { make in
            make.top.equalTo(btnStop.snp.bottom).offset(25)
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
        
        self.rx.observeWeakly(Bool.self, "isSyncing").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
    }
}

extension SyncDataVC {
    private func startSync() {
        isSyncing = true
        textConsole.text = ""
        
        // 方式一： 同步所有
//        sdk.syncData.startSync(
//            funcProgress:{ [weak self] progress in
//            self?.isSyncing = true
//            self?.lblState.text = "Progress: \(progress)%"
//        }, funcData: { [weak self] type, json, error in
//            guard let self = self else { return }
//            //self?.lblState.text = self?.lblState.text ?? "" + "\n" + ""
//            if (error == 0) {
//                self.textConsole.text = self.textConsole.text
//                + "Sync type: \(type)" + "\n"
//                + json + "\n"
//            }else {
//                self.textConsole.text = self.textConsole.text
//                + "Sync type: \(type)" + "\n"
//                + "Error code: \(error)" + "\n"
//            }
//            self.textConsole.scrollToBottom()
//        }, funcCompleted: {[weak self] errorCode in
//            self?.isSyncing = false
//            let str = errorCode == 0 ? "Sync done" : "Sync failure, error:\(errorCode)"
//            self?.lblState.text = self?.lblState.text ?? "" + str
//        })
        
//        
//        // 方式二：同步指定类型
        let types = [
            IDOSyncDataTypeClass(type: .heartRate),
            IDOSyncDataTypeClass(type: .activity),
//            IDOSyncDataTypeClass(type: .sleep),
//            IDOSyncDataTypeClass(type: .bodyPower),
//            IDOSyncDataTypeClass(type: .bloodPressure),
//            IDOSyncDataTypeClass(type: .stepCount),
        ]
//        
//        // 可以用以下方法获取支持的类型
        sdk.syncData.getSupportSyncDataTypeList { list in
            print("getSupportSyncDataTypeList list:\(list)")
        }
//        
        sdk.syncData.startSync(types: types, funcData: { [weak self] type, json, error in
            guard let self = self else { return }
            //self?.lblState.text = self?.lblState.text ?? "" + "\n" + ""
            if (error == 0) {
                self.textConsole.text = self.textConsole.text
                + "Sync type: \(type)" + "\n"
                + json + "\n"
            }else {
                self.textConsole.text = self.textConsole.text
                + "Sync type: \(type)" + "\n"
                + "Error code: \(error)" + "\n"
            }
            self.textConsole.scrollToBottom()
        }, funcCompleted: {[weak self] errorCode in
            self?.isSyncing = false
            let str = errorCode == 0 ? "Sync done" : "Sync failure, error:\(errorCode)"
            self?.lblState.text = self?.lblState.text ?? "" + str
        })
    }
    
    private func stopSync() {
        sdk.syncData.stopSync()
        lblState.text = nil
        isSyncing = false
    }
    
    private func refreshState() {
        self.btnStart.isEnabled = !self.isSyncing
        self.btnStop.isEnabled = self.isSyncing
    }
}
