//
//  SportScreenEditViewController.swift
//  IDOEditScreenDemo
//
//  Created by cyf on 2025/3/13.
//

import UIKit
import SnapKit
import protocol_channel
import SVProgressHUD

class SportScreenOperationItem: NSObject {
    
    var title = ""
    init(title: String = "") {
        self.title = title
    }
}



fileprivate let sportScreenCellIdentifier = "SportScreenCellIdentifier"

class SportScreenEditVC: UIViewController {
    
    var selectIndex = 0;
    var sportType: Int?
    var screenInfoReplyModel: IDOSportScreenInfoReplyModel?
    var screenSportDetai: IDOSportScreenInfoReplyModel?
    var selectScreenLayoutType: IDOSportScreenLayoutType?
    var screenItems = [IDOSportScreenItemModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "运动屏幕编辑"
        self.view.backgroundColor = .gray
        initUI()
        addObserverEvent()
        getSportScreenDetailInfo()
        
    }
    
    func getSportScreenDetailInfo(){
        SVProgressHUD.show()
        // 获取运动中屏幕显示详情信息
        guard let sportType = self.sportType else {return}
        let sportItem = IDOSportScreenSportItemModel(sportType: sportType, screenItems: nil)
        Cmds.getSportScreenDetailInfo([sportItem]).send { res in
            SVProgressHUD.dismiss()
            if case .success(let o) = res {
                print("get sport screen detail info success：\(String(describing: o?.toJsonString()))")
                self.screenSportDetai = o
                if let screenItems = o?.sportItems?.first?.screenItems, screenItems.count > 0 {
                    let layoutType = IDOSportScreenLayoutType()
                    layoutType.layoutType = screenItems[self.selectIndex].dataItem?.count ?? 0
                    self.screenView.addChildView(layoutStyle:layoutType)
                    self.screenView.setData(screenItems[self.selectIndex])
                    self.screenItems = screenItems
                }
                self.tableView.reloadData()
                
                
            }else{
                print("get sport screen detail info failure")
                
            }
        }
        
    }
    
    @objc func saveData(){
        guard screenItems.count > 0 ,let sportType = self.sportType else {
            return
        }
        for (i,item)  in screenItems.enumerated(){
            if var dataItem = item.dataItem {
                var dStr = ""
                for d in dataItem {
                    
                    dStr.append(IDODataSubTypDict[d.dataSubType]?.i18n ?? "")
                    dStr.append(" + ")
                    print("dataSubType: \(d.dataSubType.rawValue)")
                }
                
                print("dStr: \(dStr) ")
                
            }
        }
        
        SVProgressHUD.show()
        let sportItem = IDOSportScreenSportItemModel(sportType: sportType , screenItems: screenItems)
        Cmds.setSportScreen([sportItem]).send { res in
            SVProgressHUD.dismiss()
            if case .success(_) = res {
                // 成功
                print("set sport screen succes")
                
                
            }else {
                // 失败
                print("set sport screen failure")
            }
        }
        
        
        
    }
    
    
    func initUI(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save",
                                                                 style: UIBarButtonItem.Style.done,
                                                                 target: self,
                                                                 action: #selector(saveData))
        let screenWidth = UIScreen.main.bounds.width
        self.view .addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(64)
            make.width.equalTo(screenWidth*0.4)
            make.bottom.equalTo(-100)
        }
        
