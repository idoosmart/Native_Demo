//
//  DialZipParser.swift
//  TestCustomWatchFace
//
//  Created by hc on 2025/2/26.
//

import Foundation
import UIKit
import ZIPFoundation

class DialZipParser {
    // MARK: - Public Properties
    
    // 只读属性，用于访问解析的app.json数据
    private(set) var appConfig: IDODialAppConfig?
    
    // 只读属性，用于访问解析的iwf.json数据
    private(set) var iwfConfig: IDODialIWFConfig?
    
    // 解压后的根目录路径
    private(set) var pathRootDial: String?
    
    // 背景图 url
    private(set) var bgImgPath: String?
    
    private let fileManager = FileManager.default
    
    // 背景图名称（固定）
    //private let defaultBgImgName = "bg_24bit.png"
    private let defaultBgImgName = "bg.bmp"
    
    // 预览图尺寸，从iwf.json中获取，仅获取一次
    private var _sizePreviewImage: CGSize?
    
    // MARK: - Public Methods
    
    /// 解析表盘ZIP文件
    /// - Parameter zipFilePath: ZIP文件路径
    /// - Returns: 解析结果，成功返回true，失败返回false
    func parseDialZip(zipFilePath: String) -> Bool {
//        guard let zipFileName = URL(string: zipFilePath)?.lastPathComponent.replacingOccurrences(of: ".zip", with: "") else {
//            print("Invalid zip file path")
//            return false
//        }
        
        let zipFileName = "custom1"
        let templateDirName = "custom1_template"
        
        // 1. 删除并重新创建template目录
        let templateDirPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(templateDirName)
        
        do {
            if fileManager.fileExists(atPath: templateDirPath) {
                try fileManager.removeItem(atPath: templateDirPath)
            }
            try fileManager.createDirectory(atPath: templateDirPath, withIntermediateDirectories: true, attributes: nil)
            
            // 解压主ZIP文件到template目录
            try fileManager.unzipItem(at: URL(fileURLWithPath: zipFilePath), to: URL(fileURLWithPath: templateDirPath))
            
            // 2. 查找并解压内部的custom1.zip文件
            guard let innerZipPath = findFile(inDirectory: templateDirPath, withName: "\(zipFileName).zip") else {
                print("Failed to find inner zip file in template directory")
                return false
            }
            
            let innerZipDir = (innerZipPath as NSString).deletingLastPathComponent
            let extractDir = (innerZipDir as NSString).appendingPathComponent(zipFileName)
            if fileManager.fileExists(atPath: extractDir) {
                try fileManager.removeItem(atPath: extractDir)
            }
            try fileManager.createDirectory(atPath: extractDir, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: URL(fileURLWithPath: innerZipPath), to: URL(fileURLWithPath: extractDir))
            
            // 记录pathRootDial
            self.pathRootDial = extractDir
            
            // 删除解压后的zip文件
            try fileManager.removeItem(atPath: innerZipPath)
            
            // 3. 查找并解析app.json
            guard let appJsonPath = findFile(inDirectory: templateDirPath, withName: "app.json") else {
                print("Failed to find app.json in template directory")
                return false
            }
            
            guard let appJsonData = fileManager.contents(atPath: appJsonPath) else {
                print("Failed to read app.json data")
                return false
            }
            
            do {
                if let jsonString = String(data: appJsonData, encoding: .utf8) {
                    print("app jsonString: \(jsonString)")
                }
            } catch {
                print("Error encoding to JSON: \(error)")
            }
            
            appConfig = try JSONDecoder().decode(IDODialAppConfig.self, from: appJsonData)
            
            // 4. 查找并解析iwf.json
            guard let iwfJsonPath = findFile(inDirectory: extractDir, withName: "iwf.json") else {
                print("Failed to find iwf.json in extracted directory")
                return false
            }
            
            guard let iwfJsonData = fileManager.contents(atPath: iwfJsonPath) else {
                print("Failed to read iwf.json data")
                return false
            }
            
            do {
                if let jsonString = String(data: iwfJsonData, encoding: .utf8) {
                    print("iwf jsonString: \(jsonString)")
                }
            } catch {
                print("Error encoding to JSON: \(error)")
            }
            
            
            iwfConfig = try JSONDecoder().decode(IDODialIWFConfig.self, from: iwfJsonData)
            iwfConfig?.jsonFilePath = iwfJsonPath
            
            // 获取背景图片
            bgImgPath = findFile(inDirectory: extractDir, withName: defaultBgImgName)
            _sizePreviewImage = nil
            
            return true
        } catch {
            print("Error in parseDialZip: \(error)")
            return false
        }
    }
    
