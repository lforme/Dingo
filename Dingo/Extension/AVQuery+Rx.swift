//
//  AVQuery+Rx.swift
//  Dingo
//
//  Created by mugua on 2019/5/8.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension Reactive where Base: AVQuery {
    
    func getObjectInMainSchedulerBy(id: String) -> Observable<AVObject?> {
        return Observable<AVObject?>.create({ (obs) -> Disposable in
            
            self.base.getObjectInBackground(withId: id, block: { (obj, error) in
                obs.onNext(obj)
                obs.onCompleted()
                if let e = error {
                    obs.onError(e)
                }
            })
            
            return Disposables.create()
        })
    }
}
