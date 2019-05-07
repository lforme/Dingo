//
//  LoginViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import paper_onboarding
import ChameleonFramework

class LoginViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var onboarding: PaperOnboarding!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        interactiveNavigationBarHidden = true
        setupOnboarding()
        
    }
    
    func setupOnboarding() {
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension LoginViewController: PaperOnboardingDataSource {
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [OnboardingItemInfo(informationImage: UIImage(),
                                    title: "时刻提醒",
                                    description: "添加提醒任务\n让你的手机和其他APP亲密交谈",
                                    pageIcon: UIImage(),
                                    color: LaunchThemeManager.currentTheme().mainColor,
                                    titleColor: LaunchThemeManager.currentTheme().textColor,
                                    descriptionColor: LaunchThemeManager.currentTheme().textColor,
                                    titleFont: UIFont.boldSystemFont(ofSize: 24),
                                    descriptionFont: UIFont.systemFont(ofSize: 18)),
                
                OnboardingItemInfo(informationImage: UIImage(),
                                   title: "极速推送",
                                   description: "随心所以的设置提醒事项",
                                   pageIcon: UIImage(),
                                   color: LaunchThemeManager.currentTheme().mainColor,
                                   titleColor: LaunchThemeManager.currentTheme().textColor,
                                   descriptionColor: LaunchThemeManager.currentTheme().textColor,
                                   titleFont: UIFont.boldSystemFont(ofSize: 24),
                                   descriptionFont: UIFont.systemFont(ofSize: 18)),
                
                OnboardingItemInfo(informationImage: UIImage(),
                                   title: "开始探索",
                                   description: "开启[叮咚]吧",
                                   pageIcon: UIImage(),
                                   color: LaunchThemeManager.currentTheme().mainColor,
                                   titleColor: LaunchThemeManager.currentTheme().textColor,
                                   descriptionColor: LaunchThemeManager.currentTheme().textColor,
                                   titleFont: UIFont.boldSystemFont(ofSize: 24),
                                   descriptionFont: UIFont.systemFont(ofSize: 18))
        
        ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
}


extension LoginViewController: PaperOnboardingDelegate {
    
    @objc(onboardingDidTransitonToIndex:) func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 2 {
            onboarding.bringSubviewToFront(skipButton)
        } else {
            onboarding.sendSubviewToBack(skipButton)
        }
    }
}