        let padding = 10
        let width = (Int(screenWidth) - padding * 5)/4
        var i = 0
        for item in [
            SportScreenOperationItem(title: "top move"),
            SportScreenOperationItem(title: "bottom move"),
            SportScreenOperationItem(title: "add"),
            SportScreenOperationItem(title: "delete")
        ] {
            let btn = UIButton(type: .system)
            btn.setTitle(item.title, for: UIControl.State.normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
            btn.titleLabel?.numberOfLines = 2
            btn.backgroundColor = .orange
            btn.addTarget(self, action: #selector(operationAction(_:)), for: UIControl.Event.touchUpInside)
            view.addSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.equalTo(width)
                make.height.equalTo(40)
                make.left.equalTo(padding+(width+padding)*i)
                make.bottom.equalTo(self.view.snp.bottom).offset(-20)
            }
            
            i+=1
        }
        
        view.addSubview(screenView)
        screenView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.top).offset(50)
            make.right.equalToSuperview().offset(-5)
            make.width.equalTo(screenWidth*0.5)
            make.height.equalTo(screenWidth*0.5)
        }
        
        
        view.addSubview(switchLayoutBtn)
        switchLayoutBtn.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.right.equalTo(-15)
            make.bottom.equalTo(self.view.snp.bottom).offset(-80)
        }
    }
    
    @objc func operationAction(_ btn: UIButton){
        switch btn.titleLabel?.text {
        case "top move":
            
            if screenItems.count >= 2 {
                guard selectIndex >= 1 && selectIndex <= screenItems.count-1 else{
                    return
                }
                let empty1 = screenItems[selectIndex]
                let empty2 = screenItems[selectIndex-1]
                screenItems[selectIndex] = empty2
                screenItems[selectIndex-1] = empty1
                selectIndex = selectIndex - 1
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: selectIndex), at: UITableView.ScrollPosition.top, animated: true)
                
                let layout = IDOSportScreenLayoutType()
                layout.layoutType = screenItems[selectIndex].dataItem?.count ?? 0
                screenView.addChildView(layoutStyle: layout)
                screenView.setData(screenItems[selectIndex])
            }
            break
        case "bottom move":
            
            if screenItems.count >= 2 {
                guard selectIndex >= 0 && selectIndex < screenItems.count-1 else{return}
                let empty1 = screenItems[selectIndex]
                let empty2 = screenItems[selectIndex+1]
                screenItems[selectIndex] = empty2
                screenItems[selectIndex+1] = empty1
                selectIndex = selectIndex + 1
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: selectIndex), at: UITableView.ScrollPosition.bottom, animated: true)
                
                let layout = IDOSportScreenLayoutType()
                layout.layoutType = screenItems[selectIndex].dataItem?.count ?? 0
                screenView.addChildView(layoutStyle: layout)
                screenView.setData(screenItems[selectIndex])
                
            }
            break
        case "add":
            let alertController = UIAlertController(title: "Selected Option", message: "", preferredStyle: UIAlertController.Style.actionSheet)
            guard let screenConfItems = self.screenInfoReplyModel?.screenConfItems else {
                return
            }
            // Create the actions
            for item in screenConfItems {
                let optionAction = UIAlertAction(title: "Option\(item.layoutType)", style: .default) { [self] action in
                    let str = String(action.title?.last ?? "0")
                    if let index = Int(str) {
                        // Handle Option 1 selection
                        print("Option  selected: \(action.title?.last ?? "0")")
                        let layoutType = IDOSportScreenLayoutType()
                        layoutType.layoutType = index
                        
                        var didataItems = [IDOSportScreenDataItemModel]()
                        for _ in 0..<index {
                            didataItems.append(IDOSportScreenDataItemModel(dataType: .none, subType: .none))
                        }
                        let screenItemModel = IDOSportScreenItemModel(dataItem: didataItems)
                        screenItems.append(screenItemModel)
                        selectIndex = screenItems.count-1
                        self.tableView.reloadData()
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: screenItems.count-1), at: UITableView.ScrollPosition.bottom, animated: true)
                        
                        screenView.addChildView(layoutStyle:layoutType)
                        screenView.setData(screenItems[selectIndex])
                        
                    }
                    
                    
                }
                alertController.addAction(optionAction)
            }
            
            self.present(alertController, animated: true)
            
            break
        case "delete":
            if screenItems.count > 0  && selectIndex >= 1{
                screenItems.remove(at:screenItems.count-1)
                selectIndex = screenItems.count-1
                self.tableView.reloadData()
                let layout = IDOSportScreenLayoutType()
                layout.layoutType = screenItems[selectIndex].dataItem?.count ?? 0
                screenView.addChildView(layoutStyle: layout)
                screenView.setData(screenItems[selectIndex])
                
            }
            
            
            break
        default: break
            
        }
        self.tableView.reloadData()
    }
    
    @objc func switchLayoutAction(_ btn: UIButton){
        let alertController = UIAlertController(title: "Selected Option  ", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        guard let screenConfItems = self.screenInfoReplyModel?.screenConfItems else {
            return
        }
        // Create the actions
        for item in screenConfItems {
            let optionAction = UIAlertAction(title: "Option\(item.layoutType)", style: .default) { [self] action in
                let str = String(action.title?.last ?? "0")
                if let index = Int(str) {
                    // Handle Option 1 selection
                    print("Option  selected: \(action.title?.last ?? "0")")
                    
                    if screenItems.count > 0,let count = screenItems[selectIndex].dataItem?.count {
                        if index > count{
                            let diff = index - count
                            for _ in 0..<diff {
                                self.screenItems[selectIndex].dataItem?.append(IDOSportScreenDataItemModel(dataType: IDODataType.none, subType: IDODataSubType.none))
                            }
                        }else if index < count {
                            let diff =  count - index
                            for _ in 0..<diff {
                                self.screenItems[selectIndex].dataItem?.removeLast()
                                print("index: \(index) \(String(describing: self.screenItems[selectIndex].dataItem?.count))")
                            }
                            
                        }
                        
                        let screenLayoutType = IDOSportScreenLayoutType()
                        screenLayoutType.layoutType = index
                        screenView.addChildView(layoutStyle: screenLayoutType)
                        selectScreenLayoutType  = screenLayoutType
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: selectIndex)], with: UITableView.RowAnimation.automatic)
                        screenView.setData(screenItems[selectIndex])
                        
                    }
                }
                
                
            }
            alertController.addAction(optionAction)
            
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .gray
        // Do any additional setup after loading the view.
        tableView.register(SportScreenEditCell.self, forCellReuseIdentifier: sportScreenCellIdentifier)
        return tableView
    }()
    
    lazy var screenView: SportScreenView = {
        let screenView = SportScreenView(frame: CGRect.zero)
        screenView.openUserInteractionEnabled = true
        return screenView
    }()
    
    lazy var switchLayoutBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Switch Layout", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(switchLayoutAction(_:)), for: UIControl.Event.touchUpInside)
        view.addSubview(btn)
        return btn
    }()
    
    
    
    
}

