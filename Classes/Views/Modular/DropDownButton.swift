//
//  DropDownButton.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 07/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import DropDown

let DropDownButtonDefaultHeight: CGFloat = 44.0

class DropDownButton: UIButton {

    fileprivate var accessoryImageSize: CGSize = CGSize(width: 9.95, height: 5.75)
    
    var accessoryImage: UIImage! = UIImage(named: "iconDropDown") {
        didSet {
            self.setImage(accessoryImage, for: UIControlState.normal)
        }
    }
    
    var borderWidth: CGFloat! = 1.0 {
        didSet {
            self.plainView.layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor! = UIColor.dropDownButtonBorderColor() {
        didSet {
            self.plainView.layer.borderColor = borderColor.cgColor
        }
    }
    
    var cornerRadius: CGFloat! = 2.0 {
        didSet {
            self.plainView.layer.cornerRadius = cornerRadius
        }
    }
    
    var accessoryImageXPlace:CGFloat {
        get {
            return (self.plainView.layer.frame.width)-25
        }
    }
    
    var accessoryImageYPlace:CGFloat {
        get {
            return self.plainView.layer.frame.height/2
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.7
            } else {
                self.alpha = 1.0
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
        self.backgroundColor = UIColor.dropDownButtonBackgroundColor()
        self.titleLabel?.font = UIFont.montserratRegularFont(withSize: 16.0)
        self.setTitleColor(UIColor.primaryLightTextColor(), for: UIControlState.normal)
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        self.setImage(accessoryImage, for: UIControlState.normal)
        
        self.plainView.layer.borderColor = borderColor.cgColor
        self.plainView.layer.borderWidth = borderWidth
        self.plainView.layer.cornerRadius = cornerRadius
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        super.imageRect(forContentRect: contentRect)
        
        let imageRect = CGRect(x: accessoryImageXPlace,
                               y: accessoryImageYPlace,
                               width: accessoryImageSize.width,
                               height: accessoryImageSize.height)
        return imageRect
    }
}
