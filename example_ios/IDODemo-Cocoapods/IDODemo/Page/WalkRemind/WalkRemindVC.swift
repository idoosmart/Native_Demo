//
//  WalkRemindVC.swift
//  Runner
//
//  走动提醒独立联调页：参数设置/查询下发；监听 07 40 dataType=134 弹窗展示状态/目标/达成。
//

import UIKit
import UserNotifications
import SnapKit
import SVProgressHUD
import protocol_channel

final class WalkRemindVC: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    private var notifyObserver: NSObjectProtocol?
    private let logBuilder = NSMutableString()
    private var scrollView: UIScrollView!
    private var logContainer: UIView!
    private var allFields: [UITextField] = []

    private lazy var connChip = makeChip()
    private lazy var supportChip = makeChip()

    private lazy var swOnOff: UISwitch = {
        let s = UISwitch()
        s.isOn = true
        return s
    }()

    private lazy var etGoalStep = makeField(text: "2000")
    private lazy var etGoalTime = makeField(text: "60")
    private lazy var etStartHour = makeField(text: "9")
    private lazy var etStartMinute = makeField(text: "0")
    private lazy var etEndHour = makeField(text: "18")
    private lazy var etEndMinute = makeField(text: "0")
    private lazy var etDndStartHour = makeField(text: "0")
    private lazy var etDndStartMinute = makeField(text: "0")
    private lazy var etDndEndHour = makeField(text: "0")
    private lazy var etDndEndMinute = makeField(text: "0")

    private lazy var swDnd: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        return s
    }()

    private lazy var notifySeg: UISegmentedControl = {
        let s = UISegmentedControl(items: [
            L10n.walkRemindNotifyInvalid,
            L10n.walkRemindNotifyAllow,
            L10n.walkRemindNotifySilent,
            L10n.walkRemindNotifyOff,
        ])
        s.selectedSegmentIndex = 1
        return s
    }()

    private lazy var weekButtons: [UIButton] = {
        let titles = [
            L10n.walkRemindWeekdayMon,
            L10n.walkRemindWeekdayTue,
            L10n.walkRemindWeekdayWed,
            L10n.walkRemindWeekdayThu,
            L10n.walkRemindWeekdayFri,
            L10n.walkRemindWeekdaySat,
            L10n.walkRemindWeekdaySun,
        ]
        return titles.enumerated().map { idx, title in
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            b.tag = idx
            b.layer.cornerRadius = 16
            b.layer.borderWidth = 1
            b.isSelected = idx < 5
            b.addTarget(self, action: #selector(toggleWeek(_:)), for: .touchUpInside)
            refreshWeekButton(b)
            return b
        }
    }()

    private lazy var btnQuery = makeActionButton(title: L10n.query, color: .systemBlue, action: #selector(onQuery))
    private lazy var btnSet = makeActionButton(title: L10n.walkRemindSet, color: UIColor(red: 0.15, green: 0.55, blue: 0.35, alpha: 1), action: #selector(onSet))

    private lazy var notifyStatusLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = UIColor(red: 0.08, green: 0.35, blue: 0.65, alpha: 1)
        l.text = L10n.walkRemindWaiting
        return l
    }()

    private lazy var notifyDetailLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        l.textColor = .secondaryLabel
        l.text = L10n.walkRemindStatusGoalAchieved
        return l
    }()

    private lazy var logView: UITextView = {
        let v = UITextView()
        v.isEditable = false
        v.isSelectable = true
        v.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        v.backgroundColor = UIColor(white: 0.12, alpha: 1)
        v.textColor = UIColor(red: 0.55, green: 0.95, blue: 0.55, alpha: 1)
        v.layer.cornerRadius = 8
        v.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        v.text = L10n.walkRemindLogHint
        return v
    }()

    private lazy var keyboardToolbar: UIToolbar = {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: L10n.done, style: .done, target: self, action: #selector(dismissKeyboard)),
        ]
        return bar
    }()

    deinit {
        if let obs = notifyObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.walkRemind
        view.backgroundColor = UIColor.systemGroupedBackground
        UNUserNotificationCenter.current().delegate = self
        requestWalkReminderNotificationPermission()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.walkRemindDismissKeyboard,
            style: .plain,
            target: self,
            action: #selector(dismissKeyboard)
        )
        buildUI()
        refreshChips()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        notifyObserver = NotificationCenter.default.addObserver(
            forName: Notify.onSdkDeviceStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let model = note.object as? IDODeviceNotificationModel else { return }
            self?.onDeviceNotification(model)
        }
        appendLog(L10n.walkRemindListenTip)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshChips()
    }

    // MARK: - UI builders

    private func makeChip() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        l.layer.cornerRadius = 10
        l.clipsToBounds = true
        return l
    }

    private func makeField(text: String) -> UITextField {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.text = text
        tf.font = .systemFont(ofSize: 15)
        tf.delegate = self
        tf.inputAccessoryView = keyboardToolbar
        tf.textAlignment = .right
        allFields.append(tf)
        return tf
    }

    private func makeActionButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = color
        b.layer.cornerRadius = 10
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    private func card() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 12
        return v
    }

    private func sectionHeader(_ text: String) -> UILabel {
        let l = UILabel()
        l.text = text.uppercased()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }

    /// 左标题 + 右控件；可选下方说明
    private func formRow(title: String, hint: String?, control: UIView) -> UIView {
        let titleL = UILabel()
        titleL.text = title
        titleL.font = .systemFont(ofSize: 15, weight: .medium)
        titleL.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let hintL = UILabel()
        hintL.text = hint
        hintL.font = .systemFont(ofSize: 11)
        hintL.textColor = .tertiaryLabel
        hintL.numberOfLines = 0
        hintL.isHidden = hint == nil

        let left = UIStackView(arrangedSubviews: hint == nil ? [titleL] : [titleL, hintL])
        left.axis = .vertical
        left.spacing = 2
        left.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        control.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [left, control])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.distribution = .fill
        return row
    }

    private func timePair(h: UITextField, m: UITextField, label: String) -> UIView {
        let tag = UILabel()
        tag.text = label
        tag.font = .systemFont(ofSize: 13)
        tag.textColor = .secondaryLabel
        tag.setContentHuggingPriority(.required, for: .horizontal)

        let colon = UILabel()
        colon.text = ":"
        colon.font = .systemFont(ofSize: 16, weight: .medium)

        h.snp.makeConstraints { $0.width.equalTo(52) }
        m.snp.makeConstraints { $0.width.equalTo(52) }
        h.textAlignment = .center
        m.textAlignment = .center

        let row = UIStackView(arrangedSubviews: [tag, h, colon, m, UIView()])
        row.axis = .horizontal
        row.spacing = 6
        row.alignment = .center
        return row
    }

    private func buildUI() {
        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .onDrag
        scroll.alwaysBounceVertical = true
        self.scrollView = scroll

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16

        // 状态条
        let chipCard = card()
        let chipStack = UIStackView(arrangedSubviews: [connChip, supportChip, UIView()])
        chipStack.spacing = 8
        chipStack.alignment = .center
        chipCard.addSubview(chipStack)
        chipStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(12) }

        // 基础开关
        let basicCard = card()
        let basicStack = UIStackView(arrangedSubviews: [
            formRow(title: L10n.walkRemindMasterSwitch, hint: L10n.walkRemindOnOffHint, control: swOnOff),
            divider(),
            formRow(title: L10n.walkRemindGoalStep, hint: L10n.walkRemindGoalStepHint, control: etGoalStep),
            divider(),
            formRow(title: L10n.walkRemindGoalTime, hint: L10n.walkRemindGoalTimeHint, control: etGoalTime),
        ])
        basicStack.axis = .vertical
        basicStack.spacing = 10
        basicCard.addSubview(basicStack)
        basicStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }
        etGoalStep.snp.makeConstraints { $0.width.equalTo(88) }
        etGoalTime.snp.makeConstraints { $0.width.equalTo(88) }

        // 有效时段
        let timeCard = card()
        let timeStack = UIStackView(arrangedSubviews: [
            timePair(h: etStartHour, m: etStartMinute, label: L10n.walkRemindStart),
            timePair(h: etEndHour, m: etEndMinute, label: L10n.walkRemindEnd),
        ])
        timeStack.axis = .vertical
        timeStack.spacing = 10
        let timeHint = UILabel()
        timeHint.text = "start_hour / start_minute / end_hour / end_minute"
        timeHint.font = .systemFont(ofSize: 11)
        timeHint.textColor = .tertiaryLabel
        let timeWrap = UIStackView(arrangedSubviews: [timeHint, timeStack])
        timeWrap.axis = .vertical
        timeWrap.spacing = 8
        timeCard.addSubview(timeWrap)
        timeWrap.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 通知类型
        let notifyCard = card()
        let notifyTitle = UILabel()
        notifyTitle.text = L10n.walkRemindNotifyType
        notifyTitle.font = .systemFont(ofSize: 15, weight: .medium)
        let notifyHint = UILabel()
        notifyHint.text = L10n.walkRemindNotifyHint
        notifyHint.font = .systemFont(ofSize: 11)
        notifyHint.textColor = .tertiaryLabel
        notifyHint.numberOfLines = 0
        let notifyStack = UIStackView(arrangedSubviews: [notifyTitle, notifyHint, notifySeg])
        notifyStack.axis = .vertical
        notifyStack.spacing = 8
        notifyCard.addSubview(notifyStack)
        notifyStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 勿扰
        let dndCard = card()
        let dndStack = UIStackView(arrangedSubviews: [
            formRow(title: L10n.walkRemindDndSwitch, hint: L10n.walkRemindDndHint, control: swDnd),
            divider(),
            timePair(h: etDndStartHour, m: etDndStartMinute, label: L10n.walkRemindDndStart),
            timePair(h: etDndEndHour, m: etDndEndMinute, label: L10n.walkRemindDndEnd),
        ])
        dndStack.axis = .vertical
        dndStack.spacing = 10
        let dndHint = UILabel()
        dndHint.text = L10n.walkRemindDndFieldHint
        dndHint.font = .systemFont(ofSize: 11)
        dndHint.textColor = .tertiaryLabel
        let dndWrap = UIStackView(arrangedSubviews: [dndHint, dndStack])
        dndWrap.axis = .vertical
        dndWrap.spacing = 8
        dndCard.addSubview(dndWrap)
        dndWrap.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 重复
        let weekCard = card()
        let weekTitle = UILabel()
        weekTitle.text = L10n.walkRemindRepeat
        weekTitle.font = .systemFont(ofSize: 15, weight: .medium)
        let weekHint = UILabel()
        weekHint.text = L10n.walkRemindRepeatHint
        weekHint.font = .systemFont(ofSize: 11)
        weekHint.textColor = .tertiaryLabel
        let weekRow = UIStackView(arrangedSubviews: weekButtons)
        weekRow.axis = .horizontal
        weekRow.spacing = 6
        weekRow.distribution = .fillEqually
        weekButtons.forEach { $0.snp.makeConstraints { c in c.height.equalTo(32) } }
        let weekStack = UIStackView(arrangedSubviews: [weekTitle, weekHint, weekRow])
        weekStack.axis = .vertical
        weekStack.spacing = 8
        weekCard.addSubview(weekStack)
        weekStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 操作
        let btnRow = UIStackView(arrangedSubviews: [btnQuery, btnSet])
        btnRow.axis = .horizontal
        btnRow.spacing = 12
        btnRow.distribution = .fillEqually
        btnQuery.snp.makeConstraints { $0.height.equalTo(48) }
        btnSet.snp.makeConstraints { $0.height.equalTo(48) }

        // 通知结果
        let resultCard = card()
        resultCard.backgroundColor = UIColor(red: 0.89, green: 0.95, blue: 0.99, alpha: 1)
        let resultStack = UIStackView(arrangedSubviews: [notifyStatusLabel, notifyDetailLabel])
        resultStack.axis = .vertical
        resultStack.spacing = 6
        resultCard.addSubview(resultStack)
        resultStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 日志（放在滚动区内，保证可见）
        let logCard = card()
        self.logContainer = logCard
        let logTitle = UILabel()
        logTitle.text = L10n.walkRemindReqRespLog
        logTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        let clearBtn = UIButton(type: .system)
        clearBtn.setTitle(L10n.clear, for: .normal)
        clearBtn.addTarget(self, action: #selector(onClearLog), for: .touchUpInside)
        let logHeader = UIStackView(arrangedSubviews: [logTitle, UIView(), clearBtn])
        logHeader.axis = .horizontal
        logHeader.alignment = .center
        let logHint = UILabel()
        logHint.text = L10n.walkRemindLogEachHint
        logHint.font = .systemFont(ofSize: 11)
        logHint.textColor = .tertiaryLabel
        let logStack = UIStackView(arrangedSubviews: [logHeader, logHint, logView])
        logStack.axis = .vertical
        logStack.spacing = 8
        logCard.addSubview(logStack)
        logStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }
        logView.snp.makeConstraints { $0.height.equalTo(420) }

        [
            chipCard,
            sectionHeader(L10n.walkRemindSectionBasic), basicCard,
            sectionHeader(L10n.walkRemindSectionTime), timeCard,
            sectionHeader(L10n.walkRemindSectionNotify), notifyCard,
            sectionHeader(L10n.walkRemindSectionDnd), dndCard,
            sectionHeader(L10n.walkRemindSectionRepeat), weekCard,
            btnRow,
            sectionHeader(L10n.walkRemindSection134), resultCard,
            sectionHeader(L10n.walkRemindSectionLog), logCard,
        ].forEach { content.addArrangedSubview($0) }

        view.addSubview(scroll)
        scroll.addSubview(content)
        scroll.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16))
            make.width.equalTo(scroll.snp.width).offset(-32)
        }
    }

    private func divider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.separator.withAlphaComponent(0.35)
        v.snp.makeConstraints { $0.height.equalTo(1.0 / UIScreen.main.scale) }
        return v
    }

    // MARK: - Actions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }

    private func refreshChips() {
        let connected = sdk.state.isConnected
        connChip.text = "  \(connected ? L10n.connected : L10n.disconnected)  "
        connChip.backgroundColor = connected
            ? UIColor(red: 0.78, green: 0.90, blue: 0.79, alpha: 1)
            : UIColor(red: 1.0, green: 0.80, blue: 0.82, alpha: 1)

        let supported = sdk.funcTable.setWalkReminder
        supportChip.text = "  \(supported ? L10n.walkRemindSupportOk : L10n.walkRemindSupportNo)  "
        supportChip.backgroundColor = supported
            ? UIColor(red: 0.78, green: 0.90, blue: 0.79, alpha: 1)
            : UIColor(red: 1.0, green: 0.88, blue: 0.70, alpha: 1)
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            SVProgressHUD.showError(withStatus: L10n.deviceNotConnected)
            return false
        }
        return true
    }

    @objc private func toggleWeek(_ sender: UIButton) {
        sender.isSelected.toggle()
        refreshWeekButton(sender)
    }

    private func refreshWeekButton(_ b: UIButton) {
        if b.isSelected {
            b.backgroundColor = .systemBlue
            b.setTitleColor(.white, for: .normal)
            b.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            b.backgroundColor = .clear
            b.setTitleColor(.systemBlue, for: .normal)
            b.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }

    private func intValue(_ tf: UITextField, def: Int = 0) -> Int {
        Int(tf.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") ?? def
    }

    private func collectRepeats() -> Set<IDOWeek> {
        let all: [IDOWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        var set = Set<IDOWeek>()
        for (i, b) in weekButtons.enumerated() where b.isSelected {
            set.insert(all[i])
        }
        return set
    }

    private func applyRepeats(_ repeats: Set<IDOWeek>) {
        let all: [IDOWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        for (i, week) in all.enumerated() {
            weekButtons[i].isSelected = repeats.contains(week)
            refreshWeekButton(weekButtons[i])
        }
    }

    private func buildParam() -> IDOWalkRemindModel {
        IDOWalkRemindModel(
            onOff: swOnOff.isOn ? 1 : 0,
            goalStep: intValue(etGoalStep, def: 2000),
            startHour: intValue(etStartHour, def: 9),
            startMinute: intValue(etStartMinute),
            endHour: intValue(etEndHour, def: 18),
            endMinute: intValue(etEndMinute),
            repeats: collectRepeats(),
            goalTime: intValue(etGoalTime, def: 60),
            notifyFlag: max(0, notifySeg.selectedSegmentIndex),
            doNotDisturbOnOff: swDnd.isOn ? 1 : 0,
            noDisturbStartHour: intValue(etDndStartHour),
            noDisturbStartMinute: intValue(etDndStartMinute),
            noDisturbEndHour: intValue(etDndEndHour),
            noDisturbEndMinute: intValue(etDndEndMinute)
        )
    }

    private func fillUI(from model: IDOWalkRemindModel) {
        swOnOff.isOn = model.onOff == 1
        etGoalStep.text = "\(model.goalStep)"
        etGoalTime.text = "\(model.goalTime)"
        etStartHour.text = "\(model.startHour)"
        etStartMinute.text = "\(model.startMinute)"
        etEndHour.text = "\(model.endHour)"
        etEndMinute.text = "\(model.endMinute)"
        let flag = min(max(model.notifyFlag, 0), 3)
        notifySeg.selectedSegmentIndex = flag
        swDnd.isOn = model.doNotDisturbOnOff == 1
        etDndStartHour.text = "\(model.noDisturbStartHour)"
        etDndStartMinute.text = "\(model.noDisturbStartMinute)"
        etDndEndHour.text = "\(model.noDisturbEndHour)"
        etDndEndMinute.text = "\(model.noDisturbEndMinute)"
        applyRepeats(model.repeats)
    }

    @objc private func onQuery() {
        dismissKeyboard()
        guard ensureConnected() else { return }
        appendLog(L10n.walkRemindQuerySep)
        appendLog(String(format: L10n.walkRemindRequest, "{}"))
        scrollToLog()
        SVProgressHUD.show(withStatus: L10n.walkRemindQuerying)
        Cmds.getWalkRemind().send { [weak self] res in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard let self else { return }
                switch res {
                case .failure(let err):
                    self.appendLog(String(format: L10n.walkRemindResponseFail, "\(err.code)"))
                    SVProgressHUD.showError(withStatus: String(format: L10n.failedCode, "\(err.code)"))
                case .success(let model):
                    guard let model else {
                        self.appendLog(L10n.walkRemindResponseEmpty)
                        return
                    }
                    self.fillUI(from: model)
                    self.appendLog(String(format: L10n.walkRemindResponse, Self.prettyJson(model.toJsonString())))
                    SVProgressHUD.showSuccess(withStatus: L10n.walkRemindQueryDone)
                }
                self.scrollToLog()
            }
        }
    }

    @objc private func onSet() {
        dismissKeyboard()
        guard ensureConnected() else { return }
        let param = buildParam()
        appendLog(L10n.walkRemindSetSep)
        appendLog(String(format: L10n.walkRemindRequest, Self.prettyJson(param.toJsonString())))
        scrollToLog()
        SVProgressHUD.show(withStatus: L10n.walkRemindSetting)
        Cmds.setWalkRemind(param).send { [weak self] res in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard let self else { return }
                switch res {
                case .failure(let err):
                    self.appendLog(String(format: L10n.walkRemindResponseFail, "\(err.code)"))
                    SVProgressHUD.showError(withStatus: String(format: L10n.failedCode, "\(err.code)"))
                case .success(let reply):
                    let body = reply?.toJsonString() ?? #"{"is_success":1}"#
                    self.appendLog(String(format: L10n.walkRemindResponse, Self.prettyJson(body)))
                    SVProgressHUD.showSuccess(withStatus: L10n.walkRemindSetOk)
                }
                self.scrollToLog()
            }
        }
    }

    private func onDeviceNotification(_ model: IDODeviceNotificationModel) {
        guard model.dataType?.intValue == 134 else { return }
        let status = model.walkReminderStatus?.intValue ?? 0
        let goal = model.walkReminderGoalValue?.intValue ?? 0
        let achieved = model.walkReminderAchievedValue?.intValue ?? 0
        showWalkReminderResult(status: status, goal: goal, achieved: achieved, popup: true)
    }

    private func showWalkReminderResult(status: Int, goal: Int, achieved: Int, popup: Bool) {
        let statusText = status == 1 ? L10n.walkRemindAchieved : L10n.walkRemindNotAchieved
        notifyStatusLabel.text = String(format: L10n.walkRemindNotifyTitle, statusText)
        notifyDetailLabel.text = String(format: L10n.walkRemindNotifyBody, status, goal, achieved)
        let notifyJson = """
        {
          "data_type" : 134,
          "walk_reminder_status" : \(status),
          "walk_reminder_goal_value" : \(goal),
          "walk_reminder_achieved_value" : \(achieved)
        }
        """
        appendLog(L10n.walkRemindNotifySep)
        appendLog(String(format: L10n.walkRemindResponse, notifyJson))
        postWalkReminderLocalNotification(status: status, goal: goal, achieved: achieved)
        scrollToLog()
        guard popup else { return }
        let alert = UIAlertController(
            title: L10n.walkRemindAlertTitle,
            message: String(format: L10n.walkRemindAlertMessage, status, statusText, goal, achieved),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.knowIt, style: .default))
        present(alert, animated: true)
    }

    private func requestWalkReminderNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error {
                    self?.appendLog(String(format: L10n.walkRemindPermFail, error.localizedDescription))
                } else {
                    self?.appendLog(String(format: L10n.walkRemindPermGranted, "\(granted)"))
                }
            }
        }
    }

    private func postWalkReminderLocalNotification(status: Int, goal: Int, achieved: Int) {
        let statusText = status == 1 ? L10n.walkRemindAchieved1 : L10n.walkRemindAchieved0
        let body = String(format: L10n.walkRemindLocalBody, statusText, goal, achieved)
        let content = UNMutableNotificationContent()
        content.title = L10n.walkRemind
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "walk_reminder_134_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            DispatchQueue.main.async {
                if let error {
                    self?.appendLog(String(format: L10n.walkRemindLocalFail, error.localizedDescription))
                } else {
                    self?.appendLog(String(format: L10n.walkRemindLocalOk, body))
                }
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    @objc private func onClearLog() {
        logBuilder.setString("")
        logView.text = L10n.walkRemindLogHint
    }

    private func scrollToLog() {
        guard let logContainer else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.scrollView.scrollRectToVisible(
                logContainer.convert(logContainer.bounds, to: self?.scrollView).insetBy(dx: 0, dy: -20),
                animated: true
            )
        }
    }

    private static func prettyJson(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return L10n.emptyReply }
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let text = String(data: pretty, encoding: .utf8) else {
            return raw
        }
        return text
    }

    private func appendLog(_ text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let line = "[\(formatter.string(from: Date()))] \(text)"
        if logBuilder.length == 0 || logView.text == L10n.walkRemindLogHint {
            logBuilder.setString(line)
        } else {
            logBuilder.append("\n\(line)")
        }
        logView.text = logBuilder as String
        let bottom = NSRange(location: max(logView.text.count - 1, 0), length: 1)
        logView.scrollRangeToVisible(bottom)
    }
}
