//
//  ViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var loginVC: LoginViewController?
    var homeTab: UITabBarController?
    var baseNavigationVC: BaseNavigationController?
    var doingLiveQuery: AVLiveQuery?
    var userId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoginVC()
        observeLoginUser()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            AVUser.current()?.setObject(UIDevice.current.identifierForVendor?.uuidString, forKey: "uuid")
        
            AVUser.current()?.saveInBackground()
            
        }
    }
    
    func observeLoginUser() {
        if let user = AVUser.current(), let id = user.objectId {
            showHomeVC()
            
            // live data
            let userQuery = AVQuery(className: "_User")
            self.doingLiveQuery = AVLiveQuery(query: userQuery)
            self.doingLiveQuery?.delegate = self
            self.userId = id
            self.doingLiveQuery?.subscribe(callback: { (s, e) in
                
                print(s)
                
            })
            
        } else {
            showLoginVC()
        }
    }
    
    func showLoginVC() {
        
        homeTab?.view.removeFromSuperview()
        homeTab?.removeFromParent()
        homeTab = nil
        
        let sb = UIStoryboard(name: "Login", bundle: nil)
        loginVC = sb.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        guard let loginVC = loginVC else { return }
        baseNavigationVC = BaseNavigationController(rootViewController: loginVC)
        self.view.addSubview(baseNavigationVC!.view)
        baseNavigationVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(self.view)
        })
        self.addChild(baseNavigationVC!)
    }
    
    
    func showHomeVC() {
        
        loginVC?.view.removeFromSuperview()
        loginVC?.removeFromParent()
        loginVC = nil
        
        let tabBarVC = UITabBarController()
        tabBarVC.tabBar.isTranslucent = false
        
        let homeVC: HomeViewController = ViewLoader.Storyboard.controller(from: "Home")
        let homeItemIconNormal = UIImage(named: "rili_icon")
        let homeItemIconSelected = UIImage(named: "rili_icon")?.filled(withColor: LaunchThemeManager.currentTheme().mainColor)
        
        let myVC: MyViewController = ViewLoader.Storyboard.controller(from: "User")
        let myItemIconNormal = UIImage(named: "rili_icon")
        let myItemIconSelected = UIImage(named: "rili_icon")?.filled(withColor: LaunchThemeManager.currentTheme().mainColor)
        
        
        let tabItems: [(UIViewController, String, UIImage?, UIImage?)] = [
            (homeVC, "日常任务", homeItemIconNormal, homeItemIconSelected),
            (myVC, "我的设置", myItemIconNormal, myItemIconSelected)
        ]
        
        let navigationsVC = tabItems.map { (vc, title, normalIcon, selectedIcon) -> BaseNavigationController in
            let item = UITabBarItem(title: title, image: normalIcon, selectedImage: selectedIcon)
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : LaunchThemeManager.currentTheme().textBlackColor], for: .normal)
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : LaunchThemeManager.currentTheme().mainColor], for: .selected)
            vc.tabBarItem = item
            
            let navigationVC = BaseNavigationController(rootViewController: vc)
            return navigationVC
        }
        
        tabBarVC.viewControllers = navigationsVC
        self.view.addSubview(tabBarVC.view)
        self.addChild(tabBarVC)
    }
    
}


extension ViewController: AVLiveQueryDelegate {
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
       
        print(object)
        
    }
}
