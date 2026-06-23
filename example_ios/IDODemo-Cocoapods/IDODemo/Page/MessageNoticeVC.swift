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

// MARK: - Static Notice App Catalog

fileprivate struct StaticNoticeAppItem: Identifiable {
    let id = UUID()
    let icon: String
    let systemImage: String
    let name: String
    let associatedClass: IDOSetNoticeStatusModel
    private let getter: (IDOSetNoticeStatusModel) -> Bool
    private let setter: (IDOSetNoticeStatusModel, Bool) -> Void

    init(
        name: String,
        iconResource: String? = nil,
        systemImage: String = "app.fill",
        model: IDOSetNoticeStatusModel,
        getter: @escaping (IDOSetNoticeStatusModel) -> Bool,
        setter: @escaping (IDOSetNoticeStatusModel, Bool) -> Void
    ) {
        self.name = name
        self.systemImage = systemImage
        self.associatedClass = model
        self.getter = getter
        self.setter = setter
        if let iconResource, !iconResource.isEmpty {
            self.icon = Bundle.main.path(forResource: "imgs/\(iconResource)", ofType: ".jpg") ?? ""
        } else {
            self.icon = ""
        }
    }

    var isOpen: Bool {
        get { getter(associatedClass) }
        set { setter(associatedClass, newValue) }
    }
}

