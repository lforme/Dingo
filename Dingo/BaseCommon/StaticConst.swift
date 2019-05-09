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
}


struct DatabaseKey {
    
    static let uuid = "uuid"
    static let isLogin = "isLogin"
    static let nickname = "nickname"
    static let emailVerified = "emailVerified"
}
