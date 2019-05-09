//
//  MyViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MyViewController: UIViewController {
    
    @IBOutlet weak var verifyEmailButton: UIButton!
    
    fileprivate let userQuery = AVQuery(className: "_User")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiveData()
        LaunchThemeManager.changeStatusBarStyle(.default)
        LaunchThemeManager.applyTheme(theme: .light)
        setupButtons()
    }
    
    func setupButtons() {
        
        
        if let isVerified = AVUser.current()?.object(forKey: DatabaseKey.emailVerified) as? Bool {
            
            if isVerified {
                verifyEmailButton.isEnabled = false
                updateVerifyEmailButtonUI()
            } else {
                verifyEmailButton.isEnabled = true
            }
        }
        verifyEmailButton.setTitleColor(LaunchThemeManager.currentTheme().textBlackColor.withAlphaComponent(0.4), for: .disabled)
        
        let disableImage = UIImage(named: "yiyanzheng_icon")?.filled(withColor: LaunchThemeManager.currentTheme().mainColor)
        verifyEmailButton.setImage(disableImage, for: .disabled)
        verifyEmailButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: verifyEmailButton.frame.size.width - (disableImage?.size.width ?? 0), bottom: 0, right: 0)
    }
    
    func updateVerifyEmailButtonUI() {
        if verifyEmailButton.isEnabled == false {
            verifyEmailButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(verifyEmailButton.imageView?.image?.size.width ?? 0), bottom: 0, right: 0)
        }
    }
    
    func setupLiveData() {
        
        if let nickname = AVUser.current()?.object(forKey: DatabaseKey.nickname) as? String {
            navigationItem.title = nickname
        } else {
            navigationItem.title = AVUser.current()?.username
        }
        
        UserInfoLiveData.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (liveQuery, object, _) = block
            guard let this = self else { return }
            if this.userQuery.className == liveQuery.query.className {
                guard let user = object as? AVUser else { return }
                AVUser.changeCurrentUser(user, save: true)
                if let nickname = user.object(forKey: DatabaseKey.nickname) as? String {
                    this.navigationItem.title = nickname
                }
                if let isVerified = user.object(forKey: DatabaseKey.emailVerified) as? Bool {
                    
                    if isVerified {
                        this.verifyEmailButton.isEnabled = false
                        this.updateVerifyEmailButtonUI()
                    } else {
                        this.verifyEmailButton.isEnabled = true
                    }
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func logoutTap(_ sender: UIButton) {
        
        let logoutAction = UIAlertAction(title: "退出", style: .default) {(_) in
            
            AVUser.current()?.setObject(false, forKey: DatabaseKey.isLogin)
            AVUser.current()?.saveInBackground({ (_, _) in
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "再玩一会儿", style: .cancel, handler: nil)
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(logoutAction)
        alertVC.addAction(cancelAction)
        navigationController?.present(alertVC, animated: true, completion: nil)
        
    }
}


