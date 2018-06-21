//
//  BaseNavigationController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let NavigationBarTitleFont = UIFont.montserratMediumFont(withSize: 20.0)

class SimpleNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var operation: UINavigationControllerOperation?
    
    override init() {
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.33
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let fromView = fromVC?.view
        let toView = toVC?.view
        
        let endFrame = transitionContext.initialFrame(for: fromVC!)
        
        if operation == UINavigationControllerOperation.push {
            transitionContext.containerView.addSubview(fromView!)
            transitionContext.containerView.addSubview(toView!)
            
            var startFrame = endFrame
            var finalFrame = endFrame
            
            startFrame.origin.x += endFrame.width
            finalFrame.origin.x -= endFrame.width
            
            fromView?.frame = endFrame
            toView?.frame = startFrame
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: { () -> Void in
                            toView?.frame = endFrame
                            fromView?.frame = finalFrame
            }, completion: { (finished) -> Void in
                fromView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        } else {
            transitionContext.containerView.addSubview(fromView!)
            transitionContext.containerView.addSubview(toView!)
            
            var startFrame = endFrame
            var finalFrame = endFrame
            
            startFrame.origin.x -= endFrame.width
            finalFrame.origin.x += endFrame.width
            
            fromView?.frame = endFrame
            toView?.frame = startFrame
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: { () -> Void in
                            toView?.frame = endFrame
                            fromView?.frame = finalFrame
            }, completion: { (finished) -> Void in
                fromView?.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
}

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    // MARK: - Constructors
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.barTintColor = UIColor.primaryBackgroundColor()
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [NSFontAttributeName: NavigationBarTitleFont,
                                             NSForegroundColorAttributeName: UIColor.primaryNavigationComponentColor()]
        
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        
        delegate = self
        
        interactivePopGestureRecognizer?.delegate = nil
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationControllerOperation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = SimpleNavigationAnimator()
        animator.operation = operation
        
        return animator
    }
}
