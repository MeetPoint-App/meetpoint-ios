//
//  UserInformationHeaderView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 30/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum ActionButtonType {
    case follow
    case following
    case edit
    
    var backgroundImage: UIImage! {
        switch self {
        case .follow:
            return UIImage(named: "buttonBackgroundBlackBorders")
        case .following:
            return UIImage(named: "buttonBackgroundOrange")
        case .edit:
            return UIImage(named: "buttonBackgroundBlackBorders")
        }
    }
    
    var image: UIImage? {
        switch self {
        case .following:
            return UIImage(named: "iconTickWhite")
        default:
            return nil
        }
    }
    
    var title: String {
        switch self {
        case .follow:
            return "Follow"
        case .following:
            return "Following"
        case .edit:
            return "Edit Profile"
        }
    }
    
    var titleColor: UIColor! {
        switch self {
        case .follow:
            return UIColor.primaryDarkTextColor()
        case .following:
            return UIColor.secondaryLightTextColor()
        case .edit:
            return UIColor.primaryDarkTextColor()
        }
    }
}

fileprivate let DefaultInset: CGFloat = 15.0
fileprivate let ActionButtonFont = UIFont.montserratSemiboldFont(withSize: 14.0)
fileprivate let AvatarDimension: CGFloat = 80.0
fileprivate let TitleLabelFont = UIFont.montserratMediumFont(withSize: 16.0)
let UserInformationHeaderViewDefaultHeight: CGFloat = 185.0

let UserInformationHeaderViewReuseIdentifier = NSStringFromClass(UserInformationHeaderView.classForCoder())

class UserInformationHeaderView: UICollectionReusableView {
    weak var delegate: UserInformationHeaderViewDelegate!
    
    var avatarImageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    fileprivate var actionButton: UIButton!
    fileprivate var actionButtonWidthConstraint: NSLayoutConstraint!
    
    fileprivate var bottomShadow: UIImageView!
    
    var segmentedControl: ProfileSegmentedControl!
    
    var avatarImage: UIImage! {
        didSet {
            self.avatarImageView.image = avatarImage
        }
    }
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var actionButtonType: ActionButtonType! {
        didSet {
            actionButton.setBackgroundImage(actionButtonType.backgroundImage, for: UIControlState.normal)
            actionButton.setImage(actionButtonType.image, for: UIControlState.normal)
            actionButton.setTitleColor(actionButtonType.titleColor, for: UIControlState.normal)
            
            let title = actionButtonType.title
            
            actionButton.setTitle(title, for: UIControlState.normal)
            
            let textRect = title.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                              options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                              attributes: [NSFontAttributeName: ActionButtonFont],
                                              context: nil)
            
            var width = textRect.width + 40.0
            
            if let _ = actionButtonType.image {
                width += 20.0
            }
            
            actionButtonWidthConstraint.constant = width
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
        self.backgroundColor = UIColor.primaryBackgroundColor()
        
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.layer.cornerRadius = AvatarDimension / 2.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderColor = UIColor.secondaryBackgroundColor().cgColor
        avatarImageView.layer.borderWidth = 2.0
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))
        
        self.addSubview(avatarImageView)
        
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        
        
        let topComponentsHolderView = UIView.newAutoLayout()
        
        self.addSubview(topComponentsHolderView)
        
        topComponentsHolderView.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: avatarImageView)
        topComponentsHolderView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: avatarImageView, withOffset: DefaultInset)
        topComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        topComponentsHolderView.autoSetDimension(ALDimension.height, toSize: 62.0)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.font = TitleLabelFont
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        
        topComponentsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        titleLabel.autoSetDimension(ALDimension.height, toSize: 20.0)
        
        
        actionButton = UIButton(type: UIButtonType.custom)
        actionButton.adjustsImageWhenHighlighted = false
        actionButton.titleLabel?.font = ActionButtonFont
        actionButton.addTarget(self, action: #selector(didTapActionButton(_:)), for: UIControlEvents.touchUpInside)
        
        topComponentsHolderView.addSubview(actionButton)
        
        actionButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: titleLabel,withOffset: 8.0)
        actionButton.autoSetDimension(ALDimension.height, toSize: 34.0)
        actionButtonWidthConstraint =  actionButton.autoSetDimension(ALDimension.width, toSize: 0.0)
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.left)
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        
        
        let shadowView = UIView.newAutoLayout()
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowOpacity = 0.1
        shadowView.layer.shadowRadius = 4
        
        addSubview(shadowView)
        
        shadowView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: avatarImageView, withOffset: DefaultInset)
        shadowView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        shadowView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        shadowView.autoSetDimension(ALDimension.height, toSize: 60.0)
        
        
        let segmentedControlComponentsHolderView = UIView.newAutoLayout()
        segmentedControlComponentsHolderView.backgroundColor = UIColor.primaryBackgroundColor()
        segmentedControlComponentsHolderView.layer.cornerRadius = 4.0
        segmentedControlComponentsHolderView.layer.masksToBounds = true
        
        shadowView.addSubview(segmentedControlComponentsHolderView)
        
        segmentedControlComponentsHolderView.autoPinEdgesToSuperviewEdges()
        
        
        segmentedControl = ProfileSegmentedControl.newAutoLayout()
        segmentedControl.shouldShowSeparators = true
        segmentedControl.separatorColor = UIColor.segmentedControlSeparatorColor()
        
        segmentedControlComponentsHolderView.addSubview(segmentedControl)
        
        let segmentedControlInsets = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0.0)
        segmentedControl.autoPinEdgesToSuperviewEdges(with: segmentedControlInsets)

        
        let bottomSeparatorView = UIImageView.newAutoLayout()
        bottomSeparatorView.backgroundColor = UIColor.listSeparatorColor()
        
        addSubview(bottomSeparatorView)
        
        bottomSeparatorView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.top)
        bottomSeparatorView.autoSetDimension(ALDimension.height, toSize: 1.0)
    }
    
    // MARK: - Actions
    
    func didTapActionButton(_ button: UIButton) {
        delegate.userInformationHeaderViewDidTapActionButton(self)
    }
    
    // MARK: - Gestures
    
    func didTapAvatarImageView(_ recognizer: UITapGestureRecognizer) {
        delegate.userInformationHeaderViewDidTapAvatarImageView(self)
    }
    
    // MARK: - View Height
    
    class func viewHeight() -> CGFloat {
        return UserInformationHeaderViewDefaultHeight
    }
}

// MARK: - UserInformationHeaderViewDelegate

protocol UserInformationHeaderViewDelegate: NSObjectProtocol {
    func userInformationHeaderViewDidTapActionButton(_ view: UserInformationHeaderView)
    func userInformationHeaderViewDidTapAvatarImageView(_ view: UserInformationHeaderView)
}
