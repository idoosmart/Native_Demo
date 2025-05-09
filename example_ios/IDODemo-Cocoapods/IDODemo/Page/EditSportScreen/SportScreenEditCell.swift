//
//  SportScreenEditCell.swift
//  IDODemo
//
//  Created by cyf on 2025/3/14.
//

import UIKit
import SnapKit
import protocol_channel

class SportScreenEditCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func initUI(){
        self.contentView.addSubview(screenView)
        screenView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        self.contentView.addSubview(snLabel)
        snLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func addChildView(layoutStyle: IDOSportScreenLayoutType){
        screenView.addChildView(layoutStyle: layoutStyle)
    }
    
    func setData(_ model: IDOSportScreenItemModel){
        guard let dataItem = model.dataItem else {
            return
        }
        for (index,item) in dataItem.enumerated() {
            let view = screenView.findChildViewWithTag(index+10001)
            view.valueLabel.text = IDODataSubTypDict[item.dataSubType]?.i18n
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    lazy var snLabel: UILabel = {
        let snLabel = UILabel()
        snLabel.text = ""
        snLabel.textColor = .white
        snLabel.textAlignment = .center
        snLabel.backgroundColor = .gray
        snLabel.layer.cornerRadius = 15
        snLabel.clipsToBounds = true
        return snLabel
    }()
    
    lazy var screenView : SportScreenView = {
        let screenView = SportScreenView(frame: CGRect.zero)
        screenView.backgroundColor = .white
        return screenView
    }()
    
}

class SportScreenView:UIView {
    var openUserInteractionEnabled = false
    var clickAction: ((SportScreenChildView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
    }
    
    @objc func addAction(_ btn: SportScreenChildView){
        self.clickAction?(btn)
    }
    
    func findChildViewWithTag(_ tag: Int) -> SportScreenChildView{
        var c = SportScreenChildView()
        for v in self.subviews {
            if v.tag == tag {
                c = v as! SportScreenChildView
                break
            }
        }
        return c
    }
    
    func setData(_ model: IDOSportScreenItemModel){
        guard let dataItem = model.dataItem else {
            return
        }
        for (index,item) in dataItem.enumerated() {
            let view = self.findChildViewWithTag(index+10001)
            view.valueLabel.text = IDODataSubTypDict[item.dataSubType]?.i18n
        }
    }
    
    func addChildView(layoutStyle: IDOSportScreenLayoutType){
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        switch layoutStyle.layoutType {
        case 1:
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1)
            }
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
        case 2:
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }
            
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let bottomView = SportScreenChildView(type: .system)
            bottomView.tag = 10002
            bottomView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }
            bottomView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            break
        case 3:
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView = SportScreenChildView(type: .system)
            centerView.tag = 10002
            centerView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView)
            centerView.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            
            centerView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let bottomView = SportScreenChildView(type: .system)
            bottomView.tag = 10003
            bottomView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            bottomView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            break
        case 4:
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView1 = SportScreenChildView(type: .system)
            centerView1.tag = 10002
            centerView1.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView1)
            centerView1.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            centerView1.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView2 = SportScreenChildView(type: .system)
            centerView2.tag = 10003
            centerView2.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView2)
            centerView2.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            centerView2.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            
            let bottomView = SportScreenChildView(type: .system)
            bottomView.tag = 10004
            bottomView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(1.0/3)
            }
            bottomView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            break
        case 5:
            
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let topView2 = SportScreenChildView(type: .system)
            topView2.tag = 10002
            topView2.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView2)
            topView2.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            topView2.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView1 = SportScreenChildView(type: .system)
            centerView1.tag = 10003
            centerView1.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView1)
            centerView1.snp.makeConstraints { make in
                make.top.equalTo(topView2.snp.bottom).offset(0)
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView1.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView2 = SportScreenChildView(type: .system)
            centerView2.tag = 10004
            centerView2.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView2)
            centerView2.snp.makeConstraints { make in
                make.top.equalTo(topView2.snp.bottom).offset(0)
                make.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView2.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let bottomView = SportScreenChildView(type: .system)
            bottomView.tag = 10005
            bottomView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            bottomView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            break
        case 6:
            
            let topView = SportScreenChildView(type: .system)
            topView.tag = 10001
            topView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(topView)
            topView.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            topView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView1 = SportScreenChildView(type: .system)
            centerView1.tag = 10002
            centerView1.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView1)
            centerView1.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView1.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView2 = SportScreenChildView(type: .system)
            centerView2.tag = 10003
            centerView2.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView2)
            centerView2.snp.makeConstraints { make in
                make.top.equalTo(topView.snp.bottom).offset(0)
                make.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView2.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView3 = SportScreenChildView(type: .system)
            centerView3.tag = 10004
            centerView3.setUserInteractionEnabled(openUserInteractionEnabled)
            
            addSubview(centerView3)
            centerView3.snp.makeConstraints { make in
                make.top.equalTo(centerView1.snp.bottom).offset(0)
                make.left.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView3.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let centerView4 = SportScreenChildView(type: .system)
            centerView4.tag = 10005
            centerView4.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(centerView4)
            centerView4.snp.makeConstraints { make in
                make.top.equalTo(centerView2.snp.bottom).offset(0)
                make.right.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            centerView4.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            let bottomView = SportScreenChildView(type: .system)
            bottomView.tag = 10006
            bottomView.setUserInteractionEnabled(openUserInteractionEnabled)
            addSubview(bottomView)
            bottomView.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.25)
            }
            bottomView.addTarget(self, action: #selector(addAction(_:)), for: UIControl.Event.touchUpInside)
            
            break
        default:
            break
            
        }
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class SportScreenChildView:UIButton {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(type buttonType: UIButton.ButtonType){
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.gray.cgColor
        addSubview(valueLabel)
        //        addSubview(titleLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().offset(0)
            make.height.equalToSuperview().multipliedBy(1)
        }
        //        titleLabel.snp.makeConstraints { make in
        //            make.bottom.left.right.equalToSuperview().offset(0)
        //            make.height.equalToSuperview().multipliedBy(0.5)
        //        }
    }
    
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserInteractionEnabled(_ b: Bool) {
        isUserInteractionEnabled = b
        
    }
    // 重写高亮状态逻辑
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .darkGray : .white // 高亮状态背景色
        }
    }
    
    lazy var valueLabel: UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "-- --"
        valueLabel.textColor = .black
        valueLabel.textAlignment = .center
        return valueLabel
    }()
    
    //    lazy var titleLabel: UILabel = {
    //        let titleLabel = UILabel()
    //        titleLabel.text = "-- --"
    //        titleLabel.textColor = .black
    //        titleLabel.textAlignment = .center
    //        return titleLabel
    //    }()
    
}
