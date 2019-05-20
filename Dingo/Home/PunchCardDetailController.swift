//
//  PunchCardDetailController.swift
//  Dingo
//
//  Created by mugua on 2019/5/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import SwiftDate
import LTMorphingLabel
import PKHUD

class PunchCardDetailController: UITableViewController {
    
    var task: TaskModel!
    @IBOutlet weak var timeLabel: LTMorphingLabel!
    @IBOutlet weak var punchButton: DGRippleButton!
    @IBOutlet weak var totalLabel: UILabel!
    var timer: Timer!
    let formatter = DateFormatter()
    let query = AVQuery(className: DatabaseKey.taskTable)
    var isPunch = false
    var currentObjc: AVObject?
    var useCount = 0
    @IBOutlet weak var deleteButton: UIButton!
    
    
    deinit {
        timer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = LaunchThemeManager.currentTheme().getProjectColor(index: task.color)
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LaunchThemeManager.changeStatusBarStyle(.default)
        self.navigationController?.navigationBar.barTintColor = LaunchThemeManager.currentTheme().textWhiteColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = LaunchThemeManager.currentTheme().getProjectColor(index: task.color)
        view.backgroundColor = LaunchThemeManager.currentTheme().getProjectColor(index: task.color)
        tableView.tableFooterView = UIView(frame: .zero)
        
        title = task.remindDate
        setupUI()
        bindData()
        getTaskFromCloud()
        
    }
    
    func getTaskFromCloud() {
        guard let id = task.objcId else {
            return
        }
        query.rx.getObjectInMainSchedulerBy(id: id).subscribe(onNext: {[unowned self] (obcj) in
            
            self.currentObjc = obcj
            guard let dict = obcj else { return }
            guard let updateTime = dict.object(forKey: "updatedAt") as? Date else { return }
            guard let count = dict.object(forKey: "usedCount") as? Int else { return }
            self.useCount = count
            
            if !updateTime.isToday || self.task.usedCount != 0 {
                self.isPunch = true
            } else {
                self.isPunch = false
            }
        }, onError: { (error) in
            HUD.flash(.label(error.localizedDescription), delay: 2)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindData() {
        useCount = task.usedCount
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        totalLabel.text = "已经打卡\(task.usedCount.description)次"
        timer = Timer(timeInterval: 2, repeats: true) {[unowned self] (_) in
            self.timeLabel.text = self.formatter.string(from: Date())
        }
        RunLoop.current.add(timer, forMode: .default)
        timer.fire()
        
    }
    
    func setupUI() {
        punchButton.setupDgStyle()
        timeLabel.morphingEffect = .sparkle
    }
    
    @IBAction func punchTap(_ sender: DGRippleButton) {

        if self.isPunch {
            HUD.flash(.label("您今天已经打过卡了"), delay: 2)
        } else {
            currentObjc?.setObject(self.useCount + 1, forKey: "usedCount")
            currentObjc?.saveEventually()
            navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: .refreshState, object: nil)
        }
    }
    
    @IBAction func deleteTap(_ sender: UIButton) {
        deleteAction()
    }
    
    private func deleteAction() {
        AVQuery.doCloudQueryInBackground(withCQL: "delete from \(DatabaseKey.taskTable) where objectId='\(task.objcId!)'", callback: {[weak self] (_, error) in
            if let e = error {
                HUD.flash(.label(e.localizedDescription), delay: 2)
            } else {
                
                self?.navigationController?.popViewController(animated: true)
                
                NotificationCenter.default.post(name: .refreshState, object: nil)
            }
        })
    }
}
