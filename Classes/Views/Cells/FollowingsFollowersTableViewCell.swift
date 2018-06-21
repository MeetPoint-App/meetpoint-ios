//
//  FollowingsFollowersTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 9.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let FollowingsFollowersTableViewCellReuseIdentifier = NSStringFromClass(FollowingsFollowersTableViewCell.classForCoder())

fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let DefaultInset: CGFloat = 8.0

class FollowingsFollowersTableViewCell: UITableViewCell {
    
    var avatarImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle: String! {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.layer.cornerRadius = AvatarDimension / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.backgroundColor = UIColor.clear
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        
        
        let labelsHolderView = UILabel.newAutoLayout()
        
        contentView.addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: avatarImageView, withOffset: DefaultInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,withInset: DefaultInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,withInset: DefaultInset)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 14.0)
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        
        labelsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        titleLabel.autoSetDimension(ALDimension.height, toSize: 20.0)
        
        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        
        labelsHolderView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.top)
        subtitleLabel.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: titleLabel, withOffset: 0.0)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight() -> CGFloat {
        var cellHeight: CGFloat = 0.0
        
        cellHeight += DefaultInset * 2
        cellHeight += AvatarDimension
        
        return cellHeight
    }
}
