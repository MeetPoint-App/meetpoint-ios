//
//  LoadingView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 5.12.2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let LoadingViewAnimationIdentifier = "LoadingViewAnimationIdentifier"

class LoadingView: UIView {
    fileprivate var shieldView: UIView!
    fileprivate var iconView: UIImageView!
    
    fileprivate var shieldViewSizeConstraints: [NSLayoutConstraint]!
    
    fileprivate var rotateAnimation: CABasicAnimation!
    
    fileprivate var completionHandler: (() -> Void)!
    
    static fileprivate var sharedInstance: LoadingView!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.alpha = 0.0
        
        shieldView = UIView.newAutoLayout()
        shieldView.backgroundColor = UIColor.clear
        
        addSubview(shieldView)
        
        shieldView.autoCenterInSuperview()
        shieldViewSizeConstraints = shieldView.autoSetDimensions(to: CGSize(width: 0.0, height: 0.0))
        
        
        iconView = UIImageView.newAutoLayout()
        iconView.contentMode = UIViewContentMode.center
        iconView.image = UIImage(named: "iconLoading")
        iconView.alpha = 0.0
        
        shieldView.addSubview(iconView)
        
        iconView.autoCenterInSuperview()
        iconView.autoSetDimensions(to: CGSize(width: 32.0, height: 32.0))
        
        
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveApplicationWillResignActiveNotification(_:)),
                        name: NSNotification.Name.UIApplicationWillResignActive,
                        object: nil)
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveApplicationDidBecomeActiveNotification(_:)),
                        name: NSNotification.Name.UIApplicationDidBecomeActive,
                        object: nil)
    }
    
    // MARK: - Notification
    
    func didReceiveApplicationWillResignActiveNotification(_ notification: Notification) {
        if rotateAnimation != nil {
            iconView.layer.removeAllAnimations()
        }
    }
    
    func didReceiveApplicationDidBecomeActiveNotification(_ notification: Notification) {
        if rotateAnimation != nil {
            iconView.layer.add(rotateAnimation, forKey: LoadingViewAnimationIdentifier)
        }
    }
    
    // MARK: - Animation
    
    internal class func startAnimating() {
        if sharedInstance != nil {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        var parentViewController = appDelegate.window?.rootViewController
        
        var modalViewController = parentViewController?.presentedViewController
        
        while modalViewController != nil {
            parentViewController = modalViewController
            
            modalViewController = parentViewController?.presentedViewController
        }
        
        sharedInstance = LoadingView(frame: parentViewController!.view.bounds)
        
        parentViewController?.view.addSubview(sharedInstance)
        
        sharedInstance.layoutIfNeeded()
        
        sharedInstance.setVisible(true, animated: true)
    }
    
    internal class func stopAnimating(_ completion: @escaping () -> Void) {
        guard let sharedInstance = sharedInstance else {
            return
        }
        
        sharedInstance.completionHandler = completion
        
        sharedInstance.setComponentsVisible(false, animated: true)
    }
    
    // MARK: - Visibility
    
    fileprivate func setVisible(_ visible: Bool, animated: Bool) {
        func completionWithVisibility(_ visible: Bool) {
            if (visible) {
                self.setComponentsVisible(true, animated: animated)
            } else {
                completionHandler()
                
                self.removeFromSuperview()
                
                LoadingView.sharedInstance = nil
            }
        }
        
        for constraint in shieldViewSizeConstraints {
            constraint.constant = visible ? 80.0 : 0.0
        }
        
        if (visible) {
            if rotateAnimation == nil {
                rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                rotateAnimation.fromValue = 0.0
                rotateAnimation.toValue = 2 * Double.pi
                rotateAnimation.duration = 2.0
                rotateAnimation.repeatCount = Float(Int.max)
            }
            
            if (iconView.layer.animation(forKey: LoadingViewAnimationIdentifier) == nil) {
                iconView.layer.removeAllAnimations()
            }
            
            iconView.layer.add(rotateAnimation, forKey: LoadingViewAnimationIdentifier)
        } else {
            if (iconView.layer.animation(forKey: LoadingViewAnimationIdentifier) == nil) {
                iconView.layer.removeAllAnimations()
            }
        }
        
        if (animated) {
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.layoutIfNeeded()
                
                self.alpha = visible ? 1.0 : 0.0
            }, completion: { (finished) -> Void in
                completionWithVisibility(visible)
            })
        } else {
            self.layoutIfNeeded()
            
            completionWithVisibility(visible)
        }
    }
    
    fileprivate func setComponentsVisible(_ visible: Bool, animated: Bool) {
        func completionWithVisibility(_ visible: Bool) {
            if (!visible) {
                self.setVisible(visible, animated: animated)
            }
        }
        
        let alpha: CGFloat = visible ? 1.0 : 0.0
        
        if (animated) {
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                self.iconView.alpha = alpha
            }, completion: { (finished) -> Void in
                completionWithVisibility(visible)
            })
        } else {
            self.iconView.alpha = alpha
            
            completionWithVisibility(visible)
        }
    }
}

