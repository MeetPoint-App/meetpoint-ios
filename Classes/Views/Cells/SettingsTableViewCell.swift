//
//  SettingsTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 5.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let SettingsTableViewCellReuseIdentifier = NSStringFromClass(SettingsTableViewCell.classForCoder())

let SettingsTableViewCellDefaultHeight: CGFloat = 50.0

class SettingsTableViewCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 15.0)
        
        contentView.addSubview(titleLabel)
        
        let insets = UIEdgeInsetsMake(0.0, DefaultInset, 0.0, 0.0)
        titleLabel.autoPinEdgesToSuperviewEdges(with: insets)
    }
}
