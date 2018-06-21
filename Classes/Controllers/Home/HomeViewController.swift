//
//  HomeViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import CoreLocation
import YKPopupDialogView
import GeoFire
import UserNotifications

fileprivate enum FeedSource: Int {
    case latest
    case discover
    case nearMe
    case `private`
    
    var title: String {
        switch self {
        case .latest:
            return "Latest"
        case .discover:
            return "Discover"
        case .nearMe:
            return "Near Me"
        case .private:
            return "Private"
        }
    }
    
    static let allValues = [latest, discover, nearMe, `private`]
}

class HomeViewController: BaseCollectionViewController {
    
    // MARK: - Variables
    
    fileprivate var activeActivityIndex: Int!
    
    fileprivate var segmentedControl: TabBar!
    
    fileprivate var emptyStateView: EmptyStateView!
    fileprivate var locationPermissionEmptyStateView: EmptyStateView!
    
    fileprivate var currentFeedSource: FeedSource! = FeedSource.latest
    
    fileprivate var latestActivities: [Activity] = []
    fileprivate var discoverActivities: [Activity] = []
    fileprivate var nearMeActivities: [Activity] = []
    fileprivate var privateActivities: [Activity] = []
    
    fileprivate var currentLocationOfUser: CLLocation?
    
    fileprivate var nearMeQueryHandle: UInt?
    
    fileprivate var currentLocationAuthorizationStatus: CLAuthorizationStatus!
    
