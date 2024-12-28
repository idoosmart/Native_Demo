//
//  SyncDataVC.swift
//  IDODemo
//
//  Created by hc on 2023/10/26.
//

import UIKit
import MapKit
import CoreLocation

import RxCocoa
import RxSwift
import SnapKit
import SVProgressHUD

import protocol_channel

class SportVC: UIViewController {
    private let disposeBag = DisposeBag()
    private var disposeTimer = DisposeBag()
    private var baseModel: IDOExchangeBaseModel?
    private var duration = 0
    private var calories = 0
    private var distance = 0
    private var isSportEnd = false
    @objc dynamic private var exchangeType: SportStatus = .stopped
    
    // CoreLocation
    private let locationManager = CLLocationManager()
    private var previousLocation: CLLocation?
    
    // 路线和距离
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private var totalDistance: CLLocationDistance = 0.0
    
    lazy var btnSportStart: UIButton = {
        let btn = UIButton.createNormalButton(title: "Start")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStart()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportPause: UIButton = {
        let btn = UIButton.createNormalButton(title: "Pause")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportPause()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportResume: UIButton = {
        let btn = UIButton.createNormalButton(title: "Resume")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportResume()
        }).disposed(by: disposeBag)
        return btn
    }()
    
    lazy var btnSportStop: UIButton = {
        let btn = UIButton.createNormalButton(title: "Stop")
        btn.rx.tap.subscribe(onNext: { [weak self] in
            self?._sportStop()
        }).disposed(by: disposeBag)
        return btn
    }()
    lazy var mapView: MKMapView = {
        let v = MKMapView(frame: view.bounds)
        v.delegate = self
        v.showsUserLocation = true
        v.showsScale = true
        return v
    }()
    
    private lazy var lblState: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .gray
        v.textAlignment = .left
        return v
    }()
    
    private lazy var textConsole: UITextView = {
        let v = UITextView()
        v.font = .systemFont(ofSize: 13)
        v.textColor = .lightGray
        v.textAlignment = .left
        v.isEditable = false
        v.backgroundColor = UIColor(red: 233/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sport"
        view.backgroundColor = .white
        
        view.addSubview(lblState)
        view.addSubview(textConsole)
        view.addSubview(mapView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        stackView.addArrangedSubview(btnSportStart)
        stackView.addArrangedSubview(btnSportPause)
        stackView.addArrangedSubview(btnSportResume)
        stackView.addArrangedSubview(btnSportStop)
        view.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            } else {
                make.top.equalTo(35)
            }
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        lblState.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(25)
            make.right.equalTo(-20)
            make.left.equalTo(20)
        }
        
        textConsole.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(lblState.snp.bottom)
            make.bottom.equalTo(mapView.snp.top).offset(-8)
        }
        
        mapView.snp.makeConstraints { make in
            make.left.right.equalTo(textConsole)
            make.height.equalTo((navigationController?.view.window?.frame.height ?? 440) / 2)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }else {
                make.bottom.equalTo(5)
            }
        }
        
        sdk.dataExchange.addExchange(delegate: self)
        
        self.rx.observeWeakly(Int.self, "exchangeType").subscribe(onNext: { [weak self] _ in
            self?.refreshState()
        }).disposed(by: disposeBag)
        
        setupLocationManager()
    }
}

extension SportVC {
    
    private func refreshState() {
        
        // !!!: 设备主动发起的运动，暂时不支持与app状态联动，忽略状态刷新
        if (baseModel == nil) {
            print("ignore")
            stopTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = true
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = false
            return
        }
        
        switch exchangeType {
        case .stopped:
            print("end")
            stopTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = true
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = false
        case .started:
            print("start")
            startTimer()
            textConsole.text = ""
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = true
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = true
        case .paused:
            print("pause")
            stopTimer()
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = false
            btnSportResume.isEnabled = true
            btnSportStop.isEnabled = true
        case .resumed:
            print("resume")
            startTimer()
            btnSportStart.isEnabled = false
            btnSportPause.isEnabled = true
            btnSportResume.isEnabled = false
            btnSportStop.isEnabled = true
        default:
            break
        }
    }
    
    private func _sportStart() {
        let currentDate = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: currentDate)
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
        let second = calendar.component(.second, from: currentDate)
        
