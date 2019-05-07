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
    var homeVC: UIViewController?
    var baseNavigationVC: BaseNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoginVC()
        observeLoginUser()
    }
    
    func observeLoginUser() {
        
    }
    
    func showLoginVC() {
        
        homeVC?.view.removeFromSuperview()
        homeVC?.removeFromParent()
        homeVC = nil
        
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
        
        let sb = UIStoryboard(name: "Home", bundle: nil)
        homeVC = sb.instantiateViewController(withIdentifier: "HomeViewController") as? UIViewController
        guard let homeVC = homeVC else { return }
        baseNavigationVC = BaseNavigationController(rootViewController: homeVC)
        self.view.addSubview(baseNavigationVC!.view)
        baseNavigationVC?.view.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(self.view)
        })
        self.addChild(baseNavigationVC!)
        
    }
    
}

