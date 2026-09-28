//
//  TaskListFullSetVC.swift
//  Runner
//
//  15.114 任务清单 — 全量设置（operate=1）
//  待发送列表 + 已发送列表；添加任务随机生成多条；底部全量下发
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

class TaskListFullSetVC: UIViewController {

    /// 7.8 通知：任务清单状态变化
    private static let taskStatusDataType = 133
    /// 每次「添加任务」随机条数范围
    private static let randomAddCountRange = 2...5

    /// 已下发到设备的任务（本地缓存）
    private var sentItems: [TaskListItemDraft] = []
    /// 待发送任务（仅本地，未下发）
    private var pendingItems: [TaskListItemDraft] = []

    private var notifyObserver: NSObjectProtocol?
    private var cacheClearedObserver: NSObjectProtocol?

    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .insetGrouped)
        t.dataSource = self
        t.delegate = self
        t.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 130
        return t
    }()

    private lazy var btnFullSet: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.taskListFullSet, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.15, green: 0.7, blue: 0.4, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        b.addTarget(self, action: #selector(onFullSet), for: .touchUpInside)
        return b
    }()

    private lazy var logTitle: UILabel = {
        let l = UILabel()
        l.text = L10n.requestReplyLog
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()

    private lazy var logView: UITextView = {
        let v = UITextView()
        v.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        v.isEditable = false
        v.backgroundColor = UIColor(white: 0.96, alpha: 1)
        v.layer.borderColor = UIColor.separator.cgColor
        v.layer.borderWidth = 0.5
        v.layer.cornerRadius = 6
        v.text = L10n.taskListFullSetLogHint
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.taskList
        view.backgroundColor = .systemGroupedBackground
        // 右侧从外到内：添加任务、查询状态
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: L10n.taskListAddTask,
                style: .plain,
                target: self,
                action: #selector(onAddRandomTasks)
            ),
            UIBarButtonItem(
                title: L10n.taskListQueryStatus,
                style: .plain,
                target: self,
                action: #selector(onQueryStatusTapped)
            ),
        ]

        view.addSubview(tableView)
        view.addSubview(logTitle)
        view.addSubview(logView)
        view.addSubview(btnFullSet)

        btnFullSet.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
            make.height.equalTo(48)
        }
        logView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(btnFullSet.snp.top).offset(-10)
            make.height.equalTo(140)
        }
        logTitle.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(logView.snp.top).offset(-4)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(logTitle.snp.top).offset(-8)
        }

        notifyObserver = NotificationCenter.default.addObserver(
            forName: Notify.onSdkDeviceStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let model = note.object as? IDODeviceNotificationModel else { return }
            self?.onDeviceNotification(model)
        }
        cacheClearedObserver = NotificationCenter.default.addObserver(
            forName: Notify.onTaskListCacheCleared,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onTaskListCacheCleared()
        }
        bootstrap()
    }

    deinit {
        if let obs = notifyObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let obs = cacheClearedObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    // MARK: - Bootstrap / storage

    private func macAddress() -> String {
        let full = sdk.device.macAddressFull
        if !full.isEmpty { return full }
        return sdk.device.macAddress
    }

    private func bootstrap() {
        loadCacheFromLocal()
        // 查询状态不判断功能表，仅要求已连接
        if sdk.state.isConnected {
            queryStatusChanges(showFeedback: false)
        }
    }

    private func loadCacheFromLocal() {
        sentItems = TaskListStorage.load(macAddress())
        refreshListUi()
    }

    private func persistSentItems() {
        TaskListStorage.save(macAddress(), items: sentItems)
    }

    /// 解绑后本地缓存已清：同步清空页面内存列表
    private func onTaskListCacheCleared() {
        sentItems.removeAll()
        pendingItems.removeAll()
        refreshListUi()
        appendLog(L10n.taskListCacheCleared)
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            SVProgressHUD.showError(withStatus: L10n.deviceNotConnected)
            return false
        }
        return true
    }

    private func refreshListUi() {
        tableView.reloadData()
    }

    private func usedTaskIds() -> Set<Int> {
        Set(sentItems.map(\.taskId)).union(pendingItems.map(\.taskId))
    }

    // MARK: - Log

    private static func timeStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: Date())
    }

    private func appendLog(_ text: String) {
        let line = "[\(Self.timeStamp())] \(text)"
        if logView.text.isEmpty
            || logView.text == L10n.taskListFullSetLogHint
        {
            logView.text = line
        } else {
            logView.text += "\n" + line
        }
        let bottom = NSRange(location: max(logView.text.count - 1, 0), length: 1)
        logView.scrollRangeToVisible(bottom)
    }

    private static func prettyJsonString(_ raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: pretty, encoding: .utf8)
        else {
            return raw
        }
        return str
    }

    private static func formatReplyModel(_ model: IDOTaskListModel) -> String {
        var root: [String: Any] = ["operate": model.operate]
        if let err = model.errorCode { root["error_code"] = err }
        if model.operate == 1 {
            // 设置回复通常仅 operate + error_code
        } else if model.operate == 2 {
            if let num = model.statusItemNum { root["status_item_num"] = num }
            var arr: [[String: Any]] = []
            for item in model.statusItems ?? [] {
                arr.append([
                    "task_id": item.taskId,
                    "status": item.status,
                    "complete_timestamp": item.completeTimestamp,
                ])
            }
            root["status_items"] = arr
        }
        guard let data = try? JSONSerialization.data(withJSONObject: root, options: [.prettyPrinted, .sortedKeys]),
              let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }

    // MARK: - Random generate

    private static var detailPool: [String] {
        [
            L10n.taskListSampleMeeting,
            L10n.taskListSampleMedicine,
            L10n.taskListSampleSport,
            L10n.taskListSampleWater,
            L10n.taskListSampleCall,
            L10n.taskListSampleReport,
            L10n.taskListSampleParcel,
            L10n.taskListSampleFitness,
            L10n.taskListSampleShopping,
            L10n.taskListSampleEmail,
            L10n.taskListSampleNap,
            L10n.taskListSampleFamily,
        ]
    }

    @objc private func onAddRandomTasks() {
        let count = Int.random(in: Self.randomAddCountRange)
        var usedIds = usedTaskIds()
        let existingDetails = Set(
            (sentItems + pendingItems)
                .map { $0.taskDetail.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
        var detailChoices = Self.detailPool.filter { !existingDetails.contains($0) }.shuffled()
        if detailChoices.count < count {
            detailChoices = Self.detailPool.shuffled()
        }

        let now = Int(Date().timeIntervalSince1970)
        var usedReminds = Set((sentItems + pendingItems).map(\.remindTimestamp))
        var generated: [TaskListItemDraft] = []
        var pickedDetails = Set<String>()

        for i in 0..<count {
            guard let taskId = allocUniqueTaskId(excluding: &usedIds) else {
                SVProgressHUD.showError(withStatus: L10n.taskListCannotGenId)
                return
            }
            usedIds.insert(taskId)

            // 详情：本批互不相同；优先避开已有列表中的文案
            let detail: String
            if i < detailChoices.count, !pickedDetails.contains(detailChoices[i]) {
                detail = detailChoices[i]
            } else {
                let fallback = Self.detailPool.first { !pickedDetails.contains($0) }
                    ?? String(format: L10n.taskListSampleDetail, "\(taskId)")
                detail = fallback
            }
            pickedDetails.insert(detail)

            // 提醒时间：必须晚于当前；本批互不相同
            var remind = now + 600 + i * 900 + Int.random(in: 0..<300)
            var guardCount = 0
            while (remind <= now || usedReminds.contains(remind)) && guardCount < 40 {
                remind = now + 600 + i * 900 + Int.random(in: 0..<3600) + guardCount
                guardCount += 1
            }
            usedReminds.insert(remind)

            generated.append(
                TaskListItemDraft(
                    taskId: taskId,
                    remindTimestamp: remind,
                    taskDetail: TaskListItemDraft.clampTaskDetail(detail)
                )
            )
        }
        pendingItems.append(contentsOf: generated)
        refreshListUi()
        SVProgressHUD.showSuccess(withStatus: String(format: L10n.taskListGeneratedPending, generated.count))
    }

    /// task_id 为协议 uint32_t：从 1 起每次 +1，不超过 UInt32.max
    private func allocUniqueTaskId(excluding used: inout Set<Int>) -> Int? {
        let next = (used.max() ?? 0) + 1
        guard TaskListItemDraft.isValidTaskId(next), !used.contains(next) else { return nil }
        return next
    }

    // MARK: - Edit pending

    private func showEditPendingDialog(at index: Int) {
        guard pendingItems.indices.contains(index) else { return }
        let draft = pendingItems[index]
        let editVC = TaskListEditPendingVC(draft: draft) { [weak self] remindTimestamp, taskDetail in
            guard let self, self.pendingItems.indices.contains(index) else { return }
            self.pendingItems[index].remindTimestamp = remindTimestamp
            self.pendingItems[index].taskDetail = taskDetail
            self.refreshListUi()
        }
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // MARK: - Full set

    @objc private func onFullSet() {
        // 全量设置不判断功能表，仅要求已连接
        guard ensureConnected() else { return }
        // 全量 = 已发送 + 待发送（operate=1 整体覆盖）
        let fullList = sentItems + pendingItems
        sendFullSet(fullList) { [weak self] in
            guard let self else { return }
            // 下发成功：待发送并入已发送，清空待发送，并缓存已下发列表
            self.sentItems = fullList
            self.pendingItems.removeAll()
            self.persistSentItems()
            self.refreshListUi()
            self.appendLog(String(format: L10n.taskListCachedSent, self.sentItems.count))
        }
    }

    private func toSdkItems(_ list: [TaskListItemDraft]) -> [IDOTaskListItemModel] {
        list.map { draft in
            IDOTaskListItemModel(
                taskId: draft.taskId,
                remindTimestamp: draft.remindTimestamp,
                taskDetail: draft.taskDetail.isEmpty ? nil : draft.taskDetail
            )
        }
    }

    private func sendFullSet(
        _ list: [TaskListItemDraft],
        showFeedback: Bool = true,
        onSuccess: (() -> Void)? = nil
    ) {
        let param = IDOTaskListModel(operate: 1, items: toSdkItems(list))
        let req = Self.prettyJsonString(param.toJsonString() ?? "{\"operate\":1}")
        appendLog(String(format: L10n.taskListFullSetRequest, req))
        if showFeedback { SVProgressHUD.show(withStatus: L10n.taskListFullSetting) }
        Cmds.taskList(param).send { [weak self] res in
            if showFeedback { SVProgressHUD.dismiss() }
            guard let self else { return }
            switch res {
            case .failure(let err):
                self.appendLog(String(format: L10n.taskListFullSetReplyFail, "\(err.code)"))
                if showFeedback { SVProgressHUD.showError(withStatus: String(format: L10n.failedCode, "\(err.code)")) }
            case .success(let model):
                if let model {
                    self.appendLog(String(format: L10n.taskListFullSetReply, Self.formatReplyModel(model)))
                } else {
                    self.appendLog(L10n.taskListFullSetReplyEmpty)
                }
                if let err = model?.errorCode, err != 0 {
                    if showFeedback { SVProgressHUD.showError(withStatus: L10n.taskListErrorCodeNonzero) }
                    return
                }
                onSuccess?()
                if showFeedback {
                    SVProgressHUD.showSuccess(
                        withStatus: list.isEmpty ? L10n.taskListClearedAll : String(format: L10n.taskListSentCount, list.count)
                    )
                }
            }
        }
    }

    // MARK: - Status query / notify

    /// 按 task_id 刷新已发送列表中的任务状态与完成时间，并写回本地缓存
    @discardableResult
    private func applyStatusUpdate(taskId: Int, status: Int, completeTimestamp: Int = 0) -> Bool {
        guard let idx = sentItems.firstIndex(where: { $0.taskId == taskId }) else { return false }
        sentItems[idx].status = status
        if status == TaskListItemDraft.statusDone {
            // 通知 133 不含完成时间；仅当查询带回有效时间戳时才覆盖
            if completeTimestamp > 0 {
                sentItems[idx].completeTimestamp = completeTimestamp
            }
        } else {
            sentItems[idx].completeTimestamp = 0
        }
        return true
    }

    private func commitStatusRefresh(updatedCount: Int, source: String) {
        guard updatedCount > 0 else {
            appendLog(String(format: L10n.taskListNoLocalMatch, source))
            return
        }
        persistSentItems()
        refreshListUi()
        appendLog(String(format: L10n.taskListRefreshedCount, source, updatedCount))
    }

    private func onDeviceNotification(_ model: IDODeviceNotificationModel) {
        guard model.dataType?.intValue == Self.taskStatusDataType else { return }
        guard let taskId = TaskListItemDraft.parseUInt32(model.taskId),
              let status = model.taskCompletStatus?.intValue else { return }
        appendLog(String(format: L10n.taskListNotifyLog, "\(taskId)", "\(status)"))
        let ok = applyStatusUpdate(taskId: taskId, status: status)
        commitStatusRefresh(updatedCount: ok ? 1 : 0, source: L10n.notification)
        // 133 不含 complete_timestamp，自动查询补齐完成时间
        if sdk.state.isConnected {
            queryStatusChanges(showFeedback: false)
        }
    }

    @objc private func onQueryStatusTapped() {
        guard ensureConnected() else { return }
        queryStatusChanges(showFeedback: true)
    }

    /// 查询任务状态变化列表：刷新 status + complete_timestamp；不判断功能表
    private func queryStatusChanges(showFeedback: Bool) {
        guard sdk.state.isConnected else { return }
        let param = IDOTaskListModel(operate: 2)
        let req = Self.prettyJsonString(param.toJsonString() ?? "{\"operate\":2}")
        appendLog(String(format: L10n.taskListQueryRequest, req))
        if showFeedback { SVProgressHUD.show(withStatus: L10n.taskListQuerying) }
        Cmds.taskList(param).send { [weak self] res in
            if showFeedback { SVProgressHUD.dismiss() }
            guard let self else { return }
            switch res {
            case .failure(let err):
                self.appendLog(String(format: L10n.taskListQueryReplyFail, "\(err.code)"))
                if showFeedback { SVProgressHUD.showError(withStatus: String(format: L10n.taskListQueryFail, "\(err.code)")) }
            case .success(let model):
                guard let model else {
                    self.appendLog(L10n.taskListQueryReplyEmpty)
                    if showFeedback { SVProgressHUD.showInfo(withStatus: L10n.noJsonReply) }
                    return
                }
                self.appendLog(String(format: L10n.taskListQueryReply, Self.formatReplyModel(model)))
                if let err = model.errorCode, err != 0 {
                    if showFeedback { SVProgressHUD.showError(withStatus: String(format: L10n.taskListErrorCodeEq, "\(err)")) }
                    return
                }
                var updated = 0
                for item in model.statusItems ?? [] {
                    let tid = TaskListItemDraft.parseUInt32(item.taskId) ?? item.taskId
                    let cts = TaskListItemDraft.parseUInt32(item.completeTimestamp) ?? 0
                    if self.applyStatusUpdate(
                        taskId: tid,
                        status: item.status,
                        completeTimestamp: cts
                    ) {
                        updated += 1
                    }
                }
                self.commitStatusRefresh(updatedCount: updated, source: L10n.taskListQueryStatus)
                if showFeedback {
                    let num = model.statusItemNum ?? model.statusItems?.count ?? 0
                    if updated > 0 {
                        SVProgressHUD.showSuccess(withStatus: String(format: L10n.taskListRefreshedStatus, updated))
                    } else if num > 0 {
                        SVProgressHUD.showInfo(withStatus: String(format: L10n.taskListDeviceNoLocal, num))
                    } else {
                        SVProgressHUD.showSuccess(withStatus: L10n.taskListNoStatusChange)
                    }
                }
            }
        }
    }

}

// MARK: - UITableView

extension TaskListFullSetVC: UITableViewDataSource, UITableViewDelegate {

    private enum Section: Int, CaseIterable {
        case pending = 0
        case sent = 1

        var title: String {
            switch self {
            case .pending: return L10n.taskListPendingSection
            case .sent: return L10n.taskListSentSection
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sec = Section(rawValue: section) else { return nil }
        let count = sec == .pending ? pendingItems.count : sentItems.count
        return String(format: L10n.taskListSectionCount, sec.title, count)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .pending:
            return max(pendingItems.count, 1) // 空态占位一行
        case .sent:
            return max(sentItems.count, 1)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.selectionStyle = .default
        cell.accessoryType = .none
        cell.imageView?.image = nil

        guard let sec = Section(rawValue: indexPath.section) else { return cell }
        switch sec {
        case .pending:
            if pendingItems.isEmpty {
                cell.textLabel?.text = L10n.taskListPendingEmpty
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
            } else {
                let item = pendingItems[indexPath.row]
                cell.textLabel?.text = item.listDisplayText()
                cell.textLabel?.textColor = .label
                cell.accessoryType = .disclosureIndicator
            }
        case .sent:
            if sentItems.isEmpty {
                cell.textLabel?.text = L10n.taskListSentEmpty
                cell.textLabel?.textColor = .secondaryLabel
                cell.selectionStyle = .none
            } else {
                let item = sentItems[indexPath.row]
                cell.textLabel?.text = item.listDisplayText()
                cell.textLabel?.textColor = .label
                cell.selectionStyle = .none
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sec = Section(rawValue: indexPath.section), sec == .pending else { return }
        guard !pendingItems.isEmpty else { return }
        showEditPendingDialog(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let sec = Section(rawValue: indexPath.section), sec == .pending else { return nil }
        guard !pendingItems.isEmpty else { return nil }
        let delete = UIContextualAction(style: .destructive, title: L10n.delete) { [weak self] _, _, done in
            self?.pendingItems.remove(at: indexPath.row)
            self?.refreshListUi()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - 编辑待发送：本地年月日时分秒选择 + 任务详情（与 Android 一致）

private final class TaskListEditPendingVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

    private let taskId: Int
    private let initialSecond: Int
    private let onSave: (Int, String) -> Void
    private var scrollBottomConstraint: Constraint?
    private weak var scrollViewRef: UIScrollView?

    private lazy var tipLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    private lazy var datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            p.preferredDatePickerStyle = .wheels
        }
        // 与 Android 一致：按手机本地时区选墙钟时间，保存时再换算为 UTC 秒
        p.timeZone = .current
        p.locale = Locale(identifier: "zh_CN")
        p.calendar = Calendar.current
        p.addTarget(self, action: #selector(onDateChanged), for: .valueChanged)
        return p
    }()

    private lazy var secondTitle: UILabel = {
        let l = UILabel()
        l.text = L10n.taskListSeconds
        l.font = .systemFont(ofSize: 13, weight: .medium)
        return l
    }()

    private lazy var secondPicker: UIPickerView = {
        let p = UIPickerView()
        p.dataSource = self
        p.delegate = self
        return p
    }()

    private lazy var detailTitle: UILabel = {
        let l = UILabel()
        l.text = L10n.taskListTaskDetail
        l.font = .systemFont(ofSize: 13, weight: .medium)
        return l
    }()

    private lazy var detailTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.layer.borderColor = UIColor.separator.cgColor
        tv.layer.borderWidth = 0.5
        tv.layer.cornerRadius = 8
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        tv.delegate = self
        tv.inputAccessoryView = makeKeyboardToolbar()
        return tv
    }()

    private lazy var detailCountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.textAlignment = .right
        return l
    }()

    private lazy var previewLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()

    init(draft: TaskListItemDraft, onSave: @escaping (Int, String) -> Void) {
        self.taskId = draft.taskId
        self.onSave = onSave
        let date = TaskListItemDraft.dateFromUtcTimestamp(draft.remindTimestamp)
        self.initialSecond = Calendar.current.component(.second, from: date)
        super.init(nibName: nil, bundle: nil)
        datePicker.date = date
        detailTextView.text = draft.taskDetail
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.taskListEditPending
        view.backgroundColor = .systemBackground
        tipLabel.text = String(format: L10n.taskListEditHint, "\(taskId)")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: L10n.cancel, style: .plain, target: self, action: #selector(onCancel)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.save, style: .done, target: self, action: #selector(onConfirm)
        )

        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        scrollViewRef = scroll
        let content = UIStackView(arrangedSubviews: [
            tipLabel, datePicker, secondTitle, secondPicker, detailTitle, detailTextView, detailCountLabel, previewLabel,
        ])
        content.axis = .vertical
        content.spacing = 10
        content.setCustomSpacing(4, after: secondTitle)
        content.setCustomSpacing(4, after: detailTitle)
        content.setCustomSpacing(4, after: detailTextView)

        view.addSubview(scroll)
        scroll.addSubview(content)
        scroll.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            scrollBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
        }
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scroll.snp.width).offset(-32)
        }
        secondPicker.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        detailTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(120)
        }
        secondPicker.selectRow(initialSecond, inComponent: 0, animated: false)
        refreshPreview()
        refreshDetailCount()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func makeKeyboardToolbar() -> UIToolbar {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: L10n.done, style: .done, target: self, action: #selector(dismissKeyboard)),
        ]
        return bar
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillChange(_ note: Notification) {
        guard
            let scroll = scrollViewRef,
            let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let keyboardInView = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardInView.minY - view.safeAreaInsets.bottom)
        scrollBottomConstraint?.update(offset: -overlap)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        DispatchQueue.main.async {
            scroll.scrollRectToVisible(
                self.detailTextView.convert(self.detailTextView.bounds, to: scroll).insetBy(dx: 0, dy: -24),
                animated: true
            )
        }
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        scrollBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func onDateChanged() {
        refreshPreview()
    }

    /// 按本地墙钟取年月日时分 + 秒选择器，再换算为协议 UTC 秒时间戳
    private func composedUtcTimestamp() -> Int {
        let cal = Calendar.current
        var comps = cal.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: datePicker.date
        )
        comps.second = secondPicker.selectedRow(inComponent: 0)
        let date = cal.date(from: comps) ?? datePicker.date
        return TaskListItemDraft.utcTimestamp(from: date)
    }

    private func refreshPreview() {
        let ts = composedUtcTimestamp()
        previewLabel.text =
            String(format: L10n.taskListLocalUtc, TaskListItemDraft.formatLocalDateTime(ts), ts)
    }

    private func refreshDetailCount() {
        let count = detailTextView.text.count
        detailCountLabel.text = "\(count)/\(TaskListItemDraft.taskDetailMaxChars)"
    }

    @objc private func onCancel() {
        dismiss(animated: true)
    }

    @objc private func onConfirm() {
        view.endEditing(true)
        let remind = composedUtcTimestamp()
        guard TaskListItemDraft.isValidUInt32(remind) else {
            SVProgressHUD.showError(withStatus: L10n.taskListRemindInvalid)
            return
        }
        let now = Int(Date().timeIntervalSince1970)
        guard remind > now else {
            SVProgressHUD.showError(withStatus: L10n.taskListRemindFuture)
            return
        }
        let detail = TaskListItemDraft.clampTaskDetail(detailTextView.text ?? "")
        onSave(remind, detail)
        dismiss(animated: true)
    }

    // MARK: UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let scroll = self.scrollViewRef else { return }
            scroll.scrollRectToVisible(
                textView.convert(textView.bounds, to: scroll).insetBy(dx: 0, dy: -24),
                animated: true
            )
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current = textView.text ?? ""
        guard let swiftRange = Range(range, in: current) else { return true }
        let next = current.replacingCharacters(in: swiftRange, with: text)
        return next.count <= TaskListItemDraft.taskDetailMaxChars
    }

    func textViewDidChange(_ textView: UITextView) {
        refreshDetailCount()
    }

    // MARK: UIPickerView — 秒

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 60 }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        String(format: "%02d", row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        refreshPreview()
    }
}
