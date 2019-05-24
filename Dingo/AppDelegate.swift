//
//  AppDelegate.swift
//  Dingo
//
//  Created by mugua on 2019/5/5.
//  Copyright © 2019 mugua. All rights reserved.
//
import UserNotifications
import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var player: AVAudioPlayer?
    fileprivate let query = AVQuery(className: DatabaseKey.taskTable)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        setupPlayer()
        
        return LaunchThemeManager.launchInit()
    }
    
    private func setupPlayer() {
        if let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
            } catch let error  {
                print(error.localizedDescription)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        DGNotiBanner.shareInstance.show(title: "叮咚", subtitle: "叮咚一下", style: .info, completion: nil)
        player?.play()
        
        if let id = notification.request.content.userInfo["objcId"] as? String {
            updateTaskSynchronizationNetwork(objcId: id)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let id = response.notification.request.content.userInfo["objcId"] as? String {
            updateTaskSynchronizationNetwork(objcId: id)
        }
        
        if let dateFunctionType = response.notification.request.content.userInfo["dateType"] as? Int {
            let type = DateTaskSettingController.DateType(rawValue: dateFunctionType)
            if type == DateTaskSettingController.DateType.everyHourAt {
                center.add(response.notification.request, withCompletionHandler: nil)
            }
        }
    }
    
    private func updateTaskSynchronizationNetwork(objcId: String) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[unowned self] in
            let task = self.query.getObjectWithId(objcId)
            task?.incrementKey("usedCount")
            task?.saveInBackground()
        }
    }
}

