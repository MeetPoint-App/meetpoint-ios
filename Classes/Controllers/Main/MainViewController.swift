//
//  MainViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 11/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import KWTransition

let MainTabBarDefaultHeight: CGFloat = 50.0

enum TabType: Int {
    case home               = 0
    case search             = 1
    case createActivity     = 2
    case notifications      = 3
    case profile            = 4
    
    var selectedAsset: UIImage! {
        switch self {
        case .home:
            return UIImage(named: "iconTabBarHomeSelected")
        case .search:
            return UIImage(named: "iconTabBarSearchSelected")
        case .createActivity:
            return UIImage(named: "iconTabBarCreateActivity")
        case .notifications:
            return UIImage(named: "iconTabBarNotificationsSelected")
        case .profile:
            return UIImage(named: "iconTabBarProfileSelected")
        }
    }
    
    var defaultAsset: UIImage! {
        switch self {
        case .home:
            return UIImage(named: "iconTabBarHome")
        case .search:
            return UIImage(named: "iconTabBarSearch")
        case .createActivity:
            return UIImage(named: "iconTabBarCreateActivity")
        case .notifications:
            return UIImage(named: "iconTabBarNotifications")
        case .profile:
            return UIImage(named: "iconTabBarProfile")
        }
    }
    
    static let allValues = [home, search, createActivity, notifications, profile]
}

class MainViewController: BaseViewController {
    
    fileprivate var transition: KWTransition!
    
    fileprivate var mainTabBar: TabBar!
    
    fileprivate var temporaryBlockerView: UIView!
    
    fileprivate var homeNavigationController: BaseNavigationController!
    fileprivate var searchNavigationController: BaseNavigationController!
    fileprivate var notificationsNavigationController: BaseNavigationController!
    fileprivate var profileNavigationController: BaseNavigationController!
    
    fileprivate lazy var homeViewController: HomeViewController! = {
        [unowned self] in
        
        return HomeViewController()
        }()
    
    fileprivate lazy var searchViewController: SearchViewController! = {
        [unowned self] in
        
        return SearchViewController()
        }()
    
    fileprivate lazy var notificationsViewController: NotificationsViewController! = {
        [unowned self] in
        
        return NotificationsViewController()
        }()
    
    fileprivate lazy var profileViewController: ProfileViewController! = {
        [unowned self] in
        
        return ProfileViewController()
        }()
    
