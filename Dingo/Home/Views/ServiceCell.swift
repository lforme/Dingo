//
//  ServiceCell.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IGListKit

class ServiceCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(0.4)
            } else {
                bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
}

extension ServiceCell: ListBindable {
    
    func bindViewModel(_ viewModel: Any) {
        guard let viewModel = viewModel as? ServiceModel else { return }
        nameLabel.text = viewModel.name
    }
    
}
