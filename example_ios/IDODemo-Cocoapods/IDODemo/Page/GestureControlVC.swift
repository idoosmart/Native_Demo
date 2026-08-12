//
//  GestureControlVC.swift
//  IDODemo
//
//  15.82 手势控制联调页（对齐 PulseBand GestureActivity）：
//  进页 03→02；动态能力树；功能多选一；同功能子功能手势互斥；设置走 01。
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

class GestureControlVC: UIViewController {

    private var supportModel: IDOGestureControlModel?
    private var currentModel: IDOGestureControlModel?
    private var awaitCurrentAfterSupport = false
    private var suppressFuncSwitchCallback = false
    private var funcUis: [FuncUi] = []

    private final class SubUi {
        let subType: Int
        let allowedGestures: [Int]
        let label: UILabel
        let button: UIButton
        var selectedGesture: Int
        var options: [Int] = []

        init(subType: Int, allowedGestures: [Int], label: UILabel, button: UIButton, selectedGesture: Int) {
            self.subType = subType
            self.allowedGestures = allowedGestures
            self.label = label
            self.button = button
            self.selectedGesture = selectedGesture
            self.options = allowedGestures
        }
    }

    private final class FuncUi {
        let functionType: Int
        let uiSwitch: UISwitch
        let titleLabel: UILabel
        let subs: [SubUi]

        init(functionType: Int, uiSwitch: UISwitch, titleLabel: UILabel, subs: [SubUi]) {
            self.functionType = functionType
            self.uiSwitch = uiSwitch
            self.titleLabel = titleLabel
            self.subs = subs
        }
    }

