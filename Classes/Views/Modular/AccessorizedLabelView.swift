//
//  AccessorizedLabelView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum AccessoryImagePosition {
    case left
    case right
}

let AccessorizedLabelViewDefaultHeight: CGFloat = 20.0

class AccessorizedLabelView: UIView {
    
    // MARK: - Constants
    
    fileprivate var DefaultInset: CGFloat = 8.0
    
    fileprivate var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    
    fileprivate var imageViewLeftConstraint: NSLayoutConstraint!
    fileprivate var imageViewRightConstraint: NSLayoutConstraint!
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var textColor: UIColor! = UIColor.secondaryLightTextColor(){
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    var font: UIFont! = UIFont.montserratMediumFont(withSize: 14.0) {
        didSet {
            titleLabel.font = font
        }
    }
    
    var imagePosition: AccessoryImagePosition! {
        didSet {
            if imagePosition == .left {
                imageView.autoPinEdge(toSuperviewEdge: ALEdge.left)
                titleLabel.autoPinEdge(ALEdge.left, to: ALEdge.right, of: imageView, withOffset: DefaultInset)
                titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right)
                
                titleLabel.textAlignment = NSTextAlignment.left
            }else {
                imageView.autoPinEdge(toSuperviewEdge: ALEdge.right)
                titleLabel.autoPinEdge(ALEdge.right, to: ALEdge.left, of: imageView, withOffset: -DefaultInset)
                titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left)
                
                titleLabel.textAlignment = NSTextAlignment.right
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
        imageView = UIImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        self.addSubview(imageView)
        
        imageView.autoSetDimensions(to: CGSize(width: 15.0, height: 15.0))
        imageView.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.font = font
        titleLabel.textColor = textColor
        
        self.addSubview(titleLabel)
        
        titleLabel.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
    }
}
