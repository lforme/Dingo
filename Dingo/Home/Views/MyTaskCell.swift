//
//  MyTaskCell.swift
//  Dingo
//
//  Created by mugua on 2019/5/15.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class MyTaskCell: UICollectionViewCell {

    @IBOutlet weak var bkView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var decreaseLabel: UILabel!
    @IBOutlet weak var isOnIcon: UIView!
    @IBOutlet weak var isOnLabel: UILabel!
    @IBOutlet weak var ringsLabel: UILabel!
    @IBOutlet weak var effectBgView: UIView!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                bkView.backgroundColor = bkView.backgroundColor?.withAlphaComponent(0.4)
                effectBgView.backgroundColor = effectBgView.backgroundColor?.withAlphaComponent(0.4)
            } else {
                bkView.backgroundColor = bkView.backgroundColor?.withAlphaComponent(1)
                effectBgView.backgroundColor = effectBgView.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        bkView.clipsToBounds = true
        bkView.setShadow()
        
        isOnIcon.clipsToBounds = true
        isOnIcon.layer.borderColor = UIColor.white.cgColor
        isOnIcon.layer.borderWidth = 2
        isOnIcon.layer.cornerRadius = isOnIcon.bounds.height / 2
        
    }

    func updateAvailableIconBy(available: Bool) {
        if available {
            isOnIcon.backgroundColor = UIColor.flatGreen
            isOnLabel.text = "运行中"
        } else {
            isOnIcon.backgroundColor = LaunchThemeManager.currentTheme().secondaryRed
            isOnLabel.text = "已暂停"
        }
    }
}
