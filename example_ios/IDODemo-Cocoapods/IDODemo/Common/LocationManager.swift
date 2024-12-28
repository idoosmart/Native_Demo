//
//  LocationManager.swift
//  Runner
//
//  Created by hc on 2024/12/19.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    static let shared = LocationManager()
    
    
    private var previousLocation: CLLocation?
    private var routeCoordinates: [CLLocationCoordinate2D] = []
    private(set) var totalDistance: CLLocationDistance = 0.0
    
    var locationUpdateBlock: ((_ locations: [CLLocation]) -> Void)?
    var locationErrorBlock: ((_ error: Error) -> Void)?
    var didChangeAuthorization: ((_ status: CLAuthorizationStatus) -> Void)?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    // MARK: - 权限相关方法
    
    /// 获取当前权限状态
    private func getAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    /// 请求定位权限
    func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationServiceDisabledAlert()
            return
        }
        
        locationManager.requestWhenInUseAuthorization()
        // 或者根据需求使用
        // locationManager.requestAlwaysAuthorization()
    }
    
    /// 检查定位权限状态
    func checkLocationAuthorization() -> Bool {
        let status = getAuthorizationStatus()
        
        switch status {
        case .notDetermined:
            requestLocationPermission()
            return false
            
        case .restricted, .denied:
            showGoToSettingsAlert()
            return false
            
        case .authorizedWhenInUse, .authorizedAlways:
            return true
            
        @unknown default:
            return false
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        case .denied, .restricted:
            stopUpdatingLocation()
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
    // iOS 14及以上版本使用此代理方法
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
            
        case .denied, .restricted:
            stopUpdatingLocation()
            
        case .notDetermined:
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        handleLocationUpdate(newLocation)
        guard let newLocation = locations.last else { return }
        
        // 计算距离
        if let previousLocation = previousLocation {
            let distance = newLocation.distance(from: previousLocation)
            totalDistance += distance
        }
        previousLocation = newLocation
        
        updateRoute(with: newLocation.coordinate)
        
        locationUpdateBlock?(locations)
    }
    
    private func updateRoute(with coordinate: CLLocationCoordinate2D) {
        routeCoordinates.append(coordinate)
        
        // 绘制折线
//        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
//        mapView.addOverlay(polyline)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleLocationError(error)
        locationErrorBlock?(error)
    }
    
    // MARK: - 辅助方法
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        routeCoordinates.removeAll()
        totalDistance = 0
        previousLocation = nil
    }
    
    private func handleLocationUpdate(_ location: CLLocation) {
        print("位置更新：\(location.coordinate.latitude), \(location.coordinate.longitude) signal:\(location.horizontalAccuracy)")
    }
    
    private func handleLocationError(_ error: Error) {
        //print("定位错误：\(error.localizedDescription)")
    }
    
    // MARK: - Alert 提示
    
    private func showLocationServiceDisabledAlert() {
        let alert = UIAlertController(
            title: "定位服务未开启",
            message: "请在设置中开启定位服务",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "去设置", style: .default) { _ in
            // 跳转到系统设置
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        // 获取当前最顶层的 ViewController 来展示 alert
        if let topVC = getTopViewController() {
            topVC.present(alert, animated: true)
        }
    }
    
    private func showGoToSettingsAlert() {
        let alert = UIAlertController(
            title: "需要定位权限",
            message: "请在设置中允许访问您的位置信息",
            preferredStyle: .alert
        )
        
        let settingsAction = UIAlertAction(title: "去设置", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        if let topVC = getTopViewController() {
            topVC.present(alert, animated: true)
        }
    }
    
    // 获取顶层 ViewController
    private func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var topViewController = keyWindow?.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}


extension CLLocation {
    
    func gpsSignal() -> Int {
        if (horizontalAccuracy > 0 && horizontalAccuracy <= 25) {
            return 0x01
        }
        return 0x00
    }
}
