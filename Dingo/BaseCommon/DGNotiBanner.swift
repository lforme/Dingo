//
//  DGNotiBanner.swift
//  Dingo
//
//  Created by mugua on 2019/5/15.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import NotificationBannerSwift

final class DGNotiBanner: NSObject, NotificationBannerDelegate {
    
    final class Color: BannerColorsProtocol {
        func color(for style: BannerStyle) -> UIColor {
            switch style {
            case .danger: return #colorLiteral(red: 0.8509803922, green: 0.3294117647, blue: 0.3490196078, alpha: 1)
            case .info: return UIColor.flatSkyBlue
            case .success: return UIColor.flatGreen
            case .none: return UIColor.flatSkyBlue
            case .warning: return #colorLiteral(red: 0.9568627451, green: 0.6745098039, blue: 0.3333333333, alpha: 1)
            }
        }
    }
    
    func notificationBannerWillAppear(_ banner: BaseNotificationBanner) {}
    func notificationBannerDidAppear(_ banner: BaseNotificationBanner) {}
    func notificationBannerWillDisappear(_ banner: BaseNotificationBanner) {}
    func notificationBannerDidDisappear(_ banner: BaseNotificationBanner) {}
    
    typealias AnimationsCompletion = ()->()
    static let shareInstance = DGNotiBanner()
    var notiDismiss: AnimationsCompletion?
    
    func show(title: String, subtitle: String?, style: BannerStyle, bannerPosition: BannerPosition = .top, completion: AnimationsCompletion?) {
        
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: style, colors: Color())
        banner.show(bannerPosition: bannerPosition)
        banner.autoDismiss = true
        banner.delegate = self
        banner.duration = 1
        banner.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        notiDismiss = completion
    }
    
    func statusBarShow(title: String, subtitle: String?, style: BannerStyle, bannerPosition: BannerPosition = .top, completion: AnimationsCompletion?) {
        
        let banner = StatusBarNotificationBanner(title: title, style: style, colors: Color())
        banner.show(bannerPosition: bannerPosition)
        banner.autoDismiss = true
        banner.delegate = self
        banner.duration = 1
        banner.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        notiDismiss = completion
    }
    
    func growingShow(title: String, subtitle: String?, style: BannerStyle, bannerPosition: BannerPosition = .top, completion: AnimationsCompletion?) {
        
        let banner = GrowingNotificationBanner.init(title: title, subtitle: subtitle, leftView: nil, rightView: nil, style: style, colors: Color(), iconPosition: .top)
        banner.show(bannerPosition: bannerPosition)
        banner.autoDismiss = true
        banner.delegate = self
        banner.duration = 1
        banner.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.heavy)
        notiDismiss = completion
    }
    
}
