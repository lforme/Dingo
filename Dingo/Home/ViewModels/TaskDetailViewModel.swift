//
//  TaskDetailViewModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/16.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import PKHUD
import UserNotifications
import Action

final class TaskDetailViewModel {
    
    let _task: TaskModel
    let taksType: AddAppletType
    let dataFuncType: DateTaskSettingController.DateType
    let deleteTaskAction: Action<String, Bool>
    
    init(task: TaskModel) {
        self._task = task
        taksType = AddAppletType(rawValue: task.taskType) ?? AddAppletType.date
        dataFuncType = DateTaskSettingController.DateType(rawValue: task.functionType) ?? DateTaskSettingController.DateType.everyDayAt
        
        deleteTaskAction = Action<String, Bool>(workFactory: { (objcId) -> Observable<Bool> in
            return Observable<Bool>.create({ (observer) -> Disposable in
                
                AVQuery.doCloudQueryInBackground(withCQL: "delete from \(DatabaseKey.taskTable) where objectId='\(objcId)'", callback: { (_, error) in
                    if let e = error {
                        observer.onError(e)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                })
                
                return Disposables.create()
            })
            
        })
    }
    
    
    func cleanNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in

            let id = self._task.objcId
            let deleteIdentifiers = notificationRequests.filter { $0.identifier == id }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: deleteIdentifiers)
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
