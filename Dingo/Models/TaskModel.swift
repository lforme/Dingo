//
//  TaskModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import IGListKit


final class TaskModel {
    let name: String
    let usedCount: Int
    let remindDate: Date?
    let remindLocal: AVGeoPoint?
    let icon: String
    let color: Int
    let userId: String
    let `repeat`: Bool
    let taskType: Int
    
    init(userId: String, name: String, usedCount: Int, icon: String, color: Int, repeat: Bool, taskType: Int, remindDate: Date?, remindLocal: AVGeoPoint?) {
        self.userId = userId
        self.name = name
        self.usedCount = usedCount
        self.icon = icon
        self.color = color
        self.remindDate = remindDate
        self.remindLocal = remindLocal
        self.repeat = `repeat`
        self.taskType = taskType
    }
}

extension TaskModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        let identifier = self.userId + self.name
        return identifier as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? TaskModel else {
            return false
        }
        let right = self.userId + self.name
        let left = obj.userId + obj.name
        
        return right == left
    }    
}

extension TaskModel {
    
    func saveToLeanCloud() -> Observable<String> {
        
        return Observable<String>.create({[weak self] (obs) -> Disposable in
            
            guard let this = self else {
                return Disposables.create()
            }
            
            let leancloudObjc = AVObject(className: "TaskModel")
            leancloudObjc.setObject(this.name, forKey: "name")
            leancloudObjc.setObject(this.userId, forKey: "userId")
            leancloudObjc.setObject(this.usedCount, forKey: "usedCount")
            leancloudObjc.setObject(this.icon, forKey: "icon")
            leancloudObjc.setObject(this.color, forKey: "color")
            leancloudObjc.setObject(this.repeat, forKey: "repeat")
            leancloudObjc.setObject(this.taskType, forKey: "taskType")
            if let date = this.remindDate {
                leancloudObjc.setObject(date, forKey: "remindDate")
            }
            if let local = this.remindLocal {
                leancloudObjc.setObject(local, forKey: "remindLocal")
            }
            
            leancloudObjc.saveInBackground({ (success, error) in
                if let e = error {
                    obs.onError(e)
                } else {
                    if let id = leancloudObjc.objectId {
                        obs.onNext(id)
                        obs.onCompleted()
                    }
                }
            })
            
            return Disposables.create()
            
        }).observeOn(MainScheduler.instance)
    }
    
    static func fetchServerModels(by userId: String) -> Driver<[TaskModel]> {
        return Observable<[TaskModel]>.create({ (observer) -> Disposable in
            
            let query = AVQuery(className: "TaskModel")
            query.whereKey("userId", equalTo: userId)
            query.findObjectsInBackground({ (objs, error) in
                if let e = error {
                    observer.onError(e)
                } else {
                    let entitis = objs as? [TaskModel]
                    if let tasks = entitis {
                        observer.onNext(tasks)
                        observer.onCompleted()
                    }
                }
            })
            return Disposables.create()
        }).asDriver(onErrorJustReturn: [])
    }
}
