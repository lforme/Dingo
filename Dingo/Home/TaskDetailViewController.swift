//
//  TaskDetailViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/15.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import PKHUD

class TaskDetailViewController: UITableViewController {
    
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var runCountLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var bgViewOne: UIView!
    @IBOutlet weak var bgViewTwo: UIView!
    @IBOutlet weak var bgViewThree: UIView!
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var animationContainer: UIView!
    @IBOutlet weak var animationContainerHeighConstraint: NSLayoutConstraint!
    @IBOutlet weak var notiLabel: UILabel!
    @IBOutlet weak var createdTimeLabel: UILabel!
    
    var taskModel: TaskModel!
    var descriptionText: String?
    let isHideCloseButton = BehaviorRelay<Bool>(value: true)
    let isActiveObserver = BehaviorRelay<Bool>(value: true)
    var vm: TaskDetailViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        setupUI()
        bindData()
        setupRx()
        
        vm.cleanNotification()
    }
    
    func bindData() {
        topIcon.image = UIImage(named: taskModel.icon)
        descriptionLabel.text = descriptionText
        userLabel.text = taskModel.name
        isActiveObserver.accept(taskModel.available)
        runCountLabel.text = "· 已运行\(taskModel.usedCount)次"
        
        let query = AVQuery(className: DatabaseKey.taskTable)
        query.rx.getObjectInMainSchedulerBy(id: taskModel.objcId ?? "").map { $0?.createdAt?.description }.bind(to: createdLabel.rx.text).disposed(by: rx.disposeBag)
        
        vm = TaskDetailViewModel(task: taskModel)
    }
    
    func setupRx() {
        
        isHideCloseButton.bind(to: closeButton.rx.isHidden).disposed(by: rx.disposeBag)
        isHideCloseButton.bind(to: notiLabel.rx.isHidden).disposed(by: rx.disposeBag)
        
        isActiveObserver.bind(to: activeSwitch.rx.value).disposed(by: rx.disposeBag)
        isActiveObserver.map { $0 ? "激活" : "未激活"}.bind(to: activeLabel.rx.text).disposed(by: rx.disposeBag)
        
        activeSwitch.rx.value.bind(to: isActiveObserver).disposed(by: rx.disposeBag)
        
        activeSwitch.rx.value.subscribe(onNext: {[weak self] (isOn) in
            
            if !isOn {
                self?.showActionSheet(title: "重要提示", message: "关闭之后就会删除任务", buttonTitles: ["删除任务", "取消"], highlightedButtonIndex: 1, completion: { (index) in
                    if index == 0 {
                        guard let this = self, let objcId = this.taskModel.objcId else { return }
                        this.vm.deleteTaskAction.execute(objcId).subscribe().disposed(by: this.rx.disposeBag)
                    }
                })
            }
            
        }).disposed(by: rx.disposeBag)
        
        self.vm.deleteTaskAction.executing.bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: self.rx.disposeBag)
        self.vm.deleteTaskAction.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
        
        self.vm.deleteTaskAction.elements.subscribe(onNext: {[unowned self] (success) in
            if success {
                self.vm.cleanNotification()
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: .refreshState, object: nil)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func setupUI() {
        view.layoutIfNeeded()
        self.animationContainerHeighConstraint.constant = 0
        
        bgViewOne.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8)
        bgViewThree.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8)
        [bgViewOne, bgViewTwo].forEach {[weak self] (v) in
            guard let this = self else { return }
            v?.backgroundColor = LaunchThemeManager.currentTheme().getProjectColor(index: this.taskModel.color)
        }
        guard let taksType = AddAppletType(rawValue: taskModel.taskType) else {
            return
        }
        switch taksType {
        case .date:
            bgViewThree.backgroundColor = UIColor.flatBlueDark
            lineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        case .local:
            bgViewThree.backgroundColor = UIColor.flatBlackDark
            lineView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            
        case .punchCard: break
        case .makeSound: break
        }
        
        moreButton.underlineButton(text: "更多")
    }
    
    @IBAction func moreButtonTap(_ sender: UIButton) {
        isHideCloseButton.accept(false)
        self.tableView.reloadData()
        
        view.layoutIfNeeded()
        self.animationContainerHeighConstraint.constant = 90
        UIView.animateKeyframes(withDuration: 0.8, delay: 0.1, options: [.calculationModeLinear, .beginFromCurrentState, .calculationModeDiscrete], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func closeButtonTap(_ sender: UIButton) {
        isHideCloseButton.accept(true)
        
        view.layoutIfNeeded()
        self.animationContainerHeighConstraint.constant = 0
        
        UIView.animateKeyframes(withDuration: 0.8, delay: 0, options: [.calculationModeLinear, .beginFromCurrentState, .calculationModeDiscrete], animations: {
            self.view.layoutIfNeeded()
        }, completion: { f in
            self.tableView.reloadData()
        })
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return isHideCloseButton.value ? 260 : 360
        case 1:
            return 60
        case 2:
            return 80
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
}
