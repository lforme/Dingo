//
//  StaticConst.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension NSNotification.Name {
    
    public static let statuBarDidChnage = NSNotification.Name(rawValue: "StatuBarDidChnage")
    public static let loginStateDidChnage = NSNotification.Name(rawValue: "loginStateDidChnage")
    public static let refreshState = NSNotification.Name(rawValue: "refreshState")
}


struct DatabaseKey {
    
    static let uuid = "uuid"
    static let isLogin = "isLogin"
    static let nickname = "nickname"
    static let emailVerified = "emailVerified"
    static let portrait = "portrait"
}
