//
//  SearchResultsViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 29/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher

enum SearchHeaderViewType: Int {
    case recent = 0
    case result
    
    var title: String! {
        switch self {
        case .recent:
            return "Recent Searches"
        case .result:
            return "Search Results"
        }
    }
}

class SearchResultsViewController: BaseTableViewController {
    weak var delegate: SearchResultsViewControllerDelegate!
    
    fileprivate var headerView: SearchHeaderView! = SearchHeaderView()
    
    fileprivate var recentUsers: [User]! = [User]()
    fileprivate var filteredUsers: [User]! = [User]()
    
    fileprivate var isSearching: Bool! = false
    fileprivate var searchText: String!
    fileprivate var informationText: String!
    
    fileprivate var headerViewType: SearchHeaderViewType! = SearchHeaderViewType.recent
    
    // Debounce for search
    fileprivate var pendingRequestWorkItem: DispatchWorkItem?
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    fileprivate func commonInit() {}
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        tableView.register(SearchTableViewCell.classForCoder(), forCellReuseIdentifier: SearchTableViewCellReuseIdentifier)
        tableView.register(SearchHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: SearchHeaderViewReuseIdentifier)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.listSeparatorColor()
        tableView.tableFooterView = UIView()
        
        var insets = contentInset
        insets?.top = defaultTopInset()
        insets?.bottom = defaultBottomInset()
        
        contentInset = insets
        scrollIndicatorInsets = insets
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        loadData()
    }
    
    // MARK: - Load Data
    
    func loadData(){
        if isSearching == true {
            DatabaseManager.sharedManager.getSearchResult(searchText, completion: { (users, error) in
                if error == nil {
                    
                    if let users = users {
                        self.filteredUsers = users
                    }
                    
                    self.tableView.reloadData()
                    
                    if self.filteredUsers.count == 0 {
                        self.informationText = "\"\(self.searchText!)\" not found!"
                    }
                }else {
                    self.showPopupWith(Title: "Error", andMessage: error!.localizedDescription)
                }
            })
        } else {
            DatabaseManager.sharedManager.getSearchHistory { (users, error) in
                if error == nil {
                    
                    if let users = users {
                        self.recentUsers = users
                    }
                    
                    self.tableView.reloadData()
                    
                    if self.recentUsers.count == 0 {
                        self.informationText = "No recent search!"
                    }
                } else {
                    self.showPopupWith(Title: "Error", andMessage: error!.localizedDescription)
                }
            }
        }
    }

    // MARK: - Interface
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    override func defaultTopInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            return 76.0
        }
        
        return 64.0
    }
    
    // MARK: - Configuration
    
    fileprivate func configure(SearchTableViewCell cell: SearchTableViewCell, atIndexPath indexPath: IndexPath) {
        var user: User?
        
        if isSearching == true && filteredUsers.count > 0  {
            user = filteredUsers[indexPath.row]
        }else if isSearching == false && recentUsers.count > 0 {
            user = recentUsers[indexPath.row]
        }
        
        guard let users = user else {
            cell.information = informationText
            cell.shouldShowInfo = true
            
            tableView.allowsSelection = false
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            return
        }
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        tableView.allowsSelection = true
        
        cell.title = users.fullName
        cell.shouldShowInfo = false
        
        cell.avatarImageView.kf.indicatorType = .activity
        
        if let username = users.username {
            cell.subtitle = username.atPrefixedString()
        }
        
        if let urlString = users.profileImageUrl, let url = URL(string: urlString) {
            cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }else {
            cell.avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
        }
    }
    
    func configure(SearchHeaderView headerView: SearchHeaderView) {
        headerView.font = UIFont.montserratMediumFont(withSize: 14.0)
        headerView.type = headerViewType
        
        if (headerViewType == SearchHeaderViewType.recent)  && (recentUsers.count == 0) {
            headerView.hideActionButton = true
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == true{
            return filteredUsers.count > 0 ? filteredUsers.count : 1
        } else {
            return recentUsers.count > 0 ? recentUsers.count : 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCellReuseIdentifier) as! SearchTableViewCell
        
        configure(SearchTableViewCell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTableViewCell.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SearchHeaderViewReuseIdentifier) as! SearchHeaderView
        headerView.delegate = self
        
        configure(SearchHeaderView: headerView)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SearchHeaderViewDefaultHeight
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user: User
        
        if isSearching == true {
            user = filteredUsers[indexPath.row]
        } else {
            user = recentUsers[indexPath.row]
        }
        
        DatabaseManager.sharedManager.saveSearchHistoryWith(User: user)
        
        delegate.searchResultsViewControllerDidTapUser(self, user)
    }
}

extension SearchResultsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
        guard let text = searchController.searchBar.text else {
            return
        }
        
        if text.count > 0 {
            self.headerViewType = SearchHeaderViewType.result
            self.isSearching = true
        }else {
            self.headerViewType = SearchHeaderViewType.recent
            self.isSearching = false
        }
        
        self.searchText = text
        
        // If user typing too fast don't start the network request, only perform a request once the user hasn't typed for 0.25 seconds.
        
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            self?.loadData()
        }
        
        pendingRequestWorkItem = requestWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250) , execute: requestWorkItem)
    }
}

// MARK: - SearchResultsViewControllerDelegate

protocol SearchResultsViewControllerDelegate: NSObjectProtocol {
    func searchResultsViewControllerDidTapUser(_ controller: SearchResultsViewController, _ user: User)
}

// MARK: - SearchHeaderViewDelegate

extension SearchResultsViewController: SearchHeaderViewDelegate {
    func searchHeaderViewDidTapClear(_ view: SearchHeaderView) {
        let alertController = UIAlertController(title: "Clear search history", message: "Are you sure to clear search history?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (_) in
            DatabaseManager.sharedManager.deleteSearchHistory()
            self.loadData()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

