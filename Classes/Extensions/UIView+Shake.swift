//
//  UIView+Shake.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 8.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit

enum ShakeDirection {
    case horizontal
    case vertical
}

extension UIView {
    
    func shake() {
        self.shake(10, withDelta: 5, completion: nil)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat) {
        self.shake(times, withDelta: delta, completion: nil)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat,
               completion handler: (() -> Void)?) {
        self._shake(times, direction: 1, currentTimes: 0, withDelta: delta, speed: 0.03, shakeDirection: ShakeDirection.horizontal, completion: handler)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat,
               speed interval: TimeInterval) {
        self.shake(times, withDelta: delta, speed: interval, completion: nil)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat,
               speed interval: TimeInterval,
               completion handler: (() -> Void)?) {
        self._shake(times, direction: 1, currentTimes: 0, withDelta: delta, speed: interval, shakeDirection: ShakeDirection.horizontal, completion: handler)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat,
               speed interval: TimeInterval,
               shakeDirection: ShakeDirection) {
        self.shake(times, withDelta: delta, speed: interval, shakeDirection: shakeDirection, completion: nil)
    }
    
    func shake(_ times: Int,
               withDelta delta: CGFloat,
               speed interval: TimeInterval,
               shakeDirection: ShakeDirection,
               completion handler: (() -> Void)?) {
        self._shake(times, direction: 1, currentTimes: 0, withDelta: delta, speed: interval, shakeDirection: shakeDirection, completion: handler)
    }
    
    
    fileprivate func _shake(_ times: Int,
                            direction: Int,
                            currentTimes current: Int,
                            withDelta delta: CGFloat,
                            speed interval: TimeInterval,
                            shakeDirection: ShakeDirection,
                            completion handler: (() -> Void)?) {
        
        UIView.animate(withDuration: interval, animations: {
            () -> Void in
            self.transform = (shakeDirection == ShakeDirection.horizontal) ?
                CGAffineTransform(translationX: delta * CGFloat(direction), y: 0) :
                CGAffineTransform(translationX: 0, y: delta * CGFloat(direction))
        }, completion: {
            (finished: Bool) in
            if current >= times {
                UIView.animate(withDuration: interval, animations: {
                    () -> Void in
                    self.transform = CGAffineTransform.identity
                }, completion: {
                    (finished: Bool) in
                    if let handler = handler {
                        handler()
                    }
                })
                return
            }
            self._shake(times - 1,
                        direction: direction * -1,
                        currentTimes: current + 1,
                        withDelta: delta,
                        speed: interval,
                        shakeDirection: shakeDirection,
                        completion: handler)
        })
    }
}
