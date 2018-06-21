//
//  SearchLocationCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 8.04.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let SearchLocationCollectionViewCellSize = CGSize(width: 250.0, height: 180.0)
let SearchLocationCollectionViewCellReuseIdentifier = NSStringFromClass(SearchLocationCollectionViewCell.classForCoder())

class SearchLocationCollectionViewCell: UICollectionViewCell {
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    fileprivate var titleLabel: UILabel!
    
    var imageView: MaskedImageView!
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    override var isHighlighted: Bool {
        willSet {
            if newValue {
                self.alpha = 0.8
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
        self.clipsToBounds = true
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        
        imageView = MaskedImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        contentView.addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges()
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.secondaryLightTextColor()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 20.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        
        titleLabel.autoCenterInSuperview()
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
    }
}
