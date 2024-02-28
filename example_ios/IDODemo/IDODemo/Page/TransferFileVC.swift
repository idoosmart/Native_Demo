//
//  TransferFileVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/31.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class TransferFileVC: UIViewController {
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        return v
    }()
    
    private lazy var items: [TransType] = {
        var list: [TransType] = [
            .wallpaper,
            .contact,
            .bin
        ]
        if sdk.funcTable.getSupportV3BleMusic {
            list.append(.mp3)
        }
        return list
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transfer File"
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

extension TransferFileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let _cellID = "UITableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: _cellID) ?? UITableViewCell(style: .default, reuseIdentifier: _cellID)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.textColor = .black
        cell.textLabel?.textAlignment = .left
        let cmd = items[indexPath.row]
        cell.textLabel?.text = cmd.title()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cmd = items[indexPath.row]
        let vc = FunctionDetailVC(cmd: cmd)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - TransType

fileprivate enum TransType {
    case mp3
    case wallpaper
    case contact
    case bin
}

extension TransType {

    func title() -> String {
        switch self {
        case .mp3:
            return "Music"
        case .wallpaper:
            return "Wallpaper"
        case .contact:
            return "Contact"
        case .bin:
            return "bin文件升级"
        }
    }
}

// MARK: - FunctionDetailVC

private class FunctionDetailVC: UIViewController {
    private var cmd: TransType
    private let disposeBag = DisposeBag()
    private var cancellable: IDOCancellable?
    private lazy var bundlePath = Bundle.main.bundlePath + "/files_trans"
    @objc dynamic private var isTransferring = false
    
    private lazy var btnSend: UIButton = {
        let btn = UIButton.createNormalButton(title: "Send")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.send()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.stop()
        }).disposed(by: disposeBag)
        return btn
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
    
    required init(cmd: TransType) {
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
        
        view.addSubview(btnSend)
        view.addSubview(btnStop)
        view.addSubview(textConsole)
        
        btnSend.snp.makeConstraints { make in
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
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.top.equalTo(btnSend.snp.bottom).offset(25)
        }
        
        textConsole.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(btnStop.snp.bottom).offset(25)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalTo(0)
            }
        }
        
        self.rx.observeWeakly(Bool.self, "isTransferring").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cancellable?.cancel()
        super.viewDidDisappear(animated)
    }
    
    private func send() {
        cancellable?.cancel()
        cancellable = nil
        textConsole.text = ""
        switch cmd {
        case .mp3:
            _mp3()
            break
        case .wallpaper:
            _wallpaper()
            break
        case .contact:
            _contact()
            break
        case .bin:
            _bin()
            break
        }
    }
    
    private func stop() {
        cancellable?.cancel()
        isTransferring = false
    }
    
    private func _mp3() {
        let mp3Path = bundlePath + "/mp3"
        _trans([
            IDOTransMusicModel(filePath: "\(mp3Path)/3.mp3", fileName: "mp3_1", musicId: 1),
            IDOTransMusicModel(filePath: "\(mp3Path)/2.mp3", fileName: "mp3_2", musicId: 2),
            IDOTransMusicModel(filePath: "\(mp3Path)/1.mp3", fileName: "mp3_3", musicId: 3)
        ])
    }
    
    private func _contact() {
        let contactFilePath = bundlePath + "/contact/a.json"
        _trans([
            IDOTransNormalModel(fileType: .ml, filePath: contactFilePath, fileName: "a")
        ])
    }
    
    private func _wallpaper() {
        let picFilePath = bundlePath + "/imgs/c.png"
        _trans([
            IDOTransNormalModel(fileType: .wallpaperZ, filePath: picFilePath, fileName: "wallpaper.z")
        ])
    }
    
    private func _bin() {
        print("开始时间：\(Date())")
        //let picFilePath = bundlePath + "/bin/gtx03_ota_full_1.0.1.bin"
        let picFilePath = bundlePath + "/bin/ota_firmware.bin"
        _trans([
            IDOTransNormalModel(fileType: .bin, filePath: picFilePath, fileName: "ota_firmware.bin")
        ])
    }
    
    private func _trans<T: IDOTransBaseModel>(_ items: [T]) {
        isTransferring = true
        cancellable = sdk.transfer.transferFiles(fileItems: items, cancelPrevTranTask: true) { [weak self] currentIndex, totalCount, currentProgress, totalProgress in
            let txt = (self?.textConsole.text ?? "")
            + "index: \(currentIndex + 1)/\(totalCount) progress: \(Int(currentProgress * 100))%/"
            + String(format: "%.1f%%\n", totalProgress * 100)
            self?.textConsole.text = txt
            self?.textConsole.scrollToBottom()
        } transStatus: { [weak self] currentIndex, status, errorCode, _ in
            if status != .finished || errorCode != 0 {
                let txt = (self?.textConsole.text ?? "") + "failure, currentIndex:\(currentIndex) errorCode:\(errorCode ?? -1)\n"
                self?.textConsole.text = txt
                self?.textConsole.scrollToBottom()
            }
        } completion: { [weak self] rs in
            self?.isTransferring = false
            let txt = (self?.textConsole.text ?? "") + "result: \(rs)\n"
            self?.textConsole.text = txt
            self?.textConsole.scrollToBottom()
            print("结束时间：\(Date())")
        }
    }
    
    private func refreshState() {
        self.btnSend.isEnabled = !self.isTransferring
        self.btnStop.isEnabled = self.isTransferring
    }
}
