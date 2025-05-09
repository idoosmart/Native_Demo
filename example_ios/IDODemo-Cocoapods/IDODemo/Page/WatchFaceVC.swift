//
//  WatchFaceVC.swift
//  Runner
//
//  Created by hc on 2024/6/5.
//

import Foundation
import UIKit
import SwiftUI

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

/*
 自定义表盘：
 custom表盘设置步骤：
 private var currentWatchFaceListModel: IDOWatchListModel?
 let watchName = "custom1" // 需要与表盘包中的iwf.json中name值相同

 1、获取表盘列表:
     Cmds.getWatchListV3().send { [weak self] res in
         if case .success(let val) = res {
             self?.currentWatchFaceListModel = val
         }else if case .failure(_) = res {
             // Failed to obtain the watch face list
         }
     }

 2、判断表盘列表中是否存在将要上传的表盘，如果存在，需要先删除该表盘
     if (currentWatchFaceListModel?.items.contains { $0.name.hasPrefix(watchName) }) {
         let param = IDOWatchFaceParamModel(operate: 2, fileName: watchName, watchFileSize: 0)
         Cmds.setWatchFaceData(param).send { [weak self] res in
             if case .success(let val) = res {
                 if (val == nil || val!.errCode == 0) {
                    // successful
                    // Uninstall watch face successful
                 }
             }else if case .failure(let err) = res {
                 // Failed to obtain the watch face list err
             }
         }
     }
     

 3、上传custom表盘
     let fileItem = IDOTransNormalModel(fileType: .iwfLz, filePath:"/xx/xx/**/watch.zip", fileName: watchName)
     sdk.transfer.transferFiles(fileItems: [fileItem], cancelPrevTranTask: true) { currentIndex, totalCount, currentProgress, totalProgress in
         SVProgressHUD.showProgress(totalProgress);
     } transStatus: { currentIndex, status, errorCode, finishingTime in
         // print("status: (status) errorCode: (errorCode)")
     } completion: { [weak self] rs in
         if (rs.first ?? false) {
             // success
         }else {
             // fail
         }
     }
 */

class WatchFaceVC: UIViewController {
    private lazy var bundlePath = Bundle.main.bundlePath + "/files_trans"
    private var testWatchModel: IDOTransNormalModel?
    private var isInstalled = false
    private let disposeBag = DisposeBag()
    private var currentWatchFaceListModel: IDOWatchListModel?
    private lazy var btnGetWatchFaceList: UIButton = {
        let v = UIButton.createNormalButton(title: "Get watch list")
        v.isEnabled = true
        v.rx.tap.subscribe(onNext: { [weak self] in
            self?._getWatchList()
        }).disposed(by: disposeBag)
        return v
    }()
    
    private lazy var btnAction: UIButton = {
        let v = UIButton.createNormalButton(title: "Install watch face")
        v.isEnabled = true
        v.isHidden = true
        v.rx.tap.subscribe(onNext: { [weak self] in
            self?._installOrUninstallWatchFace()
        }).disposed(by: disposeBag)
        return v
    }()
    
    private lazy var lblTips: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 12)
        v.textColor = .gray
        v.isEditable = false
        v.text = """
添加表盘步骤：
1、从云端下载对应的表盘文件到本地
2、获取当前设备表盘列表
3、判断设备表盘数据和空间是否
4、传输表盘到设备
5、如果安装后未显示，需要调用setWatchFaceData设置为第一表盘(可选)
注：Demo只处理2、3、4，表盘文件内置在工程中

Steps to add a watch face:
1. Download the corresponding watch face file from the cloud to the local
2. Get the watch face list of the current device
3. Determine whether the device watch face data and space are
4. Transfer the watch face to the device
5. If it is not displayed after installation, you need to call setWatchFaceData to set it as the first watch face (optional)
Note: Demo only processes 2, 3, and 4, and the watch face file is built into the project
"""
        return v
    }()
    
    private var customDialZipPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Watch face upgrade"
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
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(btnAction.snp.bottom).offset(20)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-35)
            } else {
                make.bottom.equalTo(-35)
            }
        }
        
        if [7892, 512].contains(sdk.device.deviceId) {
            let btnCustomDial = UIBarButtonItem(
                title: "Custom",
                style: .plain,
                target: self,
                action: #selector(_customDial)
            )
            navigationItem.rightBarButtonItem = btnCustomDial
        }
        
        if(_initWatchTransModel()) {
            _getWatchList()
        }
    }
}

extension WatchFaceVC {
    
