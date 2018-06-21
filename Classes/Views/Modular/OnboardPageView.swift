//
//  OnboardPageView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 12/11/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum OnboardPage: Int {
    case first
    case second
    case third
    
    var title: String {
        switch self {
        case .first:
            return "SHARE WHAT ACTIVITY YOU WANT TO DO"
        case .second:
            return "LET NEARBY FRIENDS KNOW VIA NOTIFICATIONS"
        case .third:
            return "GET TOGETHER OVER AN ACTIVITY AND BE SOCIAL"
        }
    }
    
    var image: UIImage {
        switch self {
        case .first:
            return UIImage(named: "onboardingFirstImage")!
        case .second:
            return UIImage(named: "onboardingSecondImage")!
        case .third:
            return UIImage(named: "onboardingThirdImage")!
        }
    }
    
    static let allPages = [first, second, third]
}

class OnboardingPageView: UIView {
    
    fileprivate var DefaultInset: CGFloat = 16.0
    
    var titleLabel: UILabel!
    var imageView: UIImageView!
    
    fileprivate var overlayView: UIView!
    
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
        imageView = UIImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        
        self.addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges()
        
        
        overlayView = UIView.newAutoLayout()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        self.addSubview(overlayView)
        
        overlayView.autoPinEdgesToSuperviewEdges()
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.secondaryLightTextColor()
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.font = UIFont.montserratSemiboldFont(withSize: 25.0)
        titleLabel.numberOfLines = 0
        
        addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        titleLabel.autoCenterInSuperview()
    }
}
