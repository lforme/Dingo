//
//  DateTaskSettingController.swift
//  Dingo
//
//  Created by mugua on 2019/5/14.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate
import RxCocoa
import RxSwift
import RxDataSources
import Action
import PKHUD

class DateTaskSettingController: UITableViewController {
    
    enum DateType: Int {
        case everyDayAt = 0
        case everyHourAt
        case everyDayOfWeek
        case everyYearOn
    }
    
    @IBOutlet weak var functionName: UILabel!
    @IBOutlet weak var functionDescribe: UILabel!
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var chooseTextfield: UITextField!
    @IBOutlet weak var createdButton: UIButton!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    
    // 星期 swich
    @IBOutlet weak var monSwitch: UISwitch!
    @IBOutlet weak var tuesSwitch: UISwitch!
    @IBOutlet weak var wedSwitch: UISwitch!
    @IBOutlet weak var thursSwitch: UISwitch!
    @IBOutlet weak var friSwitch: UISwitch!
    @IBOutlet weak var satSwitch: UISwitch!
    @IBOutlet weak var sunSwitch: UISwitch!
    @IBOutlet weak var notiSoundLabel: UILabel!
    
    var taskType: AddAppletType!
    var dateFormatter: DateFormatter?
    let region = Region(calendar: Calendar.Identifier.gregorian, zone: Zones.asiaShanghai, locale: Locales.chinese)
    
