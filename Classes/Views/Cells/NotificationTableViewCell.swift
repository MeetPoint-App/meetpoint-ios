//
//  NotificationTableViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let NotificationTableViewCellReuseIdentifier = NSStringFromClass(NotificationTableViewCell.classForCoder())

class NotificationTableViewCell: UITableViewCell {
    
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
        
    }
}
