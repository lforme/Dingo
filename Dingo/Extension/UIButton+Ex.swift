//
//  UIButton+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

extension UIButton {
    
    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.4
        }
    }
    
    func setupDgStyle() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    func underlineButton(text: String) {
        
        guard let l = self.titleLabel else {
            return
        }
        
        let yourAttributes : [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font : l.font!,
            NSAttributedString.Key.foregroundColor : l.textColor!,
            NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
        
        let attributeString = NSMutableAttributedString(string: text,
                                                        attributes: yourAttributes)
        setAttributedTitle(attributeString, for: .normal)
        
    }
    
}
