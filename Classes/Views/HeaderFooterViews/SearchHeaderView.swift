//
//  SearchHeaderView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//


import UIKit
import PureLayout

let SearchHeaderViewReuseIdentifier = NSStringFromClass(SearchHeaderView.classForCoder())

fileprivate let DefaultInset: CGFloat = 8.0
let SearchHeaderViewDefaultHeight: CGFloat = 25.0

class SearchHeaderView: UITableViewHeaderFooterView {
    weak var delegate: SearchHeaderViewDelegate!
    
    fileprivate var titleLabel: UILabel!
    
    fileprivate var actionButton: UIButton!

    var text: String! {
        didSet {
            titleLabel.text = text
        }
    }
    
    var font: UIFont! = UIFont.montserratRegularFont(withSize: 14.0) {
        didSet {
            titleLabel.font = font
        }
    }
    
    var textColor: UIColor! = UIColor.primaryDarkTextColor() {
        didSet {
            titleLabel.textColor = textColor
        }
    }
    
    var type: SearchHeaderViewType = SearchHeaderViewType.recent {
        didSet {
            switch type {
            case SearchHeaderViewType.recent:
                hideActionButton = false
            case SearchHeaderViewType.result:
                hideActionButton = true
            }
            
            titleLabel.text = type.title
        }
    }
    
    var hideActionButton: Bool! {
        didSet {
            actionButton.isHidden = hideActionButton
        }
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    fileprivate func commonInit() {
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = textColor
        titleLabel.font = font
        
        addSubview(titleLabel)
        
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.top)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        
        
        actionButton = UIButton(type: UIButtonType.custom)
        actionButton.adjustsImageWhenHighlighted = false
        actionButton.setTitleColor(textColor, for: UIControlState.normal)
        actionButton.titleLabel?.font = font
        actionButton.setTitle("Clear", for: UIControlState.normal)
        actionButton.contentMode = UIViewContentMode.right
        actionButton.addTarget(self, action: #selector(didTapActionButton(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(actionButton)
        
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.top)
        actionButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
    }
    
    // MARK: - Actions
    
    @objc func didTapActionButton(_ button: UIButton) {
        delegate.searchHeaderViewDidTapClear(self)
    }
}

// MARK: - SearchHeaderViewDelegate

protocol SearchHeaderViewDelegate: NSObjectProtocol {
    func searchHeaderViewDidTapClear(_ view: SearchHeaderView)
}
