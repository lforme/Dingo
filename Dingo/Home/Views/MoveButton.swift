//
//  MoveButton.swift
//  IntelligentUOKO
//
//  Created by mugua on 2019/4/4.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

class MoveButton: UIButton {
    var originPoint = CGPoint.zero
    let screen = UIScreen.main.bounds
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        originPoint = touch.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        let nowPoint = touch.location(in: self)
        let offsetX = nowPoint.x - originPoint.x
        let offsetY = nowPoint.y - originPoint.y
        self.center = CGPoint(x: self.center.x + offsetX, y: self.center.y + offsetY)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactBounds(touches: touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reactBounds(touches: touches)
    }
    
    func reactBounds(touches: Set<UITouch>) {
        guard let touch = touches.first else {
            fatalError("touch can not be nil")
        }
        let endPoint = touch.location(in: self)
        let offsetX = endPoint.x - originPoint.x
        let offsetY = endPoint.y - originPoint.y
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        if center.x + offsetX >= screen.width / 2 {
            self.center = CGPoint(x: screen.width - bounds.size.width / 2 - 20, y: center.y + offsetY - 20)
        } else {
            self.center = CGPoint(x: bounds.size.width / 2 + 20, y: center.y + offsetY + 20)
        }
        if center.y + offsetY >= screen.height - bounds.size.height / 2 {
            self.center = CGPoint(x: center.x, y: screen.height - bounds.size.height / 2 - 20)
        } else if center.y + offsetY < bounds.size.height / 2 {
            self.center = CGPoint(x: center.x, y: bounds.size.height / 2 + 20)
        }
        UIView.commitAnimations()
    }
    
    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
}
