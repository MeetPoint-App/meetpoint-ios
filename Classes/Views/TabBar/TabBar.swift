//
//  TabBar.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 11/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum TabBarState {
    case `default`
    case selected
}

let TabBarDefaultHeight: CGFloat = 44.0

class TabBar: UIView {
    weak var delegate: TabBarDelegate!
    weak var dataSource: TabBarDataSource!
    
    fileprivate var selectionIndicatorView: UIView!
    fileprivate var selectionIndicatorViewLeftConstaint: NSLayoutConstraint!
    
    fileprivate var topShadow: UIImageView!
    fileprivate var bottomShadow: UIImageView!
    
    fileprivate var tabBarItems: [TabBarItem]! = []
    
    fileprivate var tabWidth: CGFloat = 0.0
    
    var font: UIFont? {
        didSet {
            for item in tabBarItems {
                item.font = font
            }
        }
    }
    
    var selectedIndex: Int! = 0 {
        didSet {
            updateSelectionWith(Index: selectedIndex, animated: true)
        }
    }
    
    var shouldShowSeparators: Bool! = false {
        didSet {
            for item in tabBarItems {
                item.shouldShowSeparator = shouldShowSeparators
            }
            
            if let lastItem = tabBarItems.last {
                lastItem.shouldShowSeparator = false
            }
        }
    }
    
    var shouldShowShadowOnTop: Bool! = false {
        didSet {
            if shouldShowShadowOnTop == true {
                if let shadow = topShadow {
                    shadow.isHidden = false
                    
                    return
                }
                
                topShadow = UIImageView.newAutoLayout()
                topShadow.image = UIImage(named: "gradientBackgroundBlackBottomToTopSmall")
                
                addSubview(topShadow)
                
                topShadow.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: self)
                topShadow.autoPinEdge(toSuperviewEdge: ALEdge.left)
                topShadow.autoPinEdge(toSuperviewEdge: ALEdge.right)
                topShadow.autoSetDimension(ALDimension.height, toSize: 5.0)
            } else {
                if let shadow = topShadow {
                    shadow.isHidden = false
                }
            }
        }
    }
    
    var shouldShowShadowOnBottom: Bool! = false {
        didSet {
            if shouldShowShadowOnBottom == true {
                if let shadow = bottomShadow {
                    shadow.isHidden = false
                    
                    return
                }
                
                bottomShadow = UIImageView.newAutoLayout()
                bottomShadow.image = UIImage(named: "gradientBackgroundBlackTopToBottomSmall")
                
                addSubview(bottomShadow)
                
                bottomShadow.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self)
                bottomShadow.autoPinEdge(toSuperviewEdge: ALEdge.left)
                bottomShadow.autoPinEdge(toSuperviewEdge: ALEdge.right)
                bottomShadow.autoSetDimension(ALDimension.height, toSize: 5.0)
            } else {
                if let shadow = bottomShadow {
                    shadow.isHidden = false
                }
            }
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            if let view = selectionIndicatorView {
                view.backgroundColor = tintColor
            }
        }
    }
    
    // MARK: - Interface
    
    func createInterface() {
        
        let numberOfTabs = dataSource.numberOfTabsInTabBar(self)
        
        tabWidth = (frame.size.width / CGFloat(numberOfTabs))
        
        var prevItem: TabBarItem?
        
        for index in 0..<numberOfTabs {
            let item = TabBarItem()
            item.shouldShowSeparator = shouldShowSeparators
            item.delegate = self
            
            if let image = dataSource.tabBar(self, buttonImageAtIndex: index, forState: TabBarState.default) {
                item.image = image
            }else {
                item.shouldDisplayImage = false
            }
            
            item.font = font
            item.title = dataSource.tabBar(self, buttonTitleAtIndex: index)
            
            addSubview(item)
            
            if prevItem != nil {
                item.autoPinEdge(ALEdge.left, to: ALEdge.right, of: prevItem!)
            }else {
                item.autoPinEdge(toSuperviewEdge: ALEdge.left)
            }
            
            item.autoPinEdge(toSuperviewEdge: ALEdge.top)
            item.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
            item.autoSetDimension(ALDimension.width, toSize: tabWidth)
            
            prevItem = item
            
            tabBarItems.append(item)
        }
        
        prevItem?.shouldShowSeparator = false
        
        if delegate.tabBarShouldShowSelectionIndicator(self) {
            selectionIndicatorView = UIView.newAutoLayout()
            selectionIndicatorView.backgroundColor = tintColor
            
            addSubview(selectionIndicatorView)
            
            selectionIndicatorView.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
            selectionIndicatorViewLeftConstaint = selectionIndicatorView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: 0.0)
            selectionIndicatorView.autoSetDimensions(to: CGSize(width: tabWidth, height: 3.0))
        }
        
        updateSelectionWith(Index: selectedIndex, animated: false)
    }
    
    // MARK: - Selection
    
    fileprivate func updateSelectionWith(Index index: Int,animated: Bool) {
        if delegate.tabBarShouldShowSelectionIndicator(self) {
            guard let constraint = selectionIndicatorViewLeftConstaint else {
                return
            }
            
            constraint.constant = (CGFloat(index) * tabWidth)
            
            if animated {
                UIView.animate(withDuration: 0.33, animations: {
                    self.layoutIfNeeded()
                })
            }else {
                self.layoutIfNeeded()
            }
        }
        
        for index in 0..<tabBarItems.count {
            let item = tabBarItems[index]
            
            var state = TabBarState.default
            
            if index == selectedIndex {
                state = TabBarState.selected
            }
            
            item.textColor = dataSource.tabBar(self, titleColorForState: state)
            item.image = dataSource.tabBar(self, buttonImageAtIndex: index, forState: state)
            item.title = dataSource.tabBar(self, buttonTitleAtIndex: index)
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if tabBarItems.count == 0 {
            createInterface()
        }
    }
}

// MARK: - TabBar Delegate

@objc protocol TabBarDelegate: NSObjectProtocol {
    func tabBar(_ tabBar: TabBar,didSelectItemAtIndex index: Int)
    func tabBarShouldShowSelectionIndicator(_ tabBar: TabBar) -> Bool
    @objc optional func tabBar(_ tabBar: TabBar, shouldSelectTabAtIndex index: Int) -> Bool
}

// MARK: - TabBar DataSource

protocol TabBarDataSource: NSObjectProtocol {
    func numberOfTabsInTabBar(_ tabBar: TabBar) -> Int
    
    func tabBar(_ tabBar: TabBar, titleColorForState state: TabBarState) -> UIColor?
    func tabBar(_ tabBar: TabBar, buttonImageAtIndex index: Int, forState state: TabBarState) -> UIImage?
    func tabBar(_ tabBar: TabBar, buttonTitleAtIndex index: Int) -> String?
}

// MARK: - TabBarItemDelegate

extension TabBar: TabBarItemDelegate {
    func tabBarItemDidReceiveTap(_ item: TabBarItem) {
        if let index = tabBarItems.index(of: item) {
            if delegate.responds(to: #selector(TabBarDelegate.tabBar(_:shouldSelectTabAtIndex:))) {
                if delegate.tabBar!(self, shouldSelectTabAtIndex: index) {
                    selectedIndex = index
                }
            }else {
                selectedIndex = index
            }
            
            delegate.tabBar(self, didSelectItemAtIndex: index)
        }
    }
}
