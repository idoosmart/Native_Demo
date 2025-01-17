//
//  BaseVC.swift
//  IDODemo
//
//  Created by hc on 2024/12/31.
//

import UIKit

class BaseVC: UIViewController {
    
    private let _lanMgr = LanguageManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let languageButton = UIBarButtonItem(
            title: getCurrentLanguageTitle(),
            style: .plain,
            target: self,
            action: #selector(languageButtonTapped)
        )
        navigationItem.rightBarButtonItem = languageButton
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged),
            name: Notification.Name(LanguageManager.keyNotifity),
            object: nil
        )
    }
    
    private func getCurrentLanguageTitle() -> String {
        switch _lanMgr.currentLanguage {
        case .english:
            return "中文"
        case .chinese:
            return "EN"
        }
    }
    
    @objc private func languageButtonTapped() {
        let alert = UIAlertController(title: "Warn", message: L10n.exitApp, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Exit", style: .default, handler: { [weak self] _ in
            self?._lanMgr.switchLanguage(to: self?._lanMgr.currentLanguage == .english ? .chinese : .english)
            print("change to: \(self?._lanMgr.currentLanguage.rawValue)")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                self?.exitApp()
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func languageChanged() {
        navigationItem.rightBarButtonItem?.title = getCurrentLanguageTitle()
    }
    
    func exitApp() {
        if #available(iOS 13.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                exit(0)
            }
            window.rootViewController?.dismiss(animated: true) {
                exit(0)
            }
        } else {
            guard let window = UIApplication.shared.keyWindow else {
                exit(0)
            }
            window.rootViewController?.dismiss(animated: true) {
                exit(0)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
