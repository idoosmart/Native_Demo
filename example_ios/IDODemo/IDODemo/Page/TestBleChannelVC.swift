//
//  TestBleChannelVC.swift
//  Runner
//
//  Created by hc on 2024/7/2.
//

import Foundation

import RxSwift
import RxCocoa
import protocol_channel

class TestBleChannelVC: UIViewController {
    var deviceModel: IDODeviceModel?
    private let disposeBag = DisposeBag()
    private lazy var txtCmd: HexTextField = {
        let v = HexTextField()
        v.borderStyle = .none
        v.layer.borderWidth = 1.0
        v.layer.borderColor = UIColor.gray.cgColor
        v.layer.cornerRadius = 8.0
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        v.placeholder = "FA FB FC FD"
        v.text = "02 03"
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
    
    private lazy var txtResponse: UITextView = {
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
    
    private lazy var btnClean: UIButton = {
        let btn = UIButton.createNormalButton(title: "Clean")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?.txtResponse.text = ""
        }).disposed(by: disposeBag)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test ble channel"
        view.backgroundColor = .white
        
        view.addSubview(btnCall)
        view.addSubview(txtCmd)
        view.addSubview(lblResponse)
        view.addSubview(txtResponse)
        
        txtCmd.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
            make.height.equalTo(44)
        }
        
        btnCall.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            make.top.equalTo(txtCmd.snp.bottom).offset(20)
        }
        
        lblResponse.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnCall.snp.bottom).offset(35)
        }
        txtResponse.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblResponse.snp.bottom).offset(5)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        txtCmd.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: btnCall.rx.isEnabled)
            .disposed(by: disposeBag)
        
        _ = NotificationCenter.default.rx.notification(Notify.onBleReceiveDataChanged).subscribe(onNext: { [weak self] notification in
            guard let self = self else { return }
            if let obj = notification.object as? IDOReceiveData {
                let s = obj.data?.hexString() ?? ""
                // debugPrint("s = \(s)")
                self.txtResponse.text = s + "\n" + self.txtResponse.text
            }
        }).disposed(by: disposeBag)
    }
    
    
    private func doCall() {
        sdk.ble.writeData(data: Data(hex: txtCmd.text ?? "02 03")!, device: deviceModel!, type: 0, platform: 2) { _ in
            
        }
    }
    
    
}

fileprivate class HexTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.delegate = self
        self.keyboardType = .asciiCapable
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func textFieldDidChange() {
        let text = self.text?.replacingOccurrences(of: " ", with: "") ?? ""
        let formattedText = formatHexText(text)
        self.text = formattedText
    }
    
    private func formatHexText(_ text: String) -> String {
        var formattedText = ""
        for (index, character) in text.enumerated() {
            if index % 2 == 0 && index > 0 {
                formattedText.append(" ")
            }
            formattedText.append(character)
        }
        return formattedText.uppercased()
    }
}

extension HexTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

extension Data {
    /// 将 Data 转换为16进制字符串
    func hexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
    
    /// 从16进制字符串初始化 Data 对象
    init?(hex: String) {
        let hexString = hex.replacingOccurrences(of: " ", with: "")
        let length = hexString.count / 2
        var data = Data(capacity: length)
        
        var index = hexString.startIndex
        for _ in 0..<length {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else {
                return nil
            }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}