    /// 创建24位PNG图片
    /// - Parameters:
    ///   - size: 图片大小
    ///   - image: 原始图片
    /// - Returns: 保存的PNG图片路径
    func create24BitPNG(size: CGSize, image: UIImage) -> String? {
        guard let newImage = image.scaledTo(size: size) else {
            print("图片缩放失败")
            return nil
        }
        
        guard let cgImage = newImage.cgImage else {
            print("无法创建 CGImage")
            return nil
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            print("无法创建 CGContext")
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let newCGImage = context.makeImage(),
              let data = UIImage(cgImage: newCGImage).pngData() else {
            print("无法创建 PNG 数据")
            return nil
        }
        
        // 保存到临时目录
        let tempDir = NSTemporaryDirectory()
        let fileName = UUID().uuidString + ".png"
        let filePath = (tempDir as NSString).appendingPathComponent(fileName)
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
            return filePath
        } catch {
            print("Error saving PNG: \(error)")
            return nil
        }
    }
    
    /// 获取预览图尺寸
    func sizePreviewImage() -> CGSize {
        if _sizePreviewImage != nil {
            return _sizePreviewImage!
        }
        guard let pathRootDial = self.pathRootDial, let previewFileName = iwfConfig?.preview else {
            return CGSizeZero
        }
        guard let imgPreviewPath = findFile(inDirectory: pathRootDial, withName: previewFileName) else {
            return CGSizeZero
        }
        guard let imgPreview = UIImage(contentsOfFile: imgPreviewPath) else {
            return CGSizeZero
        }
        _sizePreviewImage = imgPreview.size
        return imgPreview.size
    }
    
    /// 替换预览图片
    /// - Parameter newImagePath: 新图片路径
    /// - Returns: 是否替换成功
    func replacePreviewImage(newImagePath: String) -> Bool {
        guard let previewFileName = iwfConfig?.preview else {
            return false
        }
        return replace24BitImage(newImagePath: newImagePath, imgName: previewFileName)
    }
    
    /// 替换背景图片
    /// - Parameter newImagePath: 新图片路径
    /// - Returns: 是否替换成功
    func replaceBgImage(newImagePath: String) -> Bool {
        return replace24BitImage(newImagePath: newImagePath, imgName: defaultBgImgName)
    }
    
    
    /// 将表盘目录打包为ZIP文件
    /// - Returns: ZIP文件路径
    func packDialToZip() -> String? {
        guard let pathRootDial = self.pathRootDial else {
            return nil
        }
        
        let dialDirURL = URL(fileURLWithPath: pathRootDial)
        let dialDirName = "custom1"
        
        // 获取template目录
        let templateDir = (dialDirURL.path as NSString).deletingLastPathComponent
        let zipFilePath = (templateDir as NSString).appendingPathComponent("\(dialDirName).zip")
        
        do {
            // 如果ZIP文件已存在，先删除
            if fileManager.fileExists(atPath: zipFilePath) {
                try fileManager.removeItem(atPath: zipFilePath)
            }
            
            // 更新iwf.json
            _ = iwfConfig?.save()
            
            // 创建ZIP文件
            guard let archive = Archive(url: URL(fileURLWithPath: zipFilePath), accessMode: .create) else {
                print("Create archive fail")
                return nil
            }
            
            // 获取所有非隐藏文件
            let contents = try fileManager.contentsOfDirectory(atPath: pathRootDial)
            let visibleFiles = contents.filter { !$0.hasPrefix(".") }
            
            // 添加所有文件到ZIP
            for fileName in visibleFiles {
                let filePath = (pathRootDial as NSString).appendingPathComponent(fileName)
                let fileURL = URL(fileURLWithPath: filePath)
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归添加目录
                        try addDirectoryToArchive(archive: archive, directoryURL: fileURL, relativeTo: dialDirURL)
                    } else {
                        // 添加文件
                        try archive.addEntry(with: fileName, relativeTo: dialDirURL)
                    }
                }
            }
            
