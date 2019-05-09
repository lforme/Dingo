//
//  HomeViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "日常任务"
        LaunchThemeManager.changeStatusBarStyle(.default)
    }
}
