//
//  EpoVC.swift
//  IDODemo
//
//  Created by hc on 2024/08/29.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class EpoVC: UIViewController {
    private let disposeBag = DisposeBag()
    private lazy var epoMgr = IDOEpoManager.shared
    @objc dynamic private var isDoing = false
    
    private lazy var btnStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start Epo Upgrade")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.start()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop Epo Upgrade")
        btn.isEnabled = false
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.stop()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var lblState: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .right
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
        
        title = "Epo Upgrade"
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
        
        registerEpoListen()
        
        self.rx.observeWeakly(Bool.self, "isDoing").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
        
        refreshLastUpdateTime()
    }
}

extension EpoVC {
    
    private func registerEpoListen() {
        IDOEpoManager.shared.listenEpoUpgrade { [weak self] status in
            self?.textConsole.text += "\nstatus:\(status.displayName())"
        } downProgress: { [weak self] progress in
            self?.textConsole.text += "\ndown progress:\(String(format: "%.2f", progress))"
        } sendProgress: { [weak self] progress in
            self?.textConsole.text += "\nsend progress:\(String(format: "%.2f", progress))"
        } funcComplete: { [weak self] errCode in
            self?.isDoing = false
            self?.textConsole.text += "\ncomplete:\(errCode == 0 ? "success" : "failure") errCode:\(errCode)"
            self?.refreshLastUpdateTime()
        }
    }
    
    private func start() {
        guard epoMgr.isSupported else {
            SVProgressHUD.showInfo(withStatus: "该设备不支持 / This device does not support")
            return
        }
        isDoing = true
        textConsole.text = ""
        epoMgr.willStartInstall(isForce: true, retryCount: 0)
    }
    
    private func stop() {
        epoMgr.stop()
        isDoing = false
    }
    
    private func refreshState() {
        self.btnStart.isEnabled = !self.isDoing
        self.btnStop.isEnabled = self.isDoing
    }
    
    private func refreshLastUpdateTime() {
        IDOEpoManager.shared.lastUpdateTimestamp(completion: { [weak self] sec in
            self?.lblState.text = "Last update time："
            if (sec != 0) {
                self?.lblState.text! += secondsToDate(seconds: Double(sec/1000))
            } else {
                self?.lblState.text! += "none"
            }
        })
    }
}

extension IDOEpoUpgradeStatus {
    public func displayName() -> String {
        switch self {
        case .idle:
            return ".idle"
        case .ready:
            return ".ready"
        case .downing:
            return ".downing"
        case .making:
            return ".making"
        case .sending:
            return ".sending"
        case .installing:
            return ".installing"
        case .success:
            return ".success"
        case .failure:
            return ".failure"
        }
    }
}

private func secondsToDate(seconds: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: seconds)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: date)
}
