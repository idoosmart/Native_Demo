//
//  AppDelegate.swift
//  IDODemo
//
//  Created by hc on 2023/10/23.
//

import UIKit

import Flutter
import FlutterPluginRegistrant
import SVProgressHUD


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var flutterEngine: FlutterEngine?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initFlutterEngine()
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setMinimumSize(CGSizeMake(120, 100))
        SVProgressHUD.setMinimumDismissTimeInterval(1.5)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = UINavigationController(rootViewController: MainPageVC())
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate {
    private func initFlutterEngine() {
        self.flutterEngine = FlutterEngine(name: "io.flutter", project: nil)
        self.flutterEngine?.run(withEntrypoint: nil)
        if let engine = flutterEngine {
            GeneratedPluginRegistrant.register(with: engine)
            print("flutterEngine finished")
        } else {
            print("engine is null")
            assert(false, "engine is null")
        }
    }
}

