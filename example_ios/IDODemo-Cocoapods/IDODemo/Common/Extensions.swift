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


