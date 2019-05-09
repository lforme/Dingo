//
//  UIViewController+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    @discardableResult
    func createdRightNavigationItem(title: String?, font: UIFont? = UIFont.boldSystemFont(ofSize: 16), image: UIImage?, rightEdge: CGFloat = 10, color: UIColor = LaunchThemeManager.currentTheme().textBlackColor) -> UIButton {
        
        let fix = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fix.width = rightEdge - 15
        
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = font
        btn.setTitleColor(color, for: .normal)
        btn.setTitleColor(color.withAlphaComponent(0.6), for: .disabled)
        btn.setTitleColor(color.withAlphaComponent(0.4), for: .highlighted)
        btn.dgSetImage(image)
        btn.sizeToFit()
        
        var frame = btn.frame
        let width = frame.width
        
        if width < 44 {
            fix.width = fix.width - (44 - width) / 2
            frame.size.width = 44
        }
        frame.size.height = 44
        btn.frame = frame
        
        let right = UIBarButtonItem(customView: btn)
        self.navigationItem.rightBarButtonItems = [fix, right]
        return btn
    }
}
