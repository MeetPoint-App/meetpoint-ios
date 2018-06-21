//
//  ProfileViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Firebase
import SimpleImageViewer

fileprivate enum ProfileInformationType: Int {
    case activities = 0
    case followings
    case followers
    
    var title: String! {
        switch self {
        case .activities:
            return "Activities"
        case .followings:
            return "Followings"
        case .followers:
            return "Followers"
        }
    }
    
    static let allValues = [activities, followings, followers]
}

class ProfileViewController: BaseCollectionViewController {
    
    // MARK: - Variables
    
    fileprivate var paginationParameter: Double?
    
    fileprivate var user: User?
    fileprivate var isOwnProfile: Bool! = true
    
    fileprivate var activities: [Activity] = []
    
    fileprivate var userInformationHeaderView: UserInformationHeaderView!

    fileprivate var activeActivityIndex: Int!
    
    fileprivate var totalNumberOfActivities: Int {
        get {
            if isOwnProfile == true {
                if let user = AuthManager().getAuthenticatedUser(), let activityCount = user.activityCount {
                    return activityCount
                }
            } else {
                if let user = user, let activityCount = user.activityCount {
                    return activityCount
                }
            }
            
            return 0
        }
    }
    
    fileprivate var totalNumberOfFollowings: Int {
        get {
            if isOwnProfile == true {
                if let user = AuthManager().getAuthenticatedUser(), let followingCount = user.followingCount {
                    return followingCount
                }
            } else {
                if let user = user, let followingCount = user.followingCount {
                    return followingCount
                }
            }
            
            return 0
        }
    }
    