            return zipFilePath
        } catch {
            print("Error packing dial to zip: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    /// 替换图片
    /// - Parameter newImagePath: 新图片路径
    /// - Returns: 是否替换成功
    private func replace24BitImage(newImagePath: String, imgName: String) -> Bool {
        guard let pathRootDial = self.pathRootDial else {
            return false
        }
        
        guard let bgImgPath = findFile(inDirectory: pathRootDial, withName: imgName) else {
            print("Failed to find a image: \(imgName)")
            return false
        }
        
        do {
            // 如果目标文件已存在，先删除
            if fileManager.fileExists(atPath: bgImgPath) {
                try fileManager.removeItem(atPath: bgImgPath)
            }
            
            // 复制新图片到预览图片位置
            try fileManager.copyItem(atPath: newImagePath, toPath: bgImgPath)
            return true
        } catch {
            print("Error replacing \(imgName) image: \(error)")
            return false
        }
    }
    
    
    /// 递归查找文件
    private func findFile(inDirectory directory: String, withName fileName: String) -> String? {
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: directory)
            
            for item in contents {
                let itemPath = (directory as NSString).appendingPathComponent(item)
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归搜索子目录
                        if let foundPath = findFile(inDirectory: itemPath, withName: fileName) {
                            return foundPath
                        }
                    } else if item == fileName {
                        return itemPath
                    }
                }
            }
        } catch {
            print("Error searching for file: \(error)")
        }
        
        return nil
    }
    
    /// 递归添加目录到ZIP
    private func addDirectoryToArchive(archive: Archive, directoryURL: URL, relativeTo baseURL: URL) throws {
        let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
        
        for fileURL in contents {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    try addDirectoryToArchive(archive: archive, directoryURL: fileURL, relativeTo: baseURL)
                } else {
                    try archive.addEntry(with: fileURL.relativePath(from: baseURL), relativeTo: baseURL)
                }
            }
        }
    }
}

// MARK: - URL Extension
extension URL {
    func relativePath(from base: URL) -> String {
        let pathComponents = self.pathComponents
        let basePathComponents = base.pathComponents
        
        var i = 0
        while i < min(pathComponents.count, basePathComponents.count) && pathComponents[i] == basePathComponents[i] {
            i += 1
        }
        
        return pathComponents[i...].joined(separator: "/")
    }
}

// MARK: - UIImage Extension

extension UIImage {
    func scaledTo(size: CGSize) -> UIImage? {
//        if self.size.width <= size.width && self.size.height <= size.height {
//            return self
//        }

        let aspectRatio = self.size.width / self.size.height
        var scaledImageRect = CGRect.zero

        if size.width / size.height > aspectRatio {
            scaledImageRect.size.width = size.height * aspectRatio
            scaledImageRect.size.height = size.height
            scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
            scaledImageRect.origin.y = 0.0
        } else {
            scaledImageRect.size.width = size.width
            scaledImageRect.size.height = size.width / aspectRatio
            scaledImageRect.origin.x = 0.0
            scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }
}


// MARK: - Model Classes

// App.json 数据模型
class IDODialAppConfig: Codable {
    let app: AppInfo
    let select: SelectInfo
    let colors: [String]?
    let locations: [LocationInfo]?
    let version: Int
    let functionSupport: Int?
    let functionSupportNew: Int?
    let timeWidgetList: [WidgetInfo]?
    let functionList: [FunctionInfo]?
    
