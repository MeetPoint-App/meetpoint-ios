//
//  EmptyStateCollectionViewCell.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 06/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let EmptyStateCollectionViewCellReuseIdentifier = NSStringFromClass(EmptyStateCollectionViewCell.classForCoder())

class EmptyStateCollectionViewCell: UICollectionViewCell {
    
    var emptyStateView: EmptyStateView!
    
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
        emptyStateView = EmptyStateView.newAutoLayout()
        
        contentView.addSubview(emptyStateView)
        
        emptyStateView.autoPinEdgesToSuperviewEdges()
    }
}
