//
//  ViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import PKHUD

class ViewController: UIViewController {
    
    static let share = ViewController()
    
    fileprivate var loginVC: LoginViewController?
    fileprivate var homeTab: UITabBarController?
    fileprivate var baseNavigationVC: BaseNavigationController?
    fileprivate var doingLiveQuery: AVLiveQuery?
    fileprivate let userQuery = AVQuery(className: DatabaseKey.userTable)
    fileprivate var _statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    fileprivate let keychain = Keychain()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self._statusBarStyle
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkedLogin()
        UITabBar.appearance().tintColor = LaunchThemeManager.currentTheme().textBlackColor
        observeLoginStatu()
        
        NotificationCenter.default.rx.notification(.statuBarDidChnage)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (noti) in
                if let style = noti.object as? UIStatusBarStyle {
                    self?._statusBarStyle = style
                }
            }).disposed(by: rx.disposeBag)
        
        NotificationCenter.default.rx.notification(.loginStateDidChnage).takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .subscribeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (_) in
                self?.showHomeVC()
            }).disposed(by: rx.disposeBag)
    }
    
    func checkedLogin() {
        
        if let localUser = AVUser.current() {
            showHomeVC()
            
            // 自动登录
            guard let username = localUser.username, let pwd = self.keychain["password"] else { return }
            AVUser.logInWithUsername(inBackground: username, password: pwd) { (s, error) in
                print(error?.localizedDescription ?? "")
            }
            
        } else {
            showLoginVC()
        }
    }
    
    
    func observeLoginStatu() {
        UserInfoLiveData.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (liveQuery, object, _) = block
            guard let this = self else { return }
            if this.userQuery.className == liveQuery.query.className {
                guard let user = object as? AVUser else { return }
                guard let isLogin = user.object(forKey: DatabaseKey.isLogin) as? Bool else { return }
                guard let uuid = user.object(forKey: DatabaseKey.uuid) as? String else { return }
                guard let currentUUID = AVUser.current()?.object(forKey: DatabaseKey.uuid) as? String else { return }
                
                if !isLogin || uuid != currentUUID {
                    AVUser.current()?.setObject(false, forKey: DatabaseKey.isLogin)
                    AVUser.current()?.saveInBackground({ (success, error) in
                        if success {
                            AVUser.logOut()
                        }
                    })
                    this.showLoginVC()
                }
            }
        }).disposed(by: rx.disposeBag)
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
        let homeItemIconNormal = UIImage(named: "denglu_icon")
        
        let myVC: MyViewController = ViewLoader.Storyboard.controller(from: "User")
        let myItemIconNormal = UIImage(named: "rili_icon")
        
        let tabItems: [(UIViewController, String, UIImage?)] = [
            (homeVC, "日常任务", homeItemIconNormal),
            (myVC, "我的设置", myItemIconNormal)
        ]
        
        var tag = 0
        let navigationsVC = tabItems.map { (vc, title, normalIcon) -> BaseNavigationController in
            let item = UITabBarItem(title: title, image: normalIcon, tag: tag)
            tag += 1
            
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : LaunchThemeManager.currentTheme().textBlackColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)], for: .selected)
            vc.tabBarItem = item
            
            let navigationVC = BaseNavigationController(rootViewController: vc)
            return navigationVC
        }
        
        tabBarVC.viewControllers = navigationsVC
        self.view.addSubview(tabBarVC.view)
        self.addChild(tabBarVC)
    }
    
    static func visibleViewController() -> UIViewController? {
        let root = UIApplication.shared.keyWindow?.rootViewController
        
        if let navi = root?.children.last as? BaseNavigationController {
            return navi.visibleViewController
        }
        return nil
    }
    
}
