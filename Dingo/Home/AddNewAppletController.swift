//
//  AddNewAppletController.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit

enum AddAppletType: Int {
    case date = 0
    case local
}

class AddNewAppletCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(0.5)
        } else {
            bgView.backgroundColor = bgView.backgroundColor?.withAlphaComponent(1)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        bgView.setShadow()
    }
    
    func bindData(color: UIColor, text: String) {
        self.bgView.backgroundColor = color
        self.nameLabel.text = text
    }
}

struct AddNewAppletData {
    let name: String
    let index: Int
}


class AddNewAppletController: UITableViewController {
    
    var type: AddAppletType!
    var datasource: [AddNewAppletData] = []
    var color: UIColor!
    var icon: String!
    var descriptionText: String?
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        LaunchThemeManager.changeStatusBarStyle(.default)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = color
        LaunchThemeManager.changeStatusBarStyle(.lightContent)
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.register(UINib(nibName: "AddTaskHaderView", bundle: nil), forCellReuseIdentifier: "AddTaskHaderView")
        configUIByType()
    }
    
    func configUIByType() {
        guard let type = type else {
            return
        }
        switch type {
        case .date:
            configDateUI()
        case .local:
            configLocalUI()
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewAppletCell", for: indexPath) as! AddNewAppletCell
        let data = datasource[indexPath.row]
        cell.bindData(color: color, text: data.name)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "AddTaskHaderView") as? AddTaskHaderView
        
        headerView?.bindData(icon: icon, color: color, description: descriptionText)
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let t = type else {
            return
        }
        
        switch t {
        case .date:
            gotoDateSettingVC(index: indexPath.row)
        case .local:
            break
        }
    }
}

extension AddNewAppletController {
    
    func configDateUI() {
        descriptionText = "启用此服务, 按照每小时, 每天, 每周或者每年运行. 它会自动根据您所在的时区定制生成."
        
        let item0 = AddNewAppletData(name: "每天提醒", index: 0)
        let item1 = AddNewAppletData(name: "每小时提醒", index: 1)
        let item2 = AddNewAppletData(name: "每周提醒", index: 2)
        let item3 = AddNewAppletData(name: "每年提醒", index: 3)
        
        datasource = [item0, item1, item2, item3]
    }
    
    func configLocalUI() {
        
    }
    
    func gotoDateSettingVC(index: Int) {
        let dateSettingVC: DateTaskSettingController = ViewLoader.Storyboard.controller(from: "Home")
        if let type = DateTaskSettingController.DateType(rawValue: index) {
            dateSettingVC.dateType = type
        }
        if let taksType = type {
            dateSettingVC.taskType = taksType
        }
        switch index {
        case 0:
            dateSettingVC.funcNameText = "每天提醒"
            dateSettingVC.funcDescribeText = "此触发器会在您设置的特定时间触发每一天"
            dateSettingVC.chooseText = "时间"
            dateSettingVC.datePickerMode = .time
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            dateSettingVC.dateFormatter = formatter
            
        case 1:
            dateSettingVC.funcNameText = "每小时提醒"
            dateSettingVC.funcDescribeText = "此触发器会在每小时内触发一次"
            dateSettingVC.chooseText = "过了几分钟"
            
        case 2:
            dateSettingVC.funcNameText = "每周提醒"
            dateSettingVC.funcDescribeText = "此触发器仅在您提供的一周中的特定日期触发"
            dateSettingVC.chooseText = "一天中的时间"
            dateSettingVC.showDaysOfWeek = true
            dateSettingVC.datePickerMode = .time
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            dateSettingVC.dateFormatter = formatter
            
        case 3:
            dateSettingVC.funcNameText = "每年提醒"
            dateSettingVC.funcDescribeText = "此触发器仅在您提供的一年中的特定日期触发"
            dateSettingVC.chooseText = "一年中的时间"
            dateSettingVC.datePickerMode = .dateAndTime
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateSettingVC.dateFormatter = formatter
        default:
            break
        }
        navigationController?.pushViewController(dateSettingVC, animated: true)
    }
}
