//
//  UIView+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setShadow(color: UIColor = LaunchThemeManager.currentTheme().textBlackColor.withAlphaComponent(0.4)) {
        
        layer.cornerRadius = 7
        layer.shadowColor = color.cgColor
        layer.borderWidth = 0
        layer.borderColor = color.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: 4, height: 4)
    }
    
    
//    [.layerMaxXMinYCorner, .layerMinXMinYCorner] 左右下
//    [.layerMaxXMinYCorner, .layerMinXMinYCorner] 左右上
    // https://stackoverflow.com/questions/4847163/round-two-corners-in-uiview
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = corners
    }
}
