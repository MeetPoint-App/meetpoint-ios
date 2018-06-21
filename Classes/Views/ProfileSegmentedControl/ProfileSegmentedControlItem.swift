//
//  ProfileSegmentedControlItem.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 03/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class ProfileSegmentedControlItem: UIView {
    weak var delegate: ProfileSegmentedControlItemDelegate!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var separatorView: UIView!
    
    var attributedTitle: NSAttributedString! {
        didSet {
            titleLabel.attributedText = attributedTitle
        }
    }
    
    var separatorColor: UIColor! = UIColor.segmentedControlSeparatorColor(){
        didSet {
            guard let separatorView = separatorView else {
                return
            }
            
            separatorView.backgroundColor = separatorColor
        }
    }
    
    var shouldShowSeparator: Bool! {
        didSet {
            if shouldShowSeparator == true {
                if let separatorView = separatorView {
                    separatorView.isHidden = false
                    
                    return
                }
                
                separatorView = UIView.newAutoLayout()
                separatorView.backgroundColor = separatorColor
                
                addSubview(separatorView)
                
                let separatorInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: -0.5)
                separatorView.autoPinEdgesToSuperviewEdges(with: separatorInsets, excludingEdge: ALEdge.left)
                separatorView.autoSetDimension(ALDimension.width, toSize: 1.0)
            } else {
                if let separatorView = separatorView {
                    separatorView.isHidden = true
                }
            }
        }
    }
    
    // MARK: - Constsructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:))))
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.numberOfLines = 0
        
        self.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges()
    }
    
    // MARK: - Gestures
    
    func didTapBackground(_ recognizer: UITapGestureRecognizer) {
        delegate.profileSegmentedControlItemDidReceiveTap(self)
    }
}

// MARK: - ProfileSegmentedControlItemDelegate

protocol ProfileSegmentedControlItemDelegate: NSObjectProtocol {
    func profileSegmentedControlItemDidReceiveTap(_ view: ProfileSegmentedControlItem)
}
