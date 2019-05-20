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
    var remindDate: String?
    var remindLocal: AVGeoPoint?
    let icon: String
    let color: Int
    let userId: String
    let `repeat`: Bool
    let taskType: Int
    let objcId: String?
    let functionType: Int
    let available: Bool
    
    init(userId: String, name: String, usedCount: Int, icon: String, color: Int, repeat: Bool, taskType: Int, remindDate: String?, remindLocal: AVGeoPoint?, id: String?, functionType: Int, available: Bool = true) {
        self.userId = userId
        self.name = name
        self.usedCount = usedCount
        self.icon = icon
        self.color = color
        self.remindDate = remindDate
        self.remindLocal = remindLocal
        self.repeat = `repeat`
        self.taskType = taskType
        self.objcId = id
        self.functionType = functionType
        self.available = available
    }
}

extension TaskModel: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        let identifier = self.objcId
        return identifier! as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? TaskModel else {
            return false
        }
        let right = self.objcId
        let left = obj.objcId
        
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
            leancloudObjc.setObject(this.functionType, forKey: "functionType")
            leancloudObjc.setObject(this.available, forKey: "available")
            if let date = this.remindDate {
                leancloudObjc.setObject(date, forKey: "remindDate")
            }
            if let local = this.remindLocal {
                leancloudObjc.setObject(local, forKey: "remindLocal")
            }
            
            leancloudObjc.saveEventually({ (_, error) in
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
    
    static func fetchServerModels(by userId: String, page: Int = 0) -> Driver<[TaskModel]> {
        let query = AVQuery(className: "TaskModel")
        query.whereKey("userId", equalTo: userId)
        query.order(byDescending: "createdAt")
        query.limit = 10
        query.skip = 10 * page
        return TaskModel.fetchServerModels(by: userId, query: query, page: page)
    }
    
    
    static func fetchServerModels(by userId: String, query: AVQuery, querySize: Int = 10, page: Int = 0) -> Driver<[TaskModel]> {
        
        return Observable<[TaskModel]>.create({ (observer) -> Disposable in
            
            query.whereKey("userId", equalTo: userId)
            query.order(byDescending: "createdAt")
            query.limit = querySize
            query.skip = 10 * page
            query.findObjectsInBackground({ (objs, error) in
                if let e = error {
                    observer.onError(e)
                } else {
                    
                    let entities = objs?.compactMap({ (elem) -> TaskModel? in
                        guard let dict = elem as? AVObject else { return nil }
                        guard let name = dict["name"] as? String,
                            let usedCount = dict["usedCount"] as? Int,
                            let icon = dict["icon"] as? String,
                            let color = dict["color"] as? Int,
                            let userId = dict["userId"] as? String,
                            let `repeat` = dict["repeat"] as? Bool,
                            let taskType = dict["taskType"] as? Int,
                            let functionType = dict["functionType"] as? Int,
                            let available = dict["available"] as? Bool else { return nil }
                        
                        let remindDate = dict["remindDate"] as? String
                        let remindLocal = dict["remindLocal"] as? AVGeoPoint
                        let objcId = dict["objectId"] as? String
                        
                        let model = TaskModel(userId: userId, name: name, usedCount: usedCount, icon: icon, color: color, repeat: `repeat`, taskType: taskType, remindDate: remindDate, remindLocal: remindLocal, id: objcId, functionType: functionType, available: available)
                        return model
                        
                    })
                    
                    observer.onNext(entities ?? [])
                    observer.onCompleted()
                    
                }
            })
            return Disposables.create()
        }).asDriver(onErrorJustReturn: [])
    }
}
