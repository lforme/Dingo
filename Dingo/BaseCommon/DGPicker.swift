//
//  DGPicker.swift
//  Dingo
//
//  Created by mugua on 2019/5/10.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import YPImagePicker
import UIKit
import AVFoundation
import RxCocoa
import RxSwift

struct DGPicker {
    
}


extension DGPicker {
    
    static func pickImage(count: Int) -> Driver<[YPMediaItem]> {
        
        return Observable<[YPMediaItem]>.create({ (obs) -> Disposable in
            var config = YPImagePickerConfiguration()
            config.wordings.cancel = "取消"
            config.wordings.ok = "好"
            config.wordings.done = "完成"
            config.wordings.next = "下一步"
            config.wordings.libraryTitle = "相册"
            config.wordings.cameraTitle = "相机"
            config.wordings.libraryTitle = "滤镜"
            config.startOnScreen = .library
            config.shouldSaveNewPicturesToAlbum = false
            config.bottomMenuItemSelectedColour = LaunchThemeManager.currentTheme().mainColor
            config.bottomMenuItemUnSelectedColour = LaunchThemeManager.currentTheme().textBlackColor
            config.library.maxNumberOfItems = count
            config.library.minNumberOfItems = 1
            YPImagePickerConfiguration.shared = config
            
            let picker = YPImagePicker()
            picker.didFinishPicking(completion: { (item, cancel) in
                obs.onNext(item)
                obs.onCompleted()
                
            })
            UIApplication.shared.keyWindow?.rootViewController?.present(picker, animated: true, completion: nil)
            return Disposables.create {
                picker.dismiss(animated: true, completion: nil)
            }
        }).asDriver(onErrorJustReturn: [])
    }
}
