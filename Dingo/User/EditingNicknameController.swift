//
//  EditingNicknameController.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import Action
import RxCocoa
import RxSwift
import PKHUD


class EditingNicknameController: UITableViewController {
    
    let nicknameSubject = BehaviorRelay<String?>(value: nil)
    @IBOutlet weak var textfield: DGTextField!
    var saveButton: UIButton!
    var saveAction: Action<String, Bool>!
    @IBOutlet weak var containerView: UIView!
    
    deinit {
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        setupNavigationRightItem()
        bindRx()
        containerView.setShadow()
        title = "编辑昵称"
    }
    
    func bindRx() {
        
        if let nickname = AVUser.current()?.object(forKey: DatabaseKey.nickname) as? String {
            textfield.text = nickname
        }
        
        textfield.rx.text.orEmpty.distinctUntilChanged(){ $0 }.bind(to: nicknameSubject).disposed(by: rx.disposeBag)
        
        let enable = nicknameSubject.map { $0.isNotNilNotEmpty }
        saveAction = Action<String, Bool>(enabledIf: enable, workFactory: { (nick) -> Observable<Bool> in
            
            return Observable<Bool>.create({ (obs) -> Disposable in
                AVUser.current()?.setObject(nick, forKey: DatabaseKey.nickname)
                AVUser.current()?.saveInBackground({ (success, error) in
                    if let e = error {
                        obs.onError(e)
                    }
                    obs.onNext(success)
                    obs.onCompleted()
                })
                return Disposables.create()
            })
        })
        
        saveButton.rx.bind(to: saveAction) {[unowned self] (_) -> String in
            return self.nicknameSubject.value!
        }
        
        saveAction.executing.observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        saveAction.errors.actionErrorShiftError().observeOn(MainScheduler.instance).bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        saveAction.elements.observeOn(MainScheduler.instance).subscribe(onNext: {[unowned self] (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: rx.disposeBag)
        
    }
    
    func setupNavigationRightItem() {
        saveButton = createdRightNavigationItem(title: nil, image: UIImage(named: "save_icon"))
        
    }
}
