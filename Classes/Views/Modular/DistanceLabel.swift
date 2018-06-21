//
//  DistanceLabel.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 17/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let DistanceLabelDefaultHeight: CGFloat = 25.0

class DistanceLabel: UIView {
    
    fileprivate let DefaultInset: CGFloat = 6.0
    
    fileprivate var titleLabel: UILabel!
    
    var text: String! {
        didSet {
            titleLabel.text = text
            self.isHidden = false
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
        self.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
        self.isHidden = true
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.font = UIFont.montserratLightFont(withSize: 12.0)
        
        self.addSubview(titleLabel)
        
        let insets = UIEdgeInsets(top: DefaultInset, left: DefaultInset, bottom: DefaultInset, right: DefaultInset)
        titleLabel.autoPinEdgesToSuperviewEdges(with: insets)
    }
}