        let baseModel = IDOExchangeBaseModel(
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            sportType: 48
        )
        self.baseModel = baseModel
        let obj = IDOAppStartExchangeModel(
            baseModel: baseModel,
            forceStart: 1
        )
        sdk.dataExchange.appExec(model: obj)
        /*
         https://idoosmart.github.io/Native_GitBook/en/doc/IDOTools.html?h=gpsInitType
         1、户外走路 = 52, 走路 = 1, 徒步 = 4, 运动类型设为 0
         2、户外跑步 = 48, 跑步 = 2, 运动类型设为 1
         3、户外骑行 = 50, 骑行 = 3, 运动型性设为 2
         */
        sdk.tool.gpsInitType(motionTypeIn: 1) { _ in }
    }
    
    private func _sportPause() {
        guard let baseModel = baseModel else { return }
        let obj = IDOAppPauseExchangeModel(baseModel: baseModel)
        sdk.dataExchange.appExec(model: obj)
    }
    
    private func _sportResume() {
        guard let baseModel = baseModel else { return }
        let obj = IDOAppRestoreExchangeModel(baseModel: baseModel)
        sdk.dataExchange.appExec(model: obj)
    }
    
    private func _sportStop() {
        guard baseModel != nil else { return }
        let obj = IDOAppEndExchangeModel(
            baseModel: baseModel,
            duration: duration,
            calories: calories,
            distance: distance,
            isSave: 1
        )
        sdk.dataExchange.appExec(model: obj)
    }
    
    /// Synchronize brief sports data for app display
    /// Sync every 2 seconds
    private func exchangeData() {
        guard baseModel != nil else {
            return
        }
        if (sdk.dataExchange.supportV3ActivityExchange) {
            let obj = IDOAppIngV3ExchangeModel(baseModel: baseModel, version: 2, signal: 0, distance: distance, speed: 0, duration: duration, calories: calories)
            sdk.dataExchange.appExec(model: obj)
        } else {
            let obj = IDOAppIngExchangeModel(baseModel: baseModel, duration: duration, calories: calories, distance: distance, status: 0)
            sdk.dataExchange.appExec(model: obj)
        }
    }
    
    /// Synchronize complete data once
    /// Sync every 40 seconds
    private func exchangeCompleteData() {
            sdk.dataExchange.getLastActivityData()
    }
    
    /// Sync exercise heart rate data
    /// Sync every 30 seconds
    private func exchangeV3HrData() {
        if (sdk.dataExchange.supportV3ActivityExchange) {
            sdk.dataExchange.getActivityHrData()
        }
    }
    
    private func startTimer() {
        textConsole.text = "sport launched successfully"
        disposeTimer = DisposeBag()
        Observable<Int>.interval(.seconds(Constant.intervalExchangeData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeData()
            })
            .disposed(by: disposeTimer)
        
        Observable<Int>.interval(.seconds(Constant.intervalExchangeCompleteData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeCompleteData()
            })
            .disposed(by: disposeTimer)
        
        Observable<Int>.interval(.seconds(Constant.intervalExchangeHrData), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                guard self.exchangeType == .started || self.exchangeType == .resumed else { return }
                self.exchangeV3HrData()
            })
            .disposed(by: disposeTimer)
    }
    
    private func stopTimer() {
        disposeTimer = DisposeBag()
    }
    
        
}


extension SportVC: IDOExchangeDataOCDelegate {
    
