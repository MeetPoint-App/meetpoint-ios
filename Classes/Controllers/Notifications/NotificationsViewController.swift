//
//  NotificationsViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class NotificationsViewController: BaseTableViewController {
    
    fileprivate var notifications: [RemoteNotification] = []
    
    fileprivate var emptyStateView: EmptyStateView!
    
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
        title = "Notifications"
        
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveLogoutNotification(_:)),
                        name: NSNotification.Name(rawValue: UserLogoutNotification), object: nil)

        dnc.addObserver(self,
                        selector: #selector(didReceiveUserAuthenticationNotification(_:)),
                        name: NSNotification.Name(rawValue: UserAuthenticationNotification),
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserNotificationTableViewCell.classForCoder(),
                           forCellReuseIdentifier: UserNotificationTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        tableView.backgroundView = UIView()
        
        
        emptyStateView = EmptyStateView.newAutoLayout()
        emptyStateView.isHidden = true
        
        view.addSubview(emptyStateView)
        
        emptyStateView.autoPinEdgesToSuperviewEdges()
        
        
        var insets = contentInset
        insets?.bottom = defaultBottomInset()
        
        scrollIndicatorInsets = insets
        contentInset = insets
        
        
        loadData(withRefresh: true)
    }
    
    // MARK: - Interface
    
    override func canPullToRefresh() -> Bool {
        return true
    }
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    // MARK: - LoadData
    
    @discardableResult override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            self.notifications = []
            self.tableView.reloadData()
        }
        
        DatabaseManager.sharedManager.getUserNotifications { (error, notifications) in
            if let error = error {
                
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                self.endRefreshing()
                self.tableView.reloadData()
                
                return
            }
            
            guard let notifications = notifications else {
                return
            }
            
            self.notifications = notifications
            
            if self.notifications.count == 0 {
                self.emptyStateView.isHidden = false
                self.emptyStateView.update(withImage: UIImage(named: "notificationEmptyStateIcon"),
                                           andMessageTitle: "No notifications yet",
                                           andMessageSubtitle: "Check back later for updates",
                                           andButtonTitle: nil)
            } else {
                self.emptyStateView.isHidden = true
            }
            
            self.tableView.reloadData()
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.endRefreshing()
        }
        
        return true
    }
    
    // MARK: - Configure
    
    fileprivate func configure(UserNotificationTableViewCell cell: UserNotificationTableViewCell, withIndexPath indexPath: IndexPath) {
        if indexPath.row >= notifications.count {
            return
        }
        
        let notification = notifications[indexPath.row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        
        if notification.notificationType! == NotificationType.user.rawValue {
            guard let user = notification.user else {
                return
            }
            
            if let message = notification.message {
                cell.title = message
            }
            
            if let timestamp = notification.timestamp {
                let date = NSDate(timeIntervalSince1970: Double(timestamp)!)
                cell.subtitle = NSDate.timePassedSinceDate(date)
            }
            
            if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                cell.avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
            }
            
            if user.isFollowing == true {
                cell.actionButtonType = UserNotificationActionButtonType.unfollow
            } else {
                cell.actionButtonType = UserNotificationActionButtonType.follow
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserNotificationTableViewCellReuseIdentifier,
                                                 for: indexPath) as! UserNotificationTableViewCell
        
        configure(UserNotificationTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= notifications.count {
            return 0.0
        }
        
        let notification = notifications[indexPath.row]
        
        return UserNotificationTableViewCell.cellHeight(withNotification: notification)
    }
    
    // MARK: - Notification
    
    func didReceiveLogoutNotification(_ notification: Notification) {
        self.notifications = []
        
        self.navigationController?.popToRootViewController(animated: true)
        
        self.tableView.reloadData()
    }
    
    func didReceiveUserAuthenticationNotification(_ notification: Notification) {
        self.loadData(withRefresh: true)
    }
}

// MARK: - UserNotificationTableViewCellDelegate

extension NotificationsViewController: UserNotificationTableViewCellDelegate {
    func userNotificationTableViewCellDidTapUsername(_ cell: UserNotificationTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.row >= notifications.count {
            return
        }
        
        guard let user = notifications[indexPath.row].user else {
            return
        }
        
        let viewController = ProfileViewController(withUser: user)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func userNotificationTableViewCellDidTapAvatarImageView(_ cell: UserNotificationTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.row >= notifications.count {
            return
        }
        
        guard let user = notifications[indexPath.row].user else {
            return
        }
        
        let viewController = ProfileViewController(withUser: user)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func userNotificationTableViewCellDidTapActionButton(_ cell: UserNotificationTableViewCell) {
        let actionButtonType = cell.actionButtonType
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.row >= notifications.count {
            return
        }
        
        guard let user = notifications[indexPath.row].user else {
            return
        }
        
        switch actionButtonType! {
        case UserNotificationActionButtonType.follow:
            cell.actionButtonType = UserNotificationActionButtonType.unfollow
            DatabaseManager.sharedManager.follow(user.uuid!) { (error) in
                if error == nil {
                    user.isFollowing = true
                    
                    if indexPath.row >= self.notifications.count {
                        return
                    }
                    
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            }
        case UserNotificationActionButtonType.unfollow:
            cell.actionButtonType = UserNotificationActionButtonType.follow
            DatabaseManager.sharedManager.unfollow(user.uuid!) { (error) in
                if error == nil {
                    user.isFollowing = false
                    
                    if indexPath.row >= self.notifications.count {
                        return
                    }
                    
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
                }
            }
        }
    }
}
