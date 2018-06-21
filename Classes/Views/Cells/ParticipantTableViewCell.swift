//
//  ParticipantTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 26/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let DefaultEdgeInset: CGFloat = 8.0

let ParticipantTableViewCellReuseIdentifier = NSStringFromClass(ParticipantTableViewCell.classForCoder())

class ParticipantTableViewCell: UITableViewCell {
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    
    var avatarImageView: UIImageView!
    
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
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.layer.cornerRadius = AvatarDimension / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                    withInset: DefaultEdgeInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                    withInset: DefaultEdgeInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        
        
        let labelsHolderView = UILabel.newAutoLayout()
        labelsHolderView.isUserInteractionEnabled = true
        
        contentView.addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(ALEdge.left,
                                     to: ALEdge.right,
                                     of: avatarImageView,
                                     withOffset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                     withInset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                     withInset: DefaultEdgeInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                     withInset: DefaultEdgeInset)
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 14.0)
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        
        labelsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                                excludingEdge: ALEdge.bottom)
        titleLabel.autoSetDimension(ALDimension.height, toSize: 20.0)
        
        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        
        labelsHolderView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                                   excludingEdge: ALEdge.top)
        subtitleLabel.autoPinEdge(ALEdge.top,
                                  to: ALEdge.bottom,
                                  of: titleLabel, withOffset: 0.0)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight() -> CGFloat {
        var cellHeight: CGFloat = 0.0
        
        cellHeight += AvatarDimension
        cellHeight += DefaultEdgeInset * 2
        
        return cellHeight
    }
}
