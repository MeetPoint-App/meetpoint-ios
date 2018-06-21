//
//  ActivityHeaderView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let ActivityHeaderViewDefaultHeight: CGFloat = 56.0
let ActivityHeaderViewReuseIdentifier = NSStringFromClass(ActivityHeaderView.classForCoder())

class ActivityHeaderView: UICollectionReusableView {
    weak var delegate: ActivityHeaderViewDelegate!
    
    // MARK: - Constants
    
    fileprivate let ImageViewDimension: CGFloat = 40.0
    fileprivate let DefaultInset: CGFloat = 8.0
    
    // MARK: - Variables
    
    var imageView: UIImageView!
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!

    fileprivate var actionButton: UIButton!
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        imageView = UIImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        imageView.layer.cornerRadius = ImageViewDimension / 2.0
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView(_:))))
        
        addSubview(imageView)
    
        imageView.autoSetDimensions(to: CGSize(width: ImageViewDimension, height: ImageViewDimension))
        imageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        imageView.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        actionButton = UIButton(type: UIButtonType.custom)
        actionButton.setImage(UIImage(named: "iconDownArrow"), for: UIControlState.normal)
        actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(actionButton)
        
        actionButton.autoSetDimensions(to: CGSize(width: 44.0, height: 44.0))
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        actionButton.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        let labelsHolderView = UIView.newAutoLayout()
        
        addSubview(labelsHolderView)
        
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top)
        labelsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        labelsHolderView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: imageView, withOffset: DefaultInset)
        labelsHolderView.autoPinEdge(ALEdge.right, to: ALEdge.left, of: actionButton)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 14.0)
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTitle(_:))))
        
        labelsHolderView.addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right)

        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        
        labelsHolderView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: DefaultInset)
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left)
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right)
    }
    
    // MARK: - Actions
    
    func didTapImageView(_ recognizer: UITapGestureRecognizer) {
        delegate.activityHeaderViewDidTapImageView(self)
    }
    
    func actionButtonTapped(_ button: UIButton) {
        delegate.activityHeaderViewDidTapActionButton(self)
    }
    
    func didTapTitle(_ recognizer: UITapGestureRecognizer) {
        delegate.activityHeaderViewDidTapTitle(self)
    }
}

// MARK: - ActivityHeaderViewDelegate

protocol ActivityHeaderViewDelegate: NSObjectProtocol {
    func activityHeaderViewDidTapImageView(_ headerView: ActivityHeaderView)
    func activityHeaderViewDidTapActionButton(_ headerView: ActivityHeaderView)
    func activityHeaderViewDidTapTitle(_ headerView: ActivityHeaderView)
}
