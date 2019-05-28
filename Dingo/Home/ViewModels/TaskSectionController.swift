//
//  TaskSectionController.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import IGListKit

final class TaskSectionController: ListSectionController {
    
    private var task: TaskModel!
    private var selectedText: String?
    
    override init() {
        super.init()
        //        supplementaryViewSource = self
        inset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }cd
    
    override func numberOfItems() -> Int {
        return 1
    }
    
    override func sizeForItem(at index: Int) -> CGSize {
        return CGSize(width: collectionContext!.containerSize.width - 10, height: 240)
    }
    
    override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(withNibName: "MyTaskCell", bundle: nil, for: self, at: index) as? MyTaskCell else {
            fatalError()
        }
        cell.updateAvailableIconBy(available: task.available)
        let color = LaunchThemeManager.currentTheme().getProjectColor(index: task.color)
        cell.bkView.backgroundColor = color
        cell.icon.image = UIImage(named: task.icon)
        cell.ringsLabel.text = "已经提醒\(task.usedCount.description)次"
        guard let addType = AddAppletType(rawValue: task.taskType) else {
            fatalError()
        }
        guard let timeType = DateTaskSettingController.DateType(rawValue: task.functionType) else {
            fatalError()
        }
        
        switch addType {
        case .date:
            cell.effectBgView.backgroundColor = UIColor.flatNavyBlue
            switch timeType {
            case .everyDayAt:
                cell.decreaseLabel.text = "每天\(task.remindDate ?? "")叮咚就会发出提醒"
                selectedText = cell.decreaseLabel.text
            case .everyHourAt:
                cell.decreaseLabel.text = "叮咚会在每小时\(task.remindDate ?? "")发出提醒"
                selectedText = cell.decreaseLabel.text
            case .everyDayOfWeek:
                cell.decreaseLabel.text = "每个\(task.remindDate ?? "")叮咚就会发出提醒"
                selectedText = cell.decreaseLabel.text
            case .everyYearOn:
                cell.decreaseLabel.text = "一年中特殊的 \(task.remindDate![0..<19]) 叮咚就会出提醒!"
                selectedText = cell.decreaseLabel.text
            }
            return cell
            
        case .local:
            cell.effectBgView.backgroundColor = UIColor.flatBlack
            guard let locationType = LocationTaskSettingController.LocationType(rawValue: task.functionType), let building = task.remindDate else {
                fatalError()
            }
            
            switch locationType {
            case .enter:
                cell.decreaseLabel.text = "每当你进入\(building),叮咚就会提醒"
            case .exit:
                cell.decreaseLabel.text = "每当你离开\(building),叮咚就会提醒"
            case .enterAndExit:
                cell.decreaseLabel.text = "每当你进入或者离开\(building),叮咚就会提醒"
            }
            return cell
        case .punchCard:
            
            cell.decreaseLabel.text = "打卡任务\n\(task.remindDate!)"
            cell.ringsLabel.text = "已经打卡\(task.usedCount.description)次"
            
            return cell
        case .makeSound:
            if let text = task.remindDate {
                cell.decreaseLabel.text = "语音备忘:\n\(text)"
            }
            return cell
        }
    }
    
    override func didSelectItem(at index: Int) {
        
        guard let taskType = AddAppletType(rawValue: task.taskType) else {
            return
        }
        
        switch taskType {
        case .date, .local:
            let taskDetailVC: TaskDetailViewController = ViewLoader.Storyboard.controller(from: "Home")
            taskDetailVC.taskModel = task
            taskDetailVC.descriptionText = selectedText
            viewController?.navigationController?.pushViewController(taskDetailVC, animated: true)
            
        case .makeSound:
            let taskDetailOfSoundVC: TaskDetailOfSoundController = ViewLoader.Storyboard.controller(from: "Home")
            taskDetailOfSoundVC.task = task
            viewController?.navigationController?.pushViewController(taskDetailOfSoundVC, animated: true)
            
        case .punchCard:
            let punchVC: PunchCardDetailController = ViewLoader.Storyboard.controller(from: "Home")
            punchVC.task = task
            viewController?.navigationController?.pushViewController(punchVC, animated: true)
        }
    }
    
    override func didUpdate(to object: Any) {
        task = object as? TaskModel
    }
}

/*
 extension TaskSectionController: ListSupplementaryViewSource {
 func supportedElementKinds() -> [String] {
 return [UICollectionView.elementKindSectionHeader]
 }
 
 func viewForSupplementaryElement(ofKind elementKind: String, at index: Int) -> UICollectionReusableView {
 switch elementKind {
 case UICollectionView.elementKindSectionHeader:
 return generateHeaderView(atIndex: index)
 default:
 fatalError()
 }
 }
 
 func sizeForSupplementaryView(ofKind elementKind: String, at index: Int) -> CGSize {
 return CGSize(width: collectionContext!.containerSize.width, height: 40)
 }
 
 private func generateHeaderView(atIndex index: Int) -> UICollectionReusableView {
 
 guard let view = collectionContext?.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, for: self, nibName: "TaskHeaderView", bundle: nil, at: index) else {
 fatalError()
 }
 return view
 }
 }
 */
