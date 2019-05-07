//
//  UITextField+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/7.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    
    private static let _placeholderColor = ObjectAssociation<UIColor>()
    
    public var placeholderColor: UIColor? {
        get {
            return UITextField._placeholderColor[self]
        }
        set {
            UITextField._placeholderColor[self] = newValue
            self.attributedPlaceholder =
                NSAttributedString(string: self.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }
    
    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}
