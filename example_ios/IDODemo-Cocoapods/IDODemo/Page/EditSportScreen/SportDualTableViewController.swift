//
//  ViewController.swift
//  IDODemo
//
//  Created by cyf on 2025/3/15.
//

import UIKit
import SnapKit
import protocol_channel

class SportDualTableViewController: UIViewController {
    
    var screenSportDetai: IDOSportScreenInfoReplyModel?
    var didSelectCallBack: ((IDOSportScreenDataItemModel) -> Void)?
    
    // 定义两个 TableView
    private let leftTableView = UITableView()
    private let rightTableView = UITableView()
    var leftSelectIndex = 0
    var rightSelectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 配置左侧 TableView
        leftTableView.dataSource = self
        leftTableView.delegate = self
        leftTableView.tag = 0 // 标记左侧列表
        leftTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LeftCell")
        
        // 配置右侧 TableView
        rightTableView.dataSource = self
        rightTableView.delegate = self
        rightTableView.tag = 1 // 标记右侧列表
        rightTableView.register(UITableViewCell.self, forCellReuseIdentifier: "RightCell")
        
        // 使用 StackView 横向排列
        let stackView = UIStackView(arrangedSubviews: [leftTableView, rightTableView])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually // 等宽分布
        stackView.spacing = 8
        
        // 布局
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 80),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.addSubview(cancelBtn)
        view.addSubview(confirmBtn)
        cancelBtn.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-5)
        }
    }
    
    @objc func cancelAction(_ btn: UIButton){
        dismiss(animated: true)
    }
    
    @objc func confirmAction(_ btn: UIButton){
        dismiss(animated: true)
    }
    
    lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(type: .system)
        cancelBtn.setTitle("Cancel", for: UIControl.State.normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction(_:)), for: UIControl.Event.touchUpInside)
        view.addSubview(cancelBtn)
        return cancelBtn
    }()
    
    lazy var confirmBtn: UIButton = {
        let confirmBtn = UIButton(type: .system)
        confirmBtn.setTitle("Confirm", for: UIControl.State.normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        confirmBtn.addTarget(self, action: #selector(confirmAction(_:)), for: UIControl.Event.touchUpInside)
        view.addSubview(confirmBtn)
        return confirmBtn
    }()
}

// MARK: - UITableView 数据源和代理
extension SportDualTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return self.screenSportDetai?.sportItems?.first?.supportDataTypes?.count ?? 0
            
        }else
        {
            if let supportDataTypes  = self.screenSportDetai?.sportItems?.first?.supportDataTypes,supportDataTypes.count > 0  {
                
                if supportDataTypes[leftSelectIndex].dataValue.count > 0 {
                    return supportDataTypes[leftSelectIndex].dataValue.count
                }
                
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 { // 左侧列表
            let cell = tableView.dequeueReusableCell(withIdentifier: "LeftCell", for: indexPath)
            let dataType = self.screenSportDetai?.sportItems?.first?.supportDataTypes?[indexPath.row].dataType
            cell.textLabel?.text = IDODataTypDict[dataType ?? .none]?.i18n
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            return cell
        } else { // 右侧列表
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightCell", for: indexPath)
            let dataSubValue =  self.screenSportDetai?.sportItems?.first?.supportDataTypes?[leftSelectIndex].dataValue[indexPath.row]
            cell.textLabel?.text = IDODataSubTypDict[dataSubValue ?? .none]?.i18n
            cell.textLabel?.textColor = .systemBlue
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44 // 统一行高
    }
    
    // 点击事件示例
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            leftSelectIndex = indexPath.row
            rightTableView.reloadData()
        }else {
            rightSelectIndex = indexPath.row
            if let callback =  self.didSelectCallBack {
                if let supportDataTypes  = self.screenSportDetai?.sportItems?.first?.supportDataTypes,supportDataTypes.count > 0  {
                    
                    let dayaType = supportDataTypes[leftSelectIndex].dataType
                    if supportDataTypes[leftSelectIndex].dataValue.count > 0 {
                        let subDataVaule =  supportDataTypes[leftSelectIndex].dataValue[indexPath.row]
                        let model = IDOSportScreenDataItemModel(dataType: dayaType, subType: subDataVaule)
                        callback(model)
                    }
                    
                }
            }
        }
    }
}
