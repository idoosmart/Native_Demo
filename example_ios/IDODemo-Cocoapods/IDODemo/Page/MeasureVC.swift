//
//  MeasureVC.swift
//  Runner
//
//  Created by hc on 2026/03/19.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD
import protocol_channel

class MeasureVC: UIViewController {
    private let disposeBag = DisposeBag()
    private lazy var measureMgr = IDOMeasureManager.shared
    private var selectedType: IDOMeasureType = .bloodPressure
    
    private lazy var segmentType: UISegmentedControl = {
        let items = ["BP", "HR", "SpO2", "Stress", "OneClick", "Temp"]
        let v = UISegmentedControl(items: items)
        v.selectedSegmentIndex = 0
        v.rx.selectedSegmentIndex.subscribe(onNext: { [weak self] index in
            self?.selectedType = IDOMeasureType(rawValue: index) ?? .bloodPressure
        }).disposed(by: disposeBag)
        return v
    }()
    
    private lazy var btnStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start Measure")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.start()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop Measure")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.stop()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnGetData: UIButton = {
        let btn = UIButton.createNormalButton(title: "Get Measure Data")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.getData()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Measure"
        view.backgroundColor = .white
        setupUI()
        listenMeasure()
    }
    
    private func setupUI() {
        view.addSubview(segmentType)
        view.addSubview(btnStart)
        view.addSubview(btnStop)
        view.addSubview(btnGetData)
        view.addSubview(textConsole)
        
        segmentType.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            } else {
                make.top.equalTo(20)
            }
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
        btnStart.snp.makeConstraints { make in
            make.top.equalTo(segmentType.snp.bottom).offset(20)
            make.left.equalTo(15)
            make.right.equalTo(view.snp.centerX).offset(-5)
            make.height.equalTo(44)
        }
        
        btnStop.snp.makeConstraints { make in
            make.top.equalTo(btnStart)
            make.left.equalTo(view.snp.centerX).offset(5)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
        btnGetData.snp.makeConstraints { make in
            make.top.equalTo(btnStart.snp.bottom).offset(10)
            make.left.right.equalTo(segmentType)
            make.height.equalTo(44)
        }
        
        textConsole.snp.makeConstraints { make in
            make.top.equalTo(btnGetData.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(15)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-15)
            } else {
                make.bottom.equalTo(-15)
            }
        }
    }
    
    private func listenMeasure() {
        measureMgr.listenProcessMeasureData { [weak self] result in
            self?.log("Receive Data: \(self?.formatResult(result) ?? "")")
        }
    }
    
    private func formatResult(_ result: IDOMeasureResult) -> String {
        return "status:\(result.status.rawValue), value:\(result.value), bp:\(result.systolicBp)/\(result.diastolicBp), oneClick:\(result.oneClickHr)/\(result.oneClickSpo2)/\(result.oneClickStress), temp:\(result.temperatureValue)"
    }
    
    private func start() {
        log("Start Measure: \(selectedType)")
        measureMgr.startMeasure(type: selectedType) { [weak self] success in
            self?.log("Start Result: \(success)")
        }
    }
    
    private func stop() {
        log("Stop Measure: \(selectedType)")
        measureMgr.stopMeasure(type: selectedType) { [weak self] success in
            self?.log("Stop Result: \(success)")
        }
    }
    
    private func getData() {
        log("Get Measure Data: \(selectedType)")
        measureMgr.getMeasureData(type: selectedType) { [weak self] result in
            self?.log("Get Data Result: \(self?.formatResult(result) ?? "")")
        }
    }
    
    private func log(_ msg: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let time = formatter.string(from: date)
        textConsole.text += "\n[\(time)] \(msg)"
        textConsole.scrollToBottom()
    }
}
