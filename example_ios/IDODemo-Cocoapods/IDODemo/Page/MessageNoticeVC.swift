//
//  MessageNoticeVC.swift
//  Runner
//
//  Created by hc on 2024/12/20.
//

import UIKit
import SwiftUI
import Foundation

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

/**
 消息通知根据不同设备，分为静态和动态（二选一）：
 
 一、动态消息通知
 可指定应用icon，对应app的信息（如：包名、ID、图标地址）
 
 
 
 二、静态消息通知（旧设备）：
 固定的一些常用app
 
 */
class MessageNoticeVC: UIViewController {
    override func viewDidLoad() {
        self.title = "Message notice"
        let childVC = sdk.funcTable.reminderMessageIcon ? DynamicMessageNoticeVC() : StaticMessageNoticeVC()
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        childVC.didMove(toParent: self)
    }
    
    deinit {
        print("deinit - MessageNoticeVC")
    }
}

// MARK: - StaticMessageNoticeVC

// 静态消息通知
fileprivate class StaticMessageNoticeVC: UIViewController {
    override func viewDidLoad() {
        let swiftUIView = NotificationSettingsView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
        NotificationCenter.default.addObserver(self, selector: #selector(popToUIKitView), name: Notification.Name("popToUIKitView"), object: nil)
        
        if sdk.funcTable.reminderAncs {
            // 打开bt配对
            let obj = IDOSetNoticeStatusModel.createAllOffModel()
            obj.notifySwitch = .bleOn
            Cmds.setNoticeStatus(obj).send { _ in }
        }
    }
            
    @objc func popToUIKitView() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("deinit - StaticMessageNoticeVC")
    }
    
    private struct AppItem: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        var isOpen: Bool {
            get {
                switch name {
                case "短信":
                    return associatedClass.isOnSms
                case "日历":
                    return associatedClass.isOnCalendar
                case "邮件":
                    return associatedClass.isOnEmail
                case "未接电话":
                    return associatedClass.isOnDidNotCall
                case "微信":
                    return associatedClass.isOnWeChat
                case "QQ":
                    return associatedClass.isOnQq
                case "Facebook":
                    return associatedClass.isOnFaceBook
                case "X":
                    return associatedClass.isOnTwitter
                case "Instagram":
                    return associatedClass.isOnInstagram
                case "WhatsApp":
                    return associatedClass.isOnWhatsapp
                case "TikTok":
                    return associatedClass.isOnTikTok
                default:
                    return false
                }
                
            }
            set {
                switch name {
                case "短信":
                    associatedClass.isOnSms = newValue
                case "日历":
                    associatedClass.isOnCalendar = newValue
                case "邮件":
                    associatedClass.isOnEmail = newValue
                case "未接电话":
                    associatedClass.isOnDidNotCall = newValue
                case "微信":
                    associatedClass.isOnWeChat = newValue
                case "QQ":
                    associatedClass.isOnQq = newValue
                case "Facebook":
                    associatedClass.isOnFaceBook = newValue
                case "X":
                    associatedClass.isOnTwitter = newValue
                case "Instagram":
                    associatedClass.isOnInstagram = newValue
                case "WhatsApp":
                    associatedClass.isOnWhatsapp = newValue
                case "TikTok":
                    associatedClass.isOnTikTok = newValue
                default: break
                }
                
            }
        }
        let associatedClass: IDOSetNoticeStatusModel
    }
    
    private struct NotificationSettingsView: View {
        @State private var statusModel: IDOSetNoticeStatusModel?
        
        @State private var systemApps = [AppItem]()
        @State private var thirdPartyApps = [AppItem]()
        
        @State private var selectedApp: AppItem?
        @State private var selectedSection: Int?
        @State private var isOnCallSwitch = false
        @State private var allSwitch = false
        
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            List {
                Section(header: Text(L10n.systemNotifyTips)) {
                    HStack {
                        Image(systemName: "settings")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text(L10n.mainSwitch)
                            .font(.system(size: 17))
                        
                        Spacer()
                        
                        UISwitchWrapper(isOn: $allSwitch){ newValue in
                            updateMsgSwitch { rs in
                                if (!rs){
                                    allSwitch = !allSwitch
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(L10n.callRemind)) {
                    HStack {
                        Image(systemName: "phone")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text(L10n.callRemind)
                            .font(.system(size: 17))
                            .foregroundColor(allSwitch ? .black : .gray)
                        
                        Spacer()
                        
                        UISwitchWrapper(isOn: $isOnCallSwitch){ newValue in
                            updateMsgSwitch{ rs in
                                if (!rs){
                                    isOnCallSwitch = !isOnCallSwitch
                                }
                            }
                        }
                    }
                    .opacity(allSwitch ? 1 : 0.5)
                    .disabled(!allSwitch)
                    .padding(.vertical, 8)
                }
                
                ForEach(systemApps.indices, id: \.self) { index in
                        appRow(index: index, section: 0)
                            .onTapGesture {
                                self.selectedApp = self.systemApps[index]
                                self.selectedSection = 0
                            }
                    }
                .opacity(allSwitch ? 1 : 0.5)
                .disabled(!allSwitch)
                
                Section {
                    ForEach(thirdPartyApps.indices, id: \.self) { index in
                        appRow(index: index, section: 1)
                            .onTapGesture {
                                self.selectedApp = self.thirdPartyApps[index]
                                self.selectedSection = 1
                            }
                    }
                }
                .opacity(allSwitch ? 1 : 0.5)
                .disabled(!allSwitch)
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                Task {
                    SVProgressHUD.show()
                    if await fetchData() {
                        await SVProgressHUD.dismiss()
                    }else {
                        SVProgressHUD.showError(withStatus: L10n.fetchFail)
                        presentationMode.wrappedValue.dismiss()
                        NotificationCenter.default.post(name: Notification.Name("popToUIKitView"), object: nil)
                    }
                }
            }
        }
        
        func appRow(index: Int, section: Int) -> some View {
            let app = section == 0 ? systemApps[index] : thirdPartyApps[index]
            let isOpenBinding = Binding(
                get: { section == 0 ? systemApps[index].isOpen : thirdPartyApps[index].isOpen },
                set: { newValue in
                    if section == 0 {
                        systemApps[index].isOpen = newValue
                    } else {
                        thirdPartyApps[index].isOpen = newValue
                    }
                }
            )

            return HStack {
                if let uiImage = UIImage(contentsOfFile: app.icon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                }
                
                Text(app.name)
                    .font(.system(size: 17))
                    .foregroundColor(allSwitch ? .black : .gray)
                
                Spacer()
                
                UISwitchWrapper(isOn: isOpenBinding) { newValue in
                    let previousValue = isOpenBinding.wrappedValue
                    isOpenBinding.wrappedValue = newValue
                    updateMsgSwitch { success in
                        if !success {
                            DispatchQueue.main.async {
                                isOpenBinding.wrappedValue = previousValue
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        
        func fetchData() async -> Bool  {
            do {
                let res = try await withCheckedThrowingContinuation { continuation in
                    Cmds.getNoticeStatus().send { res in
                        if case .success(let val) = res {
                            continuation.resume(returning: val)
                        } else if case .failure(let err) = res {
                            let error = NSError(domain: "getNoticeMessageState", code: err.code, userInfo: [NSLocalizedDescriptionKey: err.message ?? "fail"])
                            continuation.resume(throwing: error)
                        }
                    }
                }
                statusModel = res
                systemApps.removeAll()
                thirdPartyApps.removeAll()
                isOnCallSwitch = false
                allSwitch = false
                
                guard let statusModel = res else {
                    print("Error: statusModel is nil")
                    return false
                }
                
                isOnCallSwitch = statusModel.callSwitch == .on
                allSwitch = statusModel.msgAllSwitch == .on
                
                systemApps.append(contentsOf: [
                    AppItem(icon: i("com.apple.MobileSMS_100"), name: "短信", associatedClass: statusModel),
                    AppItem(icon: i("com.apple.mobilecal_100"), name: "日历", associatedClass: statusModel),
                    AppItem(icon: i("com.apple.mobilemail_100"), name: "邮件", associatedClass: statusModel),
                    AppItem(icon: i("com.apple.missed.mobilephone_100"), name: "未接电话", associatedClass: statusModel),
                ])
                
                thirdPartyApps.append(contentsOf: [
                    AppItem(icon: i("com.tencent.xin_100"), name: "微信" , associatedClass: statusModel),
                    AppItem(icon: i("com.tencent.mqq_100"), name: "QQ" , associatedClass: statusModel),
                    AppItem(icon: i("com.facebook.Facebook_100"), name: "Facebook" , associatedClass: statusModel),
                    AppItem(icon: i("com.atebits.Tweetie2_100"), name: "X", associatedClass: statusModel),
                    AppItem(icon: i("com.burbn.instagram_100"), name: "Instagram", associatedClass: statusModel),
                    AppItem(icon: i("net.whatsapp.WhatsApp_100"), name: "WhatsApp", associatedClass: statusModel),
                    AppItem(icon: i("com.zhiliaoapp.musically_100"), name: "TikTok", associatedClass: statusModel)
                    /*
                     ...
                     添加更多, AppItem里也要同步修改
                    */
                ])
                
                return true
            }catch {
                print("Error: \(error)")
                return false
            }
        }
        
        func updateMsgSwitch(completion: @escaping (Bool) -> Void) {
            SVProgressHUD.show()
            statusModel?.callSwitch = isOnCallSwitch ? .on : .off
            statusModel?.msgAllSwitch = allSwitch ? .on : .off
            statusModel?.notifySwitch = .settingSubSwitch
            Cmds.setNoticeStatus(statusModel!).send { res in
                if case .success(let val) = res {
                    if val?.errCode == 0 {
                        SVProgressHUD.showSuccess(withStatus: nil)
                        completion(true)
                    } else {
                        SVProgressHUD.showError(withStatus: nil)
                        completion(false)
                    }
                } else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: err.message)
                    completion(false)
                }
            }
        }
        
        func i(_ iconName: String) -> String {
            let aPath = Bundle.main.path(forResource: "imgs/\(iconName)", ofType: ".jpg") ?? ""
            return aPath
        }
    }
}

// MARK: - DynamicMessageNoticeVC  动态消息通知

// 动态消息通知
fileprivate class DynamicMessageNoticeVC: UIViewController {
    override func viewDidLoad() {
        let swiftUIView = NotificationSettingsView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParent: self)
        NotificationCenter.default.addObserver(self, selector: #selector(popToUIKitView), name: Notification.Name("popToUIKitView"), object: nil)
        
        if sdk.funcTable.reminderAncs {
            // 打开bt配对
            let obj = IDOSetNoticeStatusModel.createAllOffModel()
            obj.notifySwitch = .bleOn
            Cmds.setNoticeStatus(obj).send { _ in }
        }
    }
            
    @objc func popToUIKitView() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        print("deinit - DynamicMessageNoticeVC")
    }
    
    private enum NotificationStatus: String {
        case allowed = "allowed"
        case silent = "silent"
        case disabled = "disabled"
    }

    private struct AppItem: Identifiable {
        let id = UUID()
        let icon: String
        let name: String
        var notificationStatus: NotificationStatus
        let evtType: Int64
    }
    
    private struct NotificationSettingsView: View {
        private var items = [IDOAppIconItemModel]()
        
        @State private var systemApps = [AppItem]()
        @State private var thirdPartyApps = [AppItem]()
        
        @State private var showingActionSheet = false
        @State private var selectedApp: AppItem?
        @State private var selectedSection: Int?
        @State private var isOnCallSwitch = false
        @State private var allSwitch = false
        
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            List {
                Section(header: Text(L10n.systemNotifyTips)) {
                    HStack {
                        Image(systemName: "settings")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text(L10n.mainSwitch)
                            .font(.system(size: 17))
                        
                        Spacer()
                        
                        UISwitchWrapper(isOn: $allSwitch){ newValue in
                            updateMsgSwitch { rs in
                                if (!rs){
                                    allSwitch = !allSwitch
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text(L10n.callRemind)) {
                    HStack {
                        Image(systemName: "phone")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: 30, height: 30)
                        
                        Text(L10n.callRemind)
                            .font(.system(size: 17))
                            .foregroundColor(allSwitch ? .black : .gray)
                        
                        Spacer()
                        
                        UISwitchWrapper(isOn: $isOnCallSwitch){ newValue in
                            updateCallSwitch{ rs in
                                if (!rs){
                                    isOnCallSwitch = !isOnCallSwitch
                                }
                            }
                        }
                    }
                    .opacity(allSwitch ? 1 : 0.5)
                    .disabled(!allSwitch)
                    .padding(.vertical, 8)
                }
                
                Section() {
                    ForEach(systemApps.indices, id: \.self) { index in
                        appRow(app: systemApps[index])
                            .onTapGesture {
                                self.selectedApp = self.systemApps[index]
                                self.selectedSection = 0
                                self.showingActionSheet = true
                            }
                    }
                }
                .opacity(allSwitch ? 1 : 0.5)
                .disabled(!allSwitch)
                
                Section() {
                    ForEach(thirdPartyApps.indices, id: \.self) { index in
                        appRow(app: thirdPartyApps[index])
                            .onTapGesture {
                                self.selectedApp = self.thirdPartyApps[index]
                                self.selectedSection = 1
                                self.showingActionSheet = true
                            }
                    }
                }
                .opacity(allSwitch ? 1 : 0.5)
                .disabled(!allSwitch)
            }
            .listStyle(GroupedListStyle())
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text(L10n.notifySettings),
                    message: Text(selectedApp?.name ?? ""),
                    buttons: [
                        .default(Text(L10n.notifyAllowed)) {
                            self.updateNotificationStatus(.allowed)
                        },
                        .default(Text(L10n.notifySilent)) {
                            self.updateNotificationStatus(.silent)
                        },
                        .default(Text(L10n.notifyDisabled)) {
                            self.updateNotificationStatus(.disabled)
                        },
                        .cancel(Text(L10n.cancel))
                    ]
                )
            }
            .onAppear {
                Task {
                    SVProgressHUD.show()
                    if await fetchData() {
                        await SVProgressHUD.dismiss()
                    }else {
                        SVProgressHUD.showError(withStatus: L10n.fetchFail)
                        presentationMode.wrappedValue.dismiss()
                        NotificationCenter.default.post(name: Notification.Name("popToUIKitView"), object: nil)
                    }
                }
            }
        }
        
        func appRow(app: AppItem) -> some View {
            HStack {
                if let uiImage = UIImage(contentsOfFile: app.icon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                }
                
                Text(app.name)
                    .font(.system(size: 17))
                    .foregroundColor(allSwitch ? .black : .gray)
                
                Spacer()
                
                Text(app.notificationStatus.rawValue)
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
            }
            .padding(.vertical, 8)
        }
        
        func updateNotificationStatus(_ status: NotificationStatus) {
            guard let section = selectedSection, let app = selectedApp else { return }
            
            if section == 0 {
                if let index = systemApps.firstIndex(where: { $0.id == app.id }) {
                    let orignalStatus = systemApps[index].notificationStatus
                    systemApps[index].notificationStatus = status
                    updateMsgSwitch { rs in
                        if (!rs) {
                            systemApps[index].notificationStatus = orignalStatus
                        }
                    }
                }
            } else {
                if let index = thirdPartyApps.firstIndex(where: { $0.id == app.id }) {
                    let orignalStatus = thirdPartyApps[index].notificationStatus
                    thirdPartyApps[index].notificationStatus = status
                    updateMsgSwitch { rs in
                        if (!rs) {
                            thirdPartyApps[index].notificationStatus = orignalStatus
                        }
                    }
                }
            }
        }
        
        
        func fetchData() async -> Bool  {
            do {
                
                // 1、获取来电提醒开关
                let callSwitch = try await withCheckedThrowingContinuation { continuation in
                    Cmds.getNoticeStatus().send { res in
                        if case .success(let val) = res {
                            continuation.resume(returning: val?.callSwitch == .on)
                        } else if case .failure(let err) = res {
                            let error = NSError(domain: "getNoticeMessageState", code: err.code, userInfo: [NSLocalizedDescriptionKey: err.message ?? "fail"])
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                // 2、获取所有应用图标、名字、包名 及分配evtType (固件分配的ID)，执行此接口需要等待过程，updating这个状态说明在更新中，建议添加loading或者updating为false才进入消息图标列表
                let appList = try await withCheckedThrowingContinuation { continuation in
                    sdk.messageIcon.firstGetAppInfo(force: false) { list in
                        if list.count > 0 {
                            continuation.resume(returning: list)
                        } else {
                            continuation.resume(throwing: NSError(domain: "firstGetAppInfo", code: -1))
                        }
                    }
                }
                
                // 3、获取开关状态 operat=3
                let msgState = try await withCheckedThrowingContinuation { continuation in
                    let param = IDONoticeMessageStateParamModel(operat: 3, allOnOff: 0, allSendNum: 0, nowSendIndex: 0, items: [])
                    Cmds.setNoticeMessageState(param).send { res in
                        if case .success(let val) = res {
                            continuation.resume(returning: val)
                        } else if case .failure(let err) = res {
                            let error = NSError(domain: "getNoticeMessageState", code: err.code, userInfo: [NSLocalizedDescriptionKey: err.message ?? "fail"])
                            continuation.resume(throwing: error)
                        }
                    }
                }
                
                systemApps.removeAll()
                thirdPartyApps.removeAll()
                isOnCallSwitch = callSwitch
                allSwitch = msgState?.allOnOff == 1
                for obj in appList {
                    if obj.packName == "com.apple.mobilephone" {
                        // 来电提醒需要特殊处理，使用别的接口
                        continue
                    }
                    var status = NotificationStatus.allowed
                    let objState = msgState?.items?.first(where: { $0.evtType == obj.evtType })
                    if objState?.notifyState == 2 {
                        status = .silent
                    } else if objState?.notifyState == 3 {
                        status = .disabled
                    }
                    let appItem = AppItem(icon: obj.iconLocalPathBig ?? "", name: obj.appName, notificationStatus: status, evtType: obj.evtType)
                    if obj.packName.hasPrefix("com.apple.") {
                        systemApps.append(appItem)
                    }else {
                        thirdPartyApps.append(appItem)
                    }
                    print("packName: \(obj.packName) evtType: \(obj.evtType)")
                }
                return true
            }catch {
                print("Error: \(error)")
                return false
            }
        }
        
        // 修改来电通知开关
        func updateCallSwitch(completion: @escaping (Bool) -> Void) {
            let param = IDOSetNoticeStatusModel.createDefaultModel()
            param.callSwitch = (isOnCallSwitch ? .on : .off)
            SVProgressHUD.show()
            Cmds.setNoticeStatus(param).send { res in
                if case .success(let val) = res {
                    if val?.errCode == 0 {
                        SVProgressHUD.showSuccess(withStatus: nil)
                        completion(true)
                    } else {
                        SVProgressHUD.showError(withStatus: nil)
                        completion(false)
                    }
                } else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: err.message)
                    completion(false)
                }
            }
        }
        
        func updateMsgSwitch(completion: @escaping (Bool) -> Void) {
            // !!!: 注意，当列表超过100个时，要分批发送
            SVProgressHUD.show()
            let allOnOff = allSwitch ? 1 : 0
            // 修改 operat=2
            let param = IDONoticeMessageStateParamModel(operat: 2, allOnOff: allOnOff, allSendNum: 0, nowSendIndex: 0, items: makeItems())
            Cmds.setNoticeMessageState(param).send { res in
                if case .success(let val) = res {
                    if val?.errCode == 0 {
                        SVProgressHUD.showSuccess(withStatus: nil)
                        completion(true)
                    } else {
                        SVProgressHUD.showError(withStatus: nil)
                        completion(false)
                    }
                } else if case .failure(let err) = res {
                    SVProgressHUD.showError(withStatus: err.message)
                    completion(false)
                }
            }
        }
        
        func makeItems() -> [IDONoticeMessageStateItem] {
            func _map(_ items : [AppItem]) -> [IDONoticeMessageStateItem] {
                return items.map { o in
                    var notifyState = 3
                    if (o.notificationStatus == .allowed) {
                        notifyState = 1
                    }else if (o.notificationStatus == .silent) {
                        notifyState = 2
                    }
                    return IDONoticeMessageStateItem(evtType: Int(o.evtType), notifyState: notifyState, picFlag: 1)
                }
            }
            let sysApps = _map(systemApps)
            let thirdApps = _map(thirdPartyApps)
            return sysApps + thirdApps
        }
    }
}


// MARK: - UISwitchWrapper 兼容ios13

fileprivate struct UISwitchWrapper: UIViewRepresentable {
    
    @Binding var isOn: Bool
    var onValueChanged: ((Bool) -> Void)?
    
    func updateUIView(_ uiView: UISwitch, context: Context) {
        uiView.isOn = isOn
    }
    
    func makeUIView(context: Context) -> UISwitch {
        let switchView = UISwitch()
        switchView.isOn = isOn
        switchView.addTarget(context.coordinator, action: #selector(Coordinator.switchValueChanged), for: .valueChanged)
        return switchView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: UISwitchWrapper
        
        init(_ parent: UISwitchWrapper) {
            self.parent = parent
        }
        
        @objc func switchValueChanged(_ sender: UISwitch) {
            parent.isOn = sender.isOn
            parent.onValueChanged?(sender.isOn)
        }
    }
}
