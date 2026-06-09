//
//  SdkFeatureTestVC.swift
//  IDODemo
//
//  临时独立联调页，对齐 protocol_lib/example SdkFeatureTestPage
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

/// 标准化 SDK 已落地功能联调（protocol_c_doc / SDK_FEATURE_PROGRESS）
class SdkFeatureTestVC: UIViewController {

    private var logBuffer = ""
    private var supportSyncTypesText = ""

    private lazy var buttonScrollView: UIScrollView = {
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = false
        v.alwaysBounceVertical = true
        return v
    }()

    private lazy var buttonStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 10
        v.alignment = .fill
        return v
    }()

    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        v.textColor = .darkGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233 / 255.0, green: 233 / 255.0, blue: 233 / 255.0, alpha: 1)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SDK Feature Test"
        view.backgroundColor = .white
        setupNavigationItems()
        setupLayout()
        setupActions()
        sdk.dataExchange.addExchange(delegate: self)
        refreshFuncTableSummary()
    }

    private func setupNavigationItems() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "Refresh",
                style: .plain,
                target: self,
                action: #selector(onRefreshFuncTable)
            ),
            UIBarButtonItem(
                title: "Clear",
                style: .plain,
                target: self,
                action: #selector(onClearLog)
            ),
        ]
    }

    private func setupLayout() {
        view.addSubview(buttonScrollView)
        view.addSubview(textConsole)
        buttonScrollView.addSubview(buttonStack)

        buttonScrollView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            } else {
                make.top.equalTo(8)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }

        buttonStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            make.width.equalTo(buttonScrollView.snp.width).offset(-24)
        }

        textConsole.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(buttonScrollView.snp.bottom).offset(8)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            } else {
                make.bottom.equalTo(-8)
            }
        }
    }

    private func setupActions() {
        appendSection(
            title: "基础获取类 Cmd",
            buttons: [
                ("2.61 设备状态", { [weak self] in self?.getDeviceStatus() }),
                ("15.104 左右手运动", { [weak self] in self?.getSportTypesWristSide() }),
                ("15.106 振动铃声(查询)", { [weak self] in self?.getVibrationRingtone() }),
            ]
        )
        appendSection(
            title: "V2 开关 GET/SET",
            buttons: [
                ("2.47 血氧 GET", { [weak self] in self?.getSpo2Switch() }),
                ("2.47 血氧 SET", { [weak self] in self?.setSpo2SwitchSample() }),
                ("2.47 血氧 回写", { [weak self] in self?.roundtripSpo2() }),
                ("2.46 压力 GET", { [weak self] in self?.getStressSwitch() }),
                ("2.46 压力 SET", { [weak self] in self?.setStressSwitchSample() }),
                ("2.46 压力 回写", { [weak self] in self?.roundtripStress() }),
                ("2.45 智能心率 GET", { [weak self] in self?.getSmartHrSwitch() }),
                ("2.45 智能心率 SET", { [weak self] in self?.setSmartHrSwitchSample() }),
                ("2.45 智能心率 回写", { [weak self] in self?.roundtripSmartHr() }),
            ]
        )
        appendSection(
            title: "V3 设置类 Cmd",
            buttons: [
                ("15.106 振动铃声(设置)", { [weak self] in self?.setVibrationRingtone() }),
                ("15.106 振动铃声 回写", { [weak self] in self?.roundtripVibrationRingtone() }),
            ]
        )
        appendSection(
            title: "数据交换 exchangeData",
            buttons: [
                ("15.20 运动小结", { [weak self] in self?.getActivitySummaryExchange() }),
                ("15.103 全量快照", { [weak self] in self?.getFullSnapshotExchange() }),
            ]
        )
        appendSection(
            title: "健康同步 syncData",
            buttons: [
                ("15.4.1 血氧", { [weak self] in self?.syncSpo2() }),
                ("15.4.2 压力", { [weak self] in self?.syncPressure() }),
            ]
        )
    }

    private func appendSection(title: String, buttons: [(String, () -> Void)]) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .gray
        buttonStack.addArrangedSubview(titleLabel)

        let row = UIStackView()
        row.axis = .vertical
        row.spacing = 8
        row.alignment = .fill
        buttons.forEach { title, action in
            let btn = UIButton.createNormalButton(title: title)
            btn.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            btn.addAction(UIAction { _ in action() }, for: .touchUpInside)
            row.addArrangedSubview(btn)
        }
        buttonStack.addArrangedSubview(row)
    }

    @objc private func onRefreshFuncTable() {
        clearLog()
        refreshFuncTableSummary()
    }

    @objc private func onClearLog() {
        clearLog()
        renderLog()
    }

    private func clearLog() {
        logBuffer = ""
    }

    private func log(_ msg: String) {
        logBuffer += msg + "\n"
        print("[SdkFeatureTest] \(msg)")
        renderLog()
    }

    private func renderLog() {
        textConsole.text = logBuffer.isEmpty ? "（无日志）" : logBuffer
        textConsole.scrollToBottom()
    }

    private func refreshFuncTableSummary() {
        let ft = sdk.funcTable
        sdk.syncData.getSupportSyncDataTypeList { [weak self] list in
            guard let self else { return }
            self.supportSyncTypesText = list.map { $0.syncDataType.description }.joined(separator: ", ")
            let summary = """
            【连接】\(sdk.state.isConnected ? "已连接" : "未连接")
            【V2 开关】spo2Get=\(ft.getSupportGetSpo2SwitchInfo) pressureGet=\(ft.getSupportGetPressureSwitchInfo) smartHrGet=\(ft.getSupportGetSmartHeartRate)
            【健康同步】spo2=\(ft.syncV3Spo2) pressure=\(ft.syncV3Pressure)
              血氧version兼容=\(ft.getSupportSyncSpo2UseVersionCompatible)
              压力version兼容=\(ft.getSupportSyncPressureUseVersionCompatible)
            【数据交换】syncV3ActivityExchangeData=\(ft.syncV3ActivityExchangeData)
              supportV3ActivityExchange=\(sdk.dataExchange.supportV3ActivityExchange)
            支持同步类型: \(self.supportSyncTypesText)
            """
            self.log(summary)
        }
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            SVProgressHUD.showError(withStatus: "未连接设备")
            log("错误：设备未连接")
            return false
        }
        return true
    }

    private func logCmdResult<T>(_ title: String, _ res: Result<T?, CmdError>) {
        switch res {
        case .success(let val):
            log("  code=0")
            if let model = val as? IDOBaseModel {
                let json = model.toJsonString() ?? "NULL"
                log("  json: \(Self.preview(json))")
            } else if let text = val as? String {
                log("  json: \(Self.preview(text))")
            } else if let val {
                log("  json: \(Self.preview("\(val)"))")
            } else {
                log("  json: NULL")
            }
            SVProgressHUD.showSuccess(withStatus: "成功")
        case .failure(let err):
            log("  code=\(err.code) msg=\(err.message ?? "")")
            SVProgressHUD.showError(withStatus: "失败 code=\(err.code)")
        }
    }

    private static func preview(_ text: String, limit: Int = 9800) -> String {
        guard text.count > limit else { return text }
        let end = text.index(text.startIndex, offsetBy: limit)
        return String(text[..<end]) + "..."
    }

    private func getDeviceStatus() {
        guard ensureConnected() else { return }
        log("--- 2.61 设备状态 (getDeviceStatusInfo) ---")
        log("  请求: {\"get_type\":1}")
        SVProgressHUD.show(withStatus: "2.61 设备状态")
        Cmds.getDeviceStatusInfo(getType: 1).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("2.61 设备状态", res)
        }
    }

    private func getSportTypesWristSide() {
        guard ensureConnected() else { return }
        log("--- 15.104 左右手运动类型 (getSportTypesRequiringWristSideSetting) ---")
        log("  请求: {}")
        SVProgressHUD.show(withStatus: "15.104 左右手运动")
        Cmds.getSportTypesRequiringWristSideSetting().send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("15.104 左右手运动", res)
        }
    }

    private static func switchValue(_ v: Int) -> Int { v == 1 ? 1 : 0 }

    private func spo2ModelToParam(_ model: IDOSpo2SwitchModel) -> IDOSpo2SwitchParamModel {
        IDOSpo2SwitchParamModel(
            onOff: Self.switchValue(model.onOff),
            startHour: model.startHour,
            startMinute: model.startMinute,
            endHour: model.endHour,
            endMinute: model.endMinute,
            lowSpo2OnOff: Self.switchValue(model.lowSpo2OnOff),
            lowSpo2Value: model.lowSpo2Value,
            notifyFlag: model.notifyFlag,
            measurementInterval: model.measurementInterval
        )
    }

    private func stressModelToParam(_ model: IDOStressSwitchModel) -> IDOStressSwitchParamModel {
        IDOStressSwitchParamModel(
            onOff: Self.switchValue(model.onOff),
            startHour: model.startHour,
            startMinute: model.startMinute,
            endHour: model.endHour,
            endMinute: model.endMinute,
            remindOnOff: Self.switchValue(model.remindOnOff),
            interval: model.interval,
            highThreshold: model.highThreshold,
            stressThreshold: model.stressThreshold,
            notifyFlag: model.notifyFlag,
            repeats: model.repeats,
            measurementInterval: model.measurementInterval
        )
    }

    private func smartHrModelToParam(_ model: IDOHeartRateModeSmartModel) -> IDOHeartRateModeSmartParamModel {
        IDOHeartRateModeSmartParamModel(
            mode: Self.switchValue(model.mode),
            notifyFlag: model.notifyFlag,
            highHeartMode: Self.switchValue(model.highHeartMode),
            lowHeartMode: Self.switchValue(model.lowHeartMode),
            highHeartValue: model.highHeartValue,
            lowHeartValue: model.lowHeartValue,
            startHour: model.startHour,
            startMinute: model.startMinute,
            endHour: model.endHour,
            endMinute: model.endMinute,
            measurementInterval: model.measurementInterval
        )
    }

    private func getVibrationRingtone() {
        guard ensureConnected() else { return }
        log("--- 15.106 振动铃声(查询) (deviceVibrationRingtone) ---")
        log("  请求: {\"operate\":1}")
        SVProgressHUD.show(withStatus: "15.106 振动铃声")
        Cmds.deviceVibrationRingtone().send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("15.106 振动铃声", res)
        }
    }

    private func setVibrationRingtone() {
        guard ensureConnected() else { return }
        let model = IDODeviceVibrationRingtoneModel(
            operate: 2,
            type: 3,
            vibrationIntensity: 2,
            alarmVolume: 5
        )
        log("--- 15.106 振动铃声(设置) ---")
        log("  请求: \(model.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "15.106 振动铃声(设置)")
        Cmds.deviceVibrationRingtone(model).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("15.106 振动铃声(设置)", res)
        }
    }

    private func roundtripVibrationRingtone() {
        guard ensureConnected() else { return }
        log("--- 15.106 振动铃声 GET→SET 回写 ---")
        SVProgressHUD.show(withStatus: "振动铃声回写...")
        Cmds.deviceVibrationRingtone().send { [weak self] getRes in
            guard let self else { return }
            switch getRes {
            case .success(let getModel):
                guard let getModel else {
                    SVProgressHUD.dismiss()
                    self.log("  GET 失败，中止")
                    SVProgressHUD.showError(withStatus: "GET 失败")
                    return
                }
                self.log("  GET: \(Self.preview(getModel.toJsonString() ?? "NULL"))")
                let type = getModel.type ?? 0
                if type == 0 {
                    SVProgressHUD.dismiss()
                    self.log("  type=0，跳过 SET")
                    SVProgressHUD.showInfo(withStatus: "无可设置子项")
                    return
                }
                let setModel = IDODeviceVibrationRingtoneModel(operate: 2, type: type)
                if type & 0x01 != 0 { setModel.vibrationIntensity = getModel.vibrationIntensity }
                if type & 0x02 != 0 { setModel.alarmVolume = getModel.alarmVolume }
                if type & 0x04 != 0 { setModel.callReminderVolume = getModel.callReminderVolume }
                self.log("  SET 请求: \(setModel.toJsonString() ?? "{}")")
                Cmds.deviceVibrationRingtone(setModel).send { setRes in
                    SVProgressHUD.dismiss()
                    self.logCmdResult("15.106 振动铃声 SET", setRes)
                }
            case .failure(let err):
                SVProgressHUD.dismiss()
                self.log("  GET code=\(err.code) msg=\(err.message ?? "")")
                SVProgressHUD.showError(withStatus: "GET 失败")
            }
        }
    }

    private func getSpo2Switch() {
        guard ensureConnected() else { return }
        log("--- 2.47 血氧开关(查询) (getSpo2Switch) ---")
        SVProgressHUD.show(withStatus: "2.47 血氧 GET")
        Cmds.getSpo2Switch().send { [weak self] res in
            SVProgressHUD.dismiss()
            if case .success(let model) = res, let model {
                self?.log("  measurement_interval=\(model.measurementInterval)")
            }
            self?.logCmdResult("2.47 血氧 GET", res)
        }
    }

    private func setSpo2SwitchSample() {
        guard ensureConnected() else { return }
        let param = IDOSpo2SwitchParamModel(
            onOff: 1,
            startHour: 0,
            startMinute: 0,
            endHour: 23,
            endMinute: 59,
            lowSpo2OnOff: 1,
            lowSpo2Value: 90,
            notifyFlag: 1,
            measurementInterval: 5
        )
        log("--- 2.47 血氧开关(设置) ---")
        log("  请求: \(param.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "2.47 血氧 SET")
        Cmds.setSpo2Switch(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("2.47 血氧 SET", res)
        }
    }

    private func roundtripSpo2() {
        guard ensureConnected() else { return }
        log("--- 2.47 血氧开关 GET→SET 回写 ---")
        SVProgressHUD.show(withStatus: "2.47 血氧回写")
        Cmds.getSpo2Switch().send { [weak self] getRes in
            guard let self else { return }
            switch getRes {
            case .success(let getModel):
                guard let getModel else {
                    SVProgressHUD.dismiss()
                    self.log("  GET 失败，中止")
                    SVProgressHUD.showError(withStatus: "GET 失败")
                    return
                }
                self.log("  GET: \(Self.preview(getModel.toJsonString() ?? "NULL"))")
                self.log("  measurement_interval=\(getModel.measurementInterval)")
                let param = self.spo2ModelToParam(getModel)
                self.log("  SET 请求: \(param.toJsonString() ?? "{}")")
                Cmds.setSpo2Switch(param).send { setRes in
                    SVProgressHUD.dismiss()
                    self.logCmdResult("2.47 血氧 SET", setRes)
                }
            case .failure(let err):
                SVProgressHUD.dismiss()
                self.log("  GET code=\(err.code) msg=\(err.message ?? "")")
                SVProgressHUD.showError(withStatus: "GET 失败")
            }
        }
    }

    private func getStressSwitch() {
        guard ensureConnected() else { return }
        log("--- 2.46 压力开关(查询) (getStressSwitch) ---")
        SVProgressHUD.show(withStatus: "2.46 压力 GET")
        Cmds.getStressSwitch().send { [weak self] res in
            SVProgressHUD.dismiss()
            if case .success(let model) = res, let model {
                self?.log("  measurement_interval=\(model.measurementInterval)")
            }
            self?.logCmdResult("2.46 压力 GET", res)
        }
    }

    private func setStressSwitchSample() {
        guard ensureConnected() else { return }
        let param = IDOStressSwitchParamModel(
            onOff: 1,
            startHour: 0,
            startMinute: 0,
            endHour: 23,
            endMinute: 59,
            remindOnOff: 1,
            interval: 60,
            highThreshold: 80,
            stressThreshold: 80,
            notifyFlag: 1,
            repeats: [],
            measurementInterval: 5
        )
        log("--- 2.46 压力开关(设置) ---")
        log("  请求: \(param.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "2.46 压力 SET")
        Cmds.setStressSwitch(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("2.46 压力 SET", res)
        }
    }

    private func roundtripStress() {
        guard ensureConnected() else { return }
        log("--- 2.46 压力开关 GET→SET 回写 ---")
        SVProgressHUD.show(withStatus: "2.46 压力回写")
        Cmds.getStressSwitch().send { [weak self] getRes in
            guard let self else { return }
            switch getRes {
            case .success(let getModel):
                guard let getModel else {
                    SVProgressHUD.dismiss()
                    self.log("  GET 失败，中止")
                    SVProgressHUD.showError(withStatus: "GET 失败")
                    return
                }
                self.log("  GET: \(Self.preview(getModel.toJsonString() ?? "NULL"))")
                self.log("  measurement_interval=\(getModel.measurementInterval)")
                let param = self.stressModelToParam(getModel)
                self.log("  SET 请求: \(param.toJsonString() ?? "{}")")
                Cmds.setStressSwitch(param).send { setRes in
                    SVProgressHUD.dismiss()
                    self.logCmdResult("2.46 压力 SET", setRes)
                }
            case .failure(let err):
                SVProgressHUD.dismiss()
                self.log("  GET code=\(err.code) msg=\(err.message ?? "")")
                SVProgressHUD.showError(withStatus: "GET 失败")
            }
        }
    }

    private func getSmartHrSwitch() {
        guard ensureConnected() else { return }
        log("--- 2.45 智能心率(查询) (getSmartHeartRateMode) ---")
        SVProgressHUD.show(withStatus: "2.45 智能心率 GET")
        Cmds.getSmartHeartRateMode().send { [weak self] res in
            SVProgressHUD.dismiss()
            if case .success(let model) = res, let model {
                self?.log("  measurement_interval=\(model.measurementInterval)")
            }
            self?.logCmdResult("2.45 智能心率 GET", res)
        }
    }

    private func setSmartHrSwitchSample() {
        guard ensureConnected() else { return }
        let param = IDOHeartRateModeSmartParamModel(
            mode: 1,
            notifyFlag: 1,
            highHeartMode: 1,
            lowHeartMode: 1,
            highHeartValue: 100,
            lowHeartValue: 60,
            startHour: 0,
            startMinute: 0,
            endHour: 23,
            endMinute: 59,
            measurementInterval: 300
        )
        log("--- 2.45 智能心率(设置) ---")
        log("  请求: \(param.toJsonString() ?? "{}")")
        SVProgressHUD.show(withStatus: "2.45 智能心率 SET")
        Cmds.setHeartRateModeSmart(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            self?.logCmdResult("2.45 智能心率 SET", res)
        }
    }

    private func roundtripSmartHr() {
        guard ensureConnected() else { return }
        log("--- 2.45 智能心率 GET→SET 回写 ---")
        SVProgressHUD.show(withStatus: "2.45 智能心率回写")
        Cmds.getSmartHeartRateMode().send { [weak self] getRes in
            guard let self else { return }
            switch getRes {
            case .success(let getModel):
                guard let getModel else {
                    SVProgressHUD.dismiss()
                    self.log("  GET 失败，中止")
                    SVProgressHUD.showError(withStatus: "GET 失败")
                    return
                }
                self.log("  GET: \(Self.preview(getModel.toJsonString() ?? "NULL"))")
                self.log("  measurement_interval=\(getModel.measurementInterval)")
                let param = self.smartHrModelToParam(getModel)
                self.log("  SET 请求: \(param.toJsonString() ?? "{}")")
                Cmds.setHeartRateModeSmart(param).send { setRes in
                    SVProgressHUD.dismiss()
                    self.logCmdResult("2.45 智能心率 SET", setRes)
                }
            case .failure(let err):
                SVProgressHUD.dismiss()
                self.log("  GET code=\(err.code) msg=\(err.message ?? "")")
                SVProgressHUD.showError(withStatus: "GET 失败")
            }
        }
    }

    private func getActivitySummaryExchange() {
        guard ensureConnected() else { return }
        guard sdk.dataExchange.supportV3ActivityExchange else {
            log("跳过：不支持 V3 多运动数据交换")
            SVProgressHUD.showInfo(withStatus: "不支持数据交换")
            return
        }
        log("--- 15.20 运动小结 exchangeData.getLastActivityData() ---")
        SVProgressHUD.show(withStatus: "获取运动小结...")
        sdk.dataExchange.getLastActivityData()
        SVProgressHUD.dismiss()
        log("getLastActivityData 已触发（详情见 exchangeData 回调）")
        SVProgressHUD.showSuccess(withStatus: "已触发")
    }

    private func getFullSnapshotExchange() {
        guard ensureConnected() else { return }
        log("--- 15.103 全量快照 exchangeData.getActivityExchangeFullSnapshot() ---")
        SVProgressHUD.show(withStatus: "全量快照...")
        sdk.dataExchange.getActivityExchangeFullSnapshot { [weak self] json in
            SVProgressHUD.dismiss()
            guard let self else { return }
            if let json, !json.isEmpty {
                self.log("json: \(Self.preview(json))")
                SVProgressHUD.showSuccess(withStatus: "成功")
            } else {
                self.log("返回为空或失败")
                SVProgressHUD.showError(withStatus: "失败")
            }
        }
    }

    private func syncSpo2() {
        guard ensureConnected() else { return }
        guard sdk.funcTable.syncV3Spo2 else {
            log("跳过：syncV3Spo2=false")
            SVProgressHUD.showInfo(withStatus: "不支持 V3 血氧")
            return
        }
        log("--- 15.4.1 同步血氧 ---")
        SVProgressHUD.show(withStatus: "同步血氧...")
        let types = [IDOSyncDataTypeClass(type: .bloodOxygen)]
        sdk.syncData.startSync(types: types, funcData: { [weak self] type, json, errorCode in
            guard type == .bloodOxygen else { return }
            self?.log("血氧 errorCode=\(errorCode)")
            if errorCode == 0, !json.isEmpty {
                self?.log("  payload: \(Self.preview(json))")
            }
        }, funcCompleted: { [weak self] errorCode in
            SVProgressHUD.dismiss()
            self?.log("血氧完成 errorCode=\(errorCode)")
            if errorCode == 0 {
                SVProgressHUD.showSuccess(withStatus: "完成")
            } else {
                SVProgressHUD.showError(withStatus: "失败 \(errorCode)")
            }
        })
    }

    private func syncPressure() {
        guard ensureConnected() else { return }
        guard sdk.funcTable.syncV3Pressure else {
            log("跳过：syncV3Pressure=false")
            SVProgressHUD.showInfo(withStatus: "不支持 V3 压力")
            return
        }
        log("--- 15.4.2 同步压力 ---")
        SVProgressHUD.show(withStatus: "同步压力...")
        let types = [IDOSyncDataTypeClass(type: .pressure)]
        sdk.syncData.startSync(types: types, funcData: { [weak self] type, json, errorCode in
            guard type == .pressure else { return }
            self?.log("压力 errorCode=\(errorCode)")
            if errorCode == 0, !json.isEmpty {
                self?.log("  payload: \(Self.preview(json))")
            }
        }, funcCompleted: { [weak self] errorCode in
            SVProgressHUD.dismiss()
            self?.log("压力完成 errorCode=\(errorCode)")
            if errorCode == 0 {
                SVProgressHUD.showSuccess(withStatus: "完成")
            } else {
                SVProgressHUD.showError(withStatus: "失败 \(errorCode)")
            }
        })
    }
}

extension SdkFeatureTestVC: IDOExchangeDataOCDelegate {

    func appListenBleExec(model: NSObject) {
        // 本页仅联调 app 侧主动请求，ble 发起运动不在此处理
    }

    func appListenAppExec(model: NSObject) {
        if let obj = model as? IDOAppActivityDataV3ExchangeModel {
            log("[exchangeData] 15.20 运动小结 step=\(obj.step) distance=\(obj.distance)")
            log("  bodyAge=\(obj.bodyAge) swimmingPoolDistance=\(obj.swimmingPoolDistance) actType=\(obj.actType) gpsStatus=\(obj.gpsStatus)")
        } else {
            log("[exchangeData] model=\(type(of: model))")
        }
    }

    func exchangeV2Data(model: IDOExchangeV2Model) {
        log("[exchangeV2Data] \(model)")
    }

    func exchangeV3Data(model: IDOExchangeV3Model) {
        log("[exchangeV3Data] \(model)")
    }
}
