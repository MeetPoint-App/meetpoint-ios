//
//  DescriptionInputCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 24.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let DescriptionInputCollectionViewCellReuseIdentifier = NSStringFromClass(DescriptionInputCollectionViewCell.classForCoder())
let DescriptionInputCollectionViewCellDefaultSize = CGSize(width: 90.0, height: 40.0)

class DescriptionInputCollectionViewCell: UICollectionViewCell {
    
    fileprivate var titleLabel: UILabel!
    
    var title: String! {
        didSet {
            titleLabel.text = title
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
        layer.cornerRadius = DescriptionInputCollectionViewCellDefaultSize.height / 2.0
        layer.masksToBounds = true
        
        backgroundColor = UIColor.dropDownButtonBackgroundColor()
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        
        contentView.addSubview(titleLabel)
        
        titleLabel.autoCenterInSuperview()
    }
}
