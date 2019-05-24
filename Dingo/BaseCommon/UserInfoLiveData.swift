//
//  UserInfoLiveData.swift
//  Dingo
//
//  Created by mugua on 2019/5/9.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

class UserInfoLiveData: NSObject {
    
    /////////// 公开属性 公开方法/////////////////
    public typealias DataChangedNotification = (AVLiveQuery, object: AnyObject, updatedKeys: [String]?)
    
    static let shared = UserInfoLiveData()
    
    public var liveDataHasChanged = BehaviorRelay<DataChangedNotification?>(value: nil)
    
    
    /////////// 私有属性 私有方法/////////////////
    fileprivate let doingLiveQuery: AVLiveQuery
    fileprivate let userQuery = AVQuery(className: DatabaseKey.userTable)
    fileprivate var notificationBlock: DataChangedNotification?
    
    private override init() {
        
        self.doingLiveQuery = AVLiveQuery(query: userQuery)
        self.doingLiveQuery.subscribe(callback: { (s, error) in })
        super.init()
        self.doingLiveQuery.delegate = self
    }

}


extension UserInfoLiveData: AVLiveQueryDelegate {
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidDelete object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidEnter object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidLeave object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, userDidLogin user: AVUser) {
        liveDataHasChanged.accept((liveQuery, user, nil))
        NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
    }
}




class LiveData: NSObject, AVLiveQueryDelegate{
    
    /////////// 公开属性 公开方法/////////////////
    public typealias DataChangedNotification = (AVLiveQuery, object: AnyObject, updatedKeys: [String]?)

    public var liveDataHasChanged = BehaviorRelay<DataChangedNotification?>(value: nil)
    
    /////////// 私有属性 私有方法/////////////////
    fileprivate var doingLiveQuery: AVLiveQuery?
    fileprivate var notificationBlock: DataChangedNotification?
    
    convenience init(query: AVQuery) {
        self.init()
        self.doingLiveQuery = AVLiveQuery(query: query)
        self.doingLiveQuery?.subscribe(callback: { (s, error) in })
        self.doingLiveQuery?.delegate = self
       
    }
    
    func unsubscribe() {
        self.doingLiveQuery?.unsubscribe(callback: { (_, _) in
        })
    }

    func liveQuery(_ liveQuery: AVLiveQuery, objectDidCreate object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidUpdate object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidDelete object: Any) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, nil))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidEnter object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, objectDidLeave object: Any, updatedKeys: [String]) {
        liveDataHasChanged.accept((liveQuery, object as AnyObject, updatedKeys))
    }
    
    func liveQuery(_ liveQuery: AVLiveQuery, userDidLogin user: AVUser) {
        liveDataHasChanged.accept((liveQuery, user, nil))
        NotificationCenter.default.post(name: .loginStateDidChnage, object: true)
    }
    
}



