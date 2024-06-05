//
//  WatchFaceVC.swift
//  Runner
//
//  Created by hc on 2024/6/5.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel


/// 云表盘的添加/删除操作
///
///```
/// 添加表盘步骤：
/// 1、从云端下载对应的表盘文件到本地
/// 2、获取当前设备表盘列表
/// 3、判断设备表盘空间和数据限制
/// 4、传输表盘到设备
/// 5、如果安装后未显示，需要调用setWatchFaceData设置为第一表盘
///
/// 注：Demo只处理2、3、4，表盘文件内置在工程中
/// ```
///
class WatchFaceVC: UIViewController {
    private lazy var bundlePath = Bundle.main.bundlePath + "/files_trans"
    private lazy var testWatchModel = IDOTransNormalModel(fileType: .watch, filePath: bundlePath + "/watch_face/gtx13/wf_w58.watch", fileName: "wf_w58.watch")
    private var isInstalled = false
    private let disposeBag = DisposeBag()
    private var currentWatchFaceListModel: IDOWatchListModel?
    private lazy var btnGetWatchFaceList: UIButton = {
        let btn = UIButton.createNormalButton(title: "Get watch list")
        btn.isEnabled = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._getWatchList()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btnAction: UIButton = {
        let btn = UIButton.createNormalButton(title: "Install watch face")
        btn.isEnabled = true
        btn.isHidden = true
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._installOrUninstallWatchFace()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var lblTips: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        lbl.numberOfLines = 0
        lbl.text = """
添加表盘步骤：
1、从云端下载对应的表盘文件到本地
2、获取当前设备表盘列表
3、判断设备表盘空间和数据限制
4、传输表盘到设备
5、如果安装后未显示，需要调用setWatchFaceData设置为第一表盘

注：Demo只处理2、3、4，表盘文件内置在工程中
"""
        return lbl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Watch face(GTX13 only)"
        view.backgroundColor = .white
        
        view.addSubview(btnGetWatchFaceList)
        view.addSubview(btnAction)
        view.addSubview(lblTips)
        
        btnGetWatchFaceList.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerX.equalTo(view)
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
        }
        
        btnAction.snp.makeConstraints { make in
            make.size.equalTo(btnGetWatchFaceList)
            make.centerX.equalTo(btnGetWatchFaceList)
            make.top.equalTo(btnGetWatchFaceList.snp.bottom).offset(25)
        }
        
        lblTips.snp.makeConstraints { make in
            make.left.right.equalTo(20)
            make.top.equalTo(btnAction.snp.bottom).offset(20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35)
            } else {
                make.bottom.equalTo(-35)
            }
        }
        
        _getWatchList()
    }
}

extension WatchFaceVC {
    
    private func _refreshState() {
        guard let isInstalled = currentWatchFaceListModel?.isInstalled(watchName: testWatchModel.fileName) else {
            btnAction.isEnabled = false
            self.isInstalled = false
            return
        }
        self.isInstalled = isInstalled
        btnAction.setTitle(isInstalled ? "Uninstall" : "Install", for: .normal)
        btnAction.isEnabled = true
        
    }
    
    private func _getWatchList() {
        
        SVProgressHUD.show()
        Cmds.getWatchListV3().send { [weak self] res in
            if case .success(let val) = res {
                self?.currentWatchFaceListModel = val
                self?.btnAction.isHidden = false
                SVProgressHUD.dismiss()
                self?._refreshState()
            }else if case .failure(let err) = res {
                SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list")
            }
        }
    }
    
    private func _installOrUninstallWatchFace() {
        if (isInstalled) {
            // uninstall
            SVProgressHUD.show()
            let param = IDOWatchFaceParamModel(operate: 2, fileName: testWatchModel.fileName, watchFileSize: testWatchModel.fileSize)
            Cmds.setWatchFaceData(param).send { [weak self] res in
                if case .success(let val) = res {
                    if (val == nil || val!.errCode == 0) {
                        // successful
                        SVProgressHUD.showSuccess(withStatus: "Uninstall watch face successful")
                        self?._getWatchList() // 重新获取表盘列表
                    }
                }else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list err code: \(err)")
                }
            }
        }else {
            // install
            
            SVProgressHUD.showProgress(0.0);
            //1、把表盘文件传到设备
            sdk.transfer.transferFiles(fileItems: [testWatchModel], cancelPrevTranTask: true) { currentIndex, totalCount, currentProgress, totalProgress in
                SVProgressHUD.showProgress(totalProgress);
            } transStatus: { currentIndex, status, errorCode, finishingTime in
                print("status: \(status) errorCode: \(errorCode)")
            } completion: { [weak self] rs in
                
                if (rs.first ?? false) {
                    // 传输完成
                    // 设备安装表盘需要时间，此处延迟2秒再刷新表盘列表
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self?._getWatchList() // 重新获取表盘列表
                    }
                }else{
                    SVProgressHUD.dismiss()
                }
            }

            
//            //2、设置列表生效（可选）
//            let param = IDOWatchFaceParamModel(operate: 1, fileName: testWatchModel.fileName, watchFileSize: 0)
//            Cmds.setWatchFaceData(param).send { res in
//                if case .success(let val) = res {
//                    if (val == nil || val!.errCode == 0) {
//                        // successful
//                        
//                    }
//                }else if case .failure(let err) = res {
//                    SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list")
//                }
//            }
        }
    }
    
}

extension IDOWatchListModel {
    
    /// 是否已安装
    func isInstalled(watchName: String) -> Bool {
        return items.contains { $0.name == watchName.replacingOccurrences(of: ".watch", with: "") }
    }
    
    /// 设备表盘空间是否已满
    func isCapacityFull(willInstallBytes: Int) -> Bool {
        var showFullAlertFalse = false
        let invalidCloudCount = cloudWatchNum <= userCloudWatchNum
        
        if (!sdk.funcTable.setWatchCapacitySizeDisplay) {
            showFullAlertFalse = invalidCloudCount
        }else {
            let invalidCapacity = (userWatchCapacitySize + willInstallBytes) > watchCapacitySize;
            showFullAlertFalse = invalidCloudCount || invalidCapacity;
        }
        return !showFullAlertFalse
    }
    
}

