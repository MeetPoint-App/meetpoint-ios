//
//  ProfileCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 06/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher

let ProfileCollectionViewCellReuseIdentifier = NSStringFromClass(ProfileCollectionViewCell.classForCoder())

fileprivate let ImageViewDimension: CGFloat = 220.0

class ProfileCollectionViewCell: UICollectionViewCell {
    weak var delegate: ProfileCollectionViewCellDelegate?
    
    // MARK: - Constants
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    // MARK: - Variables
    
    var headerView: ActivityHeaderView!
    var footerView: ActivityFooterView!
    
    fileprivate var imageView: MaskedImageView!
    
    fileprivate var descriptionLabel: UILabel!
    
    fileprivate var locationLabel: AccessorizedLabelView!
    fileprivate var dateLabel: AccessorizedLabelView!
    
    fileprivate var commentCountLabel: AccessorizedLabelView!
    fileprivate var participantCountLabel: AccessorizedLabelView!

    var activity: Activity! {
        didSet {
            if let coverImage = activity.coverImage {
                imageView.image = coverImage
            }
            
            if let coverImageUrl = activity.coverImageUrl, let url = URL(string: coverImageUrl) {
                imageView.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            }
            
            if let description = activity.description {
                descriptionLabel.text = description
            }
            
            if let primaryAddress = activity.primaryAddress {
                locationLabel.title = primaryAddress
            }
            
            if let activityTimestamp = activity.activityTimestamp {
                dateLabel.title = NSDate.dayDifference(activityTimestamp)
            }
            
            if let commentCount = activity.commentCount {
                commentCountLabel.title = "\(commentCount)"
            }
            
            if let participantCount = activity.participantCount {
                participantCountLabel.title = "\(participantCount)"
            }
            
            if let user = activity.user {
                
                if let fullName = user.fullName {
                    headerView.title = fullName
                }
                
                if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                    headerView.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
                } else {
                    headerView.imageView.image = UIImage(named: "placeholderAvatarSmall")
                }
                
            }
            
            if let timestamp = activity.createdTimestamp {
                let date = NSDate(timeIntervalSince1970: timestamp)
                headerView.subtitle = NSDate.timePassedSinceDate(date)
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
        clipsToBounds = true
        self.backgroundColor = UIColor.primaryBackgroundColor()
        
        headerView = ActivityHeaderView.newAutoLayout()
        headerView.backgroundColor = UIColor.primaryBackgroundColor()
        
        contentView.addSubview(headerView)
        
        headerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        headerView.autoSetDimension(ALDimension.height, toSize: ActivityHeaderViewDefaultHeight)
        
        
        imageView = MaskedImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(imageViewTapped(_:))))
        contentView.addSubview(imageView)
        
        imageView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: headerView)
        imageView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        imageView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        imageView.autoSetDimension(ALDimension.height, toSize: ImageViewDimension)
        
        
        descriptionLabel = UILabel.newAutoLayout()
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = NSTextAlignment.center
        descriptionLabel.textColor = UIColor.secondaryLightTextColor()
        descriptionLabel.font = UIFont.montserratBoldFont(withSize: 20.0)
        
        imageView.addSubview(descriptionLabel)
        
        descriptionLabel.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        descriptionLabel.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: imageView)
        descriptionLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        descriptionLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        dateLabel = AccessorizedLabelView.newAutoLayout()
        dateLabel.imagePosition = AccessoryImagePosition.left
        dateLabel.image = UIImage(named: "calendarIconSmall")
        
        imageView.addSubview(dateLabel)
        
        dateLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                              withInset: DefaultInset)
        dateLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                              withInset: DefaultInset)
        dateLabel.autoSetDimension(ALDimension.height,
                                   toSize: AccessorizedLabelViewDefaultHeight)
        dateLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                              withInset: 60.0)
        
        
        participantCountLabel = AccessorizedLabelView.newAutoLayout()
        participantCountLabel.isUserInteractionEnabled = true
        participantCountLabel.imagePosition = AccessoryImagePosition.right
        participantCountLabel.image = UIImage(named: "participantIconSmall")
        
        imageView.addSubview(participantCountLabel)
        
        participantCountLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                          withInset: DefaultInset)
        participantCountLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                          withInset: DefaultInset)
        participantCountLabel.autoSetDimension(ALDimension.height,
                                               toSize: AccessorizedLabelViewDefaultHeight)
        participantCountLabel.autoSetDimension(ALDimension.width,
                                               toSize: 60.0)
        
        
        commentCountLabel = AccessorizedLabelView.newAutoLayout()
        commentCountLabel.isUserInteractionEnabled = true
        commentCountLabel.imagePosition = AccessoryImagePosition.right
        commentCountLabel.image = UIImage(named: "commentIconSmall")
        
        imageView.addSubview(commentCountLabel)
        
        commentCountLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                      withInset: DefaultInset)
        commentCountLabel.autoPinEdge(ALEdge.bottom,
                                      to: ALEdge.top,
                                      of: participantCountLabel,
                                      withOffset: -DefaultInset)
        commentCountLabel.autoSetDimension(ALDimension.height,
                                           toSize: AccessorizedLabelViewDefaultHeight)
        commentCountLabel.autoSetDimension(ALDimension.width,
                                           toSize: 60.0)
        
        locationLabel = AccessorizedLabelView.newAutoLayout()
        locationLabel.imagePosition = AccessoryImagePosition.left
        locationLabel.image = UIImage(named: "locationIconSmall")
        
        imageView.addSubview(locationLabel)
        
        locationLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                  withInset: DefaultInset)
        locationLabel.autoPinEdge(ALEdge.bottom,
                                  to: ALEdge.top,
                                  of: dateLabel,
                                  withOffset: -DefaultInset)
        locationLabel.autoSetDimension(ALDimension.height,
                                       toSize: AccessorizedLabelViewDefaultHeight)
        locationLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                  withInset: 60.0)
        
        
        footerView = ActivityFooterView.newAutoLayout()
        
        contentView.addSubview(footerView)
        
        footerView.autoSetDimension(ALDimension.height, toSize: ActivityFooterViewDefaultHeight)
        footerView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: imageView)
        footerView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        footerView.autoPinEdge(toSuperviewEdge: ALEdge.right)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight(withActivity activity: Activity) -> CGFloat {
        var height: CGFloat = 0.0
        
        height += ImageViewDimension
        height += ActivityHeaderViewDefaultHeight
        height += ActivityFooterViewDefaultHeight
        
        return height
    }
    
    // MARK: - Recognizers
    
    @objc fileprivate func imageViewTapped(_ recognizer: UITapGestureRecognizer) {
        delegate?.profileCollectionViewCellDidTapCoverImage(self)
    }
}

// MARK: - ProfileCollectionViewCellDelegate

protocol ProfileCollectionViewCellDelegate: NSObjectProtocol {
    func profileCollectionViewCellDidTapCoverImage(_ cell: ProfileCollectionViewCell)
}
