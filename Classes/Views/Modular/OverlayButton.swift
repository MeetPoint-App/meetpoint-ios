//
//  OverlayButton.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

let OverlayButtonDefaultSize = CGSize(width: 220.0, height: 48.0)

class OverlayButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled == true {
                self.alpha = 1.0
            } else {
                self.alpha = 0.5
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
        self.backgroundColor = UIColor.overlayButtonBackgroundColor()
        self.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        self.titleLabel?.textColor = UIColor.white
        
        self.tintColor = UIColor.white
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.overlayButtonBackgroundColor().cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 6.0
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let cornerRadius = self.frame.size.height / 2.0
        
        layer.cornerRadius = cornerRadius
    }
}
