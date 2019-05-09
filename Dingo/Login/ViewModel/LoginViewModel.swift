//
//  LoginViewModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/7.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import Action
import RxCocoa
import RxSwift


struct LoginViewModel {
    
    typealias LoginInput = (username: String, password :String)
    typealias RegisterInput = (username: String, password :String, email: String)
    
    let loginAction: Action<LoginInput, AVUser?>
    let loginPhone: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let loginPwd: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    let registerAction: Action<RegisterInput, Bool>
    let registerPhone: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let registerPwd: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let registerEmail: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    init() {
        
        let loginEnable = Observable.combineLatest(loginPhone.asObservable(), loginPwd.asObservable()).map { (a, b) -> Bool in
            
            return a.isNotNilNotEmpty && b.isNotNilNotEmpty
        }
        
        loginAction = Action<LoginInput, AVUser?>(enabledIf: loginEnable, workFactory: { (inputs) -> Observable<AVUser?> in
    
            return Observable<AVUser?>.create({ (obs) -> Disposable in
                
                AVUser.logInWithUsername(inBackground: inputs.username, password: inputs.password, block: { (user, error) in
                    if let e = error {
                        obs.onError(e)
                    } else {
                        obs.onNext(user)
                        obs.onCompleted()
                    }
                })
                return Disposables.create()
            })
        })
        
        let registerEnable = Observable.combineLatest(registerPhone.asObservable(), registerPwd.asObservable(), registerEmail.asObservable()).map { (a, b, c) -> Bool in
            
            return a.isNotNilNotEmpty && b.isNotNilNotEmpty && c.isNotNilNotEmpty
        }
        
        registerAction = Action<RegisterInput, Bool>(enabledIf: registerEnable, workFactory: { (inputs) -> Observable<Bool> in
            
            return Observable<Bool>.create({ (obs) -> Disposable in
                
                let user = AVUser()
                user.username = inputs.username
                user.password = inputs.password
                user.email = inputs.email
                user.signUpInBackground({ (succeeded, error) in
                    obs.onNext(succeeded)
                    obs.onCompleted()
                    
                    if let e = error {
                        obs.onError(e)
                    }
                })
                
                return Disposables.create()
            })
        })
        
    }
}

