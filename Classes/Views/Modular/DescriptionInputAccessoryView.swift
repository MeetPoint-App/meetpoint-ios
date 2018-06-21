//
//  DescriptionInputAccessoryView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 24.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum ActivityType: Int {
    case coffee
    case dinner
    case dance
    case party
    case beer
    case movie
    case football
    case yoga
    case bowling
    case camp
    
    var title: String {
        switch self {
        case .coffee:
            return "coffee☕️"
        case .dinner:
            return "dinner🍽"
        case .dance:
            return "dance💃🏻"
        case .party:
            return "party🎉"
        case .beer:
            return "beer🍻"
        case .movie:
            return "movie🍿"
        case .football:
            return "football⚽️"
        case .yoga:
            return "yoga🧘‍♀️"
        case .bowling:
            return "bowling🎳"
        case .camp:
            return "camp🏕"
        }
    }
    
    var description: String {
        switch self {
        case .coffee:
            return "Let's drink coffee☕️"
        case .dinner:
            return "Let's eat dinner🍽"
        case .dance:
            return "Let's dance💃🏻"
        case .party:
            return "Let's party🎉"
        case .beer:
            return "Let's drink beer🍻"
        case .movie:
            return "Let's watch movie🍿"
        case .football:
            return "Let's play football⚽️"
        case .yoga:
            return "Let's do yoga🧘‍♀️"
        case .bowling:
            return "Let's play bowling🎳"
        case .camp:
            return "Let's camp🏕"
        }
    }
    
    static let allValues = [coffee, dinner, dance, party, beer, movie, football, yoga, bowling, camp]
}

class DescriptionInputAccessoryView: UIView {
    weak var delegate: DescriptionInputAccessoryViewDelegate!
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var separatorView: UIView!
    
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
        separatorView = UIView.newAutoLayout()
        separatorView.backgroundColor = UIColor.dropDownButtonBackgroundColor()
        
        addSubview(separatorView!)
        
        separatorView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        separatorView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        separatorView.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: self)
        separatorView.autoSetDimension(ALDimension.height, toSize: 0.8)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.primaryBackgroundColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.none
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        
        collectionView.register(DescriptionInputCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: DescriptionInputCollectionViewCellReuseIdentifier)
        
        addSubview(collectionView)
    }
    
    // MARK: - Configure
    
    fileprivate func configure(DescriptionInputCollectionViewCell cell: DescriptionInputCollectionViewCell,
                               withIndexPath indexPath: IndexPath) {
        if indexPath.row >= ActivityType.allValues.count {
            return
        }
        
        let activityType = ActivityType.allValues[indexPath.item]
        cell.title = "\(activityType.title)"
    }
}

// MARK: - UICollectionViewDelegate

extension DescriptionInputAccessoryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= ActivityType.allValues.count {
            return
        }
        
        let activityType = ActivityType.allValues[indexPath.item]
        
        delegate.descriptionInputAccessoryView(self, selectedActivityType: activityType)
    }
}

// MARK: - UICollectionViewDataSource

extension DescriptionInputAccessoryView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ActivityType.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: DescriptionInputCollectionViewCellReuseIdentifier,
                                                       for: indexPath) as! DescriptionInputCollectionViewCell
        
        configure(DescriptionInputCollectionViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DescriptionInputAccessoryView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return DescriptionInputCollectionViewCellDefaultSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
    }
}

// MARK: - DescriptionInputAccessoryViewDelegate

protocol DescriptionInputAccessoryViewDelegate: NSObjectProtocol {
    func descriptionInputAccessoryView(_ view: DescriptionInputAccessoryView,
                                       selectedActivityType type: ActivityType)
}
