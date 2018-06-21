//
//  NotificationSettingsTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 3.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let NotificationSettingsTableViewCellReuseIdentifier = NSStringFromClass(NotificationSettingsTableViewCell.classForCoder())

class NotificationSettingsTableViewCell: UITableViewCell {
    
    fileprivate var titleLabel: UILabel!
    var switchItem: UISwitch!
    fileprivate var switchLabel: UILabel!
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }
    
    var switchInformation: String! {
        didSet {
            switchLabel.text = switchInformation
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
        switchItem = UISwitch.newAutoLayout()
        switchItem.onTintColor = UIColor.segmentedControlTintColor()
        
        contentView.addSubview(switchItem)
        
        switchItem.autoPinEdge(toSuperviewEdge: ALEdge.right,
                               withInset: DefaultInset)
        switchItem.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        switchLabel = UILabel.newAutoLayout()
        switchLabel.textColor = UIColor.secondaryDarkTextColor()
        switchLabel.font = UIFont.montserratMediumFont(withSize: 14.0)
        switchLabel.textAlignment = NSTextAlignment.right
        
        contentView.addSubview(switchLabel)
        
        switchLabel.autoPinEdge(ALEdge.right,
                                to: ALEdge.left,
                                of: switchItem, withOffset: -4.0)
        switchLabel.autoPinEdge(toSuperviewEdge: ALEdge.top)
        switchLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.font = UIFont.montserratMediumFont(withSize: 15.0)
        
        contentView.addSubview(titleLabel)

        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left,
                               withInset: DefaultInset)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.top)
        titleLabel.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        titleLabel.autoPinEdge(ALEdge.right,
                               to: ALEdge.left,
                               of: switchLabel,
                               withOffset: DefaultInset)
    }
}