    private func _initWatchTransModel() -> Bool {
        // !!!: 不同平台设备的表盘文件、配置存在差异，不支持交叉使用
        switch(sdk.device.deviceId) {
        case 7877:
            testWatchModel = IDOTransNormalModel(fileType: .watch, filePath: bundlePath + "/watch_face/7877/wf_w58.watch", fileName: "wf_w58.watch")
        case 7814:
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/7814/w58.zip", fileName: "w58")
        case 537:
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/537/w130.zip", fileName: "w130")
        case 517:
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/517/w130.zip", fileName: "w130")
        case 543:
            testWatchModel = IDOTransNormalModel(fileType: .watch, filePath: bundlePath + "/watch_face/543/wf_w58.watch", fileName: "wf_w58.watch")
        case 7883:
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/7883/GTX02_1.zip", fileName: "GTX02_1")
        case 7892:
            //testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/7892/tmp.zip", fileName: "custom1.iwf")
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/7892/w189.zip", fileName: "w189")
        case 512:
            testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: bundlePath + "/watch_face/512/idw19_coustom1.zip", fileName: "custom1.iwf")
        default:
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Tips", message: "未找到设备'\(sdk.device.deviceId)'相关文件，请在demo代码中配置再次尝试\n\nDevice '\(sdk.device.deviceId)' related files not found, please configure in the demo code and try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popToRootViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    private func _refreshState() {
        guard let isInstalled = currentWatchFaceListModel?.isInstalled(watchName: testWatchModel!.fileName) else {
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
            }else if case .failure(_) = res {
                SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list")
            }
        }
    }
    
    private func _installOrUninstallWatchFace() {
        if (isInstalled) {
            // uninstall
            SVProgressHUD.show()
            let param = IDOWatchFaceParamModel(operate: 2, fileName: testWatchModel!.fileName, watchFileSize: testWatchModel!.fileSize)
            Cmds.setWatchFaceData(param).send { [weak self] res in
                if case .success(let val) = res {
                    if (val == nil || val!.errCode == 0) {
                        // successful
                        SVProgressHUD.showSuccess(withStatus: "Uninstall watch face successful")
                        self?._getWatchList() // 重新获取表盘列表
                    }else {
                        SVProgressHUD.showError(withStatus: "Uninstall failed")
                    }
                }else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list err code: \(err)")
                }
            }
        }else {
            // install
            
            SVProgressHUD.showProgress(0.0);
            //1、把表盘文件传到设备
            sdk.transfer.transferFiles(fileItems: [testWatchModel!], cancelPrevTranTask: true) { currentIndex, totalCount, currentProgress, totalProgress in
                SVProgressHUD.showProgress(totalProgress);
            } transStatus: { currentIndex, status, errorCode, finishingTime in
                print("status: \(status) errorCode: \(errorCode)")
            } completion: { [weak self] rs in
                
                if (rs.first ?? false) {
                    // 传输完成
                    // 设备安装表盘需要时间，此处延迟2秒再刷新表盘列表
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        
//                        // 2、设置列表生效（可选）
//                        let param = IDOWatchFaceParamModel(operate: 1, fileName: self?.testWatchModel?.fileName ?? "", watchFileSize: 0)
//                        Cmds.setWatchFaceData(param).send { res in
//                            if case .success(let val) = res {
//                                if (val == nil || val!.errCode == 0) {
//                                    // successful
//                                    
//                                }
//                            }else if case .failure(let err) = res {
//                                SVProgressHUD.showError(withStatus: "Failed to obtain the watch face list")
//                            }
//                        }
                        
                        // 重新获取表盘列表
                        self?._getWatchList()
                    }
                }else{
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @objc private func _customDial() {
        SVProgressHUD.show()
        // 获取设备屏幕信息
        Cmds.getWatchDialInfo().send { [weak self] res in
            //sdk.device.deviceShapeType
            if case .success(let o) = res, o != nil {
                self?.gotoCustomDialVC(o!)
            }else {
                SVProgressHUD.showError(withStatus: "Failed to obtain device screen information, please try again")
            }
        }
    }
    
    private func gotoCustomDialVC(_ watchDialInfo: IDOWatchDialInfoModel) {
        
        // 设备屏幕信息
        let sizeDial = CGSizeMake(CGFloat(watchDialInfo.width), CGFloat(watchDialInfo.height))
        /// 手表形状 类型：1：圆形；2：方形的； 3：椭圆
        let shapeType = sdk.device.deviceShapeType
        let dialCustomDialInfo = DialCustomDialInfo(sizeDial: sizeDial, shapeType: shapeType)
        let customDialView = DialCustomizationView(customDialInfo: dialCustomDialInfo) { [weak self] zipPath in
            guard let zipPath = zipPath else { return }
            print("customDialZipPath:\(zipPath)")
            self?.customDialZipPath = zipPath
            self?.testWatchModel = IDOTransNormalModel(fileType: .iwfLz, filePath: zipPath, fileName: "custom1")
        }
        let hostingController = UIHostingController(rootView: customDialView)
        self.navigationController?.pushViewController(hostingController, animated: true)
        SVProgressHUD.dismiss()
    }
    
}

extension IDOWatchListModel {
    
    /// 是否已安装
    func isInstalled(watchName: String) -> Bool {
        let name = watchName.replacingOccurrences(of: ".watch", with: "")
        return items.contains {
            print("isInstalled：\($0.name) name:\(name) \($0.name.hasPrefix(name))")
            return $0.name.hasPrefix(name)
        }
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