    fileprivate var paginationParameter: String?
    
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
        title = "MeetPoint"
        
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
                        selector: #selector(didReceiveApplicationDidBecomeActiveNotification(_:)),
                        name: NSNotification.Name.UIApplicationDidBecomeActive,
                        object: nil)
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveUserAuthenticationNotification(_:)),
                        name: NSNotification.Name(rawValue: UserAuthenticationNotification),
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        //layout.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout = layout
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        collectionView.register(ActivityHeaderView.classForCoder(),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: ActivityHeaderViewReuseIdentifier)
        collectionView.register(ActivityFooterView.classForCoder(),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: ActivityFooterViewReuseIdentifier)
        collectionView.register(ActivityCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: ActivityCollectionViewCellReuseIdentifier)
        
        
        segmentedControl = TabBar.newAutoLayout()
        segmentedControl.backgroundColor = UIColor.primaryBackgroundColor()
        segmentedControl.font = UIFont.montserratMediumFont(withSize: 14.0)
        segmentedControl.shouldShowSeparators = false
        segmentedControl.shouldShowShadowOnBottom = true
        segmentedControl.tintColor = UIColor.segmentedControlTintColor()
        segmentedControl.delegate = self
        segmentedControl.dataSource = self
        
        view.addSubview(segmentedControl)
        
        segmentedControl.autoPin(toTopLayoutGuideOf: self, withInset: 0.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: ALEdge.left)
        segmentedControl.autoPinEdge(toSuperviewEdge: ALEdge.right)
        segmentedControl.autoSetDimension(ALDimension.height,
                                          toSize: TabBarDefaultHeight)
        
        
        emptyStateView = EmptyStateView.newAutoLayout()
        emptyStateView.isHidden = true
        emptyStateView.delegate = self
        
        view.addSubview(emptyStateView)
        view.bringSubview(toFront: segmentedControl)
        
        emptyStateView.autoPinEdge(ALEdge.top, to: ALEdge.bottom,
                                   of: segmentedControl, withOffset: 0.0)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        emptyStateView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                   withInset: defaultBottomInset())
        
        
        locationPermissionEmptyStateView = emptyStateView
        
        
        var insets = contentInset
        
        insets?.top = defaultTopInset()
        insets?.bottom = defaultBottomInset()
        
        scrollIndicatorInsets = insets
        contentInset = insets
        
        loadData(withRefresh: true)
        
        
        LocationManager.sharedManager.requestLocationAccessPermission { (granted, error) in
            if granted {
                if self.locationPermissionEmptyStateView.isHidden == false && self.currentFeedSource == FeedSource.nearMe {
                    self.loadData(withRefresh: true)
                }
            }
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let nearMeQueryHandle = nearMeQueryHandle {
            Router.nearMe.reference.removeObserver(withHandle: nearMeQueryHandle)
        }
    }
    
    // MARK: - Interface
    
    override func shouldShowLogoAsTitleView() -> Bool {
        return true
    }
    
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
    
    // MARK: - Helpers
    
    fileprivate func activity(Index index: Int) -> Activity? {
        switch currentFeedSource! {
        case FeedSource.latest:
            if index >= latestActivities.count {
                return nil
            }
            
            return latestActivities[index]
        case FeedSource.discover:
            if index >= discoverActivities.count {
                return nil
            }
            
            return discoverActivities[index]
        case FeedSource.nearMe:
            if index >= nearMeActivities.count {
                return nil
            }
            
            return nearMeActivities[index]
        case FeedSource.private:
            if index >= privateActivities.count {
                return nil
            }
            
            return privateActivities[index]
        }
    }
    
    fileprivate func distanceString(distance: CLLocationDistance) -> String? {
        if distance < 1000 {
            return String(format: "%.1fM", distance)
        }
        
        return String(format: "%.1fKm", (CGFloat(distance) / 1000))
    }
    
    func enableSegmentedControl() {
        segmentedControl.isUserInteractionEnabled = true
        segmentedControl.alpha = 1.0
    }
    
    func disableSegmentedControl() {
        segmentedControl.isUserInteractionEnabled = false
        segmentedControl.alpha = 0.9
    }
    
    // MARK: - Load Data
    
    @discardableResult override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            latestActivities.removeAll()
            discoverActivities.removeAll()
            nearMeActivities.removeAll()
            privateActivities.removeAll()
            
            self.paginationParameter = nil
        }
        
        self.disableSegmentedControl()
        switch currentFeedSource! {
        case .latest:
            DatabaseManager.sharedManager.getLatestActivities(paginationParameter, completion: { (error, activities, parameter) in
                
                self.enableSegmentedControl()
                
                if let error = error {
                    self.finishLoading(withState: ControllerState.error,
                                       andMessage: error.localizedDescription)
                    
                    return
                }
                
                self.paginationParameter = parameter
                
                self.canLoadMore = (self.paginationParameter != nil)
                
                self.latestActivities += activities!
                
                if self.latestActivities.count == 0 {
                    self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                               andMessageTitle: "Nothing here yet!",
                                               andMessageSubtitle: "There is no activity yet.",
                                               andButtonTitle: nil)
                    self.emptyStateView.isHidden = false
                } else {
                    self.emptyStateView.isHidden = true
                }
                
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
                self.endRefreshing()
                self.collectionView.reloadData()
            })
        case .discover:
            DatabaseManager.sharedManager.getDiscoverActivities(paginationParameter, completion: { (error, activities, parameter) in
                
                self.enableSegmentedControl()
                
                if let error = error {
                    self.finishLoading(withState: ControllerState.error,
                                       andMessage: error.localizedDescription)
                    
                    return
                }
                
                self.paginationParameter = parameter
                
                self.canLoadMore = (self.paginationParameter != nil)
                
                self.discoverActivities += activities!
                
                if self.discoverActivities.count == 0 {
                    self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                               andMessageTitle: "Nothing here yet!",
                                               andMessageSubtitle: "There is no activity yet.",
                                               andButtonTitle: nil)
                    self.emptyStateView.isHidden = false
                } else {
                    self.emptyStateView.isHidden = true
                }
                
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
                self.endRefreshing()
                self.collectionView.reloadData()
            })
        case .nearMe:
            LocationManager.sharedManager.requestAuthorizationStatus(completion: { (status) in
                self.currentLocationAuthorizationStatus = status
                if status != CLAuthorizationStatus.authorizedWhenInUse {
                    self.locationPermissionEmptyStateView.update(withImage: UIImage(named: "nearMeEmptyStateIcon"),
                                                                 andMessageTitle: "Enable Location Service",
                                                                 andMessageSubtitle: "'MeetPoint' need to know where you are in order to activate 'Near Me' feature",
                                                                 andButtonTitle: "Enable")
                    
                    self.locationPermissionEmptyStateView.isHidden = false
                    self.finishLoading(withState: ControllerState.none, andMessage: nil)
                    
                    return
                } else {
                    self.locationPermissionEmptyStateView.isHidden = true
                }
                
                LocationManager.sharedManager.requestCurrentLocation(completion: { (location, error) in
                    if let _ = error {
                        // TODO: - Handle Error
                        return
                    }
                    
                    self.currentLocationOfUser = location
                    
                    let geoFire = GeoFire(firebaseRef: Router.nearMe.reference)
                    let query = geoFire.query(at: location!, withRadius: 50)
                    
                    self.nearMeActivities = []
                    var locations: [String: CLLocation] = [:]
                    var activityCount = 0
                    
                    self.nearMeQueryHandle = query.observe(GFEventType.keyEntered, with: { (identifier, location) in
                        self.nearMeActivities = []
                        
                        locations[identifier] = location
                        activityCount += 1
                    })
                    
                    self.enableSegmentedControl()
                    
                    query.observeReady({
                        if activityCount == 0 {
                            self.emptyStateView.update(withImage: UIImage(named: "nearMeEmptyStateIcon"),
                                                       andMessageTitle: "Nothing here yet!",
                                                       andMessageSubtitle: "There is no activity near you.",
                                                       andButtonTitle: nil)
                            self.emptyStateView.isHidden = false
                            
                            self.endRefreshing()
                            self.collectionView.reloadData()
                            self.finishLoading(withState: ControllerState.none, andMessage: nil)
                        } else {
                            self.emptyStateView.isHidden = true
                        }
                        
                        for (identifier, location) in locations {
                            DatabaseManager.sharedManager.getActivity(identifier, completion: { (error, activity) in
                                if let error = error {
                                    self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                                    
                                    return
                                }
                                
                                activity?.location = location
                                self.nearMeActivities.append(activity!)
                                
                                if activityCount == self.nearMeActivities.count {
                                    self.nearMeActivities.sort(by: { (p1, p2) -> Bool in
                                        return p1.createdTimestamp! > p2.createdTimestamp!
                                    })
                                    
                                    self.endRefreshing()
                                    self.collectionView.reloadData()
                                    self.finishLoading(withState: ControllerState.none, andMessage: nil)
                                }
                            })
                        }
                    })
                })
            })
        case .private:
            DatabaseManager.sharedManager.getPrivateActivities(paginationParameter, completion: { (error, activities, parameter) in
                
                self.enableSegmentedControl()
                
                if let error = error {
                    self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                    
                    return
                }
                
                self.paginationParameter = parameter
                
                self.canLoadMore = (self.paginationParameter != nil)
                
                self.privateActivities += activities!
                
                if self.privateActivities.count == 0 {
                    self.emptyStateView.update(withImage: UIImage(named: "generalEmptyStateIcon"),
                                               andMessageTitle: "Nothing here yet!",
                                               andMessageSubtitle: "There is no activity yet.",
                                               andButtonTitle: nil)
                    self.emptyStateView.isHidden = false
                } else {
                    self.emptyStateView.isHidden = true
                }
                
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
                self.endRefreshing()
                self.collectionView.reloadData()
            })
        }
        
        return true
    }
    
    // MARK: - Update
    
    fileprivate func updateFeed(WithSource source: FeedSource) {
        if currentFeedSource != source {
            currentFeedSource = source
            
            self.collectionView.reloadData()
            self.canLoadMore = false
            self.paginationParameter = nil
            self.emptyStateView.isHidden = true
            
            switch currentFeedSource! {
            case .latest:
                if latestActivities.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            case .discover:
                if discoverActivities.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            case .nearMe:
                if nearMeActivities.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            case .private:
                if privateActivities.count == 0 {
                    loadData(withRefresh: true)
                    return
                }
            }
            
            self.finishLoading(withState: ControllerState.none,
                               andMessage: nil)
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Configure
    
    fileprivate func configure(ActivityCollectionViewCell cell: ActivityCollectionViewCell,
                               withIndexPath indexPath: IndexPath) {
        
        guard let activity = self.activity(Index: indexPath.section) else {
            return
        }
        
        if let urlString = activity.coverImageUrl, let url = URL(string: urlString) {
            cell.imageView.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        cell.descriptionLabel.text = activity.description
        cell.locationLabel.title = activity.primaryAddress
        
        if let activityTimestamp = activity.activityTimestamp {
            cell.timeLabel.title = NSDate.dayDifference(activityTimestamp)
        }
        
        if let location = activity.location, let currentLocationOfUser = currentLocationOfUser {
            let distance = currentLocationOfUser.distance(from: location)
            cell.distanceLabel.text = distanceString(distance: distance)
        } else {
            cell.distanceLabel.isHidden = true
        }
        
        if let commentCount = activity.commentCount {
            cell.commentCountLabel.title = "\(commentCount)"
        }
        
        if let participantCount = activity.participantCount, let isPrivate = activity.isPrivate {
            
            let text: String
            
            if isPrivate {
                guard let invitedUsers = activity.invitedUsers else {
                    return
                }
                
                text = "\(participantCount)/\(invitedUsers.count)"
            } else {
                text = "\(participantCount)"
            }
            
            cell.participantCountLabel.title = text
        }
    }
    
    fileprivate func configure(ActivityHeaderView headerView: ActivityHeaderView,
                               withIndexPath indexPath: IndexPath) {
        
        headerView.delegate = self
        headerView.backgroundColor = UIColor.primaryBackgroundColor()
        
        guard let activity = self.activity(Index: indexPath.section) else {
            return
        }
        
        if let user = activity.user {
            
            if let fullName = user.fullName {
                headerView.title = fullName
            }
            
            if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                headerView.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                headerView.imageView.image = UIImage(named: "placeholderAvatarSmall")
            }
        }
        
        if let timestamp = activity.createdTimestamp {
            let date = NSDate(timeIntervalSince1970: timestamp)
            headerView.subtitle = NSDate.timePassedSinceDate(date)
        }
    }
    
    fileprivate func configure(ActivityFooterView footerView: ActivityFooterView,
                               withIndexPath indexPath: IndexPath) {
        footerView.delegate = self
        
        guard let activity = self.activity(Index: indexPath.section), let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        if (activityTimestamp > NSDate().timeIntervalSince1970) && (activity.isOwnActivity == false) {
            footerView.showDetailButton = false
        } else {
            footerView.showDetailButton = true
        }
        
        if activity.isParticipated == 0 {
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.selected
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        } else if activity.isParticipated == 1 {
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.selected
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
        } else {
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        }
        
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        guard let activity = self.activity(Index: indexPath.section) else {
            return
        }
        
        let viewController = ActivityDetailViewController(withActivity: activity)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if #available(iOS 11.0, *) {
            if elementKind == UICollectionElementKindSectionHeader {
                view.layer.zPosition = 0
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        switch currentFeedSource! {
        case .latest:
            return latestActivities.count
        case .discover:
            return discoverActivities.count
        case .nearMe:
            return nearMeActivities.count
        case .private:
            return privateActivities.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCollectionViewCellReuseIdentifier,
                                                      for: indexPath) as! ActivityCollectionViewCell
        
        configure(ActivityCollectionViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: ActivityHeaderViewReuseIdentifier,
                                                                             for: indexPath) as! ActivityHeaderView
            
            configure(ActivityHeaderView: headerView, withIndexPath: indexPath)
            
            return headerView
        } else if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: ActivityFooterViewReuseIdentifier, for: indexPath) as! ActivityFooterView
            
            configure(ActivityFooterView: footerView, withIndexPath: indexPath)
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width,
                      height: ActivityHeaderViewDefaultHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width, height: ActivityFooterViewDefaultHeight)
    }
    
    // MARK: - Action Sheet
    
    fileprivate func presentActionSheetForActivity(_ activity: Activity) {
        
        switch currentFeedSource! {
        case FeedSource.latest:
            guard let index = latestActivities.index(where: {$0.identifier == activity.identifier}) else {
                return
            }
            
            activeActivityIndex = Int(index)
        case FeedSource.discover:
            guard let index = discoverActivities.index(where: {$0.identifier == activity.identifier}) else {
                return
            }
            
            activeActivityIndex = Int(index)
        case FeedSource.nearMe:
            guard let index = nearMeActivities.index(where: {$0.identifier == activity.identifier}) else {
                return
            }
            
            activeActivityIndex = Int(index)
        case FeedSource.private:
            guard let index = privateActivities.index(where: {$0.identifier == activity.identifier}) else {
                return
            }
            
            activeActivityIndex = Int(index)
        }
        
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
    
    // MARK: - Activity Actions
    
    fileprivate func delete(activity: Activity) {
        guard let sectionIndex = activeActivityIndex else {
            return
        }
        
        let alertController = UIAlertController(title: "Are you sure to delete this activity?",
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: UIAlertActionStyle.cancel,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
            
            var activityIdentifier: String?
            
            switch self.currentFeedSource! {
            case FeedSource.latest:
                activityIdentifier = self.latestActivities[sectionIndex].identifier
            case FeedSource.discover:
                activityIdentifier = self.discoverActivities[sectionIndex].identifier
            case FeedSource.nearMe:
                activityIdentifier = self.nearMeActivities[sectionIndex].identifier
            case FeedSource.private:
                activityIdentifier = self.privateActivities[sectionIndex].identifier
            }
            
            if let activityIdentifier = activityIdentifier {
                DatabaseManager.sharedManager.deleteActivity(activityIdentifier, completion: { (error) in
                    if let error = error {
                        self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                        
                        return
                    }
                    
                    self.loadData(withRefresh: true)
                })
            }
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
    
    // MARK: - Notification
    
    func didReceiveFeedUpdateNotification(_ notification: Notification) {
        loadData(withRefresh: true)
    }
    
    func didReceiveLogoutNotification(_ notification: Notification) {
        self.segmentedControl.selectedIndex = 0
        self.currentFeedSource = FeedSource.latest
        
        self.latestActivities    = []
        self.nearMeActivities    = []
        self.privateActivities   = []
        
        self.collectionView.reloadData()
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didReceiveApplicationDidBecomeActiveNotification(_ notification: Notification) {
        if currentFeedSource == FeedSource.nearMe {
            LocationManager.sharedManager.requestAuthorizationStatus(completion: { (status) in
                if status == CLAuthorizationStatus.authorizedWhenInUse && status != self.currentLocationAuthorizationStatus {
                    self.loadData(withRefresh: true)
                }
            })
        }
    }
    
    func didReceiveUserAuthenticationNotification(_ notification: Notification) {
        self.loadData(withRefresh: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width,
                      height: ActivityCollectionViewCell.cellHeight())
    }
}

// MARK: - ActivityHeaderViewDelegate

extension HomeViewController: ActivityHeaderViewDelegate {
    func activityHeaderViewDidTapTitle(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        guard let activity = self.activity(Index: index) else {
            return
        }
        
        if let user = activity.user {
            showProfileViewControllerWith(User: user)
        }
    }
    
    func activityHeaderViewDidTapImageView(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        guard let activity = self.activity(Index: index) else {
            return
        }
        
        if let user = activity.user {
            showProfileViewControllerWith(User: user)
        }
    }
    
    func activityHeaderViewDidTapActionButton(_ headerView: ActivityHeaderView) {
        let index = activityIndex(ofHeaderView: headerView)
        
        guard let activity = self.activity(Index: index) else {
            return
        }
        
        presentActionSheetForActivity(activity)
    }
    
    fileprivate func activityIndex(ofHeaderView headerView: ActivityHeaderView) -> Int {
        var index: Int!
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            
            guard let sectionHeaderView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader,
                                                                           at: indexPath) else {
                                                                            continue
            }
            
            if sectionHeaderView == headerView {
                index = (indexPath as NSIndexPath).section
                
                break
            }
        }
        
        return index
    }
    
    fileprivate func showProfileViewControllerWith(User user: User) {
        let viewController = ProfileViewController(withUser: user)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - TabBarDataSource

extension HomeViewController: TabBarDataSource {
    
    func numberOfTabsInTabBar(_ tabBar: TabBar) -> Int {
        return FeedSource.allValues.count
    }
    
    func tabBar(_ tabBar: TabBar,
                titleColorForState state: TabBarState) -> UIColor? {
        switch state {
        case .default:
            return UIColor.primaryLightTextColor()
        case .selected:
            return UIColor.primaryDarkTextColor()
        }
    }
    
    func tabBar(_ tabBar: TabBar,
                buttonTitleAtIndex index: Int) -> String? {
        return FeedSource.allValues[index].title
    }
    
    func tabBar(_ tabBar: TabBar,
                buttonImageAtIndex index: Int,
                forState state: TabBarState) -> UIImage? {
        return nil
    }
}

// MARK: - TabBarDelegate

extension HomeViewController: TabBarDelegate {
    func tabBarShouldShowSelectionIndicator(_ tabBar: TabBar) -> Bool {
        return true
    }
    
    func tabBar(_ tabBar: TabBar,
                didSelectItemAtIndex index: Int) {
        updateFeed(WithSource: FeedSource.allValues[index])
    }
}

// MARK: - ActivityFooterViewDelegate

extension HomeViewController: ActivityFooterViewDelegate {
    func activityFooterViewDidTapDetailButton(_ footerView: ActivityFooterView, withInteractiveActionButton button: InteractiveActionButton) {
        let index = activityIndex(ofFooterView: footerView)
        
        guard let activity = self.activity(Index: index) else {
            return
        }
        
        let viewController = ActivityDetailViewController(withActivity: activity)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func activityFooterViewDidTapGoingButton(_ footerView: ActivityFooterView,
                                             withInteractiveActionButton button: InteractiveActionButton) {
        let index = activityIndex(ofFooterView: footerView)
        
        guard let activity = self.activity(Index: index), let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            if let error = error {
                LoadingView.stopAnimating {
                    footerView.toggleActionButton(button)
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                }
                
                return
            }
            
            let value: Int?
            if footerView.goingButton.actionButtonState == InteractiveActionButtonState.default {
                value = nil
            } else {
                value = footerView.goingButton.actionButtonType.hashValue
            }
            
            activity.isParticipated = value
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func activityFooterViewDidTapInterestedButton(_ footerView: ActivityFooterView,
                                                  withInteractiveActionButton button: InteractiveActionButton) {
        
        let index = activityIndex(ofFooterView: footerView)
        
        guard let activity = self.activity(Index: index), let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            if let error = error {
                LoadingView.stopAnimating {
                    footerView.toggleActionButton(button)
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                }
                
                return
            }
            
            let value: Int?
            if footerView.interestedButton.actionButtonState == InteractiveActionButtonState.default {
                value = nil
            } else {
                value = footerView.interestedButton.actionButtonType.hashValue
            }
            
            activity.isParticipated = value
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.reloadData()
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
            
            guard let sectionFooterView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter,
                                                                           at: indexPath) else {
                                                                            continue
            }
            
            if sectionFooterView == footerView {
                index = (indexPath as NSIndexPath).section
                
                break
            }
        }
        
        return index
    }
}

// MARK: - EmptyStateViewDelegate

extension HomeViewController: EmptyStateViewDelegate {
    func emptyStateViewDidTapButton(_ view: EmptyStateView) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
