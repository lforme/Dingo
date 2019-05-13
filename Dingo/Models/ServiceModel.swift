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
    
    init(name: String, colorType: Int, introduce: String, icon: String) {
        self.name = name
        self.colorType = colorType
        self.introduce = introduce
        self.icon = icon
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
        
        return leancloudObjc
    }
    
    static func fetchServerModels() -> Driver<[ServiceModel]?> {
        return Observable<[ServiceModel]?>.create({ (obs) -> Disposable in
            let query = AVQuery(className: "ServiceModel")
            query.findObjectsInBackground({ (obejcts, error) in
                if let e = error {
                    obs.onError(e)
                } else {
                    let models = obejcts?.compactMap{ $0 }.map({ (dict) -> ServiceModel? in
                        guard let d = dict as? AVObject else { return nil }
                        guard let name = d.object(forKey: "name") as? String,
                            let colorType = d.object(forKey: "colorType") as? Int,
                            let introduce = d.object(forKey: "introduce") as? String,
                            let icon = d.object(forKey: "icon") as? String else { return nil }
                        let model = ServiceModel(name: name, colorType: colorType, introduce: introduce, icon: icon)
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
