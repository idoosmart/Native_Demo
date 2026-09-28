//
//  TaskListTestVC.swift
//  Runner
//
//  15.114 任务清单 — 独立联调页入口
//  对齐 protocol_lib/example TaskListTestPage
//

import UIKit
import SnapKit
import SVProgressHUD
import protocol_channel

class TaskListTestVC: UIViewController {

    private lazy var statusBar: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 8
        v.alignment = .center
        v.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.95, alpha: 1)
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        return v
    }()

    private lazy var connChip = makeChip()
    private lazy var supportChip = makeChip()

    private lazy var btnFullSet: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.taskListFullSet, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.2, green: 0.55, blue: 0.95, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 6
        b.addTarget(self, action: #selector(openFullSet), for: .touchUpInside)
        return b
    }()

    private lazy var btnQuery: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(L10n.taskListQueryStatusChanges, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        b.backgroundColor = UIColor(red: 0.9, green: 0.93, blue: 0.98, alpha: 1)
        b.setTitleColor(UIColor(red: 0.15, green: 0.35, blue: 0.7, alpha: 1), for: .normal)
        b.layer.cornerRadius = 6
        b.addTarget(self, action: #selector(queryStatusChanges), for: .touchUpInside)
        return b
    }()

    private lazy var jsonTitle: UILabel = {
        let l = UILabel()
        l.text = L10n.requestReplyLog
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .darkGray
        return l
    }()

    private lazy var jsonView: UITextView = {
        let v = UITextView()
        v.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        v.isEditable = false
        v.backgroundColor = UIColor(white: 0.96, alpha: 1)
        v.layer.borderColor = UIColor.lightGray.cgColor
        v.layer.borderWidth = 0.5
        v.layer.cornerRadius = 6
        v.text = L10n.taskListQueryHint
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L10n.taskList
        view.backgroundColor = .white
        statusBar.addArrangedSubview(connChip)
        statusBar.addArrangedSubview(supportChip)
        statusBar.addArrangedSubview(UIView())

        view.addSubview(statusBar)
        view.addSubview(btnFullSet)
        view.addSubview(btnQuery)
        view.addSubview(jsonTitle)
        view.addSubview(jsonView)

        statusBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        btnFullSet.snp.makeConstraints { make in
            make.top.equalTo(statusBar.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        btnQuery.snp.makeConstraints { make in
            make.top.equalTo(btnFullSet.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        jsonTitle.snp.makeConstraints { make in
            make.top.equalTo(btnQuery.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(12)
        }
        jsonView.snp.makeConstraints { make in
            make.top.equalTo(jsonTitle.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
        refreshStatusBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStatusBar()
    }

    private func makeChip() -> UILabel {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.layer.cornerRadius = 4
        l.clipsToBounds = true
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }

    private func styleChip(_ label: UILabel, text: String, ok: Bool) {
        label.text = "  \(text)  "
        label.textColor = ok
            ? UIColor(red: 0.1, green: 0.4, blue: 0.15, alpha: 1)
            : UIColor(red: 0.55, green: 0.35, blue: 0.05, alpha: 1)
        label.backgroundColor = ok
            ? UIColor(red: 0.78, green: 0.9, blue: 0.79, alpha: 1)
            : UIColor(red: 1, green: 0.88, blue: 0.7, alpha: 1)
    }

    private func refreshStatusBar() {
        let connected = sdk.state.isConnected
        styleChip(connChip, text: connected ? L10n.connected : L10n.disconnected, ok: connected)
        let supported = sdk.funcTable.supportTaskList
        styleChip(supportChip, text: supported ? "supportTaskList" : L10n.unsupported, ok: supported)
    }

    private func ensureConnected() -> Bool {
        guard sdk.state.isConnected else {
            SVProgressHUD.showError(withStatus: L10n.deviceNotConnected)
            return false
        }
        return true
    }

    // MARK: - Log

    private static func timeStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: Date())
    }

    private func appendLog(_ text: String) {
        let line = "[\(Self.timeStamp())] \(text)"
        if jsonView.text.isEmpty
            || jsonView.text == L10n.taskListQueryHint
        {
            jsonView.text = line
        } else {
            jsonView.text += "\n" + line
        }
        let bottom = NSRange(location: max(jsonView.text.count - 1, 0), length: 1)
        jsonView.scrollRangeToVisible(bottom)
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

    @objc private func openFullSet() {
        navigationController?.pushViewController(TaskListFullSetVC(), animated: true)
    }

    /// 查询状态：不判断功能表；展示请求与回复日志
    @objc private func queryStatusChanges() {
        guard ensureConnected() else { return }
        let param = IDOTaskListModel(operate: 2)
        let req = Self.prettyJsonString(param.toJsonString() ?? "{\"operate\":2}")
        appendLog(String(format: L10n.taskListQueryRequest, req))
        SVProgressHUD.show(withStatus: L10n.taskListQuerying)
        Cmds.taskList(param).send { [weak self] res in
            SVProgressHUD.dismiss()
            guard let self else { return }
            switch res {
            case .failure(let err):
                self.appendLog(String(format: L10n.taskListQueryReplyFail, "\(err.code)"))
                SVProgressHUD.showError(withStatus: String(format: L10n.failedCode, "\(err.code)"))
            case .success(let model):
                guard let model else {
                    self.appendLog(L10n.taskListQueryReplyEmpty)
                    SVProgressHUD.showInfo(withStatus: L10n.noJsonReply)
                    return
                }
                self.appendLog(String(format: L10n.taskListQueryReply, Self.formatReply(model)))
                SVProgressHUD.showSuccess(withStatus: L10n.taskListQueryDone)
            }
        }
    }

    private static func formatReply(_ model: IDOTaskListModel) -> String {
        var root: [String: Any] = ["operate": model.operate]
        if let err = model.errorCode { root["error_code"] = err }
        if model.operate == 2 {
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
}
