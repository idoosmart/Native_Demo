//
//  DialCustomizationView.swift
//  TestCustomWatchFace
//
//  Created by hc on 2025/2/26.
//

import SwiftUI
import UniformTypeIdentifiers


class DialCustomDialInfo {
    /// 表盘尺寸
    /// Watch face size
    var sizeDial: CGSize
    /// 表盘预览图尺寸（手表首页长按切表盘时用到）
    /// Watch face preview image size (used when long-pressing the watch home screen to switch watch faces)
    var sizePreviewDail: CGSize
    /// 手表形状 类型：1：圆形；2：方形的； 3：椭圆
    /// Watch shape type: 1: round; 2: square; 3: oval
    var shapeType: Int
    
    init(sizeDial: CGSize, sizePreviewDail: CGSize = CGSizeZero, shapeType: Int) {
        self.sizeDial = sizeDial
        self.sizePreviewDail = sizePreviewDail
        self.shapeType = shapeType
    }
}

struct DialCustomizationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State
    @State private var bgImage: UIImage?
    @State private var isImporting: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var statusMessage: String = "请导入表盘ZIP文件 / Please import a watch face ZIP file"
    @State private var isProcessing: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // MARK: - Properties
    private let parser = DialZipParser()
    @State private var currentZipPath: String?
    @State private var exportedZipPath: String?
    
    @State private var captureTrigger = false
    @State private var isExporting = false
    
    @State private var config = WatchFaceConfiguration(
        isLoaded: false,
        backgroundPhoto: nil,
        functionalColor: .black,
        timeColor: .black,
        timeFuncLocation: 2,
        isImagePickerPresented: false,
        colors: [],
        locations: []
    )
    
    @State var customDialInfo: DialCustomDialInfo
    var callbackCustomZipFilePath: (String?) -> Void
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 按钮
                    // Buttons
                    Button(action: {
                        isImporting = true
                    }) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                            Text("导入ZIP文件 / Import ZIP file")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                    
                    if config.isLoaded {
                        
                        WatchFacePreview(config: $config, timeFuncLocation: $config.timeFuncLocation, customDialInfo: $customDialInfo)
                        DescriptionText()
                        PhotoSelectionView(config: $config) {
                            isImagePickerPresented = true
                        }
                        
                        if (config.colors.count > 0) {
                            ColorSelectionView(title: "Functional Components Color", selectedColor: $config.functionalColor, colors: $config.colors)
                            ColorSelectionView(title: "Time Components Color", selectedColor: $config.timeColor, colors: $config.colors)
                        }
                        
                        PositionSelectionView(config: $config, customDialInfo: $customDialInfo)
                        ActionButtonsView(isProcessing: $isExporting, onUsingAction: {
                            isExporting = true
                            captureTrigger = true
                        }, onTrashAction: {
                            config = WatchFaceConfiguration(
                                isLoaded: false,
                                backgroundPhoto: nil,
                                functionalColor: .black,
                                timeColor: .black,
                                timeFuncLocation: 2,
                                isImagePickerPresented: false,
                                colors: [],
                                locations: []
                            )
                        })
                        
                        // 状态信息
                        // Status message
                        Text(statusMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding()
                        
                        // 处理中指示器
                        // Processing indicator
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.5)
                                .padding()
                        }
                        
                    }
                }
                .padding()
                .background(SnapshotView(content: WatchFacePreview(config: $config, timeFuncLocation: $config.timeFuncLocation, customDialInfo: $customDialInfo),
                                         captureTrigger: $captureTrigger,
                                         onCapture: { image in
                    // 替换预览图
                    // Replace the preview image
                    replacePreviewImage(with: image) { rs in
                        if (rs) {
                            // 更新颜色
                            // Update colors
                            changeColor()
                            
                            // 更换function location
                            // Change the function location
                            changeTimeFuncLoction()
                            
                            // 导出制作后的表盘包
                            // Export the finished watch face package
                            exportZipFile()
                        }
                    }
                })
                    .frame(width: customDialInfo.sizePreviewDail.width, height: customDialInfo.sizePreviewDail.height)
                    .opacity(0)
                )
            }
            .navigationTitle("表盘定制工具 / Dial Customization Tool")
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.zip],
                allowsMultipleSelection: false
            ) { result in
                handleImportedFile(result: result)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $bgImage, didSelectImage: { image in
                    DispatchQueue.global(qos: .userInitiated).async {
                        guard let newImg = image.croppedCircularImage(size: customDialInfo.sizeDial, isCircle: customDialInfo.shapeType == 1) else {
                            DispatchQueue.main.async {
                                showAlert(title: "操作失败 / Operation failed", message: "图片裁剪失败 / Image cropping failed")
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            replaceBgImage(with: newImg)
                            config.backgroundPhoto = newImg
                        }
                    }
                })
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("确定 / Confirm"))
                )
            }
        }
    }
    
    // MARK: - Methods
    private func handleImportedFile(result: Result<[URL], Error>) {
        isProcessing = true
        statusMessage = "正在处理ZIP文件 / Processing ZIP file..."
        
        do {
            let selectedFileURLs = try result.get()
            guard let selectedFileURL = selectedFileURLs.first else {
                throw NSError(domain: "DialCustomizationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "没有选择文件 / No file selected"])
            }
            
            // 安全访问文件
            // Access the file securely
            guard selectedFileURL.startAccessingSecurityScopedResource() else {
                throw NSError(domain: "DialCustomizationError", code: 2, userInfo: [NSLocalizedDescriptionKey: "无法访问文件 / Unable to access the file"])
            }
            defer { selectedFileURL.stopAccessingSecurityScopedResource() }
            
            // 复制到临时目录
            // Copy to the temporary directory
            let tempDir = NSTemporaryDirectory()
            let tempZipPath = (tempDir as NSString).appendingPathComponent(selectedFileURL.lastPathComponent)
            
            if FileManager.default.fileExists(atPath: tempZipPath) {
                try FileManager.default.removeItem(atPath: tempZipPath)
            }
            try FileManager.default.copyItem(at: selectedFileURL, to: URL(fileURLWithPath: tempZipPath))
            
            currentZipPath = tempZipPath
            processZipFile()
        } catch {
            isProcessing = false
            showAlert(title: "导入失败 / Import failed", message: error.localizedDescription)
            statusMessage = "导入失败 / Import failed: \(error.localizedDescription)"
        }
    }
    
    private func processZipFile() {
        guard let zipPath = currentZipPath else {
            isProcessing = false
            statusMessage = "没有ZIP文件路径 / No ZIP file path"
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let success = parser.parseDialZip(zipFilePath: zipPath)
            
            DispatchQueue.main.async {
                isProcessing = false
                
                if success {
                    config.isLoaded = parser.appConfig != nil
                    
                    // 加载背景图
                    // Load the background image
                    loadBgImage()
                    
                    // 时间、日期颜色
                    // Time and date colors
                    config.colors = parser.appConfig?.colors?.toColors() ?? []
                    if (config.colors.count > 0) {
                        if let colorIdx = parser.appConfig?.select.funcColorIndex {
                            config.functionalColor = config.colors[colorIdx]
                        }
                        if let colorIdx = parser.appConfig?.select.timeColorIndex {
                            config.timeColor = config.colors[colorIdx]
                        }
                    }
                    
                    // 坐标、宽高
                    // Coordinates, width and height
                    config.locations = parser.appConfig?.locations ?? []
                    config.timeFuncLocation = parser.appConfig?.select.timeFuncLocation ?? 2
                    let sizePreviewImage  = parser.sizePreviewImage()
                    print("sizePreviewImage:\(sizePreviewImage)")
                    customDialInfo.sizePreviewDail = sizePreviewImage
                    
                    statusMessage = "ZIP文件解析成功 / ZIP file parsed successfully"
                } else {
                    statusMessage = "ZIP文件解析失败 / ZIP file parsing failed"
                    showAlert(title: "解析失败 / Parse failed", message: "无法解析ZIP文件，请确保文件格式正确 / Unable to parse the ZIP file, please make sure the file format is correct")
                }
            }
        }
    }
    
    private func loadBgImage() {
        guard let bgImgPath = parser.bgImgPath else {
            showAlert(title: "加载失败 / Load failed", message: "无法加载背景图 / Unable to load the background image")
            return
        }
        
        if let image = UIImage(contentsOfFile: bgImgPath) {
            self.bgImage = image
            config.backgroundPhoto = image
        }
    }
    
    private func findFile(inDirectory directory: String, withName fileName: String) -> String? {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: directory)
            
            for item in contents {
                let itemPath = (directory as NSString).appendingPathComponent(item)
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        // 递归搜索子目录
                        // Search subdirectories recursively
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
    
    fileprivate func replaceBgImage(with image: UIImage) {
        guard parser.pathRootDial != nil else {
            showAlert(title: "错误 / Error", message: "未找到表盘目录 / Watch face directory not found")
            return
        }
        
        isProcessing = true
        statusMessage = "正在替换背景图 / Replacing background image..."
        
        // 创建24位PNG
        // Create a 24-bit PNG
        DispatchQueue.global(qos: .userInitiated).async {
            if let pngPath = parser.create24BitPNG(size: customDialInfo.sizeDial, image: image) {
                let success = parser.replaceBgImage(newImagePath: pngPath)
                
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    if success {
                        statusMessage = "背景图替换成功 / Background image replaced successfully"
                    } else {
                        statusMessage = "背景图替换失败 / Background image replacement failed"
                        showAlert(title: "替换失败 / Replace failed", message: "无法替换背景图 / Unable to replace the background image")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    isProcessing = false
                    statusMessage = "无法创建PNG图片 / Unable to create PNG image"
                    showAlert(title: "创建失败 / Create failed", message: "无法创建24位PNG图片 / Unable to create a 24-bit PNG image")
                }
            }
        }
    }
    
    fileprivate func replacePreviewImage(with image: UIImage, completion: @escaping (Bool) -> Void) {
        guard parser.pathRootDial != nil else {
            showAlert(title: "错误 / Error", message: "未找到表盘目录 / Watch face directory not found")
            completion(false)
            return
        }
        
        isProcessing = true
        statusMessage = "正在替换背景图 / Replacing background image..."
        
        // 创建24位PNG
        // Create a 24-bit PNG
        DispatchQueue.global(qos: .userInitiated).async {
            if let pngPath = parser.create24BitPNG(size: customDialInfo.sizePreviewDail, image: image) {
                let success = parser.replacePreviewImage(newImagePath: pngPath)
                
                DispatchQueue.main.async {
                    isProcessing = false
                    
                    if success {
                        statusMessage = "背景图替换成功 / Background image replaced successfully"
                        completion(true)
                    } else {
                        statusMessage = "背景图替换失败 / Background image replacement failed"
                        showAlert(title: "替换失败 / Replace failed", message: "无法替换背景图 / Unable to replace the background image")
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    isProcessing = false
                    statusMessage = "无法创建PNG图片 / Unable to create PNG image"
                    showAlert(title: "创建失败 / Create failed", message: "无法创建24位PNG图片 / Unable to create a 24-bit PNG image")
                    completion(false)
                }
            }
        }
    }
    
    fileprivate func changeTimeFuncLoction() {
        guard parser.iwfConfig != nil else {
            return
        }
        
        guard let locInfo = parser.appConfig?.locations?.first(where: { $0.type == config.timeFuncLocation }) else {
            return
        }
        
        for obj in parser.iwfConfig?.item ?? [] {
            if obj.type == "time" {
                doit(obj, locInfo.time)
            }else if obj.type == "week" {
                doit(obj, locInfo.week)
            } else if obj.type == "day" {
                doit(obj, locInfo.day)
            }
        }
        
        func doit(_ obj: IDODialIWFConfig.IWFItem, _ list: [Int]) {
            obj.x = list[0]
            obj.y = list[1]
            obj.w = list[2]
            obj.h = list[3]
        }
    }
    
    fileprivate func changeColor() {
        guard parser.iwfConfig != nil else {
            return
        }

        guard config.colors.count > 0 else {
            return
        }
        
        guard let funColorIdx = config.colors.lastIndex(of: config.functionalColor),
              let timeColorIdx = config.colors.lastIndex(of: config.timeColor) else {
            return
        }
        
        guard let funColorStr = parser.appConfig?.colors?[funColorIdx],
              let timeColorStr = parser.appConfig?.colors?[timeColorIdx] else {
            return
        }
        
        for obj in parser.iwfConfig?.item ?? [] {
            if obj.type == "time" {
                obj.fgcolor = timeColorStr.replacingOccurrences(of: "#", with: "0xFF")
            }else if obj.type == "week" || obj.type == "day" {
                obj.fgcolor = funColorStr.replacingOccurrences(of: "#", with: "0xFF")
            }
        }
    }
    
    fileprivate func exportZipFile() {
        guard parser.iwfConfig != nil else {
            return
        }
        
        isProcessing = true
        statusMessage = "正在导出ZIP文件 / Exporting ZIP file..."
        
        changeColor()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let zipPath = parser.packDialToZip() {
                DispatchQueue.main.async {
                    isProcessing = false
                    isExporting = false
                    exportedZipPath = zipPath
                    statusMessage = "ZIP文件导出成功 / ZIP file exported successfully: \(URL(fileURLWithPath: zipPath).lastPathComponent)"
                    print("zipPath: \(zipPath)")
                    self.callbackCustomZipFilePath(zipPath)
                    //self.navigationController?.popViewController(animated: true)
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    isProcessing = false
                    isExporting = false
                    statusMessage = "ZIP文件导出失败 / ZIP file export failed"
                    showAlert(title: "导出失败 / Export failed", message: "无法打包ZIP文件 / Unable to pack the ZIP file")
                }
            }
        }
    }
    
    func captureScreenshot(of view: some View) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

// MARK: - 辅助视图 / Helper views
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 图片选择器 / Image picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var didSelectImage: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.didSelectImage(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 文件共享视图 / File share view
struct ShareSheet: UIViewControllerRepresentable {
    let filePath: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [URL(fileURLWithPath: filePath)],
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Watch Face Configuration Model
struct WatchFaceConfiguration {
    var isLoaded: Bool
    var backgroundPhoto: UIImage?      // Stores the selected photo
    var functionalColor: Color = .clear        // Color for functional components (e.g., day/date)
    var timeColor: Color = .clear          // Color for time components
    var timeFuncLocation: Int = 0
    var isImagePickerPresented: Bool
    var colors: [Color]
    var locations: [IDODialAppConfig.LocationInfo]
}

// MARK: - Watch Face Preview
struct WatchFacePreview: View {
    @Binding var config: WatchFaceConfiguration
    @Binding var timeFuncLocation: Int
    @Binding var customDialInfo: DialCustomDialInfo
    
    var body: some View {
        ZStack(alignment: timeFuncLocation.postion().0) {
            // Background photo or placeholder
            if let uiImage = config.backgroundPhoto {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.5)
            }
            
            VStack(alignment: .center, spacing: 0) {
                // Functional components (day and date)
                Text("MON 28")
                    .foregroundColor(config.functionalColor)
                    .font(.system(size: 16, weight: .medium))
                // Time components
                Text("09:30")
                    .foregroundColor(config.timeColor)
                    .font(.system(size: 26, weight: .bold))
            }.padding(timeFuncLocation.postion().1)
        }
        .frame(width: customDialInfo.sizePreviewDail.width, height: customDialInfo.sizePreviewDail.height)
        .clipShape(ConditionalShape(isCircle: customDialInfo.shapeType == 1))
        //.cornerRadius(customDialInfo.shapeType == 1 ? customDialInfo.sizePreviewDail.width/2 : 16)
        .shadow(radius: 5).offset(x: 0, y: 0)
    }
}

struct ConditionalShape: Shape {
    var isCircle: Bool

    func path(in rect: CGRect) -> Path {
        if isCircle {
            return Circle().path(in: rect)
        } else {
            return RoundedRectangle(cornerRadius: 16).path(in: rect)
        }
    }
}

// MARK: - Description Text
struct DescriptionText: View {
    var body: some View {
        Text("Choose a photo, and every time you lift your wrist, this photo will display as setup Watch face.")
            .foregroundColor(.gray)
            .font(.system(size: 14))
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

// MARK: - Photo Selection View
struct PhotoSelectionView: View {
    @Binding var config: WatchFaceConfiguration
    
    var onSelectPhotoAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select photo")
                .font(.headline)
            
            VStack(spacing: 20) {
                Button(action: {
                    onSelectPhotoAction()
                }) {
                    HStack {
                        Text("Select from album")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.black)
                }
                .disabled(config.isLoaded == false)
            }
        }
        .padding(.horizontal)
    }
    
}


// MARK: - Color Selection View
struct ColorSelectionView: View {
    let title: String
    @Binding var selectedColor: Color
    @Binding var colors: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}


// MARK: - Position Selection View
struct PositionSelectionView: View {
    @Binding var config: WatchFaceConfiguration
    @Binding var customDialInfo: DialCustomDialInfo
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time & Functional Location")
                .font(.headline)
            HStack(spacing: 15) {
                ForEach(config.locations, id: \.self) { item in
                    ZStack(alignment: item.type.postion().0) {
                        ConditionalShape(isCircle: customDialInfo.shapeType == 1)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80 * customDialInfo.sizeDial.height / customDialInfo.sizeDial.width)
                        VStack(alignment: .center, spacing: 0) {
                            Text("10:08")
                                .font(.system(size: 14))
                        }.padding(item.type.postion().1)
                    }
                    .overlay(
                        ConditionalShape(isCircle: customDialInfo.shapeType == 1)
                            .stroke(item.type == config.timeFuncLocation ? Color.green : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture {
                        config.timeFuncLocation = item.type
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}


// MARK: - Action Buttons View
struct ActionButtonsView: View {
    
    @Binding var isProcessing: Bool
    var onUsingAction: () -> Void
    var onTrashAction: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                onTrashAction()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: {
                onUsingAction()
            }) {
                Text("Using")
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .frame(width: 220, height: 50)
            .disabled(isProcessing)
        }
        .padding(.horizontal)
    }
}

// 截图工具视图
// Snapshot helper view
fileprivate struct SnapshotView<Content: View>: UIViewRepresentable {
    let content: Content
    @Binding var captureTrigger: Bool
    var onCapture: (UIImage) -> Void
    var onComplete: (() -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        return hostingController.view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard captureTrigger else { return }
        
        DispatchQueue.main.async {
            let renderer = UIGraphicsImageRenderer(bounds: uiView.bounds)
            let image = renderer.image { _ in
                uiView.drawHierarchy(in: uiView.bounds, afterScreenUpdates: true)
            }
            onCapture(image)
            onComplete?()
            captureTrigger = false
        }
    }
}


extension [String] {
    func toColors() -> [Color] {
        return self.map { Color(hex: $0) }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let redComponent = Double((rgb & 0xFF0000) >> 16) / 255.0
        let greenComponent = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blueComponent = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: redComponent, green: greenComponent, blue: blueComponent)
    }
}

extension UIImage {
    func croppedCircularImage(size: CGSize, isCircle: Bool) -> UIImage? {
        // 1. 获取原始图片的 CGImage
        // 1. Get the original image's CGImage
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // 2. 计算中心点
        // 2. Compute the center point
        let centerX = imageWidth / 2
        let centerY = imageHeight / 2
        
        // 3. 计算裁剪区域的 Rect
        // 3. Compute the crop area's Rect
        let cropRect = CGRect(x: centerX - size.width / 2,
                              y: centerY - size.height / 2,
                              width: size.width,
                              height: size.height)
        
        // 4. 执行裁剪 (确保裁剪区域在图片范围内)
        // 4. Perform the crop (make sure the crop area is within the image bounds)
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }
        
        // 5. 从 CGImage 创建 UIImage
        // 5. Use the CGImage to create a UIImage
        var croppedImage = UIImage(cgImage: croppedCGImage)
        
        // 6. 创建遮罩
        // 6. Create the mask
        croppedImage = croppedImage.createImage(isCircle: isCircle)
        
        return croppedImage
    }
    
    
    func createImage(isCircle: Bool) -> UIImage {
            if isCircle {
                let squareImage = self
                let minLength = min(squareImage.size.width, squareImage.size.height)
                let circleRect = CGRect(x: 0, y: 0, width: minLength, height: minLength)

                UIGraphicsBeginImageContextWithOptions(circleRect.size, false, 0)
                guard let context = UIGraphicsGetCurrentContext() else {
                    return self
                }

                context.beginPath()
                context.addEllipse(in: circleRect)
                context.closePath()
                context.clip()

                squareImage.draw(in: circleRect)

                let roundedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()

                return roundedImage
            } else {
                let rect = CGRect(origin: .zero, size: self.size)
                let cornerRadius: CGFloat = 16

                UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
                guard UIGraphicsGetCurrentContext() != nil else {
                    return self
                }

                let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
                path.addClip()
                self.draw(in: rect)

                let roundedRectImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()

                return roundedRectImage
            }
        }
}

// 控制坐标
// Position control
private extension Int {
    
    func postion(_ isCircle: Bool = false) -> (Alignment, EdgeInsets) {
        
        let space = isCircle ? 0.0 : 4.0
        
        //0invalid
        //1 dial (top left)
        //2 dial (top middle)
        //3 dial (top right)
        //4 dial (middle left)
        //5 dial (middle middle)
        //55/10  dial (middle middle)
        //6 dial (middle right)
        //7 dial (bottom left)
        //8 dial (bottom middle)
        //9 dial (bottom right)
        switch self {
        case 1:
            return (.topLeading, EdgeInsets(top: space, leading: space, bottom: 0, trailing: 0))
        case 2:
            return (.top, EdgeInsets(top: space, leading: 0, bottom: 0, trailing: 0))
        case 3:
            return (.topTrailing, EdgeInsets(top: space, leading: 0, bottom: 0, trailing: space))
        case 4:
            return (.leading, EdgeInsets(top: 0, leading: space, bottom: 0, trailing: 0))
        case 5:
            return (.center, EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        case 6:
            return (.trailing, EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: space))
        case 7:
            return (.bottomLeading, EdgeInsets(top: 0, leading: space, bottom: space, trailing: 0))
        case 8:
            return (.bottom, EdgeInsets(top: 0, leading: 0, bottom: space, trailing: 0))
        case 9:
            return (.bottomTrailing, EdgeInsets(top: 0, leading: 0, bottom: space, trailing: space))
        case 55, 10:
            return (.center, EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        default:
            return (.center, EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
}
