//
//  SearchViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher

fileprivate enum UserSource {
    case topUsers
    case newestUsers
    
    var title: String {
        switch self {
        case .topUsers:
            return "Top Users List"
        case .newestUsers:
            return "Newest Users List"
        }
    }
    
    static let allValues = [topUsers, newestUsers]
}

class SearchViewController: BaseTableViewController {
    
    fileprivate var emptyStateView: EmptyStateView!
    fileprivate var segmentedControl: TabBar!
    
    fileprivate var topUsers: [User]! = []
    fileprivate var newestUsers: [User]! = []
    
    fileprivate var searchController: UISearchController?
    
    fileprivate var currentUserSource: UserSource! = UserSource.topUsers
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.title = "Search"
        
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveLogoutNotification(_:)),
                        name: NSNotification.Name(rawValue: UserLogoutNotification),
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        
        tableView.register(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: SearchTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        tableView.backgroundView = UIView()
        
        
        let resultController = SearchResultsViewController()
        resultController.delegate = self
        
        searchController = UISearchController(searchResultsController: resultController)
        searchController?.searchResultsUpdater = resultController
        searchController?.hidesNavigationBarDuringPresentation = false
        searchController?.dimsBackgroundDuringPresentation = true
        
        let searchBar = searchController?.searchBar
        searchBar?.tintColor = UIColor.defaultTintColor()
        searchBar?.sizeToFit()
        searchBar?.searchBarStyle = UISearchBarStyle.minimal
        searchBar?.placeholder = "Search"
        searchBar?.autocapitalizationType = UITextAutocapitalizationType.words
        
        let textFieldInsideSearchBar = searchBar!.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.primaryDarkTextColor()
        textFieldInsideSearchBar?.font = UIFont.montserratRegularFont(withSize: 14.0)
        
        self.navigationItem.titleView = searchBar
        
        
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
        
        
        var insets = contentInset
        insets?.top = defaultTopInset()
        insets?.bottom = defaultBottomInset()
        
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
            switch currentUserSource! {
            case .topUsers:
                topUsers.removeAll()
            case .newestUsers:
                newestUsers.removeAll()
            }
        }
        
        self.disableSegmentedControl()
        
        switch currentUserSource! {
        case .topUsers:
            DatabaseManager.sharedManager.getTopUsers(completion: { (users, error) in
                
                self.enableSegmentedControl()
                
                if let error = error {
                    self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                    return
                }
                
                guard let users = users else {
                    return
                }
                
                self.topUsers = users
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.finishLoading(withState: ControllerState.none, andMessage: nil)
                    self.endRefreshing()
                    self.tableView.reloadData()
                }
            })
        case .newestUsers:
            DatabaseManager.sharedManager.getNewestUsers(completion: { (users, error) in
                
                self.enableSegmentedControl()
                
                if let error = error {
                    self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                    return
                }
                
                guard let users = users else {
                    return
                }
                
                self.newestUsers = users
                
                self.tableView.reloadData()
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
                self.endRefreshing()
            })
        }
        
        return true
    }
    
    // MARK: - Update
    
    fileprivate func updateUsers(WithSource source: UserSource) {
        if currentUserSource != source {
            currentUserSource = source
            
            switch currentUserSource! {
            case .topUsers:
                if topUsers.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            case .newestUsers:
                if newestUsers.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            }
            
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Configure
    
    fileprivate func configure(SearchTableViewCell cell: SearchTableViewCell, withIndexPath indexPath: IndexPath) {
        
        let user: User
        
        switch currentUserSource! {
        case .topUsers:
            if indexPath.row >= topUsers.count {
                return
            }
            user = topUsers[indexPath.row]
        case .newestUsers:
            if indexPath.row >= newestUsers.count {
                return
            }
            user = newestUsers[indexPath.row]
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
        
        let user: User!
        switch currentUserSource! {
        case .topUsers:
            if indexPath.row >= topUsers.count {
                return
            }
            
            user = topUsers[indexPath.row]
        case .newestUsers:
            if indexPath.row >= newestUsers.count {
                return
            }
            user = newestUsers[indexPath.row]
        }
        
        presentProfileViewController(withUser: user)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentUserSource! {
        case .topUsers:
            return topUsers.count
        case .newestUsers:
            return newestUsers.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCellReuseIdentifier, for: indexPath) as! SearchTableViewCell
        
        configure(SearchTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight()
    }
    
    // MARK: - Present
    
    func presentProfileViewController(withUser user: User) {
        let profileViewController = ProfileViewController(withUser: user)
        navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    // MARK: - Notification
    
    func didReceiveLogoutNotification(_ notification: Notification) {
        self.segmentedControl.selectedIndex = 0
        self.currentUserSource = UserSource.topUsers
        
        self.topUsers       = []
        self.newestUsers    = []
        
        self.tableView.reloadData()
        
        self.navigationController?.popToRootViewController(animated: true)
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

extension SearchViewController: TabBarDelegate {
    
    func tabBar(_ tabBar: TabBar, shouldSelectTabAtIndex index: Int) -> Bool {
        return true
    }
    
    func tabBarShouldShowSelectionIndicator(_ tabBar: TabBar) -> Bool {
        return true
    }
    
    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int) {
        updateUsers(WithSource: UserSource.allValues[index])
    }
}

// MARK: - TabBarDataSource

extension SearchViewController: TabBarDataSource {
    func tabBar(_ tabBar: TabBar, buttonImageAtIndex index: Int, forState state: TabBarState) -> UIImage? {
        return nil
    }
    
    func numberOfTabsInTabBar(_ tabBar: TabBar) -> Int {
        return UserSource.allValues.count
    }
    
    func tabBar(_ tabBar: TabBar, buttonTitleAtIndex index: Int) -> String? {
        return UserSource.allValues[index].title
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

// MARK: - SearchResultsViewControllerDelegate

extension SearchViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidTapUser(_ controller: SearchResultsViewController, _ user: User) {
        presentProfileViewController(withUser: user)
    }
}
