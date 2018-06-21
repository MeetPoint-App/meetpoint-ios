//
//  UserNotificationTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 25.03.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import ActiveLabel

let UserNotificationTableViewCellReuseIdentifier = NSStringFromClass(UserNotificationTableViewCell.classForCoder())

fileprivate let DefaultInset: CGFloat = 8.0
fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let SubtitleLabelDefaultHeight: CGFloat = 20.0
fileprivate let ActionButtonDefaultWidth: CGFloat = 30.0

fileprivate let TitleLabelFont = UIFont.montserratRegularFont(withSize: 14.0)

enum UserNotificationActionButtonType {
    case follow
    case unfollow
    
    var image: UIImage {
        switch self {
        case .follow:
            return UIImage(named: "iconFollow")!
        case .unfollow:
            return UIImage(named: "iconUnfollow")!
        }
    }
    
    static let allValues = [follow, unfollow]
}

class UserNotificationTableViewCell: UITableViewCell {
    weak var delegate: UserNotificationTableViewCellDelegate!
    
    fileprivate var titleLabel: ActiveLabel!
    fileprivate var titleLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var subtitleLabel: UILabel!
    
    fileprivate var actionButton: UIButton!
    
    var avatarImageView: UIImageView!
    
    var title: String! {
        didSet {
            titleLabel.text = title
            
            let size = CGSize(width: UIScreen.main.bounds.size.width - AvatarDimension - DefaultInset * 4 - ActionButtonDefaultWidth,
                              height: CGFloat.greatestFiniteMagnitude)
            
            let textSize = title.boundingRect(with: size,
                                                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                attributes: [NSFontAttributeName: TitleLabelFont],
                                                context: nil)
            
            titleLabelHeightConstraint.constant = textSize.height + 2.0
            
            layoutIfNeeded()
        }
    }
    
    var subtitle: String! {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    var actionButtonType: UserNotificationActionButtonType! {
        didSet {
            actionButton.setImage(actionButtonType.image, for: UIControlState.normal)
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
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.backgroundColor = UIColor.clear
        avatarImageView.layer.borderWidth = 1.5
        avatarImageView.layer.borderColor = UIColor.secondaryBackgroundColor().cgColor
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarImageViewTapped(_:))))
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        
        
        actionButton = UIButton(type: UIButtonType.custom)
        actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        actionButton.addTarget(self,
                               action: #selector(didTapActionButton(_:)),
                               for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(actionButton)
        
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        actionButton.autoSetDimension(ALDimension.width, toSize: ActionButtonDefaultWidth)
        actionButton.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: avatarImageView)
        
        
        let labelsHolderView = UIView.newAutoLayout()
        
        contentView.addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(ALEdge.left,
                                     to: ALEdge.right, of: avatarImageView, withOffset: DefaultInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                     withInset: DefaultInset * 2 + ActionButtonDefaultWidth)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,withInset: DefaultInset)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,withInset: DefaultInset)
        
        
        titleLabel = ActiveLabel.newAutoLayout()
        titleLabel.enabledTypes = [.mention]
        titleLabel.customize { (label) in
            label.textColor = UIColor.primaryDarkTextColor()
            label.font = TitleLabelFont
            label.mentionColor = UIColor.secondaryDarkTextColor()
            label.numberOfLines = 0
            label.mentionSelectedColor = UIColor.secondaryDarkTextColor().withAlphaComponent(0.7)
        }
        
        titleLabel.handleMentionTap {_ in
            self.delegate.userNotificationTableViewCellDidTapUsername(self)
        }
        
        labelsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        titleLabelHeightConstraint = titleLabel.autoSetDimension(ALDimension.height, toSize: 0.0)
        
        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.font = UIFont.montserratRegularFont(withSize: 13.0)
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        
        labelsHolderView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left)
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right)
        subtitleLabel.autoSetDimension(ALDimension.height, toSize: SubtitleLabelDefaultHeight)
        subtitleLabel.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: titleLabel, withOffset: 2.0)
    }
    
    // MARK: - Actions
    
    func didTapActionButton(_ button: UIButton) {
        delegate.userNotificationTableViewCellDidTapActionButton(self)
    }
    
    // MARK: - Recognizers
    
    func avatarImageViewTapped(_ recognizer: UIGestureRecognizer) {
        delegate.userNotificationTableViewCellDidTapAvatarImageView(self)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight(withNotification notification: RemoteNotification) -> CGFloat {
        var cellHeight: CGFloat = 0.0
        
        if let message = notification.message {
            cellHeight += notificationMessageHeight(message)
        }
        
        cellHeight += DefaultInset * 2
        cellHeight += SubtitleLabelDefaultHeight
        cellHeight += 2.0
        
        return cellHeight
    }
    
    class func notificationMessageHeight(_ message: String) -> CGFloat {
        let size = CGSize(width: UIScreen.main.bounds.size.width - AvatarDimension - DefaultInset * 4 - ActionButtonDefaultWidth,
                          height: CGFloat.greatestFiniteMagnitude)
        
        let textSize = message.boundingRect(with: size,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [NSFontAttributeName: TitleLabelFont],
                                            context: nil)
        return textSize.height + 2.0
    }
}

// MARK: - UserNotificationTableViewCellDelegate

protocol UserNotificationTableViewCellDelegate: NSObjectProtocol {
    func userNotificationTableViewCellDidTapUsername(_ cell: UserNotificationTableViewCell)
    func userNotificationTableViewCellDidTapAvatarImageView(_ cell: UserNotificationTableViewCell)
    func userNotificationTableViewCellDidTapActionButton(_ cell: UserNotificationTableViewCell)
}
