//
//  SetFunctionVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD
import AVFoundation

import protocol_channel

class SetFunctionVC: UIViewController {
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    private lazy var items: [CmdType] = [
        .setDateTime,
        .setBleVoice
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Set Function"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(0)
                make.bottom.equalTo(0)
            }
            make.left.right.equalTo(0)
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension SetFunctionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .black
        cell.textLabel?.textAlignment = .left
        cell.detailTextLabel?.textAlignment = .left
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.numberOfLines = 2
        let cmd = items[indexPath.row]
        cell.textLabel?.text = cmd.title()
        cell.detailTextLabel?.text = cmd.desc()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = items[indexPath.row]
        let vc = FunctionDetailVC(cmd: cmd)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - CmdType

fileprivate protocol CmdTypeProtocol {
    
}


fileprivate enum CmdType {
    /// Set Time
    case setDateTime
    /// Set phone volume for device event number
    case setBleVoice
}

extension CmdType {

    func title() -> String {
        switch self {
        case .setDateTime:
            return "setDateTime"
        case .setBleVoice:
            return "setBleVoice"
        }
    }
    
    func desc() -> String {
        switch self {
        case .setDateTime:
            return "Set Time"
        case .setBleVoice:
            return "Set phone volume for device event number"
        }
    }
    
    func param() -> IDOBaseModel {
        switch self {
        case .setDateTime:
            let currentDate = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            let day = calendar.component(.day, from: currentDate)
            let hour = calendar.component(.hour, from: currentDate)
            let minute = Int(arc4random_uniform(59)) + 1
            let second = calendar.component(.second, from: currentDate)
            let timeZone = TimeZone.current.secondsFromGMT(for: currentDate)
            let weekday = calendar.component(.weekday, from: currentDate)
            var adjustedWeekday = weekday - 2
            if adjustedWeekday < 0 {
                adjustedWeekday += 7
            }
            return IDODateTimeParamModel(year: year, monuth: month, day: day,
                                             hour: hour, minute: minute, second: second,
                                             week: adjustedWeekday, timeZone: timeZone)
        case .setBleVoice:
            return IDOBleVoiceParamModel(totalVolume: 100, currentVolume: Int(getCurrentVolume()))
        }
    }
    
    
    private func getCurrentVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            let currentVolume = audioSession.outputVolume * 100
            return currentVolume
        } catch {
            print("Failed to get current volume: \(error)")
            return 0.0
        }
    }
}

// MARK: - FunctionDetailVC

private class FunctionDetailVC: UIViewController {
    private var cmd: CmdType
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    private lazy var lblParam: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Parameter"
        return v
    }()
    
    private lazy var lblResponse: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.text = "Response"
        return v
    }()
    
    private lazy var textParam: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var textResponse: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()
    
    private lazy var btnCall: UIButton = {
        let btn = UIButton.createNormalButton(title: "Send")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.doCall()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    required init(cmd: CmdType) {
        self.cmd = cmd
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = cmd.title()
        view.backgroundColor = .white
        
        view.addSubview(btnCall)
        view.addSubview(lblParam)
        view.addSubview(textParam)
        view.addSubview(lblResponse)
        view.addSubview(textResponse)
        
        btnCall.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        lblParam.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnCall.snp.bottom).offset(15)
        }
        textParam.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblParam.snp.bottom).offset(5)
            make.height.equalTo(160)
        }
        lblResponse.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(textParam.snp.bottom).offset(35)
        }
        textResponse.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblResponse.snp.bottom).offset(5)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        textParam.text = cmd.param().toJsonString()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewDidDisappear(animated)
    }
    
    private func doCall() {
        cancellable?.cancel()
        cancellable = nil
        textResponse.text = ""
        btnCall.isEnabled = false
        switch cmd {
        case .setDateTime:
            cancellable = Cmds.setDateTime(cmd.param() as! IDODateTimeParamModel).send { [weak self] res in
                self?.doPrint(res)
            }
            break
        case .setBleVoice:
            cancellable = Cmds.setBleVoice(cmd.param() as! IDOBleVoiceParamModel).send { [weak self] res in
                self?.doPrint(res)
            }
            break
        }
    }
    
    private func doPrint<T>(_ res: Result<T?, CmdError>) {
        btnCall.isEnabled = true
        if case .success(let val) = res {
            if (val == nil) {
                textResponse.text = "Successful"
            }else if T.self is String.Type {
                textResponse.text = val as? String
            }else if T.self is IDOBaseModel.Type {
                let obj = val as? IDOBaseModel
                textResponse.text = "\(obj?.toJsonString() ?? "")\n\n\n" + "\(printProperties(obj) ?? "")"
            }
        }else if case .failure(let err) = res {
            textResponse.text = "Error code: \(err.code)\nMessage: \(err.message ?? "")"
        }
    }
}
