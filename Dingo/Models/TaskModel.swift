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
    
    init(userId: String, name: String, usedCount: Int, icon: String, color: Int, repeat: Bool, remindDate: Date?, remindLocal: AVGeoPoint?) {
        self.userId = userId
        self.name = name
        self.usedCount = usedCount
        self.icon = icon
        self.color = color
        self.remindDate = remindDate
        self.remindLocal = remindLocal
        self.repeat = `repeat`
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
    
    func saveToLeanCloud(by userId: String) -> Bool {
        let leancloudObjc = AVObject(className: "TaskModel")
        leancloudObjc.setObject(name, forKey: "name")
        leancloudObjc.setObject(userId, forKey: "userId")
        leancloudObjc.setObject(usedCount, forKey: "usedCount")
        leancloudObjc.setObject(icon, forKey: "icon")
        leancloudObjc.setObject(color, forKey: "color")
        leancloudObjc.setObject(`repeat`, forKey: "repeat")
        if let date = remindDate {
            leancloudObjc.setObject(date, forKey: "remindDate")
        }
        if let local = remindLocal {
            leancloudObjc.setObject(local, forKey: "remindLocal")
        }
        
       return leancloudObjc.save()
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
