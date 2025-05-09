//
//  ViewController.swift
//  IDOEditScreenDemo
//
//  Created by cyf on 2025/3/13.
//

import UIKit
import protocol_channel
import SVProgressHUD

fileprivate let sportCellIdentifier = "SportCellIdentifier"

class SportListVC: UITableViewController {
    
    var screenInfoReplyModel:IDOSportScreenInfoReplyModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "运动类型列表"
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: sportCellIdentifier)
        
        getSportScreenBaseInfoCmd()
    }
    
    func getSportScreenBaseInfoCmd(){
        SVProgressHUD.show()
        // 获取运动中屏幕显示基础信息
        Cmds.getSportScreenBaseInfo().send { res in
            SVProgressHUD.dismiss()
            if case .success(let o) = res {
                // 成功
                self.screenInfoReplyModel = o
                print("get sport screen base info success：\(String(describing: o?.toJsonString()))")
                self.tableView.reloadData()
            }else
            {
                // 失败
                print("get sport screen base info failure")
            }
        }
    }
    
    func getSportName(_ sportType: Int) -> String{
        switch sportType {
        case 0x01: // 走路
            return "walk".i18n
        case 0x02 : //跑步
            return "run".i18n
        case 0x03 : //骑行
            return "ride".i18n
        case 0x04 : //徒步
            return "hike".i18n
        case 0x05 : //游泳
            return "swim".i18n
        case 0x06 : //爬山
            return "mountain climbing".i18n
        case 0x07 : //羽毛球
            return "badminton".i18n
        case 0x08 : //其他(other)
            return "other".i18n
        case 0x09 : //健身
            return "fitness".i18n
        case 0x0A : //动感单车
            return "spinning".i18n
        case 0x0B : //椭圆球
            return "elliptical machine".i18n
        case 0x0C : //跑步机
            return "treadmill".i18n
        case 0x0D : //仰卧起坐
            return "sit-ups".i18n
        case 0x0E : //俯卧撑
            return "push-ups".i18n
        case 0x0F : //哑铃
            return "dumbbells".i18n
        case 0x10 : //举重
            return "weight lifting".i18n
        case 0x11 : //健身操
            return "calisthenics".i18n
        case 0x12 : //瑜伽
            return "yoga".i18n
        case 0x13 : //跳绳
            return "rope skipping".i18n
        case 0x14 : //乒乓球
            return "table tennis".i18n
        case 0x15 : //篮球
            return "basketball".i18n
        case 0x16 : //足球
            return "football".i18n
        case 0x17 : //排球
            return "volleyball".i18n
        case 0x18 : //网球
            return "tennis".i18n
        case 0x19 : //高尔夫
            return "golf".i18n
        case 0x1A : //棒球
            return "baseball".i18n
        case 0x1B : //滑冰
            return "skiing".i18n
        case 0x1C : //轮滑
            return "roller skating".i18n
        case 0x1D : //跳舞
            return "dancing".i18n
        case 0x1F : //滚轮训练机
            return "indoor rowing".i18n
        case 0x20 : //普拉提
            return "pilates".i18n
        case 0x21 : //交叉训练
            return "cross training".i18n
        case 0x22 : //有氧运动
            return "aerobics".i18n
        case 0x23 : //尊巴舞
            return "zumba".i18n
        case 0x24 : //广场舞
            return "square dance".i18n
        case 0x25 : //平板支撑
            return "plank".i18n
        case 0x26 : //健身房
            return "gym".i18n
        case 0x27 : //有氧健身操
            return ""
        case 0x30 : //户外跑步
            return "outdoor running".i18n
        case 0x31 : //室内跑步
            return "indoor running".i18n
        case 0x32 : //户外骑行
            return "indoor cycling".i18n
        case 0x33 : //室内骑行
            return "indoor cycling".i18n
        case 0x34 : //户外走路
            return "outdoor walking".i18n
        case 0x35 : //室内走路
            return "indoor walking".i18n
        case 0x36 : //室内游泳(泳池游泳)
            return "pool swimming".i18n
        case 0x37 : //室外游泳(开放水域游泳)
            return "open water swimming".i18n
        case 0x38 : //椭圆机
            return "elliptical machine".i18n
        case 0x39 : //划船机
            return "rowing machine".i18n
        case 0x3A : //高强度间歇训练法
            return "high-intensity interval training".i18n
        case 0x4B : //板球运动
            return "cricket".i18n
        case 0x64 : //自由训练
            return "free training".i18n
        case 0x65 : //功能性力量训练
            return "functional strength training".i18n
        case 0x66 : //核心训练
            return "core training".i18n
        case 0x67 : //踏步机
            return "treadmills".i18n
        case 0x68 : //整理放松
            return "organize and relax".i18n
        case 0x6E : //传统力量训练
            return "traditional strength training".i18n
        case 0x70 : //引体向上
            return "pull ups".i18n
        case 0x72 : //开合跳
            return "jumping jacks".i18n
        case 0x73 : //深蹲
            return "squats".i18n
        case 0x74 : //高抬腿
            return "high knees".i18n
        case 0x75 : //拳击
            return "boxing".i18n
        case 0x76 : //杠铃
            return "barbell".i18n
        case 0x77 : //武术
            return "martial arts".i18n
        case 0x78 : //太极
            return "tai chi".i18n
        case 0x79 : //跆拳道
            return "taekwondo".i18n
        case 0x7A : //空手道
            return "karate".i18n
        case 0x7B : //自由搏击
            return "kickboxing".i18n
        case 0x7C : //击剑
            return "fencing".i18n
        case 0x7D : //射箭
            return "archery".i18n
        case 0x7E : //体操
            return "gymnastics".i18n
        case 0x7F : //单杠
            return "horizontal bar".i18n
        case 0x80 : //双杠
            return "parallel bar".i18n
        case 0x81 : //漫步机
            return "walking machine".i18n
        case 0x82 : //登山机
            return "climbing machine".i18n
        case 0x83 : //保龄球
            return "bowling".i18n
        case 0x84 : //台球
            return "billiards".i18n
        case 0x85 : //曲棍球
            return "hockey".i18n
        case 0x86 : //橄榄球
            return "rugby".i18n
        case 0x87 : //壁球
            return "squash".i18n
        case 0x88 : //垒球
            return "softball".i18n
        case 0x89 : //手球
            return "handball".i18n
        case 0x8A : //毽球
            return "shuttlecock".i18n
        case 0x8B : //沙滩足球
            return "beach soccer".i18n
        case 0x8C : //藤球
            return "sepak takraw".i18n
        case 0x8D : //躲避球
            return "dodgeball".i18n
        case 0x98 : //街舞
            return "hip-hop".i18n
        case 0x99 : //芭蕾
            return "ballet".i18n
        case 0x9A : //社交舞
            return "social dance".i18n
        case 0x9B : //飞盘
            return "frisbee".i18n
        case 0x9C : //飞镖
            return "darts".i18n
        case 0x9D : //骑马
            return "horseback riding"
        case 0x9E : //爬楼
            return "stair climbing".i18n
        case 0x9F : //放风筝
            return "kite flying".i18n
        case 0xA0 : //钓鱼
            return "fishing".i18n
        case 0xA1 : //雪橇
            return "sled".i18n
        case 0xA2 : //雪车
            return "snowmobile".i18n
        case 0xA3 : //单板滑雪
            return "snowboard".i18n
        case 0xA4 : //雪上运动
            return "snow sports".i18n
        case 0xA5 : //高山滑雪
            return "alpine skiing".i18n
        case 0xA6 : //越野滑雪
            return "cross-country skiing".i18n
        case 0xA7 : //冰壶
            return "curling".i18n
        case 0xA8 : //冰球
            return "ice hockey".i18n
        case 0xA9 : //冬季两项
            return "biathlon".i18n
        case 0xAA : //冲浪
            return "surfing".i18n
        case 0xAB : //帆船
            return "sailing".i18n
        case 0xAC : //帆板
            return "windsurfing".i18n
        case 0xAD : //皮艇
            return "kayak".i18n
        case 0xAE : //摩托艇
            return "motorboat".i18n
        case 0xAF : //划艇
            return "rowing".i18n
        case 0xB0 : //赛艇
            return "rowing".i18n
        case 0xB1 : //龙舟
            return "dragon boat".i18n
        case 0xB2 : //水球
            return "water polo".i18n
        case 0xB3 : //漂流
            return "rafting".i18n
        case 0xB4 : //滑板
            return "skateboarding"
        case 0xB5 : //攀岩
            return "rock climbing"
        case 0xB6 : //蹦极
            return "bungee jumping".i18n
        case 0xB7 : //跑酷
            return "parkour".i18n
        case 0xB8 : //BMX
            return "BMX"
        case 0xBB : //足排球
            return "Soccer volleyball"
            
        case 0xBC : //站立滑水
            return "Standing water skiing".i18n
        case 0xBD : //越野跑
            return "Cross country running".i18n
        case 0xBE : //卷腹
            return "Roll up the belly".i18n
        case 0xBF : //波比跳
            return "Wave ratio hop".i18n
        case 0xC0 : //卡巴迪
            return "".i18n
        case 0xC1 : //户外玩耍(KR01)
            return "Kabaddi".i18n
        case 0xC2 : //其他运动(KR01)
            return "Other Sports (KR01)".i18n
        case 0xC3 : //蹦床
            return "trampoline".i18n
       
//        case 0xC4 : //呼啦圈
//        case 0xC5 : //赛车
//        case 0xC6 : //战绳
//        case 0xC7 : //跳伞
//        case 0xC8 : //定向越野
//        case 0xC9 : //山地骑行
//        case 0xCA : //沙滩网球
//        case 0xCB : //智能跳绳
//        case 0xCC : //匹克球
//        case 0xCD : //轮椅运动
//        case 0xCE : //体能训练
//        case 0xCF : //壶铃训练
//        case 0xD0 : //团体操
//        case 0xD1 : //Cross fit
//        case 0xD2 : //障碍赛
//        case 0xD3 : //滑板车
//        case 0xD4 : //滑翔车
//        case 0xD5 : //滑雪
//        case 0xD6 : //雪板滑雪
//        case 0xD7 : //搏击操
//        case 0xD8 : //剑道
//        case 0xD9 : //太极拳
//        case 0xDA : //综合格斗
//        case 0xDB : //角力
//        case 0xDC : //肚皮舞
//        case 0xDD : //爵士舞
//        case 0xDE : //拉丁舞
//        case 0xDF : //踢踏舞
//        case 0xE0 : //其他舞蹈
//        case 0xE1 : //沙滩排球
//        case 0xE2 : //门球
//        case 0xE3 : //马球
//        case 0xE4 : //袋棍球
//        case 0xE5 : //皮划艇
//        case 0xE6 : //桨板冲浪
//        case 0xE7 : //对战游戏
//        case 0xE8 : //拔河
//        case 0xE9 : //秋千
//        case 0xEA : //马术运动
        case 0xEB : //田径
            return "Track and field".i18n
//        case 0xEC : //爬楼机
//        case 0xED : //柔韧训练
//        case 0xEE : //国际象棋
//        case 0xEF : //国际跳棋
//        case 0xF0 : //围棋
//        case 0xF1 : //桥牌
//        case 0xF2 : //桌游
//        case 0xF3 : //民族舞
//        case 0xF4 : //嘻哈舞
//        case 0xF5 : //钢管舞
//        case 0xF6 : //霹雳舞
//        case 0xF7 : //现代舞
//        case 0xF8 : //泰拳
//        case 0xF9 : //柔道
//        case 0xFA : //柔术
//        case 0xFB : //回力球
//        case 0xFC : //雪地摩托
//        case 0xFD : //滑翔伞
//        case 0xFE : //长曲棍球
//        case 0xFF : //美式橄榄球
        default:
            return "\(sportType)"
        }
    }
}

extension SportListVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.screenInfoReplyModel?.sportItems?.count ?? 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sportCellIdentifier, for: indexPath)
        if let count = self.screenInfoReplyModel?.sportItems?.count,
           let sportItems = self.screenInfoReplyModel?.sportItems, count > 0 {
            cell.textLabel?.text = self.getSportName(sportItems[indexPath.row].sportType)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let count = self.screenInfoReplyModel?.sportItems?.count,
           let sportItems = self.screenInfoReplyModel?.sportItems, count > 0 {
            let sportScrrenEditVC = SportScreenEditVC()
            sportScrrenEditVC.screenInfoReplyModel = self.screenInfoReplyModel
            sportScrrenEditVC.sportType = sportItems[indexPath.row].sportType
            self.navigationController?.pushViewController(sportScrrenEditVC, animated: true)
        }
       
    }
}

