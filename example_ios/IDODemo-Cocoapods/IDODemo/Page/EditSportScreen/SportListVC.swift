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
        self.navigationController?.title = "运动类型列表 / Sport type list"
        self.view.backgroundColor = .white
        self.tableView.backgroundColor = .white
        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: sportCellIdentifier)
        
        getSportScreenBaseInfoCmd()
    }
    
    func getSportScreenBaseInfoCmd(){
        SVProgressHUD.show()
        // 获取运动中屏幕显示基础信息
        // Get basic info for the in-sport screen display
        Cmds.getSportScreenBaseInfo().send { res in
            SVProgressHUD.dismiss()
            if case .success(let o) = res {
                // 成功
                // Succeeded
                self.screenInfoReplyModel = o
                print("get sport screen base info success：\(String(describing: o?.toJsonString()))")
                self.tableView.reloadData()
            }else
            {
                // 失败
                // Failed
                print("get sport screen base info failure")
            }
        }
    }
    
    func getSportName(_ sportType: Int) -> String{
        switch sportType {
        case 0x01: // 走路 / Walk
            return "walk".i18n
        case 0x02 : //跑步 / Run
            return "run".i18n
        case 0x03 : //骑行 / Ride
            return "ride".i18n
        case 0x04 : //徒步 / Hike
            return "hike".i18n
        case 0x05 : //游泳 / Swim
            return "swim".i18n
        case 0x06 : //爬山 / Mountain climbing
            return "mountain climbing".i18n
        case 0x07 : //羽毛球 / Badminton
            return "badminton".i18n
        case 0x08 : //其他(other) / Other
            return "other".i18n
        case 0x09 : //健身 / Fitness
            return "fitness".i18n
        case 0x0A : //动感单车 / Spinning
            return "spinning".i18n
        case 0x0B : //椭圆球 / Elliptical machine
            return "elliptical machine".i18n
        case 0x0C : //跑步机 / Treadmill
            return "treadmill".i18n
        case 0x0D : //仰卧起坐 / Sit-ups
            return "sit-ups".i18n
        case 0x0E : //俯卧撑 / Push-ups
            return "push-ups".i18n
        case 0x0F : //哑铃 / Dumbbells
            return "dumbbells".i18n
        case 0x10 : //举重 / Weight lifting
            return "weight lifting".i18n
        case 0x11 : //健身操 / Calisthenics
            return "calisthenics".i18n
        case 0x12 : //瑜伽 / Yoga
            return "yoga".i18n
        case 0x13 : //跳绳 / Rope skipping
            return "rope skipping".i18n
        case 0x14 : //乒乓球 / Table tennis
            return "table tennis".i18n
        case 0x15 : //篮球 / Basketball
            return "basketball".i18n
        case 0x16 : //足球 / Football
            return "football".i18n
        case 0x17 : //排球 / Volleyball
            return "volleyball".i18n
        case 0x18 : //网球 / Tennis
            return "tennis".i18n
        case 0x19 : //高尔夫 / Golf
            return "golf".i18n
        case 0x1A : //棒球 / Baseball
            return "baseball".i18n
        case 0x1B : //滑冰 / Skating
            return "skiing".i18n
        case 0x1C : //轮滑 / Roller skating
            return "roller skating".i18n
        case 0x1D : //跳舞 / Dancing
            return "dancing".i18n
        case 0x1F : //滚轮训练机 / Roller trainer
            return "indoor rowing".i18n
        case 0x20 : //普拉提 / Pilates
            return "pilates".i18n
        case 0x21 : //交叉训练 / Cross training
            return "cross training".i18n
        case 0x22 : //有氧运动 / Aerobics
            return "aerobics".i18n
        case 0x23 : //尊巴舞 / Zumba
            return "zumba".i18n
        case 0x24 : //广场舞 / Square dance
            return "square dance".i18n
        case 0x25 : //平板支撑 / Plank
            return "plank".i18n
        case 0x26 : //健身房 / Gym
            return "gym".i18n
        case 0x27 : //有氧健身操 / Aerobic calisthenics
            return ""
        case 0x30 : //户外跑步 / Outdoor running
            return "outdoor running".i18n
        case 0x31 : //室内跑步 / Indoor running
            return "indoor running".i18n
        case 0x32 : //户外骑行 / Outdoor cycling
            return "indoor cycling".i18n
        case 0x33 : //室内骑行 / Indoor cycling
            return "indoor cycling".i18n
        case 0x34 : //户外走路 / Outdoor walking
            return "outdoor walking".i18n
        case 0x35 : //室内走路 / Indoor walking
            return "indoor walking".i18n
        case 0x36 : //室内游泳(泳池游泳) / Indoor swimming (pool swimming)
            return "pool swimming".i18n
        case 0x37 : //室外游泳(开放水域游泳) / Outdoor swimming (open water swimming)
            return "open water swimming".i18n
        case 0x38 : //椭圆机 / Elliptical machine
            return "elliptical machine".i18n
        case 0x39 : //划船机 / Rowing machine
            return "rowing machine".i18n
        case 0x3A : //高强度间歇训练法 / High-intensity interval training
            return "high-intensity interval training".i18n
        case 0x4B : //板球运动 / Cricket
            return "cricket".i18n
        case 0x64 : //自由训练 / Free training
            return "free training".i18n
        case 0x65 : //功能性力量训练 / Functional strength training
            return "functional strength training".i18n
        case 0x66 : //核心训练 / Core training
            return "core training".i18n
        case 0x67 : //踏步机 / Stepper
            return "treadmills".i18n
        case 0x68 : //整理放松 / Cooldown
            return "organize and relax".i18n
        case 0x6E : //传统力量训练 / Traditional strength training
            return "traditional strength training".i18n
        case 0x70 : //引体向上 / Pull-ups
            return "pull ups".i18n
        case 0x72 : //开合跳 / Jumping jacks
            return "jumping jacks".i18n
        case 0x73 : //深蹲 / Squats
            return "squats".i18n
        case 0x74 : //高抬腿 / High knees
            return "high knees".i18n
        case 0x75 : //拳击 / Boxing
            return "boxing".i18n
        case 0x76 : //杠铃 / Barbell
            return "barbell".i18n
        case 0x77 : //武术 / Martial arts
            return "martial arts".i18n
        case 0x78 : //太极 / Tai chi
            return "tai chi".i18n
        case 0x79 : //跆拳道 / Taekwondo
            return "taekwondo".i18n
        case 0x7A : //空手道 / Karate
            return "karate".i18n
        case 0x7B : //自由搏击 / Kickboxing
            return "kickboxing".i18n
        case 0x7C : //击剑 / Fencing
            return "fencing".i18n
        case 0x7D : //射箭 / Archery
            return "archery".i18n
        case 0x7E : //体操 / Gymnastics
            return "gymnastics".i18n
        case 0x7F : //单杠 / Horizontal bar
            return "horizontal bar".i18n
        case 0x80 : //双杠 / Parallel bars
            return "parallel bar".i18n
        case 0x81 : //漫步机 / Walking machine
            return "walking machine".i18n
        case 0x82 : //登山机 / Climbing machine
            return "climbing machine".i18n
        case 0x83 : //保龄球 / Bowling
            return "bowling".i18n
        case 0x84 : //台球 / Billiards
            return "billiards".i18n
        case 0x85 : //曲棍球 / Hockey
            return "hockey".i18n
        case 0x86 : //橄榄球 / Rugby
            return "rugby".i18n
        case 0x87 : //壁球 / Squash
            return "squash".i18n
        case 0x88 : //垒球 / Softball
            return "softball".i18n
        case 0x89 : //手球 / Handball
            return "handball".i18n
        case 0x8A : //毽球 / Shuttlecock
            return "shuttlecock".i18n
        case 0x8B : //沙滩足球 / Beach soccer
            return "beach soccer".i18n
        case 0x8C : //藤球 / Sepak takraw
            return "sepak takraw".i18n
        case 0x8D : //躲避球 / Dodgeball
            return "dodgeball".i18n
        case 0x98 : //街舞 / Hip-hop
            return "hip-hop".i18n
        case 0x99 : //芭蕾 / Ballet
            return "ballet".i18n
        case 0x9A : //社交舞 / Social dance
            return "social dance".i18n
        case 0x9B : //飞盘 / Frisbee
            return "frisbee".i18n
        case 0x9C : //飞镖 / Darts
            return "darts".i18n
        case 0x9D : //骑马 / Horseback riding
            return "horseback riding"
        case 0x9E : //爬楼 / Stair climbing
            return "stair climbing".i18n
        case 0x9F : //放风筝 / Kite flying
            return "kite flying".i18n
        case 0xA0 : //钓鱼 / Fishing
            return "fishing".i18n
        case 0xA1 : //雪橇 / Sled
            return "sled".i18n
        case 0xA2 : //雪车 / Bobsleigh
            return "snowmobile".i18n
        case 0xA3 : //单板滑雪 / Snowboarding
            return "snowboard".i18n
        case 0xA4 : //雪上运动 / Snow sports
            return "snow sports".i18n
        case 0xA5 : //高山滑雪 / Alpine skiing
            return "alpine skiing".i18n
        case 0xA6 : //越野滑雪 / Cross-country skiing
            return "cross-country skiing".i18n
        case 0xA7 : //冰壶 / Curling
            return "curling".i18n
        case 0xA8 : //冰球 / Ice hockey
            return "ice hockey".i18n
        case 0xA9 : //冬季两项 / Biathlon
            return "biathlon".i18n
        case 0xAA : //冲浪 / Surfing
            return "surfing".i18n
        case 0xAB : //帆船 / Sailing
            return "sailing".i18n
        case 0xAC : //帆板 / Windsurfing
            return "windsurfing".i18n
        case 0xAD : //皮艇 / Kayak
            return "kayak".i18n
        case 0xAE : //摩托艇 / Motorboat
            return "motorboat".i18n
        case 0xAF : //划艇 / Paddling
            return "rowing".i18n
        case 0xB0 : //赛艇 / Rowing
            return "rowing".i18n
        case 0xB1 : //龙舟 / Dragon boat
            return "dragon boat".i18n
        case 0xB2 : //水球 / Water polo
            return "water polo".i18n
        case 0xB3 : //漂流 / Rafting
            return "rafting".i18n
        case 0xB4 : //滑板 / Skateboarding
            return "skateboarding"
        case 0xB5 : //攀岩 / Rock climbing
            return "rock climbing"
        case 0xB6 : //蹦极 / Bungee jumping
            return "bungee jumping".i18n
        case 0xB7 : //跑酷 / Parkour
            return "parkour".i18n
        case 0xB8 : //BMX
            return "BMX"
        case 0xBB : //足排球 / Soccer volleyball
            return "Soccer volleyball"
            
        case 0xBC : //站立滑水 / Standing water skiing
            return "Standing water skiing".i18n
        case 0xBD : //越野跑 / Cross-country running
            return "Cross country running".i18n
        case 0xBE : //卷腹 / Crunches
            return "Roll up the belly".i18n
        case 0xBF : //波比跳 / Burpees
            return "Wave ratio hop".i18n
        case 0xC0 : //卡巴迪 / Kabaddi
            return "".i18n
        case 0xC1 : //户外玩耍(KR01) / Outdoor play (KR01)
            return "Kabaddi".i18n
        case 0xC2 : //其他运动(KR01) / Other sports (KR01)
            return "Other Sports (KR01)".i18n
        case 0xC3 : //蹦床 / Trampoline
            return "trampoline".i18n
       
//        case 0xC4 : //呼啦圈 / //Hula hoop
//        case 0xC5 : //赛车 / //Auto racing
//        case 0xC6 : //战绳 / //Battle ropes
//        case 0xC7 : //跳伞 / //Skydiving
//        case 0xC8 : //定向越野 / //Orienteering
//        case 0xC9 : //山地骑行 / //Mountain biking
//        case 0xCA : //沙滩网球 / //Beach tennis
//        case 0xCB : //智能跳绳 / //Smart rope skipping
//        case 0xCC : //匹克球 / //Pickleball
//        case 0xCD : //轮椅运动 / //Wheelchair sports
//        case 0xCE : //体能训练 / //Physical training
//        case 0xCF : //壶铃训练 / //Kettlebell training
//        case 0xD0 : //团体操 / //Group gymnastics
//        case 0xD1 : //Cross fit
//        case 0xD2 : //障碍赛 / //Obstacle race
//        case 0xD3 : //滑板车 / //Scooter
//        case 0xD4 : //滑翔车 / //Glider
//        case 0xD5 : //滑雪 / //Skiing
//        case 0xD6 : //雪板滑雪 / //Snowboard skiing
//        case 0xD7 : //搏击操 / //Combat aerobics
//        case 0xD8 : //剑道 / //Kendo
//        case 0xD9 : //太极拳 / //Tai chi chuan
//        case 0xDA : //综合格斗 / //Mixed martial arts
//        case 0xDB : //角力 / //Wrestling
//        case 0xDC : //肚皮舞 / //Belly dance
//        case 0xDD : //爵士舞 / //Jazz dance
//        case 0xDE : //拉丁舞 / //Latin dance
//        case 0xDF : //踢踏舞 / //Tap dance
//        case 0xE0 : //其他舞蹈 / //Other dance
//        case 0xE1 : //沙滩排球 / //Beach volleyball
//        case 0xE2 : //门球 / //Gateball
//        case 0xE3 : //马球 / //Polo
//        case 0xE4 : //袋棍球 / //Lacrosse
//        case 0xE5 : //皮划艇 / //Canoeing
//        case 0xE6 : //桨板冲浪 / //Stand-up paddleboarding
//        case 0xE7 : //对战游戏 / //Battle games
//        case 0xE8 : //拔河 / //Tug of war
//        case 0xE9 : //秋千 / //Swing
//        case 0xEA : //马术运动 / //Equestrian
        case 0xEB : //田径 / Track and field
            return "Track and field".i18n
//        case 0xEC : //爬楼机 / //Stair climber
//        case 0xED : //柔韧训练 / //Flexibility training
//        case 0xEE : //国际象棋 / //Chess
//        case 0xEF : //国际跳棋 / //Checkers
//        case 0xF0 : //围棋 / //Go
//        case 0xF1 : //桥牌 / //Bridge
//        case 0xF2 : //桌游 / //Board games
//        case 0xF3 : //民族舞 / //Folk dance
//        case 0xF4 : //嘻哈舞 / //Hip-hop dance
//        case 0xF5 : //钢管舞 / //Pole dance
//        case 0xF6 : //霹雳舞 / //Breakdance
//        case 0xF7 : //现代舞 / //Modern dance
//        case 0xF8 : //泰拳 / //Muay Thai
//        case 0xF9 : //柔道 / //Judo
//        case 0xFA : //柔术 / //Jiu-jitsu
//        case 0xFB : //回力球 / //Jai alai
//        case 0xFC : //雪地摩托 / //Snowmobile
//        case 0xFD : //滑翔伞 / //Paragliding
//        case 0xFE : //长曲棍球 / //Lacrosse (long stick)
//        case 0xFF : //美式橄榄球 / //American football
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