    private lazy var scrollView = UIScrollView()
    private lazy var contentStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 10
        v.alignment = .fill
        return v
    }()

    private lazy var lblStatus: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 15)
        v.numberOfLines = 0
        v.text = "状态: 空闲"
        return v
    }()

    private lazy var lblSummary: UILabel = {
        let v = UILabel()
        v.font = .boldSystemFont(ofSize: 13)
        v.numberOfLines = 0
        v.text = "流程: 支持项(03) → 当前配置(02) → 设置(01)"
        return v
    }()

    private lazy var switchMaster: UISwitch = {
        let v = UISwitch()
        v.addTarget(self, action: #selector(onMasterChanged), for: .valueChanged)
        return v
    }()

    private lazy var treeStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 8
        v.alignment = .fill
        return v
    }()

    private lazy var textResult: UITextView = {
        let v = UITextView()
        v.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        v.isEditable = false
        v.backgroundColor = UIColor(white: 0.95, alpha: 1)
        v.text = "（暂无）"
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Word.gestureControl
        view.backgroundColor = .white
        setupUI()
        if ensureSupport() {
            enterPage()
        }
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
            make.width.equalTo(scrollView.snp.width).offset(-24)
        }

        let title = UILabel()
        title.text = "手势控制（15.82）"
        title.font = .boldSystemFont(ofSize: 18)

        let masterRow = UIStackView()
        masterRow.axis = .horizontal
        masterRow.alignment = .center
        masterRow.spacing = 8
        let masterLbl = UILabel()
        masterLbl.text = "手势总开关"
        masterLbl.font = .systemFont(ofSize: 15)
        masterRow.addArrangedSubview(masterLbl)
        masterRow.addArrangedSubview(UIView())
        masterRow.addArrangedSubview(switchMaster)

        let treeTitle = UILabel()
        treeTitle.text = "功能 / 子功能 / 手势（由 operate=3 决定）"
        treeTitle.font = .boldSystemFont(ofSize: 14)

        let help = UILabel()
        help.text = "进页自动：03 建能力树 → 02 刷状态。功能多选一；同功能下子功能手势互斥。修改后点设置走 01。"
        help.font = .systemFont(ofSize: 12)
        help.textColor = .darkGray
        help.numberOfLines = 0

        let btnSupport = UIButton.createNormalButton(title: "查支持(03)")
        btnSupport.addTarget(self, action: #selector(onQuerySupport), for: .touchUpInside)
        let btnGet = UIButton.createNormalButton(title: "查当前(02)")
        btnGet.addTarget(self, action: #selector(onQueryCurrent), for: .touchUpInside)
        let row = UIStackView(arrangedSubviews: [btnSupport, btnGet])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        btnSupport.snp.makeConstraints { $0.height.equalTo(40) }
        btnGet.snp.makeConstraints { $0.height.equalTo(40) }

        let btnSet = UIButton.createNormalButton(title: "设置手势(01)")
        btnSet.addTarget(self, action: #selector(onSet), for: .touchUpInside)
        btnSet.snp.makeConstraints { $0.height.equalTo(40) }

        let btnRefresh = UIButton.createNormalButton(title: "重新加载(03→02)")
        btnRefresh.addTarget(self, action: #selector(onRefresh), for: .touchUpInside)
        btnRefresh.snp.makeConstraints { $0.height.equalTo(40) }

        let btnClear = UIButton.createNormalButton(title: "清空显示")
        btnClear.addTarget(self, action: #selector(onClear), for: .touchUpInside)
        btnClear.snp.makeConstraints { $0.height.equalTo(40) }

        let resultTitle = UILabel()
        resultTitle.text = "最近回调 JSON"
        resultTitle.font = .boldSystemFont(ofSize: 14)

        textResult.snp.makeConstraints { $0.height.equalTo(220) }

        [
            title, lblStatus, lblSummary, masterRow, treeTitle, treeStack, help,
            row, btnSet, btnRefresh, btnClear, resultTitle, textResult
        ].forEach { contentStack.addArrangedSubview($0) }
    }

    @discardableResult
    private func ensureSupport() -> Bool {
        guard sdk.funcTable.supportOperateGestureControl else {
            lblStatus.text = "此设备不支持手势控制（supportOperateGestureControl=false）"
            SVProgressHUD.showError(withStatus: "不支持 / not support")
            return false
        }
        return true
    }

    private func enterPage() {
        lblStatus.text = "状态: 正在查询支持项(03)…"
        awaitCurrentAfterSupport = true
        querySupport()
    }

    @objc private func onQuerySupport() {
        guard ensureSupport() else { return }
        awaitCurrentAfterSupport = false
        querySupport()
    }

    @objc private func onQueryCurrent() {
        guard ensureSupport() else { return }
        queryCurrent()
    }

    @objc private func onRefresh() {
        guard ensureSupport() else { return }
        enterPage()
    }

    @objc private func onSet() {
        guard ensureSupport() else { return }
        setFromUi()
    }

    @objc private func onClear() {
        supportModel = nil
        currentModel = nil
        clearTreeUi()
        textResult.text = "（暂无）"
        lblSummary.text = "流程: 支持项(03) → 当前配置(02) → 设置(01)"
        lblStatus.text = "状态: 空闲"
    }

    @objc private func onMasterChanged() {
        refreshSummaryFromUi()
    }

    private func querySupport() {
        SVProgressHUD.show(withStatus: "查支持(03)")
        Cmds.getGestureControlSupportConfigs().send { [weak self] res in
            guard let self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                switch res {
                case .failure(let err):
                    self.lblStatus.text = "状态: 03 失败, code=\(err.code)"
                    self.textResult.text = "error=\(err.code)"
                    self.awaitCurrentAfterSupport = false
                case .success(let model):
                    guard let model else {
                        self.lblStatus.text = "状态: 03 失败, empty"
                        self.awaitCurrentAfterSupport = false
                        return
                    }
                    self.supportModel = model
                    self.textResult.text = model.toJsonString() ?? "NULL"
                    self.lblStatus.text = "状态: 支持项已加载(03)"
                    self.buildTreeFromSupport(model)
                    if let current = self.currentModel {
                        self.applyCurrentToUi(current)
                    }
                    if self.awaitCurrentAfterSupport {
                        self.awaitCurrentAfterSupport = false
                        self.queryCurrent()
                    }
                }
            }
        }
    }

    private func queryCurrent() {
        SVProgressHUD.show(withStatus: "查当前(02)")
        Cmds.getGestureControl().send { [weak self] res in
            guard let self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                switch res {
                case .failure(let err):
                    self.lblStatus.text = "状态: 02 失败, code=\(err.code)"
                    self.textResult.text = "error=\(err.code)"
                case .success(let model):
                    guard let model else {
                        self.lblStatus.text = "状态: 02 失败, empty"
                        return
                    }
                    self.currentModel = model
                    self.textResult.text = model.toJsonString() ?? "NULL"
                    self.lblStatus.text = "状态: 当前配置已加载(02)"
                    if !self.funcUis.isEmpty {
                        self.applyCurrentToUi(model)
                    }
                }
            }
        }
    }

    private func setFromUi() {
        guard let support = supportModel else {
            lblStatus.text = "状态: 请先查支持项(03)"
            return
        }
        guard let model = buildSetModelFromUi(support) else {
            lblStatus.text = "状态: 组包失败"
            return
        }
        lblStatus.text = "状态: 正在设置(01)…"
        SVProgressHUD.show(withStatus: "设置手势(01)")
        Cmds.setGestureControl(model).send { [weak self] res in
            guard let self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                switch res {
                case .failure(let err):
                    self.lblStatus.text = "状态: 01 失败, code=\(err.code)"
                    self.textResult.text = "error=\(err.code) setReq=\(model.toJsonString() ?? "")"
                case .success(let reply):
                    self.textResult.text = reply?.toJsonString() ?? model.toJsonString() ?? "NULL"
                    self.lblStatus.text = "状态: 设置成功(01)"
                }
            }
        }
    }

    private func clearTreeUi() {
        treeStack.arrangedSubviews.forEach {
            treeStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        funcUis.removeAll()
        switchMaster.isOn = false
    }

    private func buildTreeFromSupport(_ support: IDOGestureControlModel) {
        clearTreeUi()
        let items = support.gestureFunctionItems ?? []
        for item in items {
            let funcType = item.functionType
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 8
            let titleLabel = UILabel()
            titleLabel.text = Self.gestureFuncLabel(funcType)
            titleLabel.font = .systemFont(ofSize: 15)
            let sw = UISwitch()
            sw.isOn = false
            sw.tag = funcType
            sw.addTarget(self, action: #selector(onFuncSwitchChanged(_:)), for: .valueChanged)
            row.addArrangedSubview(titleLabel)
            row.addArrangedSubview(UIView())
            row.addArrangedSubview(sw)
            treeStack.addArrangedSubview(row)

            var subUis: [SubUi] = []
            for sub in item.gestureSubFunctionItems ?? [] {
                let allowed = (sub.gestureTypeItems ?? []).map { $0.gestureType }.filter { $0 > 0 }
                guard !allowed.isEmpty else { continue }
                let subRow = UIStackView()
                subRow.axis = .horizontal
                subRow.alignment = .center
                subRow.spacing = 8
                let label = UILabel()
                label.text = Self.gestureSubLabel(funcType: funcType, subType: sub.subFunctionType)
                label.font = .systemFont(ofSize: 14)
                label.setContentHuggingPriority(.defaultLow, for: .horizontal)
                let btn = UIButton(type: .system)
                btn.contentHorizontalAlignment = .right
                btn.titleLabel?.font = .systemFont(ofSize: 14)
                btn.setTitle(Self.gestureTypeLabel(allowed[0]), for: .normal)
                let subUi = SubUi(
                    subType: sub.subFunctionType,
                    allowedGestures: allowed,
                    label: label,
                    button: btn,
                    selectedGesture: allowed[0]
                )
                btn.addAction(UIAction { [weak self, weak subUi] _ in
                    guard let self, let subUi else { return }
                    self.presentGesturePicker(for: subUi)
                }, for: .touchUpInside)
                subRow.addArrangedSubview(label)
                subRow.addArrangedSubview(btn)
                btn.snp.makeConstraints { $0.width.greaterThanOrEqualTo(140) }
                treeStack.addArrangedSubview(subRow)
                subUis.append(subUi)
            }

            let funcUi = FuncUi(functionType: funcType, uiSwitch: sw, titleLabel: titleLabel, subs: subUis)
            funcUis.append(funcUi)
            assignInitialGestures(funcUi, item: item)
            refreshMutualExclusiveButtons(funcUi)
        }

        let onOff = support.gestureControlOnOff
        if onOff == 0 || onOff == 1 {
            switchMaster.isOn = onOff == 1
        }
        lblSummary.text = "支持项: \(funcUis.count) 个功能已加载（功能多选一），等待当前配置…"
    }

    @objc private func onFuncSwitchChanged(_ sender: UISwitch) {
        if suppressFuncSwitchCallback { return }
        if sender.isOn {
            selectOnlyFunction(sender.tag)
        }
        refreshSummaryFromUi()
    }

    private func selectOnlyFunction(_ functionType: Int) {
        suppressFuncSwitchCallback = true
        for f in funcUis {
            f.uiSwitch.isOn = (f.functionType == functionType)
        }
        suppressFuncSwitchCallback = false
    }

    private func refreshSummaryFromUi() {
        let masterText = switchMaster.isOn ? "开" : "关"
        let enabled = funcUis.first(where: { $0.uiSwitch.isOn })
        var text = "当前: 总开关=\(masterText)"
        for f in funcUis {
            text += " | \(Self.gestureFuncLabel(f.functionType))=\(f.uiSwitch.isOn ? "开" : "关")"
        }
        text += " | 启用=\(enabled.map { Self.gestureFuncLabel($0.functionType) } ?? "无")"
        lblSummary.text = text
    }

    private func assignInitialGestures(_ funcUi: FuncUi, item: IDOGestureFunctionItemModel) {
        var used = Set<Int>()
        let subs = item.gestureSubFunctionItems ?? []
        for subUi in funcUi.subs {
            let types = (subs.first(where: { $0.subFunctionType == subUi.subType })?.gestureTypeItems ?? [])
                .map { $0.gestureType }
                .filter { $0 > 0 }
            let chosen = types.first(where: { !used.contains($0) })
                ?? subUi.allowedGestures.first(where: { !used.contains($0) })
                ?? subUi.allowedGestures[0]
            subUi.selectedGesture = chosen
            used.insert(chosen)
        }
    }

    private func applyCurrentToUi(_ current: IDOGestureControlModel) {
        let onOff = current.gestureControlOnOff
        if onOff == 0 || onOff == 1 {
            switchMaster.isOn = onOff == 1
        }
        let byType = Dictionary(uniqueKeysWithValues: (current.gestureFunctionItems ?? []).map { ($0.functionType, $0) })
        var selectedType: Int?
        for funcUi in funcUis {
            if let item = byType[funcUi.functionType], item.functionSwitch == 1, selectedType == nil {
                selectedType = funcUi.functionType
            }
        }

        suppressFuncSwitchCallback = true
        for funcUi in funcUis {
            let item = byType[funcUi.functionType]
            funcUi.uiSwitch.isOn = (selectedType != nil && funcUi.functionType == selectedType)
            if let item {
                var used = Set<Int>()
                let subs = item.gestureSubFunctionItems ?? []
                for subUi in funcUi.subs {
                    let picked = (subs.first(where: { $0.subFunctionType == subUi.subType })?.gestureTypeItems ?? [])
                        .map { $0.gestureType }
                        .first(where: { subUi.allowedGestures.contains($0) })
                    let g: Int
                    if let picked, !used.contains(picked) {
                        g = picked
                    } else {
                        g = subUi.allowedGestures.first(where: { !used.contains($0) }) ?? subUi.selectedGesture
                    }
                    subUi.selectedGesture = g
                    used.insert(g)
                }
            }
            refreshMutualExclusiveButtons(funcUi)
        }
        suppressFuncSwitchCallback = false
        refreshSummaryFromUi()
    }

    private func refreshMutualExclusiveButtons(_ funcUi: FuncUi) {
        for subUi in funcUi.subs {
            let takenByOthers = Set(funcUi.subs.filter { $0 !== subUi }.map { $0.selectedGesture })
            var options = subUi.allowedGestures.filter { !takenByOthers.contains($0) }
            if options.isEmpty {
                options = subUi.allowedGestures
            }
            if !options.contains(subUi.selectedGesture) {
                subUi.selectedGesture = options[0]
            }
            subUi.options = options
            subUi.button.setTitle(Self.gestureTypeLabel(subUi.selectedGesture), for: .normal)
        }
    }

    private func presentGesturePicker(for subUi: SubUi) {
        let parent = funcUis.first(where: { $0.subs.contains(where: { $0 === subUi }) })
        let sheet = UIAlertController(title: "选择手势", message: nil, preferredStyle: .actionSheet)
        for g in subUi.options {
            sheet.addAction(UIAlertAction(title: Self.gestureTypeLabel(g), style: .default, handler: { [weak self] _ in
                guard let self else { return }
                subUi.selectedGesture = g
                if let parent {
                    self.refreshMutualExclusiveButtons(parent)
                } else {
                    subUi.button.setTitle(Self.gestureTypeLabel(g), for: .normal)
                }
                self.refreshSummaryFromUi()
            }))
        }
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = subUi.button
            pop.sourceRect = subUi.button.bounds
        }
        present(sheet, animated: true)
    }

    private func buildSetModelFromUi(_ support: IDOGestureControlModel) -> IDOGestureControlModel? {
        guard let items = support.gestureFunctionItems else { return nil }
        let enabledType = funcUis.first(where: { $0.uiSwitch.isOn })?.functionType
        let outItems: [IDOGestureFunctionItemModel] = items.map { supportItem in
            let funcUi = funcUis.first(where: { $0.functionType == supportItem.functionType })
            let subs: [IDOGestureSubFunctionItemModel] = (supportItem.gestureSubFunctionItems ?? []).map { supportSub in
                let subUi = funcUi?.subs.first(where: { $0.subType == supportSub.subFunctionType })
                let gesture = subUi?.selectedGesture
                    ?? supportSub.gestureTypeItems?.first?.gestureType
                    ?? 0
                return IDOGestureSubFunctionItemModel(
                    subFunctionType: supportSub.subFunctionType,
                    gestureTypeItems: [IDOGestureTypeItemModel(gestureType: gesture)]
                )
            }
            return IDOGestureFunctionItemModel(
                functionSwitch: (enabledType != nil && supportItem.functionType == enabledType) ? 1 : 0,
                functionType: supportItem.functionType,
                gestureSubFunctionItems: subs
            )
        }
        return IDOGestureControlModel(
            operate: 1,
            gestureControlOnOff: switchMaster.isOn ? 1 : 0,
            gestureFunctionItems: outItems
        )
    }

    private static let funcCall = 1
    private static let funcPhoto = 2
    private static let funcMusic = 3
    private static let subAnswer = 1
    private static let subHangUp = 2
    private static let subPhoto = 1
    private static let subMusicNext = 1
    private static let typeFlipPalm = 1
    private static let typePlayTwice = 2
    private static let typeArmHorizontal = 3
    private static let typeArmVertical = 4

    static func gestureFuncLabel(_ type: Int) -> String {
        switch type {
        case funcCall: return "控制通话"
        case funcPhoto: return "遥控拍照"
        case funcMusic: return "音乐控制"
        default: return "功能\(type)"
        }
    }

    static func gestureSubLabel(funcType: Int, subType: Int) -> String {
        switch funcType {
        case funcCall:
            switch subType {
            case subAnswer: return "接听电话"
            case subHangUp: return "挂断电话"
            default: return "子功能\(subType)"
            }
        case funcPhoto:
            return subType == subPhoto ? "遥控拍照" : "子功能\(subType)"
        case funcMusic:
            return subType == subMusicNext ? "下一曲" : "子功能\(subType)"
        default:
            return "子功能\(subType)"
        }
    }

    static func gestureTypeLabel(_ type: Int) -> String {
        switch type {
        case typeFlipPalm: return "手掌翻转90°×2"
        case typePlayTwice: return "弹两下"
        case typeArmHorizontal: return "手臂水平旋转90°×2"
        case typeArmVertical: return "手臂垂直旋转90°×2"
        default: return "手势\(type)"
        }
    }
}
