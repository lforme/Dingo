//
//  LaunchTheme.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import ChameleonFramework
import EasyAnimation
import UserNotifications

enum LaunchTheme: Int {
    case dark = 0
    case light
    
    var mainColor: UIColor {
        switch self {
        case .dark:
            return UIColor.flatSkyBlue
        case .light:
            return UIColor.flatSkyBlue
        }
    }
    
    var secondaryRed: UIColor {
        return #colorLiteral(red: 0.8509803922, green: 0.3294117647, blue: 0.3490196078, alpha: 1)
    }
    
    var textWhiteColor: UIColor {
        return UIColor.white
    }
    
    var textBlackColor: UIColor {
        return #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
    }
    
    var iconColor: UIColor {
        switch self {
        case .dark:
            return UIColor.flatWhite
        case .light:
            return UIColor.flatBlack
        }
    }
}

struct LaunchThemeManager {
    
    private static let selectedThemeKey = "SelectedTheme"
    
    @discardableResult
    static func launchInit() -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        EasyAnimation.enable()
        
        AVOSCloud.setApplicationId("fI1sUJD8N9y9VgmmSV0OL1PB-gzGzoHsz", clientKey: "3qqQwnHfMSFj3soa8q4b9sYr")
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications permission granted.")
            }
            else {
                print("Notifications permission denied because: \(error?.localizedDescription ?? "错误").")
            }
        }
        return true
    }
    
    static func currentTheme() -> LaunchTheme {
        if let storedTheme = UserDefaults.standard.value(forKey: selectedThemeKey) as? Int {
            
            return LaunchTheme(rawValue: storedTheme) ?? .light
        } else {
            return .light
        }
    }
    
    static func applyTheme(theme: LaunchTheme) {
        // 1
        switch theme {
        case .dark:
            UserDefaults.standard.set(0, forKey: selectedThemeKey)
        case .light:
            UserDefaults.standard.set(1, forKey: selectedThemeKey)
        }
        UserDefaults.standard.synchronize()
    }
    
    static func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        NotificationCenter.default.post(name: .statuBarDidChnage, object: style)
    }
}
