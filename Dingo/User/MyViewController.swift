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
import PKHUD
import LTMorphingLabel
import ChameleonFramework

class MyViewController: UIViewController {
    
    @IBOutlet weak var verifyEmailButton: UIButton!
    @IBOutlet weak var appVersionLabel: LTMorphingLabel!
    @IBOutlet weak var cleanCacheButton: UIButton!
    
    
    fileprivate let userQuery = AVQuery(className: DatabaseKey.userTable)
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = AVUser.current()?.object(forKey: DatabaseKey.portrait) as? Data  {
            let bgColor = UIColor(patternImage: UIImage(data: data)!)
            self.navigationController?.navigationBar.barTintColor = bgColor
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiveData()
        LaunchThemeManager.changeStatusBarStyle(.default)
        LaunchThemeManager.applyTheme(theme: .light)
        setupButtons()
        setupVersionLabel()
    }
    
    
    func setupVersionLabel() {
        appVersionLabel.morphingEffect = .sparkle
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            appVersionLabel.text = "版本"
            
            Completable.create {[weak self] (complete) -> Disposable in
                self?.appVersionLabel.text = "v\(version)"
                complete(.completed)
                return Disposables.create()
                }.delay(.seconds(3), scheduler: MainScheduler.instance)
                .subscribe()
                .disposed(by: rx.disposeBag)
        }
    }
    
    func setupButtons() {
        verifyEmailButton.setTitleColor(LaunchThemeManager.currentTheme().textBlackColor.withAlphaComponent(0.4), for: .disabled)
        verifyEmailButton.setTitleColor(LaunchThemeManager.currentTheme().textBlackColor.withAlphaComponent(0.4), for: .highlighted)
        
        if let disableTitle = verifyEmailButton.titleLabel?.text {
            let string = NSMutableAttributedString(string: disableTitle + "   (已验证)")
            string.setColorForText("(已验证)", with: LaunchThemeManager.currentTheme().mainColor)
            string.setFontForText("(已验证)", with: UIFont.boldSystemFont(ofSize: 14))
            verifyEmailButton.setAttributedTitle(string, for: .disabled)
            
        }
        
        if let isVerified = AVUser.current()?.object(forKey: DatabaseKey.emailVerified) as? Bool {
            
            if isVerified {
                verifyEmailButton.isEnabled = false
            } else {
                verifyEmailButton.isEnabled = true
            }
        }
        
        let cache = UIDevice.current.getAppUsedDiskSpaceInMB().description
        guard let title = self.cleanCacheButton.titleLabel?.text else { return }
        let string = NSMutableAttributedString(string: title + "  " + "已使用(\(cache))MB")
        string.setColorForText("已使用(\(cache))MB", with: LaunchThemeManager.currentTheme().textBlackColor.withAlphaComponent(0.7))
        string.setFontForText("已使用(\(cache))MB", with: UIFont.boldSystemFont(ofSize: 14))
        cleanCacheButton.setAttributedTitle(string, for: .normal)
        
    }
    
    
    func setupLiveData() {
        
        if let nickname = AVUser.current()?.object(forKey: DatabaseKey.nickname) as? String, let data = AVUser.current()?.object(forKey: DatabaseKey.portrait) as? Data  {
            navigationItem.title = nickname
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: UIImage(data: data)!)
        } else {
            navigationItem.title = AVUser.current()?.username
        }
        
        UserInfoLiveData.shared.liveDataHasChanged.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (notification) in
            guard let block = notification else { return }
            let (liveQuery, object, _) = block
            guard let this = self else { return }
            if this.userQuery.className == liveQuery.query.className {
                guard let user = object as? AVUser else { return }
                
                if let nickname = user.object(forKey: DatabaseKey.nickname) as? String {
                    this.navigationItem.title = nickname
                }
                if let isVerified = user.object(forKey: DatabaseKey.emailVerified) as? Bool {
                    
                    if isVerified {
                        this.verifyEmailButton.isEnabled = false
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
            AVUser.current()?.saveInBackground({ (s, e) in
                print(s)
                print(e?.localizedDescription ?? "")
                
            })
            
            // 为了防止 socket 失效
            NotificationCenter.default.post(name: .loginStateDidChnage, object: false)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let alertVC = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertVC.addAction(logoutAction)
        alertVC.addAction(cancelAction)
        navigationController?.present(alertVC, animated: true, completion: nil)
        
    }
    
    @IBAction func verifyButtonTap(_ sender: UIButton) {
        guard let email = AVUser.current()?.email else {
            HUD.flash(.label("无法获取用户邮箱"), delay: 2)
            return
        }
        
        self.showAlert(title: "重要", message: "确定要给: \(email) 发送邮件验证码?", buttonTitles: ["发送", "取消"], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                AVUser.requestEmailVerify(email, with: { (s, e) in
                    if let error = e {
                        HUD.flash(.label(error.localizedDescription), delay: 2)
                    } else {
                        HUD.flash(.label("发送成功, 请登录邮箱查询"), delay: 2)
                    }
                })
            }
        }
    }
    
    
    @IBAction func changeHeaderTap(_ sender: UIButton) {
        
        DGPicker.pickImage(count: 1).drive(onNext: { (items) in
            
            guard let image = items.singlePhoto else { return }
            if let data = image.image.compressedData() {
                AVUser.current()?.setObject(data, forKey: DatabaseKey.portrait)
                AVUser.current()?.saveInBackground({[weak self] (s, error) in
                    if let e = error {
                        HUD.flash(.label(e.localizedDescription), delay: 2)
                    } else {
                        HUD.flash(.label("保存成功"), delay: 2)
                        let bgColor = UIColor(patternImage: image.image)
                        let titleColor = ContrastColorOf(bgColor, returnFlat: true)
                        self?.navigationController?.navigationBar.barTintColor = bgColor
                        self?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
                        self?.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : titleColor]
                        
                    }
                })
            }
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func cleanTap(_ sender: UIButton) {
     
        self.showAlert(title: "重要提示!", message: "清除缓存会导致APP在无网络情况下无法使用", buttonTitles: ["清除", "取消"], highlightedButtonIndex: 1) { (index) in
            if index == 0 {
                AVQuery.clearAllCachedResults()
            }
        }
    }
}