    fileprivate var totalNumberOfFollowers: Int {
        get {
            if isOwnProfile == true {
                if let user = AuthManager().getAuthenticatedUser(), let followerCount = user.followerCount {
                    return followerCount
                }
            } else {
                if let user = user, let followerCount = user.followerCount {
                    return followerCount
                }
            }
            
            return 0
        }
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    init(withUser user: User) {
        super.init()
        self.user = user
        
        if let uuid = user.uuid {
            if uuid == Auth.auth().currentUser?.uid {
                self.isOwnProfile = true
            } else {
                self.isOwnProfile = false
            }
        }
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        let settingsButton = UIButton(type: UIButtonType.system)
        settingsButton.tintColor = UIColor.defaultTintColor()
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        settingsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        
        if let user = user {
            
            if let username = user.username {
                self.title = username.atPrefixedString()
            }
            
            if self.isOwnProfile == true {
                settingsButton.setImage(UIImage(named: "iconSettings"), for: UIControlState())
            } else {
                settingsButton.setImage(UIImage(named: "iconMore"), for: UIControlState())
            }
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        } else {
            guard let user = AuthManager().getAuthenticatedUser() else {
                return
            }
            
            if let username = user.username {
                self.title = username.atPrefixedString()
            }
            
            settingsButton.setImage(UIImage(named: "iconSettings"), for: UIControlState())
        }
        
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
        
        
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveFeedUpdateNotification(_:)),
                        name: NSNotification.Name(rawValue: FeedUpdateNotification),
                        object: nil)
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveLogoutNotification(_:)),
                        name: NSNotification.Name(rawValue: UserLogoutNotification),
                        object: nil)
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveUserAuthenticationNotification(_:)),
                        name: NSNotification.Name(rawValue: UserAuthenticationNotification),
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        collectionViewLayout = layout
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        collectionView.register(ProfileCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: ProfileCollectionViewCellReuseIdentifier)
        collectionView.register(EmptyStateCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: EmptyStateCollectionViewCellReuseIdentifier)
        collectionView.register(UserInformationHeaderView.classForCoder(),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UserInformationHeaderViewReuseIdentifier)

        var insets = contentInset
        
        insets?.bottom = defaultBottomInset()
        
        scrollIndicatorInsets = insets
        contentInset = insets
        
        
        loadData(withRefresh: true)
    }
    
    // MARK: - Interface
    
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
            activities = []
            self.endRefreshing()
            self.paginationParameter = nil
        }
        
        let uid: String
        if let user = self.user, let uuid = user.uuid {
            uid = uuid
        } else {
            guard let uuid = Auth.auth().currentUser?.uid else {
                return true
            }
            uid = uuid
        }
        
        DatabaseManager.sharedManager.getActivitiesOfUser(uid, parameter: paginationParameter) { (activities, error, parameter) in
            if let error = error {
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                
                return
            }
            
            self.paginationParameter = parameter
            
            self.canLoadMore = (self.paginationParameter != nil)
            
            if let activities = activities {
                self.activities += activities
                
                DatabaseManager.sharedManager.getActivityCount(uid, { (count) in
                    if self.activities.count == count {
                        self.canLoadMore = false
                    }
                })
                
                self.updateUserInformationView({
                    self.finishLoading(withState: ControllerState.none, andMessage: nil)
                    self.collectionView.reloadData()
                })
            }
        }
        
        return true
    }
    
    // MARK: - Update
    
    fileprivate func updateUserInformationView(_ completion: (() -> ())?) {
        
        if isOwnProfile == true {
            AuthManager.sharedManager.updateAuthenticatedUser({
                self.userInformationHeaderView.segmentedControl.reloadData()
                
                if let completion = completion {
                    completion()
                }
            })
        } else {
            guard let user = user else {
                return
            }
            
            DatabaseManager.sharedManager.getUserWith(user.uuid!) { (user, error) in
                if let user = user {
                    self.user = user
                    self.userInformationHeaderView.segmentedControl.reloadData()
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    // MARK: - Configure
    
    fileprivate func configure(UserInformationHeaderView headerView: UserInformationHeaderView,
                               withIndexPath indexPath: IndexPath) {
        headerView.segmentedControl.delegate = self
        headerView.segmentedControl.dataSource = self
        headerView.delegate = self
        
        if isOwnProfile {
            headerView.actionButtonType = ActionButtonType.edit
            
            guard let user = AuthManager().getAuthenticatedUser() else {
                return
            }
            
            if let fullName = user.fullName {
                headerView.title = fullName
            }
            
            if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                headerView.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                headerView.avatarImageView.image = UIImage(named: "placeholderAvatarLarge")
            }
        } else {
            guard let user = user else {
                return
            }
            
            if let fullName = user.fullName {
                headerView.title = fullName
            }
            
            if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                headerView.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                headerView.avatarImageView.image = UIImage(named: "placeholderAvatarLarge")
            }
            
            DatabaseManager.sharedManager.isFollowing(user.uuid!, completion: { (isFollowing) in
                headerView.actionButtonType = isFollowing ? ActionButtonType.following : ActionButtonType.follow
            })
        }
    }
    
    fileprivate func configure(ProfileCollectionViewCell cell: ProfileCollectionViewCell,
                               withIndexPath indexPath: IndexPath) {
        
        if indexPath.item >= activities.count {
            return
        }
        
        let activity = activities[indexPath.item]
        
        cell.activity = activity
        cell.delegate = self
        cell.headerView.delegate = self
        cell.footerView.delegate = self
        
        guard let timestamp = activity.activityTimestamp else {
            return
        }
        
        if (timestamp > NSDate().timeIntervalSince1970) && (activity.isOwnActivity == false) {
            cell.footerView.showDetailButton = false
        } else {
            cell.footerView.showDetailButton = true
        }
        
        if activity.isParticipated == 0 {
            cell.footerView.goingButton.actionButtonState = InteractiveActionButtonState.selected
            cell.footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        } else if activity.isParticipated == 1 {
            cell.footerView.interestedButton.actionButtonState = InteractiveActionButtonState.selected
            cell.footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
        } else {
            cell.footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
            cell.footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        }
    }
    
    // MARK: - Actions
    
    func settingsButtonTapped(_ button: UIButton) {
        if isOwnProfile == true {
            self.navigationController?.pushViewController(SettingsViewController(), animated: true)
        } else {
            self.presentActionSheetForProfile()
        }
    }
    
    func followButtonTapped() {
        guard let user = user else {
            return
        }
        
        self.userInformationHeaderView.actionButtonType = ActionButtonType.following
        
        DatabaseManager.sharedManager.follow(user.uuid!) { (error) in
            if error == nil {
                self.updateUserInformationView(nil)
            }
        }
    }
    
    func unfollowButtonTapped() {
        guard let user = user else {
            return
        }
        
        self.userInformationHeaderView.actionButtonType = ActionButtonType.follow
        
        DatabaseManager.sharedManager.unfollow(user.uuid!) { (error) in
            if error == nil {
                self.updateUserInformationView(nil)
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        //BUG FIX: - ScrollIndicator is not visible on headerView(iOS 11)
        if #available(iOS 11.0, *) {
            if elementKind == UICollectionElementKindSectionHeader {
                view.layer.zPosition = 0
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        
        if activities.count == 0 {
            return 1 // It is for EmptyStateCollectionViewCell
        }
        return activities.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if activities.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCollectionViewCellReuseIdentifier, for: indexPath) as! EmptyStateCollectionViewCell
            cell.emptyStateView.delegate = self
            if isOwnProfile == true {
                cell.emptyStateView.update(withImage: nil, andMessageTitle: "Nothing here yet!", andMessageSubtitle: "Here is what to do now.", andButtonTitle: "CREATE ACTIVITY")
            } else {
                cell.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"), andMessageTitle: "Nothing here yet!", andMessageSubtitle: "There is no activity yet.", andButtonTitle: nil)
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCellReuseIdentifier, for: indexPath) as! ProfileCollectionViewCell
            
            configure(ProfileCollectionViewCell: cell, withIndexPath: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            userInformationHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserInformationHeaderViewReuseIdentifier, for: indexPath) as! UserInformationHeaderView
            
            configure(UserInformationHeaderView: userInformationHeaderView, withIndexPath: indexPath)
            
            return userInformationHeaderView
        }
        
        return UICollectionReusableView()
    }
    
    // MARK: - Action Sheet
    
    fileprivate func presentActionSheetForActivity(_ activity: Activity) {
        
        guard let index = activities.index(where: {$0.identifier == activity.identifier}) else {
            return
        }
        
        activeActivityIndex = Int(index)
        
        let alertController = UIAlertController()
        
        if activity.isOwnActivity == true {
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
                self.delete(activity: activity)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }else {
            alertController.addAction(UIAlertAction(title: "Report Abuse", style: UIAlertActionStyle.default, handler: { (_) in
                self.report(activity: activity)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func presentActionSheetForProfile() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Report Abuse", style: UIAlertActionStyle.default, handler: { (_) in
            
            guard let user = self.user else {
                return
            }
            
            self.report(user: user)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Activity Actions
    
    fileprivate func delete(activity: Activity) {
        guard let identifier = activity.identifier else {
            return
        }
        
        let alertController = UIAlertController(title: "Are you sure to delete this activity?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
            DatabaseManager.sharedManager.deleteActivity(identifier, completion: { (error) in
                if error == nil {
                    self.loadData(withRefresh: true)
                }
            })
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func report(activity: Activity) {
        DatabaseManager.sharedManager.reportActivity(activity) { (error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
            }
            
            self.showPopupWith(Title: "Success",
                               andMessage: "Thanks for reporting this activity. We will examine it.")
        }
    }
    
    fileprivate func report(user: User) {
        DatabaseManager.sharedManager.reportUser(user) { (error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
            }
            
            self.showPopupWith(Title: "Success",
                               andMessage: "Thanks for reporting this user. We will examine it.")
        }
    }
    
    // MARK: - Notification
    
    func didReceiveFeedUpdateNotification(_ notification: Notification) {
        self.loadData(withRefresh: true)
    }
    
    func didReceiveLogoutNotification(_ notification: Notification) {
        self.activities     = []
        self.user           = nil

        self.collectionView.reloadData()
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didReceiveUserAuthenticationNotification(_ notification: Notification) {
        self.loadData(withRefresh: true)
    }
}

// MARK: - ProfileSegmentedControlDelegate

extension ProfileViewController: ProfileSegmentedControlDelegate {
    func profileSegmentedControl(_ segmentedControl: ProfileSegmentedControl,
                                 didSelectSegmentAtIndex index: Int) {
        let user: User
        if isOwnProfile == true {
            user = AuthManager().getAuthenticatedUser()!
        } else {
            user = self.user!
        }
        
        let informationType = ProfileInformationType.allValues[index]
        
        switch informationType {
        case ProfileInformationType.followings:
            let viewController = FollowingsViewController(withUser: user)
            self.navigationController?.pushViewController(viewController, animated: true)
        case ProfileInformationType.followers:
            let viewController = FollowersViewController(withUser: user)
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            break;
        }
    }
}

// MARK: - ProfileSegmentedControlDataSource

extension ProfileViewController: ProfileSegmentedControlDataSource {
    func numberOfSegmentsInProfileSegmentedControl(_ segmentedControl: ProfileSegmentedControl) -> Int {
        return ProfileInformationType.allValues.count
    }
    
    func profileSegmentedControl(_ segmentedControl: ProfileSegmentedControl,
                                 attributedTitleAtIndex index: Int) -> NSAttributedString? {
        let informationType = ProfileInformationType(rawValue: index)
        
        let attributedString = NSMutableAttributedString()
        switch informationType! {
        case .activities:
            attributedString.append(NSAttributedString(string: "\(totalNumberOfActivities)\n",
                attributes: [NSFontAttributeName: UIFont.montserratSemiboldFont(withSize: 15.0),
                             NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()]))
        case .followings:
            attributedString.append(NSAttributedString(string: "\(totalNumberOfFollowings)\n",
                attributes: [NSFontAttributeName: UIFont.montserratSemiboldFont(withSize: 15.0),
                             NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()]))
        case .followers:
            attributedString.append(NSAttributedString(string: "\(totalNumberOfFollowers)\n",
                attributes: [NSFontAttributeName: UIFont.montserratSemiboldFont(withSize: 15.0),
                             NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()]))
        }
        
        attributedString.append(NSAttributedString(string: informationType!.title,
                                                   attributes: [NSFontAttributeName: UIFont.montserratRegularFont(withSize: 15.0),
                                                                NSForegroundColorAttributeName: UIColor.primaryLightTextColor()]))
        
        return attributedString
    }
}

// MARK: - UserInformationHeaderViewDelegate

extension ProfileViewController: UserInformationHeaderViewDelegate {
    func userInformationHeaderViewDidTapActionButton(_ view: UserInformationHeaderView) {
        let actionButtonType = view.actionButtonType
        
        switch actionButtonType! {
        case ActionButtonType.edit:
            guard let user = AuthManager().getAuthenticatedUser() else {
                return
            }
            
            let viewController = EditProfileViewController(withUser: user)
            viewController.delegate = self
            let navigationController = BaseNavigationController(rootViewController: viewController)
            
            present(navigationController, animated: true, completion: nil)
        case ActionButtonType.follow:
            self.followButtonTapped()
        case ActionButtonType.following:
            self.unfollowButtonTapped()
        }
    }
    
    func userInformationHeaderViewDidTapAvatarImageView(_ view: UserInformationHeaderView) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = view.avatarImageView
        }
        
        let imageViewerController = ImageViewerController(configuration: configuration)
        
        present(imageViewerController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 {
            return CGSize(width: view.frame.size.width, height: UserInformationHeaderView.viewHeight())
        }
        
        return CGSize(width: view.frame.size.width, height: ActivityHeaderViewDefaultHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if activities.count == 0 {
            let emptyStateViewHeight = collectionView.frame.height - UserInformationHeaderView.viewHeight() - defaultTopInset() - defaultBottomInset()
            return CGSize(width: view.frame.size.width, height: emptyStateViewHeight)
        }
        
        if indexPath.row >= activities.count {
            return CGSize.zero
        }
        
        let activity = activities[indexPath.row]
        
        return CGSize(width: view.frame.size.width, height: ProfileCollectionViewCell.cellHeight(withActivity: activity))
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {

        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - EmptyStateViewDelegate

extension ProfileViewController: EmptyStateViewDelegate {
    func emptyStateViewDidTapButton(_ view: EmptyStateView) {
        
        let navigationController = BaseNavigationController(rootViewController: ActivityCreationViewController())
        self.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - ActivityHeaderViewDelegate

extension ProfileViewController: ActivityHeaderViewDelegate {
    func activityHeaderViewDidTapTitle(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        if index >= activities.count {
            return
        }
        
        let activity = activities[index]
        
        if let user = activity.user {
            showProfileViewControllerWith(User: user)
        }
    }
    
    func activityHeaderViewDidTapImageView(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        if index >= activities.count {
            return
        }
        
        let activity = activities[index]
        
        if let user = activity.user {
            showProfileViewControllerWith(User: user)
        }
    }
    
    func activityHeaderViewDidTapActionButton(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        if index >= activities.count {
            return
        }
        
        let activity = activities[index]
        
        presentActionSheetForActivity(activity)
    }
    
    fileprivate func activityIndex(ofHeaderView headerView: ActivityHeaderView) -> Int {
        var index: Int!
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            
            let profileCollectionViewCell = cell as! ProfileCollectionViewCell
            
            if profileCollectionViewCell.headerView == headerView {
                index = (indexPath as NSIndexPath).item
                
                break
            }
        }
        
        return index
    }
    
    fileprivate func showProfileViewControllerWith(User user: User) {
        self.navigationController?.pushViewController(ProfileViewController(withUser: user), animated: true)
    }
}

// MARK: - ActivityFooterViewDelegate

extension ProfileViewController: ActivityFooterViewDelegate {
    func activityFooterViewDidTapDetailButton(_ footerView: ActivityFooterView, withInteractiveActionButton button: InteractiveActionButton) {
        let index = activityIndex(ofFooterView: footerView)
        
        if index >= self.activities.count {
            return
        }
        
        let activity = self.activities[index]
        
        let viewController = ActivityDetailViewController(withActivity: activity)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func activityFooterViewDidTapGoingButton(_ footerView: ActivityFooterView,
                                             withInteractiveActionButton button: InteractiveActionButton) {
        
        let index = activityIndex(ofFooterView: footerView)
        
        if index >= self.activities.count {
            return
        }
        
        let activity = self.activities[index]
        
        guard let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        let value: Int?
        if footerView.goingButton.actionButtonState == InteractiveActionButtonState.default {
            value = nil
        } else {
            value = footerView.goingButton.actionButtonType.hashValue
        }
        
        activity.isParticipated = value
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                
                return
            }
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.performBatchUpdates({
                        let indexPath = IndexPath(item: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                    }, completion: nil)
                }
            }
        }
    }
    
    func activityFooterViewDidTapInterestedButton(_ footerView: ActivityFooterView,
                                                  withInteractiveActionButton button: InteractiveActionButton) {
        let index = activityIndex(ofFooterView: footerView)
        
        if index >= self.activities.count {
            return
        }
        
        let activity = self.activities[index]
        
        guard let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        let value: Int?
        if footerView.interestedButton.actionButtonState == InteractiveActionButtonState.default {
            value = nil
        } else {
            value = footerView.interestedButton.actionButtonType.hashValue
        }
        
        activity.isParticipated = value
        
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                
                return
            }
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.performBatchUpdates({
                        let indexPath = IndexPath(item: index, section: 0)
                        self.collectionView.reloadItems(at: [indexPath])
                    }, completion: nil)
                }
            }
        }
    }
    
    fileprivate func activityIndex(ofFooterView footerView: ActivityFooterView) -> Int {
        var index: Int!
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            
            let profileCollectionViewCell = cell as! ProfileCollectionViewCell
            
            if profileCollectionViewCell.footerView == footerView {
                index = (indexPath as NSIndexPath).item
                
                break
            }
        }
        
        return index
    }
}

// MARK: - EditProfileViewControllerDelegate

extension ProfileViewController: EditProfileViewControllerDelegate {
    func editProfileViewControllerDidClose(_ controller: EditProfileViewController) {
        self.loadData(withRefresh: true)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ProfileCollectionViewCellDelegate

extension ProfileViewController: ProfileCollectionViewCellDelegate {
    func profileCollectionViewCellDidTapCoverImage(_ cell: ProfileCollectionViewCell) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.row >= activities.count {
            return
        }
        
        let activity = activities[indexPath.item]
        
        let viewController = ActivityDetailViewController(withActivity: activity)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
