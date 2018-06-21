//
//  ParticipantViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 26/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Firebase

enum ParticipantSource: Int {
    case going
    case interested
    
    var title: String {
        switch self {
        case .going:
            return "Going"
        case .interested:
            return "Interested"
        }
    }
    
    static let allValues = [going, interested]
}

class ParticipantViewController: BaseTableViewController {
    
    fileprivate var segmentedControl: TabBar!
    
    fileprivate var goingUsers: [User] = []
    fileprivate var interestedUsers: [User] = []
    
    fileprivate var currentParticipantSource: ParticipantSource! = ParticipantSource.going
    
    fileprivate var activity: Activity?
    
    fileprivate var emptyStateView: EmptyStateView!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(withActivity activity: Activity) {
        super.init()
        self.activity = activity
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.title = "Participants"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ParticipantTableViewCell.classForCoder(), forCellReuseIdentifier: ParticipantTableViewCellReuseIdentifier)
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.separatorInset = UIEdgeInsetsMake(0.0, 56.0, 0.0, 8.0)
        tableView.tableFooterView = UIView()
        
        segmentedControl = TabBar.newAutoLayout()
        segmentedControl.backgroundColor = UIColor.primaryBackgroundColor()
        segmentedControl.font = UIFont.montserratMediumFont(withSize: 14.0)
        segmentedControl.shouldShowSeparators = true
        segmentedControl.shouldShowShadowOnBottom = true
        segmentedControl.tintColor = UIColor.segmentedControlTintColor()
        segmentedControl.delegate = self
        segmentedControl.dataSource = self
        
        view.addSubview(segmentedControl)
        
        segmentedControl.autoPin(toTopLayoutGuideOf: self, withInset: 0.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: ALEdge.left)
        segmentedControl.autoPinEdge(toSuperviewEdge: ALEdge.right)
        segmentedControl.autoSetDimension(ALDimension.height, toSize: TabBarDefaultHeight)
        
        
        emptyStateView = EmptyStateView.newAutoLayout()
        emptyStateView.isHidden = true
        
        view.addSubview(emptyStateView)
        view.bringSubview(toFront: segmentedControl)
        
        emptyStateView.autoPinEdge(ALEdge.top, to: ALEdge.bottom,
                                   of: segmentedControl, withOffset: 0.0)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                   withInset: defaultBottomInset())
        
        
        var insets = contentInset
        insets?.top = defaultTopInset()
        
        scrollIndicatorInsets = insets
        contentInset = insets
        
        
        loadData(withRefresh: true)
    }
    
    // MARK: - Interface
    
    override func shouldShowShadowUnderNavigationBar() -> Bool {
        return false
    }
    
    override func defaultTopInset() -> CGFloat {
        return TabBarDefaultHeight
    }
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    override func canPullToRefresh() -> Bool {
        return true
    }
    
    // MARK: - Load Data
    
    @discardableResult override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            goingUsers.removeAll()
            interestedUsers.removeAll()
        }
        
        guard let activity = activity, let identifier = activity.identifier else {
            return true
        }
        
        self.disableSegmentedControl()
        
        DatabaseManager.sharedManager.getParticipantList(identifier, type: currentParticipantSource.rawValue, completion: { (users, error) in
            if let error = error {
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                
                return
            }
            
            switch self.currentParticipantSource! {
            case ParticipantSource.going:
                self.goingUsers = users!
                
                if self.goingUsers.count == 0 {
                    self.emptyStateView.isHidden = false
                    self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                               andMessageTitle: "Nothing is here!",
                                               andMessageSubtitle: "No one is participated in this activity yet.",
                                               andButtonTitle: nil)
                } else {
                    self.emptyStateView.isHidden = true
                }
            case ParticipantSource.interested:
                self.interestedUsers = users!
                
                if self.interestedUsers.count == 0 {
                    self.emptyStateView.isHidden = false
                    self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                               andMessageTitle: "Nothing is here!",
                                               andMessageSubtitle: "No one is interested in this activity yet.",
                                               andButtonTitle: nil)
                } else {
                    self.emptyStateView.isHidden = true
                }
            }
            
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.tableView.reloadData()
            self.endRefreshing()
            
            self.enableSegmentedControl()
        })
        
        return true
    }
    
    // MARK: - Update
    
    fileprivate func updateParticipants(WithSource source: ParticipantSource) {
        if currentParticipantSource != source {
            currentParticipantSource = source
            
            self.tableView.reloadData()
            self.emptyStateView.isHidden = true
            
            switch currentParticipantSource! {
            case .going:
                if goingUsers.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            case .interested:
                if interestedUsers.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            }
            
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Configure
    
    func configure(ParticipantTableViewCell cell: ParticipantTableViewCell, withIndexPath indexPath: IndexPath) {
        let user: User
        
        switch currentParticipantSource! {
        case ParticipantSource.going:
            if indexPath.row >= goingUsers.count {
                return
            }
            user = goingUsers[indexPath.row]
        case ParticipantSource.interested:
            if indexPath.row >= interestedUsers.count {
                return
            }
            user = interestedUsers[indexPath.row]
        }
        
        if let fullName = user.fullName {
            cell.title = fullName
        }
        
        if let username = user.username {
            cell.subtitle = username.atPrefixedString()
        }
        
        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
            cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            cell.avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user: User
        
        switch currentParticipantSource! {
        case ParticipantSource.going:
            if indexPath.row >= goingUsers.count {
                return
            }
            user = goingUsers[indexPath.row]
        case ParticipantSource.interested:
            if indexPath.row >= interestedUsers.count {
                return
            }
            user = interestedUsers[indexPath.row]
        }
        
        let viewController = ProfileViewController(withUser: user)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentParticipantSource! {
        case ParticipantSource.going:
            return self.goingUsers.count
        case ParticipantSource.interested:
            return self.interestedUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParticipantTableViewCellReuseIdentifier, for: indexPath) as! ParticipantTableViewCell
        
        configure(ParticipantTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ParticipantTableViewCell.cellHeight()
    }
    
    // MARK: - Helpers
    
    func enableSegmentedControl() {
        segmentedControl.isUserInteractionEnabled = true
        segmentedControl.alpha = 1.0
    }
    
    func disableSegmentedControl() {
        segmentedControl.isUserInteractionEnabled = false
        segmentedControl.alpha = 0.9
    }
}

// MARK: - TabBarDelegate

extension ParticipantViewController: TabBarDelegate {
    
    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int) {
        updateParticipants(WithSource: ParticipantSource.allValues[index])
    }
    
    func tabBar(_ tabBar: TabBar, shouldSelectTabAtIndex index: Int) -> Bool {
        return true
    }
    
    func tabBarShouldShowSelectionIndicator(_ tabBar: TabBar) -> Bool {
        return true
    }
}

// MARK: - TabBarDataSource

extension ParticipantViewController: TabBarDataSource {
    func tabBar(_ tabBar: TabBar, buttonImageAtIndex index: Int, forState state: TabBarState) -> UIImage? {
        return nil
    }
    
    func numberOfTabsInTabBar(_ tabBar: TabBar) -> Int {
        return ParticipantSource.allValues.count
    }
    
    func tabBar(_ tabBar: TabBar, buttonTitleAtIndex index: Int) -> String? {
        return ParticipantSource.allValues[index].title
    }
    
    func tabBar(_ tabBar: TabBar, titleColorForState state: TabBarState) -> UIColor? {
        switch state {
        case .default:
            return UIColor.primaryLightTextColor()
        case .selected:
            return UIColor.primaryDarkTextColor()
        }
    }
}
