//
//  DGMapViewViewModel.swift
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

struct DGMapModel {
    let location: CLLocation
    let name: String
}

class DGMapViewViewModel: NSObject {
    
    class SearchApi: AMapSearchAPI {}
    
    typealias LocationResul = (location: CLLocation, name: String)
    
    fileprivate let search: SearchApi
    fileprivate var currentLocation = CLLocation(latitude: 0, longitude: 0)
    fileprivate let request = AMapPOIKeywordsSearchRequest()
    
    
    let touchLoctionObservable = BehaviorRelay<LocationResul?>(value: nil)
    let searchTextObservable = BehaviorRelay<String?>(value: nil)
    let models = BehaviorRelay<[DGMapModel]>(value: [])
    let city: String
    
    init(city: String) {
        self.city = city
        search = SearchApi()
        super.init()
        search.delegate = self
        commonInit()
    }
    
    private func commonInit() {
        
        request.requireExtension = true
        request.requireSubPOIs = true
        request.city = city
        request.cityLimit = true
        
        searchTextObservable.filter { $0.isNotNilNotEmpty }.subscribe(onNext: {[weak self] (txt) in
            guard let this = self else { return }
            this.request.keywords = txt!
            this.search.aMapPOIKeywordsSearch(this.request)
        }).disposed(by: rx.disposeBag)
        
    }
}


extension DGMapViewViewModel: MAMapViewDelegate {
    
    /// 单击地图
    ///
    /// - Parameters:
    ///   - mapView
    ///   - pois:
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        
        let locationEntity = pois.compactMap { $0 as? MATouchPoi }.last
        guard let info = locationEntity else { return }
        
        currentLocation = CLLocation(latitude: info.coordinate.latitude, longitude: info.coordinate.longitude)
        
        touchLoctionObservable.accept((currentLocation, info.name))
        
    }
}


extension DGMapViewViewModel: AMapSearchDelegate {
    
    // 逆编码
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
        touchLoctionObservable.accept((currentLocation, response.regeocode.formattedAddress))
    }
    
    //    搜索结果
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        if response.count > 0 {
            
            var temp: [DGMapModel] = []
            temp.removeAll()
            
            response.pois.forEach { (poi) in
                guard let lat = poi.location?.latitude, let long = poi.location?.longitude, let name = poi.name else { return }

                let loction = CLLocation(latitude: Double(lat), longitude: Double(long))
                let m = DGMapModel(location: loction, name: name)
                temp.append(m)
            }
            
            models.accept(temp)
        }
    }
}
