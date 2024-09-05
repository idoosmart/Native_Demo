//
//  Extension.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import Foundation
import UIKit
import protocol_channel
import SVProgressHUD
import SSZipArchive

extension UIView {
    func showBorder(borderWidth: Float = 0.5, cornerRadius: Float = 12) {
        layer.cornerRadius = CGFloat(cornerRadius)
        layer.borderWidth = CGFloat(borderWidth)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = true
    }
}

extension UIButton {
    static func createNormalButton(title: String? = nil, borderWidth: Float = 0.5, cornerRadius: Float = 12) -> UIButton {
        let btn = UIButton()
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        let imgBg = UIColor.blue.createImage()
        btn.setBackgroundImage(imgBg, for: .normal)
        btn.showBorder(borderWidth: borderWidth, cornerRadius: cornerRadius)
        return btn
    }
}

extension UserDefaults {
    func isBind(_ macAddress: String) -> Bool {
        let key = Constant.bindKey + "-" + macAddress
        return bool(forKey: key)
    }
    
    func setBind(_ macAddress: String, isBind: Bool) {
        let key = Constant.bindKey + "-" + macAddress
        setValue(isBind, forKey: key)
        synchronize()
    }
}

extension UIColor {
    func createImage() -> UIImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            setFill()
            let path = UIBezierPath(rect: CGRect(origin: .zero, size: size))
            path.fill()
        }
        return image
    }
}

extension UITextView {
    func scrollToBottom() {
        guard contentSize.height > bounds.height else { return }
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height)
        setContentOffset(bottomOffset, animated: true)
    }
}


func printProperties(_ obj: Any?) -> String? {
    guard let obj = obj else {
        return nil
    }
    let mirror = Mirror(reflecting: obj)
    var rs = "\(type(of: obj)) : {\n"
    for case let (label?, value) in mirror.children {
        rs += "\(label): \(value)\n"
    }
    rs += "}"
    return rs
}


extension FunctionPageVC {
    // 导出日志
    func doExportLog() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let appLogAction = UIAlertAction(title: "App log", style: .default) { _ in
            self.handleAppLogSelection()
        }
        alertController.addAction(appLogAction)
        
        let bleLogAction = UIAlertAction(title: "Ble log", style: .default) { _ in
            self.handleBleLogSelection()
        }
        alertController.addAction(bleLogAction)
        
        let flashLogAction = UIAlertAction(title: "Device log", style: .default) { _ in
            self.handleFlashLogSelection()
        }
        alertController.addAction(flashLogAction)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func handleAppLogSelection() {
        SVProgressHUD.show(withStatus: "Export app logs...")
        sdk.tool.exportLog { [weak self] path in
            print("log path:\(path)")
            if (path.count > 0) {
                // 成功
                self?.share(filePath: path)
            }else {
                SVProgressHUD.showError(withStatus: "操作失败")
            }
        }
    }
    
    private func handleBleLogSelection() {
        SVProgressHUD.show(withStatus: "Export ble logs...")
        sdk.ble.exportLog { [weak self] path in
            print("log path:\(path ?? "")")
            if (path != nil && path!.count > 0) {
                // 成功
                self?.share(filePath: path!)
            }else {
                SVProgressHUD.showError(withStatus: "操作失败")
            }
        }
    }
    
    private func handleFlashLogSelection() {
        SVProgressHUD.show(withStatus: "Export device logs...")
        sdk.deviceLog.startGet(types: [IDODeviceLogTypeClass(logType: .general)], timeOut: 60) { progress in
            print("progress: \(progress)")
        } completion: { [weak self] rs in
            print("设备日志获取 rs=\(rs)")
            if (rs) {
                let path = sdk.deviceLog.logDirPath
                if (path.count > 0) {
                    let zipFilePath = self?.zipFile(dirPath: path)
                    if(zipFilePath != nil) {
                        self?.share(filePath: zipFilePath!)
                    }else {
                        SVProgressHUD.showError(withStatus: "操作失败")
                    }
                }else {
                    SVProgressHUD.showError(withStatus: "操作失败")
                }
            } else {
                SVProgressHUD.showError(withStatus: "操作失败")
            }
        }
    }
    
    private func share(filePath: String) {
        SVProgressHUD.dismiss(withDelay: 0)
        let fileURL = URL(fileURLWithPath: filePath)
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard]
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    private func zipFile(dirPath: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "\(dateFormatter.string(from: Date()))_log.zip"
        let zipFilePath = NSTemporaryDirectory() + "/" + fileName
        if (SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: dirPath)) {
            return zipFilePath
        }
        return nil
    }
    
}