    lazy var datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.locale = Locale(identifier: "zh")
        p.minimumDate = Date()
        p.date = Date()
        p.datePickerMode = datePickerMode
        return p
    }()
    
    lazy var valuePicker: UIPickerView = {
        let p = UIPickerView()
        return p
    }()
    
    private let stringPickerAdapter = RxPickerViewStringAdapter<[[String]]>(components: [], numberOfComponents: { (ds, pk, components) -> Int in
        return components.count
    }, numberOfRowsInComponent: { (ds, pk, components, component) -> Int in
        return components[component].count
    }) { (ds, pk, components, row, component) -> String? in
        return components[component][row]
    }
    
    var funcNameText: String?
    var funcDescribeText: String?
    var chooseText: String?
    var showDaysOfWeek = false
    var dateType: DateType = .everyDayAt
    var datePickerMode: UIDatePicker.Mode = .date
    
    private let offsetTime = ["15", "30", "45"]
    
    var vm: DateTaskSettingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "新任务"
        setupUI()
        setupViewModel()
        bindData()
        setupRx()
    }
    
    func setupRx() {
        
        createdButton.rx.bind(to: vm.action) {[unowned self] (_) -> DateTaskSettingViewModel.Inptu in
            return (self.vm.observerDate.value!, "")
        }
        
        monSwitch.rx.value.bind(to: vm.mon).disposed(by: rx.disposeBag)
        tuesSwitch.rx.value.bind(to: vm.tues).disposed(by: rx.disposeBag)
        wedSwitch.rx.value.bind(to: vm.wed).disposed(by: rx.disposeBag)
        thursSwitch.rx.value.bind(to: vm.thurs).disposed(by: rx.disposeBag)
        friSwitch.rx.value.bind(to: vm.fir).disposed(by: rx.disposeBag)
        satSwitch.rx.value.bind(to: vm.sta).disposed(by: rx.disposeBag)
        sunSwitch.rx.value.bind(to: vm.sun).disposed(by: rx.disposeBag)
        
        vm.action.elements.subscribe(onNext: {[unowned self] (_) in
            HUD.flash(.label("设置成功"), delay: 2)
            self.navigationController?.popToRootViewController(animated: true)
            NotificationCenter.default.post(name: .refreshState, object: nil)
        }).disposed(by: rx.disposeBag)
        
        vm.action.executing.asObservable().bind(to: PKHUD.sharedHUD.rx.animation).disposed(by: rx.disposeBag)
        vm.action.errors.actionErrorShiftError().bind(to: PKHUD.sharedHUD.rx.showError).disposed(by: rx.disposeBag)
    }
    
    func setupViewModel() {
        guard let userId = AVUser.current()?.objectId else {
            return
        }
        
        if self.dateType == .everyYearOn {
            vm = DateTaskSettingViewModel(type: self.dateType, userId: userId, taskType: self.taskType, repeats: false)
        } else {
            vm = DateTaskSettingViewModel(type: self.dateType, userId: userId, taskType: self.taskType)
        }
    }
    
    func bindData() {
        functionName.text = funcNameText
        functionDescribe.text = funcDescribeText
        chooseLabel.text = chooseText
        
        if self.dateType == .everyHourAt {
            
            Observable.just([offsetTime]).subscribeOn(MainScheduler.asyncInstance)
                .observeOn(MainScheduler.asyncInstance)
                .bind(to: valuePicker.rx.items(adapter: stringPickerAdapter))
                .disposed(by: rx.disposeBag)
            chooseTextfield.inputView = valuePicker
            let share = valuePicker.rx.itemSelected.map {[unowned self] (row, com) -> String in
                return self.offsetTime[row]
                }.share()
            share.bind(to: chooseTextfield.rx.text).disposed(by: rx.disposeBag)
            share.map { Int($0) ?? 15 }.bind(to: vm.observerOfset).disposed(by: rx.disposeBag)
            chooseTextfield.text = offsetTime.first
            vm.observerDate.accept(Date())
            
        } else {
            
            chooseTextfield.inputView = datePicker
            let shareObserver = datePicker.rx.value.share()
            shareObserver.map {[weak self] (date) -> String in
                self?.dateFormatter?.string(from: date) ?? ""
                }.bind(to: chooseTextfield.rx.text).disposed(by: rx.disposeBag)
            
            shareObserver.map {[weak self] (date) -> Date in
                guard let this = self, let time = this.dateFormatter?.string(from: date) else { return date }
                return time.toDate()?.date ?? Date()
                
                }.bind(to: vm.observerDate).disposed(by: rx.disposeBag)
        }
    }
    
    func setupUI() {
        topContainerView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8)
        bottomContainerView.roundCorners([.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 8)
        let image = UIImage.from(color: createdButton.backgroundColor ?? UIColor.white)
        createdButton.dgSetBackgroundImage(image)
        createdButton.setupDgStyle()
        
        chooseTextfield.delegate = self
        let arrow = UIImageView(image: UIImage(named: "downward_icon"))
        if let size = arrow.image?.size {
            arrow.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        arrow.contentMode = .center
        chooseTextfield.rightView = arrow
        chooseTextfield.rightViewMode = .always
    }
    
//    @IBAction func showSoundListTap(_ sender: UIButton) {
//        let popVC: SoundListPopViewController = ViewLoader.Storyboard.controller(from: "Home")
//        popVC.preferredContentSize = CGSize(width: 150, height: 320)
//        popVC.modalPresentationStyle = .popover
//        popVC.isModalInPopover = false
//        let popoverPresentationController = popVC.popoverPresentationController
//        popoverPresentationController?.sourceView = sender
//        popoverPresentationController?.permittedArrowDirections = .up
//        popoverPresentationController?.delegate = self
//        popoverPresentationController?.sourceRect = CGRect(x: sender.frame.size.width / 2, y: sender.frame.size.height, width: 0, height: 0)
//        self.present(popVC, animated: false, completion: nil)
//
//        popVC.didSelectSound = {[weak self] (soundName) in
//            self?.notiSoundLabel.text = "已选择的提示音:\(soundName)"
//            self?.vm.observerNotiSouneName.accept(soundName)
//        }
//    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if showDaysOfWeek && section == 2 {
            return 8
        }
        return 1
    }
}

// MARK: - UITextFieldDelegate
extension DateTaskSettingController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
}


extension DateTaskSettingController: UIPopoverPresentationControllerDelegate {
   
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
