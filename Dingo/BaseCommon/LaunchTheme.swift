//
//  LaunchTheme.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import ChameleonFramework


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
    
    var textColor: UIColor {
        return UIColor.white
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
    
    static func launchInit() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldPlayInputClicks = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        AVOSCloud.setApplicationId("fI1sUJD8N9y9VgmmSV0OL1PB-gzGzoHsz", clientKey: "3qqQwnHfMSFj3soa8q4b9sYr")
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
            Chameleon.setGlobalThemeUsingPrimaryColor(theme.mainColor, with: .dark)
        case .light:
            Chameleon.setGlobalThemeUsingPrimaryColor(theme.mainColor, with: .light)
            UserDefaults.standard.set(1, forKey: selectedThemeKey)
        }
        UserDefaults.standard.synchronize()
        
        // 2
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        UINavigationBar.appearance().tintColor = theme.mainColor
        
    }
}
