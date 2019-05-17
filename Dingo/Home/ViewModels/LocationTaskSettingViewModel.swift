//
//  LocationTaskSettingViewModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/17.
//  Copyright © 2019 mugua. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Action
import MapKit
import UserNotifications

class LocationTaskSettingViewModel: NSObject {
    
    class SearchApi: AMapSearchAPI {}
    
    typealias LocationResul = (location: CLLocation, name: String)
    typealias Inptu = (location: CLLocation, notiIdentifier: String)
    
    fileprivate let search: SearchApi
    fileprivate var currentLocation = CLLocation(latitude: 0, longitude: 0)
    
    let locationObservale = BehaviorRelay<LocationResul?>(value: nil)
    let currentCity = BehaviorRelay<String?>(value: nil)
    let content: UNMutableNotificationContent
    var action: Action<Inptu, Void>!
    let _userId: String
    let locationType: LocationTaskSettingController.LocationType
    
    private var task: TaskModel!
    
    
    init(userId: String, type: LocationTaskSettingController.LocationType) {
        search = SearchApi()
        content = UNMutableNotificationContent()
        content.title = "叮咚叮咚"
        content.categoryIdentifier = Date().localString()
        content.sound = UNNotificationSound.default
        self._userId = userId
        self.locationType = type
        super.init()
        search.delegate = self
        
        setupAction()
    }
    
    func setupAction() {
        guard let username = AVUser.current()?.username else  {
            return
        }
        let nickName = AVUser.current()?.object(forKey: "nickName") as? String
        
        let enable = locationObservale.map { (info) -> Bool in
            if info == nil {
                return false
            } else {
                return true
            }
        }
        
        action = Action<Inptu, Void>(enabledIf: enable, workFactory: {[unowned self] (input) -> Observable<Void> in
            
            let n = nickName.isNilOrEmpty ? username : nickName
            
           let avPoint = AVGeoPoint(latitude: self.locationObservale.value!.location.coordinate.latitude, longitude: self.locationObservale.value!.location.coordinate.longitude)
            
            self.task = TaskModel(userId: self._userId, name: n!, usedCount: 0, icon: "server_local_icon", color: 1, repeat: true, taskType: AddAppletType.local.rawValue, remindDate: self.locationObservale.value!.name, remindLocal: avPoint, id: nil, functionType: self.locationType.rawValue)
            
            return self.task.saveToLeanCloud().flatMapLatest({ (id) -> Observable<Void> in
                
                return Observable<Void>.create({[weak self] (obs) -> Disposable in
                    guard let this = self else {
                        return Disposables.create()
                    }
                    this.content.userInfo = ["objcId": id]
                    this.generateNotification(notiIdentifier: id, repeats: true)
                    obs.onNext(())
                    obs.onCompleted()
                    return Disposables.create()
                })
            })
        })
    }
    
    
    private func generateNotification(notiIdentifier: String, repeats: Bool) {
        guard let info = locationObservale.value else {
            return
        }
        
        let center = CLLocationCoordinate2DMake(info.location.coordinate.latitude, info.location.coordinate.longitude)
        let region = CLCircularRegion.init(center: center, radius: 100, identifier: info.name)
        switch locationType {
        case .enter:
            content.body = "您已经进入\(info.name)"
            region.notifyOnEntry = true
            region.notifyOnExit = false
        case .exit:
            content.body = "您已经离开\(info.name)"
            region.notifyOnExit = true
            region.notifyOnEntry = false
        case .enterAndExit:
            content.body = "您已经进入或者离开\(info.name)"
            region.notifyOnExit = true
            region.notifyOnEntry = true
        }
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: repeats)
        let notificationReq = UNNotificationRequest(identifier: notiIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(notificationReq, withCompletionHandler: nil)
    }
}


extension LocationTaskSettingViewModel: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        guard let info = userLocation.location else {
            return
        }
        
        let point = AMapGeoPoint.location(withLatitude: CGFloat(info.coordinate.latitude), longitude: CGFloat(info.coordinate.longitude))
        
        currentLocation = CLLocation(latitude: userLocation.location.coordinate.latitude, longitude: userLocation.location.coordinate.longitude)
        
        let requset = AMapReGeocodeSearchRequest()
        requset.location = point
        requset.requireExtension = true
        search.aMapReGoecodeSearch(requset)
        
        mapView.showsUserLocation = false
    }
}


extension LocationTaskSettingViewModel: AMapSearchDelegate {
    
    // 逆编码
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
        locationObservale.accept((currentLocation, response.regeocode.formattedAddress))
        currentCity.accept(response.regeocode.addressComponent.city)
    }
}