extension SportScreenEditVC: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return screenItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width/3
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        view.backgroundColor = .gray
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sportScreenCellIdentifier, for: indexPath) as? SportScreenEditCell
        guard let c = cell else {
            return UITableViewCell()
        }
        if screenItems.count > 0 {
            let item = screenItems[indexPath.section]
            c.snLabel.text = "\(indexPath.section+1)"
            let layout = IDOSportScreenLayoutType()
            layout.layoutType = item.dataItem?.count ?? 0
            c.addChildView(layoutStyle:layout)
            if let d = selectScreenLayoutType, selectIndex == indexPath.section {
                c.addChildView(layoutStyle:d)
            }
            c.setData(item)
            c.snLabel.backgroundColor = selectIndex == indexPath.section ? .blue : .gray
        }
        
        return c
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if screenItems.count > 0 {
            let item = screenItems[indexPath.section]
            selectIndex = indexPath.section
            let layout = IDOSportScreenLayoutType()
            layout.layoutType = item.dataItem?.count ?? 0
            selectScreenLayoutType = layout
            screenView.addChildView(layoutStyle:layout)
            screenView.setData(item)
            tableView.reloadData()
        }
        
    }
}

extension SportScreenEditVC {
    
    func addObserverEvent(){
        screenView.clickAction = { btn in
            let modelVC =  SportDualTableViewController()
            modelVC.screenSportDetai = self.screenSportDetai
            self.present(modelVC, animated: true, completion: nil)
            
            modelVC.didSelectCallBack = { model in
                if  self.screenItems.count > 0 {
                    let item = self.screenItems[self.selectIndex]
                    guard let count = item.dataItem?.count, count > 0 else {
                        return
                    }
                    let i = btn.tag - 10001
                    let itemModel = IDOSportScreenDataItemModel(dataType: model.dataType, subType: model.dataSubType)
                    if let count = item.dataItem?.count , i < count {
                        item.dataItem![i] = itemModel
                    }
                    self.tableView.reloadData()
                    self.screenView.setData(item)
                }
            }
        }
    }
    
    
}
