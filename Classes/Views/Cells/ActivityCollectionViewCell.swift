//
//  HomeCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let ActivityCollectionViewCellReuseIdentifier = NSStringFromClass(ActivityCollectionViewCell.classForCoder())

fileprivate let ImageViewDimension: CGFloat = 220.0

class ActivityCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    // MARK: - Variables
    
    var imageView: MaskedImageView!
    
    var descriptionLabel: UILabel!
    
    var locationLabel: AccessorizedLabelView!
    var timeLabel: AccessorizedLabelView!
    
    var commentCountLabel: AccessorizedLabelView!
    var participantCountLabel: AccessorizedLabelView!
    
    var distanceLabel: DistanceLabel!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.alpha = 0.9
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
        clipsToBounds = true
        self.backgroundColor = UIColor.primaryBackgroundColor()
        
        imageView = MaskedImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        contentView.addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                               excludingEdge: ALEdge.bottom)
        imageView.autoSetDimension(ALDimension.height,
                                   toSize: ImageViewDimension)
        
        
        descriptionLabel = UILabel.newAutoLayout()
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = NSTextAlignment.center
        descriptionLabel.textColor = UIColor.secondaryLightTextColor()
        descriptionLabel.font = UIFont.montserratBoldFont(withSize: 20.0)
        
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        descriptionLabel.autoAlignAxis(ALAxis.horizontal,
                                       toSameAxisOf: imageView)
        descriptionLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                     withInset: DefaultInset)
        descriptionLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                     withInset: DefaultInset)
        
        
        timeLabel = AccessorizedLabelView.newAutoLayout()
        timeLabel.imagePosition = AccessoryImagePosition.left
        timeLabel.image = UIImage(named: "calendarIconSmall")
        
        contentView.addSubview(timeLabel)
        
        timeLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                              withInset: DefaultInset)
        timeLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                              withInset: DefaultInset)
        timeLabel.autoSetDimension(ALDimension.height,
                                   toSize: AccessorizedLabelViewDefaultHeight)
        timeLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                              withInset: 60.0)
        
        
        participantCountLabel = AccessorizedLabelView.newAutoLayout()
        participantCountLabel.isUserInteractionEnabled = true
        participantCountLabel.imagePosition = AccessoryImagePosition.right
        participantCountLabel.image = UIImage(named: "participantIconSmall")
        
        contentView.addSubview(participantCountLabel)
        
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
        
        contentView.addSubview(commentCountLabel)
        
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
        
        contentView.addSubview(locationLabel)
        
        locationLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                  withInset: DefaultInset)
        locationLabel.autoPinEdge(ALEdge.bottom,
                                  to: ALEdge.top,
                                  of: timeLabel,
                                  withOffset: -DefaultInset)
        locationLabel.autoSetDimension(ALDimension.height,
                                       toSize: AccessorizedLabelViewDefaultHeight)
        locationLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                  withInset: 60.0)
        
        
        distanceLabel = DistanceLabel.newAutoLayout()
        
        contentView.addSubview(distanceLabel)
        
        distanceLabel.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                  withInset: DefaultInset)
        distanceLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                  withInset: DefaultInset)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight() -> CGFloat {
        return ImageViewDimension
    }
}
