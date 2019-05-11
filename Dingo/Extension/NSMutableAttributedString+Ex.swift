//
//  NSMutableAttributedString+Ex.swift
//  Dingo
//
//  Created by mugua on 2019/5/11.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    func setFontForText(_ textToFind: String, with Font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: Font, range: range)
        }
    }
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}
