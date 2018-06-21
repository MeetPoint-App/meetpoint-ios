//
//  ActivityFooterView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 21/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let ActivityFooterViewReuseIdentifier = NSStringFromClass(ActivityFooterView.classForCoder())

let ActivityFooterViewDefaultHeight: CGFloat = 56.0

class ActivityFooterView: UICollectionReusableView {
    weak var delegate: ActivityFooterViewDelegate!
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    var goingButton: InteractiveActionButton!
    fileprivate var goingButtonWidthConstraint: NSLayoutConstraint!
    
    var interestedButton: InteractiveActionButton!
    fileprivate var interestedButtonWidthConstraint: NSLayoutConstraint!
    
    var detailButton: InteractiveActionButton!
    
    fileprivate var separatorView: UIView!
    
    var showDetailButton: Bool = false {
        didSet {
            if showDetailButton {
                goingButton.isHidden = true
                interestedButton.isHidden = true
                detailButton.isHidden = false
            } else {
                goingButton.isHidden = false
                interestedButton.isHidden = false
                detailButton.isHidden = true
            }
        }
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.backgroundColor = UIColor.primaryBackgroundColor()
        
        detailButton = InteractiveActionButton.newAutoLayout()
        detailButton.actionButtonType = InteractiveActionButtonType.detail
        detailButton.actionButtonState = InteractiveActionButtonState.selected
        detailButton.isHidden = true
        detailButton.addTarget(self, action: #selector(didTapDetailButton(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(detailButton)
        
        detailButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        detailButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        detailButton.autoSetDimension(ALDimension.height, toSize: 40.0)
        detailButton.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        goingButton = InteractiveActionButton.newAutoLayout()
        goingButton.actionButtonType = InteractiveActionButtonType.going
        goingButton.actionButtonState = InteractiveActionButtonState.default
        goingButton.addTarget(self, action: #selector(didTapGoingButton(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(goingButton)
        
        goingButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        goingButtonWidthConstraint = goingButton.autoSetDimension(ALDimension.width, toSize: 0.0)
        goingButton.autoSetDimension(ALDimension.height, toSize: 40.0)
        goingButton.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        interestedButton = InteractiveActionButton.newAutoLayout()
        interestedButton.actionButtonType = InteractiveActionButtonType.interested
        interestedButton.actionButtonState = InteractiveActionButtonState.default
        interestedButton.addTarget(self, action: #selector(didTapInterestedButton(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(interestedButton)
        
        interestedButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        interestedButtonWidthConstraint = interestedButton.autoSetDimension(ALDimension.width, toSize: 0.0)
        interestedButton.autoSetDimension(ALDimension.height, toSize: 40.0)
        interestedButton.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        separatorView = UIView.newAutoLayout()
        separatorView.backgroundColor = UIColor.listSeparatorColor()
        
        addSubview(separatorView!)
        
        let insets = UIEdgeInsetsMake(0.0, DefaultInset, 0.0, DefaultInset)
        separatorView.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: ALEdge.top)
        separatorView.autoSetDimension(ALDimension.height, toSize: 0.3)
    }
    
    // MARK: - Actions
    
    func didTapGoingButton(_ button: InteractiveActionButton) {
        delegate.activityFooterViewDidTapGoingButton(self, withInteractiveActionButton: button)
    }
    
    func didTapInterestedButton(_ button: InteractiveActionButton) {
        delegate.activityFooterViewDidTapInterestedButton(self, withInteractiveActionButton: button)
    }
    
    func didTapDetailButton(_ button: InteractiveActionButton) {
        if delegate.responds(to: #selector(ActivityFooterViewDelegate.activityFooterViewDidTapDetailButton(_:withInteractiveActionButton:))) {
            delegate.activityFooterViewDidTapDetailButton!(self, withInteractiveActionButton: button)
        }
    }
    
    func toggleActionButton(_ button: InteractiveActionButton) {
        if button == goingButton {
            
            if button.actionButtonState == .default {
                button.actionButtonState = .selected
                interestedButton.actionButtonState = .default
            } else {
                button.actionButtonState = .default
            }
        } else if button == interestedButton {
            if button.actionButtonState == .default {
                button.actionButtonState = .selected
                goingButton.actionButtonState = .default
            } else {
                button.actionButtonState = .default
            }
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        goingButtonWidthConstraint.constant = self.frame.width / 2.0 - DefaultInset * 2
        interestedButtonWidthConstraint.constant = self.frame.width / 2.0 - DefaultInset * 2
    }
}

// MARK: - ActivityFooterViewDelegate

@objc protocol ActivityFooterViewDelegate: NSObjectProtocol {
    func activityFooterViewDidTapGoingButton(_ footerView: ActivityFooterView, withInteractiveActionButton button: InteractiveActionButton)
    func activityFooterViewDidTapInterestedButton(_ footerView: ActivityFooterView, withInteractiveActionButton button: InteractiveActionButton)
    @objc optional func activityFooterViewDidTapDetailButton(_ footerView: ActivityFooterView, withInteractiveActionButton button: InteractiveActionButton)
}
