//
//  ProfileSegmentedControl.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 03/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let ProfileSegmentedControlDefaultHeight: CGFloat = 40.0

class ProfileSegmentedControl: UIView {
    weak var delegate: ProfileSegmentedControlDelegate!
    weak var dataSource: ProfileSegmentedControlDataSource!
    
    fileprivate var segmentedControlItems: [ProfileSegmentedControlItem] = []
    
    var separatorColor: UIColor! = UIColor.segmentedControlSeparatorColor() {
        didSet {
            for item in segmentedControlItems {
                item.separatorColor = separatorColor
            }
        }
    }
    
    var shouldShowSeparators: Bool! = true {
        didSet {
            for item in segmentedControlItems {
                item.shouldShowSeparator = shouldShowSeparators
            }
            
            if let lastItem = segmentedControlItems.last {
                lastItem.shouldShowSeparator = false
            }
        }
    }

    // MARK: - Interface
    
    fileprivate func create() {
        let numberOfItems = dataSource.numberOfSegmentsInProfileSegmentedControl(self)
        
        let segmentWidth = (frame.width / CGFloat(numberOfItems))
        
        var prevSegment: ProfileSegmentedControlItem?
        
        for index in 0..<numberOfItems {
            let item = ProfileSegmentedControlItem()
            item.shouldShowSeparator = shouldShowSeparators
            item.attributedTitle = dataSource.profileSegmentedControl(self, attributedTitleAtIndex: index)
            item.delegate = self
            
            addSubview(item)
            
            if prevSegment != nil {
                item.autoPinEdge(ALEdge.left, to: ALEdge.right, of: prevSegment!)
            } else {
                item.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self)
            }
            
            item.autoPinEdge(toSuperviewEdge: ALEdge.top)
            item.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
            item.autoSetDimension(ALDimension.width, toSize: segmentWidth)
            
            prevSegment = item
            
            segmentedControlItems.append(item)
        }
        
        prevSegment?.shouldShowSeparator = false
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if segmentedControlItems.count == 0 {
            create()
        }
    }
    
    // MARK: - Reload
    
    func reloadData() {
        for index in 0..<segmentedControlItems.count {
            let item = segmentedControlItems[index]
            
            let attributedTitle = dataSource.profileSegmentedControl(self, attributedTitleAtIndex: index)
            
            item.attributedTitle = attributedTitle
            item.shouldShowSeparator = shouldShowSeparators
            
            item.separatorColor = separatorColor
        }
        
        if let lastItem = segmentedControlItems.last {
            lastItem.shouldShowSeparator = false
        }
    }
}

// MARK: - ProfileSegmentedControlDelegate

protocol ProfileSegmentedControlDelegate: NSObjectProtocol {
    func profileSegmentedControl(_ segmentedControl: ProfileSegmentedControl, didSelectSegmentAtIndex index: Int)
}

// MARK: - ProfileSegmentedControlDataSource

protocol ProfileSegmentedControlDataSource: NSObjectProtocol {
    func numberOfSegmentsInProfileSegmentedControl(_ segmentedControl: ProfileSegmentedControl) -> Int
    func profileSegmentedControl(_ segmentedControl: ProfileSegmentedControl, attributedTitleAtIndex index: Int) -> NSAttributedString?
}

// MARK: - ProfileSegmentedControlItemDelegate

extension ProfileSegmentedControl: ProfileSegmentedControlItemDelegate {
    func profileSegmentedControlItemDidReceiveTap(_ view: ProfileSegmentedControlItem) {
        if let index = segmentedControlItems.index(of: view) {
            delegate.profileSegmentedControl(self, didSelectSegmentAtIndex: index)
        }
    }
}

