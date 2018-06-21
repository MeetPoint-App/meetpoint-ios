//
//  CommentCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 22/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let CommentCollectionViewCellReuseIdentifier = NSStringFromClass(CommentCollectionViewCell.classForCoder())

fileprivate let SubtitleLabelFont = UIFont.montserratRegularFont(withSize: 14.0)
fileprivate let TopComponentsHolderViewHeight: CGFloat = 20.0
fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let CommentCellDefaultEdgeInset: CGFloat = 8.0

class CommentCollectionViewCell: UICollectionViewCell {
    weak var delegate: CommentCollectionViewCellDelegate!
    
    var avatarImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    
    fileprivate var subtitleLabel: UILabel!
    fileprivate var subtitleLabelHeightConstraint: NSLayoutConstraint!
    
    fileprivate var actionButton: UIButton!
    fileprivate var timeLabel: UILabel!
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle: String! {
        didSet {
            subtitleLabel.text = subtitle
            
            let textSize = subtitle.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - AvatarDimension - CommentCellDefaultEdgeInset * 3, height: CGFloat.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSFontAttributeName: SubtitleLabelFont],
                                                 context: nil)
            subtitleLabelHeightConstraint.constant = textSize.height + 2.0
        }
    }
    
    var time: String! {
        didSet {
            timeLabel.text = time
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
        backgroundColor = UIColor.primaryBackgroundColor()
        
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.layer.cornerRadius = AvatarDimension / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                    withInset: CommentCellDefaultEdgeInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                    withInset: CommentCellDefaultEdgeInset)
        
        
        let topComponentsHolderView = UIView.newAutoLayout()
        
        contentView.addSubview(topComponentsHolderView)
        
        topComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                            withInset: CommentCellDefaultEdgeInset)
        topComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                            withInset: CommentCellDefaultEdgeInset)
        topComponentsHolderView.autoPinEdge(ALEdge.left,
                                            to: ALEdge.right,
                                            of: avatarImageView,
                                            withOffset: CommentCellDefaultEdgeInset)
        topComponentsHolderView.autoSetDimension(ALDimension.height,
                                                 toSize: TopComponentsHolderViewHeight)
        
        
        actionButton = UIButton(type: UIButtonType.custom)
        actionButton.setImage(UIImage(named: "iconDownArrow"), for: UIControlState.normal)
        actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)),
                               for: UIControlEvents.touchUpInside)
        
        topComponentsHolderView.addSubview(actionButton)
        
        actionButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                                  excludingEdge: ALEdge.left)
        actionButton.autoSetDimension(ALDimension.width, toSize: 22.0)
        
        
        timeLabel = UILabel.newAutoLayout()
        timeLabel.font = UIFont.montserratRegularFont(withSize: 13.0)
        timeLabel.textColor = UIColor.primaryLightTextColor()
        timeLabel.textAlignment = NSTextAlignment.right
        
        topComponentsHolderView.addSubview(timeLabel)
        
        timeLabel.autoPinEdge(toSuperviewEdge: ALEdge.top)
        timeLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        timeLabel.autoPinEdge(ALEdge.right, to: ALEdge.left, of: actionButton)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.isUserInteractionEnabled = true
        titleLabel.font = UIFont.montserratMediumFont(withSize: 14.0)
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: #selector(didTapTitleLabel(_:))))
        
        topComponentsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                                excludingEdge: ALEdge.right)
        titleLabel.autoPinEdge(ALEdge.right, to: ALEdge.left, of: timeLabel)
        
        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.font = SubtitleLabelFont
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        
        contentView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdge(ALEdge.left,
                                  to: ALEdge.right,
                                  of: avatarImageView,
                                  withOffset: CommentCellDefaultEdgeInset)
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                  withInset: CommentCellDefaultEdgeInset)
        subtitleLabel.autoPinEdge(ALEdge.top,
                                  to: ALEdge.bottom,
                                  of: topComponentsHolderView, withOffset: 2.0)
        subtitleLabelHeightConstraint = subtitleLabel.autoSetDimension(ALDimension.height,
                                                                       toSize: 0.0)
        
        
        let separatorView = UIView.newAutoLayout()
        separatorView.backgroundColor = UIColor.listSeparatorColor()
        
        contentView.addSubview(separatorView)
        
        separatorView.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                  withInset: CommentCellDefaultEdgeInset * 2 + AvatarDimension)
        separatorView.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                  withInset: CommentCellDefaultEdgeInset)
        separatorView.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 0.2) // To solve hidden separator bug
        separatorView.autoSetDimension(ALDimension.height, toSize: 0.5)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight(withComment comment: Comment) -> CGFloat {
        
        var cellHeight: CGFloat = 0.0
        
        if let _ = comment.commentText {
            cellHeight += CommentCollectionViewCell.commentTextHeight(forComment: comment)
        }
        
        cellHeight += 2.5
        cellHeight += TopComponentsHolderViewHeight
        cellHeight += CommentCellDefaultEdgeInset * 2
        
        return cellHeight
    }
    
    class func commentTextHeight(forComment comment: Comment) -> CGFloat {
        let textSize = comment.commentText!.boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - AvatarDimension - CommentCellDefaultEdgeInset * 3, height: CGFloat.greatestFiniteMagnitude),
                                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                         attributes: [NSFontAttributeName: SubtitleLabelFont],
                                                         context: nil)
        return textSize.height + 2.0
    }
    
    // MARK: - Actions
    
    func didTapAvatarImageView(_ recognizer: UIGestureRecognizer) {
        delegate.commentCollectionViewCellDidTapAvatarImageView(self)
    }
    
    func didTapTitleLabel(_ recognizer: UIGestureRecognizer) {
        delegate.commentCollectionViewCellDidTapTitleLabel(self)
    }
    
    func actionButtonTapped(_ button: UIButton) {
        delegate.commentCollectionViewCellDidActionButtonTapped(self)
    }
}

// MARK: - CommentCollectionViewCellDelegate

protocol CommentCollectionViewCellDelegate: NSObjectProtocol {
    func commentCollectionViewCellDidTapAvatarImageView(_ cell: CommentCollectionViewCell)
    func commentCollectionViewCellDidTapTitleLabel(_ cell: CommentCollectionViewCell)
    func commentCollectionViewCellDidActionButtonTapped(_ cell: CommentCollectionViewCell)
}
