//
//  AddTaskHaderView.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class AddTaskHaderView: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindData(icon: String, color: UIColor, description: String?) {
        self.icon.image = UIImage(named: icon)
        self.contentView.backgroundColor = color
        self.descriptionLabel.text = description
    }

}
