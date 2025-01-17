//
//  LanguageManager.swift
//  IDODemo
//
//  Created by hc on 2024/12/31.
//

import Foundation

class LanguageManager {
    static let shared = LanguageManager()
    static let keyNotifity = "key.languagemanager.changed"
    // 支持的语言
    enum Language: String {
        case english = "en"
        case chinese = "zh-Hans"
        
        var locale: Locale {
            return Locale(identifier: self.rawValue)
        }
    }
    
    private(set) var currentLanguage: Language = .english
    
    func switchLanguage(to language: Language) {
        currentLanguage = language
        
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(LanguageManager.keyNotifity), object: nil)
    }
    
    private init() {
        if let languageCode = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as? String {
            currentLanguage = Language(rawValue: languageCode) ?? .english
        }
    }
}
