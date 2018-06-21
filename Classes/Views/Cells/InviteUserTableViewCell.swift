//
//  InviteUserTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 22.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let InviteUserTableViewCellReuseIdentifier = NSStringFromClass(InviteUserTableViewCell.classForCoder())

fileprivate let AvatarDimension: CGFloat = 40.0
fileprivate let DefaultInset: CGFloat = 8.0

class InviteUserTableViewCell: UITableViewCell {
    weak var delegate: InviteUserTableViewCellDelegate!
    
    var avatarImageView: UIImageView!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    
    var checkboxButton: CheckboxButton!

    var isCheckboxSelected: Bool! {
        didSet {
            if isCheckboxSelected == true {
                checkboxButton.updateInterfaceWith(State: CheckboxState.selected)
            } else {
                checkboxButton.updateInterfaceWith(State: CheckboxState.default)
            }
        }
    }
    
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
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                    action: #selector(didTapAvatarImageView(_:))))
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        
        
        checkboxButton = CheckboxButton.newAutoLayout()
        
        contentView.addSubview(checkboxButton)
        
        checkboxButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        checkboxButton.autoSetDimension(ALDimension.width, toSize: CheckboxButtonDefaultDimension)
        checkboxButton.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        let labelsHolderView = UILabel.newAutoLayout()
        
        contentView.addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: avatarImageView, withOffset: DefaultInset)
        labelsHolderView.autoPinEdge(ALEdge.right, to: ALEdge.left, of: checkboxButton)
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
    
    // MARK: - Recognizers
    
    func didTapAvatarImageView(_ recognizer: UITapGestureRecognizer) {
        delegate.inviteUserTableViewCellDidTapAvatarImage(self)
    }
    
    // MARK: - Cell Height
    
    class func cellHeight() -> CGFloat {
        var cellHeight: CGFloat = 0.0
        
        cellHeight += DefaultInset * 2
        cellHeight += AvatarDimension
        
        return cellHeight
    }
}

// MARK: - InviteUserTableViewCellDelegate

protocol InviteUserTableViewCellDelegate: NSObjectProtocol {
    func inviteUserTableViewCellDidTapAvatarImage(_ cell: InviteUserTableViewCell)
}
