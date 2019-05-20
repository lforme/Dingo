//
//  SoundListPopViewController.swift
//  Dingo
//
//  Created by mugua on 2019/5/20.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SoundListPopViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let query = AVQuery(className: DatabaseKey.taskTable)
    var section: SectionModel<String, TaskModel>!
    var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, TaskModel>>!
    var didSelectSound: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        setupRx()
    }
    
    func setupRx() {
        
        guard let userId = AVUser.current()?.objectId else {
            return
        }
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, TaskModel>>.init(configureCell: { (ds, tv, ip, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "UITableViewCell", for: ip)
            cell.textLabel?.text = item.remindDate
            return cell
        })
        
        let taskType = AddAppletType.makeSound
        query.whereKey("taskType", equalTo: taskType.rawValue)
        
        TaskModel.fetchServerModels(by: userId, query: query, querySize: 100, page: 0).asObservable().map { (models) -> [SectionModel<String, TaskModel>] in
            
            return [SectionModel<String, TaskModel>(model: "自定义铃声", items: models)]
            
            }.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(TaskModel.self).subscribe(onNext: {[weak self] (item) in
            self?.dismiss(animated: false, completion: nil)
            guard let name = item.remindDate else { return }
            self?.didSelectSound?(name)
        }).disposed(by: rx.disposeBag)
    }
}

