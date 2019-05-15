//
//  TaskHeaderSectionController.swift
//  Dingo
//
//  Created by mugua on 2019/5/15.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class TaskHeaderSectionController: ListSectionController {
    
    private var title: String!
    
    override init() {
        super.init()
        inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 20, height: 50)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "TaskHeaderView", bundle: nil, for: self, at: index) as? TaskHeaderView else {
            fatalError()
        }
        return cell
    }
    
    override func didUpdate(to object: Any) {
        title = object as? String
    }
}