    /// ble发起运动 app监听ble
    /// - Parameter model: 监听ble执行数据实体
    /// ```
    /// 数据实体包括：
    /// ble设备发送交换运动数据开始 IDOBleStartExchangeModel
    /// ble设备交换运动数据过程中 IDOBleIngExchangeModel
    /// ble设备发送交换运动数据结束 IDOBleEndExchangeModel
    /// ble设备发送交换运动数据暂停 IDOBlePauseExchangeModel
    /// ble设备发送交换运动数据恢复 IDOBleRestoreExchangeModel
    /// ble设备操作运动计划 IDOBleOperatePlanExchangeModel
    /// app发起运动 app监听ble
    /// ble设备发送交换运动数据暂停 IDOAppBlePauseExchangeModel
    /// ble设备发送交换运动数据恢复 IDOAppBleRestoreExchangeModel
    /// ble设备发送交换运动数据结束 IDOAppBleEndExchangeModel
    func appListenBleExec(model: NSObject) {
        if (model is IDOBleStartExchangeModel) {
            guard let obj = model as? IDOBleStartExchangeModel else {
                print("异常：数据为空")
                return
            }
            let sendModel = IDOBleStartReplyExchangeModel(baseModel: obj.baseModel, operate: obj.operate, retCode: 0)
            // !!!: 暂时不支持设备启动运动和app联动
            //baseModel = obj.baseModel
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .started
        }
        else if (model is IDOBleIngExchangeModel) {
            let obj = model as? IDOBleIngExchangeModel
            let sendModel = IDOBleIngReplyExchangeModel(baseModel: obj?.baseModel, distance: obj?.distance ?? 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
        }
        else if (model is IDOBleEndExchangeModel) {
            let obj = model as? IDOBleEndExchangeModel
            let sendModel = IDOBleEndReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .stopped
        }
        else if (model is IDOBlePauseExchangeModel) {
            let obj = model as? IDOBlePauseExchangeModel
            let sendModel = IDOBlePauseReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .paused
        }
        else if (model is IDOBleRestoreExchangeModel) {
            let obj = model as? IDOBleRestoreExchangeModel
            let sendModel = IDOBleRestoreReplyExchangeModel(baseModel: obj?.baseModel, retCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .resumed
        }
        else if (model is IDOAppBlePauseExchangeModel) {
            let obj = model as? IDOAppBlePauseExchangeModel
            let sendModel = IDOAppBlePauseReplyExchangeModel(baseModel: obj?.baseModel, errCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .paused
        }
        else if (model is IDOAppBleRestoreExchangeModel) {
            let obj = model as? IDOAppBleRestoreExchangeModel
            let sendModel = IDOAppRestoreReplyExchangeModel(baseModel: obj?.baseModel, errCode: 0)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .resumed
        }
        else if (model is IDOAppBleEndExchangeModel) {
            guard let obj = model as? IDOAppBleEndExchangeModel else {
                print("异常：数据为空")
                return
            }
            let sendModel = IDOAppBleEndReplyExchangeModel(baseModel: baseModel,
                                                           errCode: 0,
                                                           duration: obj.duration,
                                                           calories: obj.calories,
                                                           distance: obj.distance)
            sdk.dataExchange.appReplyExec(model: sendModel)
            exchangeType = .stopped
            sdk.dataExchange.getActivityHrData()
            sdk.dataExchange.getLastActivityData()
            isSportEnd = true
        }
    }
    
    func appListenAppExec(model: NSObject) {
        
        /// app执行响应
        /// - Parameter model: 监听app执行Ble响应实体
        /// ```
        /// 响应实体包括：
        /// app 开始发起运动 ble回复 IDOAppStartReplyExchangeModel
        /// app 发起运动结束 ble回复 IDOAppEndReplyExchangeModel
        /// app 交换运动数据 ble回复 IDOAppIngReplyExchangeModel
        /// app 交换运动数据暂停 ble回复 IDOAppPauseReplyExchangeModel
        /// app 交换运动数据恢复 ble回复 IDOAppRestoreReplyExchangeModel
        /// app v3交换运动数据 ble回复 IDOAppIngV3ReplyExchangeModel
        /// app 操作运动计划 ble回复 IDOAppOperatePlanReplyExchangeModel
        /// app 获取v3多运动一次活动数据 ble回复 IDOAppActivityDataV3ExchangeModel
        /// app 获取v3多运动一次心率数据 ble回复 IDOAppHrDataExchangeModel
        /// app 获取v3多运动一次GPS数据 ble回复 IDOAppGpsDataExchangeModel
        
        if (model is IDOAppStartReplyExchangeModel) {
            let obj = model as? IDOAppStartReplyExchangeModel
            print("sport started now : \(String(describing: obj))")
            //* - 0:成功; 1:设备已经进入运动模式失败;
            //* - 2:设备电量低失败;3:手环正在充电
            //* - 4:正在使用Alexa 5:通话中
            guard obj?.retCode == 0 else {
                textConsole.text = "sport failed to launch, because of \(String(describing: obj?.retCode))"
                return
            }
            exchangeType = .started
        }
        else if (model is IDOAppEndReplyExchangeModel) {
            let obj = model as? IDOAppEndReplyExchangeModel
            print("reply for app's end reply: \(String(describing: obj))")
            exchangeType = .stopped
            baseModel = nil
            sdk.dataExchange.getActivityHrData()
            sdk.dataExchange.getLastActivityData()
            isSportEnd = true
        }
        else if (model is IDOAppIngReplyExchangeModel) {
            let obj = model as? IDOAppIngReplyExchangeModel
            print("data of sport from device: \(String(describing: obj))")
        }
        else if (model is IDOAppPauseReplyExchangeModel) {
            let obj = model as? IDOAppPauseReplyExchangeModel
            print("reply for app's pause cmd: \(String(describing: obj))")
            exchangeType = .paused
        }
        else if (model is IDOAppRestoreReplyExchangeModel) {
            let obj = model as? IDOAppRestoreReplyExchangeModel
            print("reply for app's restore cmd: \(String(describing: obj))")
            exchangeType = .resumed
        }
        else if (model is IDOAppIngV3ReplyExchangeModel) {
            let obj = model as? IDOAppIngV3ReplyExchangeModel
            print("v3 data of sport from device: \(String(describing: obj))")
        }
        else if (model is IDOAppOperatePlanReplyExchangeModel) {
            let obj = model as? IDOAppOperatePlanReplyExchangeModel
            print("reply for app's operate plan cmd: \(String(describing: obj))")
        }
        else if (model is IDOAppActivityDataV3ExchangeModel) {
            let obj = model as? IDOAppActivityDataV3ExchangeModel
            print("appActivityDataReply: \(String(describing: obj))")
            duration = max(duration, obj?.durations ?? 0)
            calories = max(calories, obj?.calories ?? 0)
            distance = max(distance, obj?.distance ?? 0)
            if (isSportEnd) {
                isSportEnd = false
                // TODO: 运动任务结束
                print("运动任务结束!! / Sports mission completed!!")
            }
        }
        else if (model is IDOAppHrDataExchangeModel) {
            let obj = model as? IDOAppHrDataExchangeModel
            print("appActivityHrReply: \(String(describing: obj))")
        }
        else if (model is IDOAppGpsDataExchangeModel) {
            let obj = model as? IDOAppGpsDataExchangeModel
            print("appActivityGpsReply: \(String(describing: obj))")
        }
    }
    
    func exchangeV2Data(model: IDOExchangeV2Model) {
        print("exchangeV2Data: \(model)")
    }
    
    func exchangeV3Data(model: IDOExchangeV3Model) {
        print("exchangeV3Data: \(model)")
    }
    
    
}


@objc
private enum SportStatus: Int {
    case stopped, started, paused, resumed
}


extension SportVC: CLLocationManagerDelegate, MKMapViewDelegate {
    // 配置定位管理器
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    // CLLocationManagerDelegate - 获取位置更新
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // 计算距离
        if let previousLocation = previousLocation {
            let distance = newLocation.distance(from: previousLocation)
            totalDistance += distance
        }
        previousLocation = newLocation
        
        let fliterGps = extractLocationData(from: newLocation)
        
        // 更新路线
        updateRoute(with: newLocation.coordinate)
        
        // 更新距离标签
        lblState.text = String(format: "Distance: %.1f m", totalDistance)
        distance = Int(totalDistance)
    }
    
    // 更新路线并绘制到地图上
    private func updateRoute(with coordinate: CLLocationCoordinate2D) {
//        sdk.tool.gpsSmoothData(json: <#T##String#>) { <#String#> in
//            <#code#>
//        }
        
        routeCoordinates.append(coordinate)
        
        // 绘制折线
        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        mapView.addOverlay(polyline)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    // 错误处理
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
    }
    
    // MARK: - MKMapViewDelegate 
    
    // 绘制折线
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .blue
            renderer.lineWidth = 2.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func startLocations () {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocations() {
        locationManager.stopUpdatingLocation()
        routeCoordinates.removeAll()
        totalDistance = 0
    }
    
    fileprivate func extractLocationData(from location: CLLocation) -> FilterGps {
        let lon = location.coordinate.longitude
        let lat = location.coordinate.latitude
        let timestamp = Int(location.timestamp.timeIntervalSince1970)
        let horAccuracy = location.horizontalAccuracy
        let verAccuracy = location.verticalAccuracy
        let filterGps = FilterGps(lat: lat, lon: lon, timestamp: timestamp, horAccuracy: horAccuracy, verAccuracy: verAccuracy)
        return filterGps
    }
}

// MARK: - FilterGps

fileprivate struct FilterGps: Codable {
    /// 纬度
    let lat: Double
    
    /// 经度
    let lon: Double
    
    /// 时间戳
    let timestamp: Int
    
    /// 水平定位精度
    let horAccuracy: Double
    
    /// 垂直定位精度
    let verAccuracy: Double
    
    // CodingKeys 用于自定义 JSON 键名（如果需要）
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case timestamp
        case horAccuracy
        case verAccuracy
    }
    
    init(lat: Double, lon: Double, timestamp: Int, horAccuracy: Double, verAccuracy: Double) {
        self.lat = lat
        self.lon = lon
        self.timestamp = timestamp
        self.horAccuracy = horAccuracy
        self.verAccuracy = verAccuracy
    }
}

extension FilterGps {
    func toJson() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    func toJsonString() throws -> String? {
        let data = try self.toJson()
        return String(data: data, encoding: .utf8)
    }
    
    static func fromJson(_ data: Data) throws -> FilterGps {
        return try JSONDecoder().decode(FilterGps.self, from: data)
    }
    
    static func fromJsonString(_ jsonString: String) throws -> FilterGps? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try fromJson(data)
    }
}
