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
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
        
    }
    
    func setupOnboarding() {
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @IBAction func startTap(_ sender: UIButton) {
        
        AVUser.loginAnonymously { (user, error) in
            if let e = error {
                print(e.localizedDescription)
            } else {
                print(user ?? "")
                NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
            }
        }
    }
}

extension LoginViewController: PaperOnboardingDataSource {
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [OnboardingItemInfo(informationImage: UIImage(),
                                   title: "时刻提醒",
                                   description: "添加提醒任务",
                                   pageIcon: UIImage(),
                                   color: LaunchThemeManager.currentTheme().mainColor,
                                   titleColor: LaunchThemeManager.currentTheme().textWhiteColor,
                                   descriptionColor: LaunchThemeManager.currentTheme().textWhiteColor,
                                   titleFont: UIFont.boldSystemFont(ofSize: 24),
                                   descriptionFont: UIFont.systemFont(ofSize: 18)),
                
                OnboardingItemInfo(informationImage: UIImage(),
                                   title: "自定义提醒铃声",
                                   description: "自定义提醒铃声",
                                   pageIcon: UIImage(),
                                   color: LaunchThemeManager.currentTheme().mainColor,
                                   titleColor: LaunchThemeManager.currentTheme().textWhiteColor,
                                   descriptionColor: LaunchThemeManager.currentTheme().textWhiteColor,
                                   titleFont: UIFont.boldSystemFont(ofSize: 24),
                                   descriptionFont: UIFont.systemFont(ofSize: 18)),
                
                OnboardingItemInfo(informationImage: UIImage(),
                                   title: "开始探索",
                                   description: "开启[叮咚]吧",
                                   pageIcon: UIImage(),
                                   color: LaunchThemeManager.currentTheme().mainColor,
                                   titleColor: LaunchThemeManager.currentTheme().textWhiteColor,
                                   descriptionColor: LaunchThemeManager.currentTheme().textWhiteColor,
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
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseIn], animations: {
                self.skipButton.alpha = 1
                self.skipButton.center.y -= 10
            }, completion: nil)
        }
    }
    
    @objc(onboardingWillTransitonToIndex:) func onboardingWillTransitonToIndex(_ index: Int) {
        if index != 2 {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: [.curveEaseOut], animations: {
                self.skipButton.center.y += 10
                self.skipButton.alpha = 0
            }, completion: { finished in
                if finished {
                    self.onboarding.sendSubviewToBack(self.skipButton)
                }
            })
        }
    }
    
}
