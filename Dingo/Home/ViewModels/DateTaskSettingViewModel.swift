//
//  DateTaskSettingViewModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/14.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import PKHUD
import UserNotifications
import SwiftDate
import Action

extension Date {
    func localString(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> String {
        return DateFormatter.localizedString(from: self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
}

final class DateTaskSettingViewModel {
    
    typealias Inptu = (date: Date, notiIdentifier: String)
    
    let content: UNMutableNotificationContent
    let dateType: DateTaskSettingController.DateType
    let _userId: String
    let observerDate = BehaviorRelay<Date?>(value: nil)
    var action: Action<Inptu, Void>!
    let _repeats: Bool
    let _taskType: AddAppletType
    let observerOfset = BehaviorRelay<Int>(value: 15)
    private var task: TaskModel!
    
    // 星期几 observe property
    let mon = BehaviorRelay<Bool>(value: false)
    let tues = BehaviorRelay<Bool>(value: false)
    let wed = BehaviorRelay<Bool>(value: false)
    let thurs = BehaviorRelay<Bool>(value: false)
    let fir = BehaviorRelay<Bool>(value: false)
    let sta = BehaviorRelay<Bool>(value: false)
    let sun = BehaviorRelay<Bool>(value: false)
    
    
    init(type: DateTaskSettingController.DateType, userId: String, taskType: AddAppletType, repeats: Bool = true) {
        content = UNMutableNotificationContent()
        content.title = "叮咚叮咚"
        content.body = "这是一条您于\(Date().localString())设置的提醒任务"
        content.categoryIdentifier = Date().localString()
        content.sound = UNNotificationSound.default
        dateType = type
        _userId = userId
        _repeats = repeats
        _taskType = taskType
        setupAction()
    }
    
    func setupAction() {
        
        guard let username = AVUser.current()?.username else  {
            return
        }
        
        let enable = observerDate.map { (d) -> Bool in
            if d == nil {
                return false
            } else {
                return true
            }
        }
        
        action = Action<Inptu, Void>(enabledIf: enable, workFactory: {[unowned self] (input) -> Observable<Void> in
            
            let n = username + Date().localString()
            self.task = TaskModel(userId: self._userId, name: n, usedCount: 0, icon: "server_date_icon", color: 2, repeat: self._repeats, taskType: self._taskType.rawValue, remindDate: nil, remindLocal: nil, id: nil, functionType: self.dateType.rawValue)
            let guaranteeValue =  self.observerDate.value!
            switch self.dateType {
            case .everyDayAt:
                
                self.task.remindDate = String(guaranteeValue.hour) + ":" + String( guaranteeValue.minute)
                
            case .everyHourAt:
                let date = guaranteeValue + self.observerOfset.value.minutes
                self.task.remindDate = String(date.hour) + ":" + String( date.minute)
                
            case .everyDayOfWeek:
                var weekDay = 0
               let weekString = [self.mon.value, self.tues.value, self.wed.value, self.thurs.value, self.fir.value, self.sta.value, self.sun.value].map { (isOn) -> (Int, Bool) in
                    weekDay += 1
                    return (weekDay, isOn)
                    }.filter{ $0.1 }.map { "星期\($0.0)." }.description
                
                self.task.remindDate = weekString + "\(guaranteeValue.hour)" + ":" + "\(guaranteeValue.minute)"
                
            case .everyYearOn:
                
                self.task.remindDate = guaranteeValue.description
            }
            
            
            return self.task.saveToLeanCloud().flatMapLatest({ (id) -> Observable<Void> in
                
                return Observable<Void>.create({[weak self] (obs) -> Disposable in
                    guard let this = self else {
                        return Disposables.create()
                    }
                    this.content.userInfo = ["objecId": id]
                    this.generateNotification(notiIdentifier: id, repeats: this._repeats)
                    obs.onNext(())
                    obs.onCompleted()
                    return Disposables.create()
                })
            })
        })
    }
    
    private func generateNotification(notiIdentifier: String, repeats: Bool) {
        guard let date = observerDate.value else {
            return
        }
        
        switch dateType {
        case .everyDayAt:
            var dateCompo = DateComponents()
            dateCompo.hour = date.hour
            dateCompo.minute = date.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: repeats)
            let notificationReq = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
            
        case .everyHourAt:
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(self.observerOfset.value * 60), repeats: repeats)
            let notificationReq = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
            
        case .everyDayOfWeek:
            var weekDay = 0
            [mon.value, tues.value, wed.value, thurs.value, fir.value, sta.value, sun.value].map { (isOn) -> (Int, Bool) in
                weekDay += 1
                return (weekDay, isOn)
                }.forEach { (tuple) in
                    let (d, isOn) = tuple
                    if isOn {
                        var dateCompo = DateComponents()
                        dateCompo.hour = date.hour
                        dateCompo.minute = date.minute
                        dateCompo.weekday = d + 1
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: repeats)
                        let notificationReq = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
                    }
            }
            
        case .everyYearOn:
            
            var dateCompo = DateComponents()
            dateCompo.hour = date.hour
            dateCompo.minute = date.minute
            dateCompo.year = date.year
            dateCompo.weekday = date.weekday
            dateCompo.day = date.day
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateCompo, repeats: repeats)
            let notificationReq = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
        }
    }
}