    enum CodingKeys: String, CodingKey {
        case app, select, colors, locations, version
        case functionSupport = "function_support"
        case functionSupportNew = "function_support_new"
        case timeWidgetList = "time_widget_list"
        case functionList = "function_list"
    }
    
    class AppInfo: Codable {
        let name: String
        let bpp: Int
        let format: String
    }
    
    class SelectInfo: Codable {
        let timeFuncLocation: Int
        let timeColorIndex: Int
        let funcColorIndex: Int
        let function: [Int]?
        
        enum CodingKeys: String, CodingKey {
            case timeFuncLocation = "timeFuncLocation"
            case timeColorIndex = "timeColorIndex"
            case funcColorIndex = "funcColorIndex"
            case function
        }
    }
    
    class LocationInfo: Codable, Hashable {
        let type: Int
        let time: [Int]
        let day: [Int]
        let week: [Int]
        let timeWidget: [WidgetInfo]?
        let functionCoordinate: [FunctionCoordinate]?
        
        enum CodingKeys: String, CodingKey {
            case type, time, day, week
            case timeWidget = "time_widget"
            case functionCoordinate = "function_coordinate"
        }
        
        static func == (lhs: LocationInfo, rhs: LocationInfo) -> Bool {
                return lhs.type == rhs.type &&
                       lhs.time == rhs.time &&
                       lhs.day == rhs.day &&
                       lhs.week == rhs.week
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(type)
                hasher.combine(time)
                hasher.combine(day)
                hasher.combine(week)
            }
    }
    
    class WidgetInfo: Codable {
        let widget: String
        let type: String
        let font: String?
        let fontnum: Int?
        let x: Int?
        let y: Int?
        let w: Int?
        let h: Int?
        let supportColorSet: Bool?
        let bg: String?
        let align: String?
        
        enum CodingKeys: String, CodingKey {
            case widget, type, font, fontnum, x, y, w, h
            case supportColorSet = "support_color_set"
            case bg, align
        }
    }
    
    class FunctionCoordinate: Codable {
        let function: Int
        let item: [CoordinateItem]?
    }
    
    class CoordinateItem: Codable {
        let widget: String
        let type: String
        let coordinate: [Int]?
    }
    
    class FunctionInfo: Codable {
        let function: Int
        let name: String
        let smallIcon: String?
        let item: [FunctionItem]?
        
        enum CodingKeys: String, CodingKey {
            case function, name
            case smallIcon = "small_icon"
            case item
        }
    }
    
    class FunctionItem: Codable {
        let widget: String
        let type: String
        let font: String?
        let fontnum: Int?
        let supportColorSet: Bool?
        let bg: String?
        let align: String?
        
        enum CodingKeys: String, CodingKey {
            case widget, type, font, fontnum
            case supportColorSet = "support_color_set"
            case bg, align
        }
    }
}

// iwf.json 数据模型
class IDODialIWFConfig: Codable {
    let version: Int = 0
    let clouddialversion: Int?
    let preview: String?
    let name: String?
    let author: String?
    let description: String?
    let compress: String?
    let item: [IWFItem]?

    // 非JSON属性，用于保存文件路径
    fileprivate var jsonFilePath: String?

    // 使用 CodingKeys 枚举指定需要编码的属性
    enum CodingKeys: String, CodingKey {
        case version
        case clouddialversion
        case preview
        case name
        case author
        case description
        case compress
        case item
    }

    // 保存方法
    func save() -> Bool {
        guard let filePath = jsonFilePath else {
            return false
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(self)

            try jsonData.write(to: URL(fileURLWithPath: filePath))
            return true
        } catch {
            print("Error saving iwf.json: \(error)")
            return false
        }
    }

    class IWFItem: Codable {
        let widget: String
        let type: String
        var x: Int = 0
        var y: Int = 0
        var w: Int = 0
        var h: Int = 0
        let bg: String?
        var bgcolor: String?
        var fgcolor: String?
        var fgrender: String?
        let font: String?
        let fontnum: Int?
    }
}
