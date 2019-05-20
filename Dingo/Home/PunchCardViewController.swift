//
//  PunchCardViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class PunchCardViewController: UIViewController {

    var type: AddAppletType!
    var saveAction: Action<TaskModel, String>!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = LaunchThemeManager.currentTheme().mainColor
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LaunchThemeManager.changeStatusBarStyle(.default)
        self.navigationController?.navigationBar.barTintColor = LaunchThemeManager.currentTheme().textWhiteColor
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRx()
    }
    
    func setupRx() {
        
        guard let userId = AVUser.current()?.objectId, let name = AVUser.current()?.username else { return }
        let enable = textField.rx.text.orEmpty.distinctUntilChanged().map { !$0.isEmpty }
        
        saveAction = Action<TaskModel, String>.init(enabledIf: enable, workFactory: { (taskModel) -> Observable<String> in
            return taskModel.saveToLeanCloud()
        })
        
        saveButton.rx.bind(to: saveAction) {[unowned self] (_) -> TaskModel in
            
            let model = TaskModel(userId: userId, name: name, usedCount: 0, icon: "punch_card_icon", color: 2, repeat: true, taskType: self.type.rawValue, remindDate: self.textField.text!, remindLocal: nil, id: nil, functionType: 0)
            
            return model
        }
        
        saveAction.executing.bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        saveAction.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        saveAction.elements.subscribe(onNext: {[unowned self] (_) in
            
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: .refreshState, object: nil)
            
        }).disposed(by: rx.disposeBag)
    }

}
