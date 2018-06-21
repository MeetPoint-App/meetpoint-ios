//
//  CardView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    var cornerRadius: CGFloat = 6.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    var shadowOffset: CGSize = CGSize(width: 0.0, height: 3.0) {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    var shadowOpacity: Float = 1 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = self.shadowColor.cgColor
        layer.shadowOffset = self.shadowOffset
        layer.shadowOpacity = self.shadowOpacity
        layer.shadowRadius = self.cornerRadius
        layer.shadowPath = shadowPath.cgPath
    }
}