    var activeNavigationController: BaseNavigationController?
    fileprivate var activeTab: TabType?
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    func commonInit() {
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveAuthenticationNotification(_:)),
                        name: NSNotification.Name(rawValue: UserAuthenticationNotification),
                        object: nil)
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveLogoutNotification(_:)),
                        name: NSNotification.Name(rawValue: UserLogoutNotification),
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        transition = KWTransition.manager()
        transition.style = KWTransitionStyle.fadeBackOver
        
        mainTabBar = TabBar.newAutoLayout()
        mainTabBar.clipsToBounds = true
        mainTabBar.backgroundColor = UIColor.black
        mainTabBar.tintColor = UIColor.segmentedControlTintColor()
        mainTabBar.shouldShowShadowOnTop = true
        mainTabBar.delegate = self
        mainTabBar.dataSource = self
        
        view.addSubview(mainTabBar)
        
        mainTabBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.top)
        mainTabBar.autoSetDimension(ALDimension.height, toSize: MainTabBarDefaultHeight)
        
        if AuthManager().hasAuthenticatedUser() {
            updateWith(tabType: TabType.home)
        }else {
            temporaryBlockerView = UIView.newAutoLayout()
            temporaryBlockerView.backgroundColor = UIColor.primaryBackgroundColor()
            
            view.addSubview(temporaryBlockerView)
            
            temporaryBlockerView.autoPinEdgesToSuperviewEdges()
        }
        
        
        // Status Bar Background
        let statusBarBackgroundView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarBackgroundView.backgroundColor = UIColor.primaryBackgroundColor()
        
        view.addSubview(statusBarBackgroundView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if !AuthManager().hasAuthenticatedUser() {
            presentOnboardingViewController()
        }
    }
    
    // MARK: - Activity Creation
    
    @objc fileprivate func createButtonTapped(_ button: UIButton) {
        presentActivityCreation()
    }
    
    fileprivate func presentActivityCreation() {
        let controller = ActivityCreationViewController()
        
        let navigationController = BaseNavigationController(rootViewController: controller)
        navigationController.providesPresentationContextTransitionStyle = true
        navigationController.definesPresentationContext = true
        navigationController.modalPresentationStyle = UIModalPresentationStyle.currentContext
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.transitioningDelegate = self
        
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - OnBoarding
    
    func presentOnboardingViewController() {
        let signInViewController = OnboardingViewController()
        let navigationController = BaseNavigationController(rootViewController: signInViewController)
        
        self.present(navigationController, animated: true) {
            if self.temporaryBlockerView != nil {
                self.temporaryBlockerView.removeFromSuperview()
                
                self.temporaryBlockerView = nil
            }
        }
    }
    
    // MARK: - Notification
    
    func didReceiveAuthenticationNotification(_ notification: Notification) {
        updateWith(tabType: TabType.home)
        mainTabBar.selectedIndex = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    func didReceiveLogoutNotification(_ notification: Notification) {
        
        presentOnboardingViewController()
    }
}

// MARK: - TabBarDelegate

extension MainViewController: TabBarDelegate {
    
    func tabBar(_ tabBar: TabBar, didSelectItemAtIndex index: Int) {
        if let type = TabType(rawValue: index) {
            if type == TabType.createActivity {
                presentActivityCreation()
            }
            else {
                updateWith(tabType: type)
            }
        }
    }
    
    func tabBarShouldShowSelectionIndicator(_ tabBar: TabBar) -> Bool {
        return false
    }
    
    func tabBar(_ tabBar: TabBar, shouldSelectTabAtIndex index: Int) -> Bool {
        return (index != TabType.createActivity.rawValue)
    }
    
    // MARK: - Update
    
    fileprivate func updateWith(tabType type: TabType) {
        
        if type == TabType.createActivity {
            return
        }
        
        if type == activeTab {
            return
        }
        
        if let controller = activeNavigationController {
            controller.view.removeFromSuperview()
            
            controller.removeFromParentViewController()
        }
        
        switch type {
        case .home:
            if homeNavigationController == nil {
                homeNavigationController = BaseNavigationController(rootViewController: homeViewController)
                
            }
            
            view.addSubview(homeNavigationController.view)
            
            homeNavigationController.view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
            
            activeNavigationController = homeNavigationController
            activeTab = TabType.home
        case .search:
            if searchNavigationController == nil {
                searchNavigationController = BaseNavigationController(rootViewController: searchViewController)
            }
            
            view.addSubview(searchNavigationController.view)
            
            searchNavigationController.view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
            
            activeNavigationController = searchNavigationController
            activeTab = TabType.search
        case .notifications:
            if notificationsNavigationController == nil {
                notificationsNavigationController = BaseNavigationController(rootViewController: notificationsViewController)
            }
            view.addSubview(notificationsNavigationController.view)
            
            notificationsNavigationController.view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
            
            activeNavigationController = notificationsNavigationController
            activeTab = TabType.notifications
        case .profile:
            if profileNavigationController == nil {
                profileNavigationController = BaseNavigationController(rootViewController: profileViewController)
                
            }
            
            view.addSubview(profileNavigationController.view)
            
            profileNavigationController.view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero)
            
            activeNavigationController = profileNavigationController
            activeTab = TabType.profile
        default:
            break
        }
        
        addChildViewController(activeNavigationController!)
        
        view.sendSubview(toBack: activeNavigationController!.view)
    }
}

// MARK: - TabBarDataSource

extension MainViewController: TabBarDataSource {
    func numberOfTabsInTabBar(_ tabBar: TabBar) -> Int {
        return TabType.allValues.count
    }
    
    func tabBar(_ tabBar: TabBar, titleColorForState state: TabBarState) -> UIColor? {
        return nil
    }
    
    func tabBar(_ tabBar: TabBar, buttonImageAtIndex index: Int, forState state: TabBarState) -> UIImage? {
        guard let type = TabType(rawValue: index) else {
            return nil
        }
        
        switch state {
        case .default:
            return type.defaultAsset
        case .selected:
            return type.selectedAsset
        }
    }
    
    func tabBar(_ tabBar: TabBar, buttonTitleAtIndex index: Int) -> String? {
        return nil
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transition.action = KWTransitionStep.present
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        self.transition.action = KWTransitionStep.dismiss
        
        return transition
    }
}
