
//
//  SettingsFooterView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 5.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit

let SettingsFooterViewDefaultHeight: CGFloat = 100.0

let SettingsFooterViewReuseIdentifier = NSStringFromClass(SettingsFooterView.classForCoder())

class SettingsFooterView: UITableViewHeaderFooterView {
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    fileprivate var titleLabel: UILabel!
    
    var title: String! {
        didSet {
            titleLabel.text = title
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
        titleLabel.font = UIFont.montserratMediumFont(withSize: 15.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = UIColor.primaryLightTextColor()
        titleLabel.numberOfLines = 0
        
        contentView.addSubview(titleLabel)
        
        let insets = UIEdgeInsets(top: 0.0, left: DefaultInset, bottom: 0.0, right: 0.0)
        titleLabel.autoPinEdgesToSuperviewEdges(with: insets)
    }
}
