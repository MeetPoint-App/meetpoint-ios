//
//  SearchTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let SearchTableViewCellReuseIdentifier = NSStringFromClass(SearchTableViewCell.classForCoder())

fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let DefaultEdgeInset: CGFloat = 8.0
fileprivate let IconImageDimension: CGFloat = 16.0

class SearchTableViewCell: UITableViewCell {
    
    var avatarImageView: UIImageView!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    fileprivate var informationLabel: UILabel!
    
    fileprivate var iconImageView: UIImageView!
    
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
    
    var information: String! {
        didSet {
            informationLabel.text = information
        }
    }
    
    var icon: UIImage! = UIImage(named: "iconSearch") {
        didSet {
            iconImageView.image = icon
        }
    }
    
    var shouldShowInfo: Bool! {
        didSet {
            if shouldShowInfo == true {
                informationLabel.isHidden = false
                iconImageView.isHidden = false
                
                avatarImageView.isHidden = true
                titleLabel.isHidden = true
                subtitleLabel.isHidden = true
            }else {
                informationLabel.isHidden = true
                iconImageView.isHidden = true
                
                avatarImageView.isHidden = false
                titleLabel.isHidden = false
                subtitleLabel.isHidden = false
            }
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
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultEdgeInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultEdgeInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        
        
        let labelsHolderView = UILabel.newAutoLayout()
        
        contentView.addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: avatarImageView, withOffset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,withInset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,withInset: DefaultEdgeInset)
        
        
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
        
        
        iconImageView = UIImageView.newAutoLayout()
        iconImageView.image = icon
        iconImageView.contentMode = UIViewContentMode.scaleAspectFill
        iconImageView.isHidden = true
        
        contentView.addSubview(iconImageView)
        
        iconImageView.autoSetDimensions(to: CGSize(width: IconImageDimension, height: IconImageDimension))
        iconImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultEdgeInset)
        iconImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultEdgeInset)
        
        
        informationLabel = UILabel.newAutoLayout()
        informationLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
        informationLabel.textColor = UIColor.primaryLightTextColor()
        informationLabel.isHidden = true
        
        contentView.addSubview(informationLabel)
        
        informationLabel.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultEdgeInset)
        informationLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultEdgeInset)
        informationLabel.autoPinEdge(ALEdge.left, to: ALEdge.right, of: iconImageView, withOffset: DefaultEdgeInset)
        
        shouldShowInfo = false
    }
    
    // MARK: - Calculate Cell Height
    
    class func cellHeight() -> CGFloat {
        var cellHeight: CGFloat = 0.0
        
        cellHeight += DefaultEdgeInset * 2
        cellHeight += AvatarDimension
        
        return cellHeight
    }
}
