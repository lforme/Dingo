//
//  ServiceModel.swift
//  Dingo
//
//  Created by mugua on 2019/5/13.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import IGListKit
import RxSwift
import RxCocoa

final class ServiceModel {
    let name: String
    let colorType: Int
    let introduce: String
    let icon: String
    let functionType: Int
    
    init(name: String, colorType: Int, introduce: String, icon: String, functionType: Int) {
        self.name = name
        self.colorType = colorType
        self.introduce = introduce
        self.icon = icon
        self.functionType = functionType
    }
}

extension ServiceModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return name as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let obj = object as? ServiceModel else {
            return false
        }
        return obj.name == self.name
    }
}

extension ServiceModel {
    
    func shiftToLCObject() -> AVObject {
        let leancloudObjc = AVObject(className: "ServiceModel")
        leancloudObjc.setObject(self.name, forKey: "name")
        leancloudObjc.setObject(self.colorType, forKey: "colorType")
        leancloudObjc.setObject(self.introduce, forKey: "introduce")
        leancloudObjc.setObject(self.icon, forKey: "icon")
        leancloudObjc.setObject(self.functionType, forKey: "functionType")
        return leancloudObjc
    }
    
    static func fetchServerModels() -> Driver<[ServiceModel]?> {
        let query = AVQuery(className: DatabaseKey.serviceTable)
        return ServiceModel.fetchServerModelsBy(query: query)
    }
    
    
    static func fetchServerModelsBy(query: AVQuery) ->  Driver<[ServiceModel]?> {
        return Observable<[ServiceModel]?>.create({ (obs) -> Disposable in
            query.cachePolicy = AVCachePolicy.networkElseCache
            query.findObjectsInBackground({ (obejcts, error) in
                if let e = error {
                    obs.onError(e)
                } else {
                    let models = obejcts?.compactMap{ $0 }.map({ (dict) -> ServiceModel? in
                        guard let d = dict as? AVObject else { return nil }
                        guard let name = d.object(forKey: "name") as? String,
                            let colorType = d.object(forKey: "colorType") as? Int,
                            let introduce = d.object(forKey: "introduce") as? String,
                            let icon = d.object(forKey: "icon") as? String,
                            let functionType = d.object(forKey: "functionType") as? Int else { return nil }
                        let model = ServiceModel(name: name, colorType: colorType, introduce: introduce, icon: icon, functionType: functionType)
                        return model
                    }).compactMap { $0 }
                    
                    obs.onNext(models)
                    obs.onCompleted()
                }
            })
            
            return Disposables.create()
            
        }).asDriver(onErrorJustReturn: nil)
    }
}
