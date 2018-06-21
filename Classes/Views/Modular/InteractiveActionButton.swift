//
//  InteractiveActionButton.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 20/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum InteractiveActionButtonType: Int {
    case going       = 0
    case interested  = 1
    case detail      = 2
    
    var title: String {
        switch self {
        case .going:
            return "Going"
        case .interested:
            return "Interested"
        case .detail:
            return "See The Details"
        }
    }
}

enum InteractiveActionButtonState {
    case `default`
    case selected
}

let InteractiveActionButtonsDimension: CGSize = CGSize(width: 140.0, height: 40.0)

class InteractiveActionButton: UIButton {
    
    var actionButtonType: InteractiveActionButtonType!
    
    var actionButtonState: InteractiveActionButtonState! = InteractiveActionButtonState.default {
        didSet {
            if actionButtonType ==  InteractiveActionButtonType.going {
                self.setTitle(actionButtonType.title, for: UIControlState.normal)
                if actionButtonState == .default {
                    self.setTitleColor(UIColor.secondaryBackgroundColor(), for: UIControlState.normal)
                    self.layer.borderColor = UIColor.goingButtonSelectedColor().cgColor
                    self.backgroundColor = UIColor.clear
                } else {
                    self.backgroundColor = UIColor.goingButtonSelectedColor()
                    self.setTitleColor(UIColor.secondaryLightTextColor(), for: UIControlState.normal)
                }
            }else if actionButtonType ==  InteractiveActionButtonType.interested {
                self.setTitle(actionButtonType.title, for: UIControlState.normal)
                
                if actionButtonState == .default {
                    self.setTitleColor(UIColor.secondaryBackgroundColor(), for: UIControlState.normal)
                    self.layer.borderColor = UIColor.interestedButtonSelectedColor().cgColor
                    self.backgroundColor = UIColor.clear
                } else {
                    self.setTitleColor(UIColor.secondaryLightTextColor(), for: UIControlState.normal)
                    self.backgroundColor = UIColor.interestedButtonSelectedColor()
                }
            } else {
                self.setTitle(actionButtonType.title, for: UIControlState.normal)
                self.backgroundColor = UIColor.goingButtonSelectedColor()
                self.layer.borderColor = UIColor.goingButtonSelectedColor().cgColor
                self.setTitleColor(UIColor.secondaryLightTextColor(), for: UIControlState.normal)
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
        self.layer.cornerRadius = InteractiveActionButtonsDimension.height / 2.0
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2.0
        
        self.titleLabel?.font = UIFont.montserratMediumFont(withSize: 16.0)
    }
}
