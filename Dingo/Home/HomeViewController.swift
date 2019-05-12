//
//  HomeViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import IGListKit

class HomeViewController: UIViewController {
    
    var collectionView: ListCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日常任务"
        LaunchThemeManager.changeStatusBarStyle(.default)
    }
    
  
}
