//
//  HorizontalUserListCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 10.04.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let HorizontalUserListCollectionViewCellReuseIdentifier = NSStringFromClass(HorizontalUserListCollectionViewCell.classForCoder())

let HorizontalUserListCollectionViewCellDefaultHeight: CGFloat = 44.0

class HorizontalUserListCollectionViewCell: UICollectionViewCell {
    
    var avatarImageView: UIImageView!
    
    var image: UIImage! {
        didSet {
            avatarImageView.image = image
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
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.layer.cornerRadius = HorizontalUserListCollectionViewCellDefaultHeight / 2.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.borderColor = UIColor.secondaryBackgroundColor().cgColor
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdgesToSuperviewEdges()
    }
}