fileprivate enum StaticNoticeAppCatalog {
    private struct Spec {
        let name: String
        var iconResource: String? = nil
        let systemImage: String
        let isSystem: Bool
        let isSupported: (IDOFuncTableInterface) -> Bool
        let getter: (IDOSetNoticeStatusModel) -> Bool
        let setter: (IDOSetNoticeStatusModel, Bool) -> Void
    }

    private static let specs: [Spec] = [
        Spec(name: "短信", iconResource: "com.apple.MobileSMS_100", systemImage: "message.fill", isSystem: true,
             isSupported: { $0.reminderMessage }, getter: { $0.isOnSms }, setter: { $0.isOnSms = $1 }),
        Spec(name: "日历", iconResource: "com.apple.mobilecal_100", systemImage: "calendar", isSystem: true,
             isSupported: { $0.reminderCalendar }, getter: { $0.isOnCalendar }, setter: { $0.isOnCalendar = $1 }),
        Spec(name: "邮件", iconResource: "com.apple.mobilemail_100", systemImage: "envelope.fill", isSystem: true,
             isSupported: { $0.reminderEmail }, getter: { $0.isOnEmail }, setter: { $0.isOnEmail = $1 }),
        Spec(name: "未接电话", iconResource: "com.apple.missed.mobilephone_100", systemImage: "phone.fill", isSystem: true,
             isSupported: { $0.reminderMissedCall }, getter: { $0.isOnDidNotCall }, setter: { $0.isOnDidNotCall = $1 }),

        Spec(name: "微信", iconResource: "com.tencent.xin_100", systemImage: "message.fill", isSystem: false,
             isSupported: { $0.reminderWeixin }, getter: { $0.isOnWeChat }, setter: { $0.isOnWeChat = $1 }),
        Spec(name: "QQ", iconResource: "com.tencent.mqq_100", systemImage: "bubble.left.fill", isSystem: false,
             isSupported: { $0.reminderQq }, getter: { $0.isOnQq }, setter: { $0.isOnQq = $1 }),
        Spec(name: "Facebook", iconResource: "com.facebook.Facebook_100", systemImage: "f.circle.fill", isSystem: false,
             isSupported: { $0.reminderFacebook }, getter: { $0.isOnFaceBook }, setter: { $0.isOnFaceBook = $1 }),
        Spec(name: "X", iconResource: "com.atebits.Tweetie2_100", systemImage: "x.circle.fill", isSystem: false,
             isSupported: { $0.reminderTwitter }, getter: { $0.isOnTwitter }, setter: { $0.isOnTwitter = $1 }),
        Spec(name: "Instagram", iconResource: "com.burbn.instagram_100", systemImage: "camera.fill", isSystem: false,
             isSupported: { $0.reminderInstagram }, getter: { $0.isOnInstagram }, setter: { $0.isOnInstagram = $1 }),
        Spec(name: "WhatsApp", iconResource: "net.whatsapp.WhatsApp_100", systemImage: "phone.circle.fill", isSystem: false,
             isSupported: { $0.reminderWhatsapp }, getter: { $0.isOnWhatsapp }, setter: { $0.isOnWhatsapp = $1 }),
        Spec(name: "TikTok", iconResource: "com.zhiliaoapp.musically_100", systemImage: "music.note", isSystem: false,
             isSupported: { $0.reminderTiktok }, getter: { $0.isOnTikTok }, setter: { $0.isOnTikTok = $1 }),

        Spec(name: "淘宝", systemImage: "bag.fill", isSystem: false,
             isSupported: { $0.reminderTaobao }, getter: { $0.isOnTaobao }, setter: { $0.isOnTaobao = $1 }),
        Spec(name: "钉钉", systemImage: "person.3.fill", isSystem: false,
             isSupported: { $0.reminderDingding }, getter: { $0.isOnDingTalk }, setter: { $0.isOnDingTalk = $1 }),
        Spec(name: "支付宝", systemImage: "creditcard.fill", isSystem: false,
             isSupported: { $0.reminderAlipay }, getter: { $0.isOnAlipay }, setter: { $0.isOnAlipay = $1 }),
        Spec(name: "今日头条", systemImage: "newspaper.fill", isSystem: false,
             isSupported: { $0.reminderToutiao }, getter: { $0.isOnToutiao }, setter: { $0.isOnToutiao = $1 }),
        Spec(name: "天猫", systemImage: "cart.fill", isSystem: false,
             isSupported: { $0.reminderTmall }, getter: { $0.isOnTmail }, setter: { $0.isOnTmail = $1 }),
        Spec(name: "京东", systemImage: "shippingbox.fill", isSystem: false,
             isSupported: { $0.reminderJd }, getter: { $0.isOnJD }, setter: { $0.isOnJD = $1 }),
        Spec(name: "拼多多", systemImage: "gift.fill", isSystem: false,
             isSupported: { $0.reminderPinduoduo }, getter: { $0.isOnPinduoduo }, setter: { $0.isOnPinduoduo = $1 }),
        Spec(name: "百度", systemImage: "magnifyingglass.circle.fill", isSystem: false,
             isSupported: { $0.reminderBaidu }, getter: { $0.isOnBaidu }, setter: { $0.isOnBaidu = $1 }),
        Spec(name: "美团", systemImage: "fork.knife.circle.fill", isSystem: false,
             isSupported: { $0.reminderMeituan }, getter: { $0.isOnMeituan }, setter: { $0.isOnMeituan = $1 }),
        Spec(name: "饿了么", systemImage: "takeoutbag.and.cup.and.straw.fill", isSystem: false,
             isSupported: { $0.reminderEleme }, getter: { $0.isOnEleme }, setter: { $0.isOnEleme = $1 }),
        Spec(name: "抖音", systemImage: "play.rectangle.fill", isSystem: false,
             isSupported: { $0.reminderDouyin }, getter: { $0.isOnDouyin }, setter: { $0.isOnDouyin = $1 }),

        Spec(name: "Google Messages", systemImage: "message.circle.fill", isSystem: false,
             isSupported: { $0.reminderGoogleMessages }, getter: { $0.isOnGoogleMessages }, setter: { $0.isOnGoogleMessages = $1 }),
        Spec(name: "Apple Calendar", systemImage: "calendar.circle.fill", isSystem: false,
             isSupported: { $0.reminderAppleCalendar }, getter: { $0.isOnAppleCalendar }, setter: { $0.isOnAppleCalendar = $1 }),
        Spec(name: "Apple Mail", systemImage: "envelope.circle.fill", isSystem: false,
             isSupported: { $0.reminderAppleMail }, getter: { $0.isOnAppleMail }, setter: { $0.isOnAppleMail = $1 }),
        Spec(name: "Google Calendar", systemImage: "calendar.badge.clock", isSystem: false,
             isSupported: { $0.reminderGoogleCalendar }, getter: { $0.isOnGoogleCalendar }, setter: { $0.isOnGoogleCalendar = $1 }),
        Spec(name: "Health &U", systemImage: "heart.text.square.fill", isSystem: false,
             isSupported: { $0.reminderHealthU }, getter: { $0.isOnHealthU }, setter: { $0.isOnHealthU = $1 }),
        Spec(name: "Zalo", systemImage: "bubble.left.and.bubble.right.fill", isSystem: false,
             isSupported: { $0.reminderZalo }, getter: { $0.isOnZalo }, setter: { $0.isOnZalo = $1 }),
        Spec(name: "滴滴打车", systemImage: "car.fill", isSystem: false,
             isSupported: { $0.reminderDidiTaxi }, getter: { $0.isOnDidiTaxi }, setter: { $0.isOnDidiTaxi = $1 }),
        Spec(name: "Zoom Workplace", systemImage: "video.fill", isSystem: false,
             isSupported: { $0.reminderZoomWorkplace }, getter: { $0.isOnZoomWorkplace }, setter: { $0.isOnZoomWorkplace = $1 }),
        Spec(name: "BUZUD", systemImage: "bell.badge.fill", isSystem: false,
             isSupported: { $0.reminderBuzud }, getter: { $0.isOnBuzud }, setter: { $0.isOnBuzud = $1 }),
    ]

    static func buildApps(model: IDOSetNoticeStatusModel, funcTable: IDOFuncTableInterface) -> (system: [StaticNoticeAppItem], thirdParty: [StaticNoticeAppItem]) {
        var system: [StaticNoticeAppItem] = []
        var thirdParty: [StaticNoticeAppItem] = []
        for spec in specs where spec.isSupported(funcTable) {
            let item = StaticNoticeAppItem(
                name: spec.name,
                iconResource: spec.iconResource,
                systemImage: spec.systemImage,
                model: model,
                getter: spec.getter,
                setter: spec.setter
            )
            if spec.isSystem {
                system.append(item)
            } else {
                thirdParty.append(item)
            }
        }
        return (system, thirdParty)
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
    
    private struct NotificationSettingsView: View {
        @State private var statusModel: IDOSetNoticeStatusModel?
        
        @State private var systemApps = [StaticNoticeAppItem]()
        @State private var thirdPartyApps = [StaticNoticeAppItem]()
        
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
                    }
                .opacity(allSwitch ? 1 : 0.5)
                .disabled(!allSwitch)
                
                Section(header: Text("Third-party apps")) {
                    ForEach(thirdPartyApps.indices, id: \.self) { index in
                        appRow(index: index, section: 1)
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
                if !app.icon.isEmpty, let uiImage = UIImage(contentsOfFile: app.icon) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .cornerRadius(15)
                } else {
                    Image(systemName: app.systemImage)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
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
                
                let grouped = StaticNoticeAppCatalog.buildApps(model: statusModel, funcTable: sdk.funcTable)
                systemApps = grouped.system
                thirdPartyApps = grouped.thirdParty
                
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
