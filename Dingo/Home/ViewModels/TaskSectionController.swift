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
    }
    
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
        if addType == .date {
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
        } else {
            cell.effectBgView.backgroundColor = UIColor.flatBlack
            cell.decreaseLabel.text = "有过你进入或者离开\("这个区域"), 叮咚就会发出提醒"
            return cell
        }
    }
    
    override func didSelectItem(at index: Int) {
        let taskDetailVC: TaskDetailViewController = ViewLoader.Storyboard.controller(from: "Home")
        taskDetailVC.taskModel = task
        taskDetailVC.descriptionText = selectedText
        viewController?.navigationController?.pushViewController(taskDetailVC, animated: true)
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
