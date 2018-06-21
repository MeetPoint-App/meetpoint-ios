//
//  TabBarItem.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 11/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class TabBarItem: UIView {
    weak var delegate: TabBarItemDelegate!
    
    fileprivate var imageView: UIImageView!
    fileprivate var titleLabel: UILabel!
    
    fileprivate var separatorView: UIView?
    
    fileprivate var imageViewHeightConstraint: NSLayoutConstraint!
    
    var image: UIImage? {
        didSet {
            if let imageView = imageView {
                imageView.image = image
            }
        }
    }
    
    var title: String? {
        didSet {
            if let titleLabel = titleLabel {
                titleLabel.text = title
            }
        }
    }
    
    var font: UIFont? {
        didSet {
            if let font = font {
                titleLabel.font = font
            }
        }
    }
    
    var shouldDisplayImage: Bool? {
        didSet {
            if let shouldDisplayImage = shouldDisplayImage {
                if shouldDisplayImage == false {
                    imageViewHeightConstraint.constant = 0.0
                    titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
                }
            }
        }
    }
    
    var shouldShowSeparator: Bool! {
        didSet {
            if shouldShowSeparator == true {
                if let view = separatorView {
                    view.isHidden = false
                    
                    return
                }
                
                separatorView = UIView.newAutoLayout()
                separatorView?.backgroundColor = UIColor.listSeparatorColor()
                
                addSubview(separatorView!)
                
                let insets = UIEdgeInsetsMake(7.0, 0.0, 7.0, -0.5)
                separatorView?.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: ALEdge.left)
                separatorView?.autoSetDimension(ALDimension.width, toSize: 1.0)
            }else {
                if let view = separatorView {
                    view.isHidden = true
                }
            }
        }
    }
    
    var textColor: UIColor? {
        didSet {
            if let titleLabel = titleLabel {
                titleLabel.textColor = textColor
            }
        }
    }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        backgroundColor = UIColor.clear
        
        imageView = UIImageView.newAutoLayout()
        imageView.contentMode = UIViewContentMode.center
        
        addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        imageViewHeightConstraint = imageView.autoSetDimension(ALDimension.height, toSize: 0.0)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textAlignment = .center
        
        addSubview(titleLabel)
        
        titleLabel.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: imageView)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:))))
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let _ = image {
            imageViewHeightConstraint.constant = frame.size.height
        }
    }
    
    // MARK: - Gestures
    
    @objc func didTapBackground(_ recognizer: UITapGestureRecognizer) {
        delegate.tabBarItemDidReceiveTap(self)
    }
}

protocol TabBarItemDelegate: NSObjectProtocol {
    func tabBarItemDidReceiveTap(_ item: TabBarItem)
}
