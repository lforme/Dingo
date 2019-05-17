//
//  LoginAndRegisterController.swift
//  Dingo
//
//  Created by mugua on 2019/5/6.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class LoginAndRegisterController: UIViewController {
    
    enum SwitchButtonType: Int {
        case login = 0
        case register
    }
    
    @IBOutlet weak var switchButton: UIButton!
    
    @IBOutlet weak var loginUserNameTf: UITextField!
    @IBOutlet weak var loginPwdTf: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginContainer: UIView!
    
    @IBOutlet weak var registerContainer: UIView!
    @IBOutlet weak var registerUserNameTF: UITextField!
    @IBOutlet weak var registerPwdTf: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTf: UITextField!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let keychain = Keychain()
    
    let observeableSwitchButtonType:BehaviorSubject<SwitchButtonType> = BehaviorSubject(value: .register)
    
    let vm = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactiveNavigationBarHidden = true
        setupUI()
        bindRx()
    }
    
    func setupUI() {
        [loginPwdTf, loginUserNameTf, registerUserNameTF, registerPwdTf, emailTf].forEach { (tf) in
            tf?.layer.borderWidth = 2
            tf?.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3).cgColor
            tf?.layer.cornerRadius = 7
            tf?.placeholderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
            tf?.paddingLeftCustom = 8
            tf?.tintColor = UIColor.white
        }
        
        [loginButton, registerButton].forEach { (bt) in
            bt?.setupDgStyle()
            bt?.isEnabled = false
            let image = UIImage.from(color: bt?.backgroundColor ?? UIColor.white)
            bt?.dgSetBackgroundImage(image)
        }
        
        registerContainer.alpha = 0
    }
    
    func bindRx() {
        
        observeableSwitchButtonType.observeOn(MainScheduler.instance).subscribe(onNext: {[unowned self] (type) in
            switch type {
            case .login:
                self.switchButton.underlineButton(text: "登录")
                self.switchButton.tag = type.rawValue
                self.displayRegisterContainer()
                self.descriptionLabel.text = "注册您的 [ 叮咚 ] 账户"
            case .register:
                self.switchButton.underlineButton(text: "注册")
                self.switchButton.tag = type.rawValue
                self.displayLoginContainer()
                self.descriptionLabel.text = "开始探索 [ 叮咚 ]"
            }
        }).disposed(by: rx.disposeBag)
        
        
        loginUserNameTf.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.loginPhone).disposed(by: rx.disposeBag)
        loginPwdTf.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.loginPwd).disposed(by: rx.disposeBag)
        
        loginButton.rx.bind(to: vm.loginAction) {[unowned self] (_) -> (LoginViewModel.LoginInput) in
            
            self.view.endEditing(true)
            
            return (self.vm.loginPhone.value!, self.vm.loginPwd.value!)
        }
        
        vm.loginAction.executing.observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        vm.loginAction.errors.actionErrorShiftError().observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        vm.loginAction.elements.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (user) in
            
            HUD.flash(.label("登录成功"), delay: 2)
            AVUser.current()?.setObject(true, forKey: DatabaseKey.isLogin)
            AVUser.current()?.setObject(UIDevice.current.identifierForVendor?.uuidString, forKey: DatabaseKey.uuid)
            AVUser.current()?.saveInBackground({ (s, e) in
                print(s)
                print(e?.localizedDescription ?? "")
            })
            guard let pwd = self?.vm.loginPwd.value else { return }
            try? self?.keychain.set(pwd, key: "password")
        }).disposed(by: rx.disposeBag)
        
        
        registerUserNameTF.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.registerPhone).disposed(by: rx.disposeBag)
        registerPwdTf.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.registerPwd).disposed(by: rx.disposeBag)
        emailTf.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: vm.registerEmail).disposed(by: rx.disposeBag)
        
        registerButton.rx.bind(to: vm.registerAction) {[unowned self] (_) -> (LoginViewModel.RegisterInput) in
            
            self.view.endEditing(true)
            
            return (self.vm.registerPhone.value!, self.vm.registerPwd.value!, self.vm.registerEmail.value!)
        }
        
        vm.registerAction.executing.observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        vm.registerAction.errors.actionErrorShiftError().observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        vm.registerAction.elements.observeOn(MainScheduler.instance).subscribe(onNext: {[weak self] (succeeded) in
            
            if succeeded {
                HUD.flash(.label("注册成功"), delay: 2)
                guard let pwd = self?.vm.loginPwd.value else { return }
                try? self?.keychain.set(pwd, key: "password")
                NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    @IBAction func switchButtonTap(_ sender: UIButton) {
        guard let type = SwitchButtonType(rawValue: sender.tag) else { return }
        
        switch type {
        case .login:
            observeableSwitchButtonType.onNext(.register)
        case .register:
            observeableSwitchButtonType.onNext(.login)
        }
    }
}

// MARK: - 动画
extension LoginAndRegisterController {
    
    
    func displayRegisterContainer() {
        UIView.animateAndChain(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.loginContainer.alpha = 0
            self.loginContainer.center.y -= 100
        }, completion: nil).animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.registerContainer.alpha = 1
            self.registerContainer.center = self.view.center
        }, completion: nil)
    }
    
    func displayLoginContainer() {
        UIView.animateAndChain(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.registerContainer.alpha = 0
            self.registerContainer.center.y -= 100
        }, completion: nil).animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.loginContainer.alpha = 1
            self.loginContainer.center = self.view.center
        }, completion: nil)
    }
    
    
}
