//
//  InviteUserViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 09/11/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Firebase
import Kingfisher

class InviteUserViewController: BaseTableViewController {
    weak var delegate: InviteUserViewControllerDelegate!
    
    fileprivate var selectedUsers: [User] = []
    
    fileprivate var users: [User] = []
    fileprivate var filteredUsers: [User] = []
    
    fileprivate var isSearching: Bool = false
    fileprivate var searchText: String = ""
    
    fileprivate var confirmButton: OverlayButton!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(withUsers users: [User]?) {
        super.init()
        
        if let users = users {
            self.selectedUsers = users

            let title = users.count > 1 ? "\(users.count) Followers Selected" : "\(users.count) Follower Selected"
            self.title = title
        } else {
            self.title = "Select Followers to Invite"
        }
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customCrossButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        tableView.register(InviteUserTableViewCell.classForCoder(),
                           forCellReuseIdentifier: InviteUserTableViewCellReuseIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 56.0, bottom: 0.0, right: 0.0)
        tableView.backgroundView = UIView()
        
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchBar.placeholder = "Search..."
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.done
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.primaryDarkTextColor()
        textFieldInsideSearchBar?.font = UIFont.montserratRegularFont(withSize: 14.0)
        
        searchBar.tintColor = UIColor.defaultTintColor()
        
        if #available(iOS 11.0, *) {
            searchBar.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 56.0)
        } else {
            searchBar.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 44.0)
        }
        
        tableView.tableHeaderView = searchBar
        
        var insets = contentInset
        insets?.bottom = defaultBottomInset()
        
        contentInset = insets
        
        
        confirmButton = OverlayButton(type: UIButtonType.system)
        confirmButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        confirmButton.setTitle("CONFIRM SELECTION", for: UIControlState.normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped(_:)),
                                for: UIControlEvents.touchUpInside)
        
        view.addSubview(confirmButton)
        
        confirmButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        confirmButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        confirmButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 16.0)
        
        
        loadData(withRefresh: false)
    }
    
    // MARK: - Interface
    
    override func shouldHideKeyboardWhenTappedArround() -> Bool {
        return true
    }
    
    override func defaultBottomInset() -> CGFloat {
        return OverlayButtonDefaultSize.height + 32.0
    }
    
    // MARK: - Load Data
    
    @discardableResult
    override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        DatabaseManager.sharedManager.getAllFollowersOfAuthenticatedUser(selectedUsers) { (users, error) in
            if let error = error {
                self.finishLoading(withState: ControllerState.error,
                                   andMessage: error.localizedDescription)
                return
            }
            
            self.users = users!
            
            if self.users.count == 0 {
                
            }
            
            self.finishLoading(withState: ControllerState.none, andMessage: nil)
            self.endRefreshing()
            self.tableView.reloadData()
        }
        
        return true
    }
    
    // MARK: - Configure
    
    fileprivate func configure(InviteUserTableViewCell cell: InviteUserTableViewCell,
                               withIndexPath indexPath: IndexPath) {
        
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        let user: User?
        
        if isSearching {
            if indexPath.row >= filteredUsers.count {
                return
            }
            
            user = filteredUsers[indexPath.row]
        } else {
            if indexPath.row >= users.count {
                return
            }
            
            user = users[indexPath.row]
        }
        
        guard let _ = user else {
            return
        }
        
        if let fullName = user?.fullName {
            cell.title = fullName
        }
        
        if let username = user?.username {
            cell.subtitle = username.atPrefixedString()
        }
        
        if let urlString = user?.profileImageUrl, let url = URL(string: urlString) {
            cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            cell.avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
        }
        
        if user?.isSelected == true {
            cell.checkboxButton.updateInterfaceWith(State: CheckboxState.selected)
        } else {
            cell.checkboxButton.updateInterfaceWith(State: CheckboxState.default)
        }
        
        cell.checkboxButton.delegate = self
    }
    
    // MARK: - Actions
    
    override func crossButtonTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonTapped(_ button: OverlayButton) {
        if self.selectedUsers.count == 0 {
            self.showPopupWith(Title: "Opps", andMessage: "No selection.")
            
            return
        }
        
        delegate.inviteUserViewController(self, withSelectedUsers: self.selectedUsers)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredUsers.count
        }
        
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InviteUserTableViewCellReuseIdentifier,
                                                 for: indexPath) as! InviteUserTableViewCell
        
        configure(InviteUserTableViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return InviteUserTableViewCell.cellHeight()
    }
}

// MARK: - CheckboxButtonDelegate

extension InviteUserViewController: CheckboxButtonDelegate {
    func checkboxButtonTapped(_ button: CheckboxButton) {
        guard let cell = button.superview?.superview as? InviteUserTableViewCell else {
            return
        }
        
        guard let  indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let user: User?
        
        if isSearching {
            if indexPath.row >= filteredUsers.count {
                return
            }
            
            user = filteredUsers[indexPath.row]
        } else {
            if indexPath.row >= users.count {
                return
            }
            
            user = users[indexPath.row]
        }
        
        guard let _ = user else {
            return
        }
        
        if button.state == CheckboxState.selected {
            
            user?.isSelected = true
            
            let contains = selectedUsers.contains(where: { (u) -> Bool in
                u.uuid == user?.uuid
            })
            
            if !contains {
                self.selectedUsers.append(user!)
            }
        } else {
            
            user?.isSelected = false
            
            guard let index = selectedUsers.index(where: { (u) -> Bool in
                u.uuid == user!.uuid
            }) else {
                return
            }
            
            self.selectedUsers.remove(at: index)
        }
        
        let title = selectedUsers.count > 1 ? "\(selectedUsers.count) Followers Selected" : "\(selectedUsers.count) Follower Selected"
        self.title = title
    }
}

// MARK: - UISearchBarDelegate

extension InviteUserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filterUsers(searchText)
        }
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func filterUsers(_ searchText: String) {
        filteredUsers = users.filter({ (user: User) -> Bool in
            let userNameMatch = user.fullName!.range(of: searchText,
                                                     options: NSString.CompareOptions.caseInsensitive)
            return userNameMatch != nil
        })
    }
}

// MARK: - InviteUserTableViewCellDelegate

extension InviteUserViewController: InviteUserTableViewCellDelegate {
    func inviteUserTableViewCellDidTapAvatarImage(_ cell: InviteUserTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let user: User?
        
        if isSearching {
            if indexPath.row >= filteredUsers.count {
                return
            }
            
            user = filteredUsers[indexPath.row]
        } else {
            if indexPath.row >= users.count {
                return
            }
            
            user = users[indexPath.row]
        }
        
        guard let _ = user else {
            return
        }
        
        let viewController = ProfileViewController(withUser: user!)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - InviteUserViewController

protocol InviteUserViewControllerDelegate: NSObjectProtocol {
    func inviteUserViewController(_ controller: InviteUserViewController,
                                  withSelectedUsers users: [User])
}
