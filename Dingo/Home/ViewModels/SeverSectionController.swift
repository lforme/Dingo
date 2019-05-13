//
//  SeverSectionController.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IGListKit


final class SeverSectionController: ListSectionController {
    
    private var service: ServiceModel?
    private let colors = [LaunchThemeManager.currentTheme().mainColor,
                          LaunchThemeManager.currentTheme().textBlackColor,
                          LaunchThemeManager.currentTheme().secondaryRed]

    override init() {
        super.init()
        displayDelegate = self
        inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width / 2, height: 180)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "ServiceCell", bundle: nil, for: self, at: index) as? ServiceCell else {
            fatalError()
        }
        
        let name = service?.name
        if let color = service?.colorType, let icon = service?.icon  {
            cell.iconView.image = UIImage(named: icon)
            cell.bgView.backgroundColor = colors[color]
        }
        cell.nameLabel.text = name
        
        return cell
    }
    
    override func didUpdate(to object: Any) {
        service = object as? ServiceModel
    }
    
    override func didSelectItem(at index: Int) {
        let addVC: AddNewAppletController = ViewLoader.Storyboard.controller(from: "Home")
        addVC.color = colors[service?.colorType ?? 0]
        if let i = service?.icon {
            addVC.icon = i
        }
        switch index {
        case 0:
            addVC.type = .date
        case 1:
            addVC.type = .local
        default:
            break
        }
        self.viewController?.navigationController?.pushViewController(addVC, animated: true)
    }
}


extension SeverSectionController: ListDisplayDelegate {
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, willDisplay sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
    
    func listAdapter(_ listAdapter: ListAdapter, didEndDisplaying sectionController: ListSectionController, cell: UICollectionViewCell, at index: Int) {
        
    }
    
    
}
