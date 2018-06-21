//
//  FollowersViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 9.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit

class FollowersViewController: BaseTableViewController {
    
    fileprivate var paginationParameter: String?
    
    fileprivate var followers: [User] = []
    
    fileprivate var user: User?
    
    fileprivate var emptyStateView: EmptyStateView!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(withUser user: User) {
        super.init()
        self.user = user
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.title = "Followers"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowingsFollowersTableViewCell.classForCoder(), forCellReuseIdentifier: FollowingsFollowersTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        tableView.backgroundView = UIView()
        
        
        emptyStateView = EmptyStateView.newAutoLayout()
        emptyStateView.isHidden = true
        
        view.addSubview(emptyStateView)
        view.bringSubview(toFront: emptyStateView)
        
        emptyStateView.autoPinEdgesToSuperviewEdges()
        
        
        var insets = contentInset
        insets?.bottom = defaultBottomInset()
        
        scrollIndicatorInsets = insets
        contentInset = insets
        
        _ = loadData(withRefresh: true)
    }
    
    // MARK: - Interface
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    override func canPullToRefresh() -> Bool {
        return true
    }
    
    // MARK: - Load Data
    
    override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            followers = []
            self.endRefreshing()
            self.paginationParameter = nil
        }
        
        guard let user = user, let uid = user.uuid else {
            return true
        }
        
        DatabaseManager.sharedManager.getFollowers(uid, parameter: paginationParameter) { (users, error, parameter) in
            if let error = error {
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                
                return
            }
            
            if let error = error {
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                
                return
            }
            
            self.paginationParameter = parameter
            
            self.canLoadMore = (self.paginationParameter != nil)
            
            if let users = users {
                self.followers += users
            }
            
            DatabaseManager.sharedManager.getFollowersCount(uid, { (count) in
                if self.followers.count == count {
                    self.canLoadMore = false
                }
            })
            
            if self.followers.count == 0 {
                self.emptyStateView.isHidden = false
                self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                           andMessageTitle: "Nothing Here Yet!",
                                           andMessageSubtitle: "There are no followers.",
                                           andButtonTitle: nil)
            } else {
                self.emptyStateView.isHidden = true
            }
            
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.endRefreshing()
            self.tableView.reloadData()
        }
        
        return true
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row >= followers.count {
            return
        }
        
        let user = followers[indexPath.row]
        
        let viewController = ProfileViewController(withUser: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowingsFollowersTableViewCellReuseIdentifier, for: indexPath) as! FollowingsFollowersTableViewCell
        
        configure(FollowingsFollowersTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FollowingsFollowersTableViewCell.cellHeight()
    }
    
    // MARK: - Configure
    
    fileprivate func configure(FollowingsFollowersTableViewCell cell: FollowingsFollowersTableViewCell,
                               withIndexPath indexPath: IndexPath) {
        
        if indexPath.row >= followers.count {
            return
        }
        
        let user = followers[indexPath.row]
        
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
}
