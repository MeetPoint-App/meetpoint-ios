//
//  BaseScrollViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class ScrollView: UIScrollView {
    var customInputAccessoryView: UIView?
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override var canResignFirstResponder : Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return customInputAccessoryView
    }
}

class BaseScrollViewController : BaseViewController {
    var scrollView: ScrollView!
    var contentView: UIView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = ScrollView.newAutoLayout()
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = UIColor.clear
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        
        self.view.addSubview(scrollView)
        
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
        
        
        contentView = UIView.newAutoLayout()
        contentView.backgroundColor = UIColor.clear
        
        self.scrollView.addSubview(contentView)
        
        contentView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
        contentView.autoPinEdge(ALEdge.leading, to: ALEdge.leading, of: self.view)
        contentView.autoPinEdge(ALEdge.trailing, to: ALEdge.trailing, of: self.view)
    }
    
    // MARK: - Keyboard Notifications
    
    override func didReceiveKeyboardWillShowNotification(_ notification: Notification) {
        handleInsetsOf(ScrollView: scrollView, forAction: KeyboardAction.show, withNotification: notification)
    }
    
    override func didReceiveKeyboardWillHideNotification(_ notification: Notification) {
        handleInsetsOf(ScrollView: scrollView, forAction: KeyboardAction.hide, withNotification: notification)
    }
}
