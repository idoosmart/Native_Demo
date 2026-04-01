//
//  MainPageVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/23.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

// Alexa client id （测试用）
let clientId = "amzn1.application-oa2-client.e45ff1ade6064c24a265fe6924c6f75d"

// MARK: - MainPageVC

class MainPageVC: BaseVC {
    var dataList = [IDODeviceModel]()
    var bleState: IDOBluetoothStateModel?
    var deviceState: IDODeviceStateModel?
    
    weak var funcPage: FunctionPageVC?
    
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.dataSource = self
        v.delegate = self
        v.register(CustomCell.self, forCellReuseIdentifier: CustomCell.cellIdentifier)
        return v
    }()
    
    lazy var btnReload: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(L10n.refresh, for: .normal)
        btn.addTarget(self, action: #selector(_reload), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        title = "IDO Demo"
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        view.addSubview(btnReload)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        btnReload.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(80, 80))
            make.bottom.equalTo(tableView.snp.bottom).offset(-30)
            make.right.equalTo(tableView.snp.right).offset(-20)
        }
        
        registerSDK()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopScan()
    }
    
    override func languageChanged() {
        super.languageChanged()
        
        btnReload.setTitle(L10n.refresh, for: .normal)
    }
    
    fileprivate func _goOta(otaModel: IDODeviceModel) {
        stopScan() // 停止扫描
        
        // 98|99平台设备ota需要先标记为OTA模式
        if ([98, 99].contains(otaModel.platform)) {
            Task {
                _ = await withCheckedContinuation { continuation in
                    sdk.bridge.markOtaMode?(macAddress: otaModel.macAddress ?? "",
                                            iosUUID: otaModel.uuid ?? "",
                                            platform: otaModel.platform,
                                            deviceId: otaModel.deviceId,
                                            completion: { _ in
                        continuation.resume(returning: true)
                    })
                    
                }
            }
        }
        
        let vc = TransferFileDetailVC(cmd: .ota)
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: UITableViewDelegate, UITableViewDataSource

extension MainPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.cellIdentifier, for: indexPath) as! CustomCell
        cell.accessoryType = .disclosureIndicator
        let deviceModel = dataList[indexPath.row]
        var devName = deviceModel.name ?? ""
        if (deviceModel.deviceId == 0) {
            // 从系统连接列表获取的设备(连过的设备), 高亮显示
            cell.backgroundColor = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
        }else {
            cell.backgroundColor = .white
            devName += "(\(deviceModel.deviceId))"
        }
        cell.configure(
            title: devName,
            subtitle: "\(deviceModel.macAddress ?? "unknow") - rssi:\(deviceModel.rssi)",
            buttonTitle: deviceModel.isOta ? "OTA" : ""
        )
        cell.buttonAction = { [weak self] in
            // ota
            self?._goOta(otaModel: deviceModel)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deviceModel = dataList[indexPath.row]
        if (deviceModel.isOta) {
            print("设备处理ota状态，先去升级")
            tableView.deselectRow(at: indexPath, animated: false)
            return;
        }
        let vc = FunctionPageVC()
        vc.deviceModel = deviceModel
        funcPage = vc
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


fileprivate class CustomCell: UITableViewCell {
    
    static let cellIdentifier = "CustomCell"
    
    // MARK: - UI 控件
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let actionButton = UIButton(type: .system)
    
    // 定义点击按钮的闭包（推荐方式）
    var buttonAction: (() -> Void)?
    
    // MARK: - 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 设置 UI
    private func setupUI() {
        // 标题
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .label
        
        // 副标题
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1
        
        // 按钮
        actionButton.setTitle("", for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        actionButton.titleLabel?.textColor = .blue
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        // 添加到 contentView
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(actionButton)
        
        // 关闭自动转换约束
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置约束
        NSLayoutConstraint.activate([
            // 标题
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            // 副标题
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            // 按钮
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    // MARK: - 按钮点击事件
    @objc private func buttonTapped() {
        buttonAction?()        // 执行外部传入的闭包
    }
    
    // MARK: - 配置 Cell 数据（推荐使用这个方法）
    func configure(title: String, subtitle: String, buttonTitle: String = "") {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.isHidden = buttonTitle.isEmpty
    }
}
