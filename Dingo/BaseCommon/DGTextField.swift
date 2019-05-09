//
//  DGTextField.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import TextFieldEffects

class DGTextField: HoshiTextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupStyle()
    }
    
    private func setupStyle() {
        
        borderInactiveColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
        borderActiveColor = LaunchThemeManager.currentTheme().mainColor
        placeholderColor = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 0.5)
        placeholderFontScale = 1
        
        self.animationCompletionHandler = { type in
            
            switch type {
            case .textEntry:
                self.placeholderLabel.textColor = LaunchThemeManager.currentTheme().mainColor
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
                self.placeholderLabel.sizeToFit()
                
            case .textDisplay:
                self.placeholderLabel.textColor = #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 0.28)
                self.placeholderLabel.font = UIFont.systemFont(ofSize: 18)
                self.placeholderLabel.sizeToFit()
            }
        }
        
    }

}
