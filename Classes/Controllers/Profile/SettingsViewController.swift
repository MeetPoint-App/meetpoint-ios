//
//  SettingsViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 22.12.2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import MessageUI
import UserNotifications
import YKPopupDialogView

fileprivate enum Sections {
    case userSettings
    case support
    case documents
    case other
    
    var title: String {
        switch self {
        case .userSettings:
            return "User Settings"
        case .support:
            return "Support"
        case .documents:
            return "Documents"
        case .other:
            return "Other"
        }
    }
    
    var numberOfRows: Int {
        switch self {
        case .userSettings:
            return 4
        case .support:
            return 3
        case .documents:
            return 2
        case .other:
            return 1
        }
    }
    
    var cellTitles: [String] {
        switch self {
        case .userSettings:
            return ["Notification Settings", "Change Geofence Settings", "Change Password", "Edit Profile"]
        case .support:
            return ["Recommend MeetPoint", "Rate on the App Store", "Contact Us"]
        case .documents:
            return ["Terms of Use", "Privacy Policy"]
        case .other:
            return ["Logout"]
        }
    }
    
    var cellAccessoryTypes: [UITableViewCellAccessoryType] {
        switch self {
        case .userSettings:
            return [UITableViewCellAccessoryType.none,
                    UITableViewCellAccessoryType.disclosureIndicator,
                    UITableViewCellAccessoryType.disclosureIndicator,
                    UITableViewCellAccessoryType.disclosureIndicator]
        case .support:
            return [UITableViewCellAccessoryType.none,
                    UITableViewCellAccessoryType.none,
                    UITableViewCellAccessoryType.disclosureIndicator]
        case .documents:
            return [UITableViewCellAccessoryType.disclosureIndicator,
                    UITableViewCellAccessoryType.disclosureIndicator]
        case .other:
            return [UITableViewCellAccessoryType.none]
        }
    }
    
    static let allValues = [userSettings, support, documents, other]
}

class SettingsViewController: BaseViewController {
    
    fileprivate var tableView: UITableView!
    
    fileprivate var allowPushNotification: Bool = false
    
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
        title = "Settings"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        let dnc = NotificationCenter.default
        
        dnc.addObserver(self,
                        selector: #selector(didReceiveApplicationDidBecomeActiveNotification(_:)),
                        name: NSNotification.Name.UIApplicationDidBecomeActive,
                        object: nil)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: view.bounds, style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        tableView.separatorColor = UIColor.listSeparatorColor()
        
        tableView.register(SettingsHeaderView.classForCoder(),
                           forHeaderFooterViewReuseIdentifier: SettingsHeaderViewReuseIdentifier)
        tableView.register(SettingsFooterView.classForCoder(),
                           forHeaderFooterViewReuseIdentifier: SettingsFooterViewReuseIdentifier)
        tableView.register(SettingsTableViewCell.classForCoder(),
                           forCellReuseIdentifier: SettingsTableViewCellReuseIdentifier)
        tableView.register(NotificationSettingsTableViewCell.classForCoder(),
                           forCellReuseIdentifier: NotificationSettingsTableViewCellReuseIdentifier)
        
        view.addSubview(tableView)
        
        
        var insets = tableView.contentInset
        
        insets.bottom = defaultBottomInset()
        
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        
        checkNotificationPermission()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIApplicationDidBecomeActive,
                                                  object: nil)
    }
    
    // MARK: - Interface
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    // MARK: - Helpers
    
    func presentMailComposeViewController() {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["support@meetpointapp.co"])
    
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            self.showPopupWith(Title: "Error", andMessage: "Your email address was not found!")
        }
    }
    
    func open(_ url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                
            })
        } else if UIApplication.shared.openURL(url) {
            
        }
    }
    
    func presentLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure to logout?", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (_) in
            
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            AuthManager().removeAuthenticatedUser()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == UNAuthorizationStatus.authorized) {
                self.allowPushNotification = true
            } else {
                self.allowPushNotification = false
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func presentGeofencePopupDialogView() {
        let popupDialogView = YKPopupDialogView()
        popupDialogView.popupViewWidth = UIScreen.main.bounds.width - 64.0
        
        popupDialogView.closeOnTap = false
        popupDialogView.popupViewInnerPadding = 18.0
        popupDialogView.popupViewCornerRadius = 30
        popupDialogView.buttonAlignment = .horizontal
        popupDialogView.imageSize = CGSize(width: 120.24, height: 104.04)
        popupDialogView.setImage(UIImage(named: "nearMeEmptyStateIcon")!)
        
        let attributedString = NSMutableAttributedString()
        
        attributedString.append(NSAttributedString(string: "Enable geofencing to get instant notifications for activities nearby.",
                                                   attributes: [NSFontAttributeName: UIFont.montserratMediumFont(withSize: 15.0),
                                                                NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()]))
        
        attributedString.append(NSAttributedString(string: "\nYou can always enable/disable geofencing from settings later.",
                                                   attributes: [NSFontAttributeName: UIFont.montserratMediumFont(withSize: 15.0),
                                                                NSForegroundColorAttributeName: UIColor.primaryLightTextColor()]))
        
        popupDialogView.setTitle("Enable Geofencing",
                                 attributes: [NSFontAttributeName: UIFont.montserratSemiboldFont(withSize: 17.0),
                                              NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()])
        
        popupDialogView.setMessage(attributedString)
        
        
        let decideLaterButton = popupDialogView.addButton("Decide Later",
                                                          textColor: UIColor.primaryLightTextColor(),
                                                          backgroundColor: UIColor.clear,
                                                          font: UIFont.montserratMediumFont(withSize: 16.0), cornerRadius: 0)
        decideLaterButton.addTarget(self, action: #selector(decideLaterButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        let enableButton = popupDialogView.addButton("Enable",
                                                     textColor: UIColor.secondaryDarkTextColor(),
                                                     backgroundColor: UIColor.clear,
                                                     font: UIFont.montserratMediumFont(withSize: 16.0), cornerRadius: 0)
        enableButton.contentHorizontalAlignment = .right
        enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        popupDialogView.show(YKPopupDialogAnimationPattern.slideTopBottom)
    }
    
    // MARK: - Actions
    
    func notificationSwitchChanged(_ switchItem: UISwitch) {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func decideLaterButtonTapped(_ sender: YKPopupDialogButton) {
        sender.popupDialogView.hide(YKPopupDialogAnimationPattern.slideTopBottom)
    }
    
    func enableButtonTapped(_ sender: YKPopupDialogButton) {
        //sender.popupDialogView.hide(YKPopupDialogAnimationPattern.zoomInOut)
        // TODO: - Enable/Disable Geofence
    }
    
    // MARK: - Notification
    
    func didReceiveApplicationDidBecomeActiveNotification(_ notification: Notification) {
        checkNotificationPermission()
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {
    // MARK: - Cell
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.allValues[section].numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationSettingsTableViewCellReuseIdentifier,
                                                     for: indexPath) as! NotificationSettingsTableViewCell
            
            
            cell.title = Sections.allValues[indexPath.section].cellTitles[indexPath.row]
            cell.accessoryType = Sections.allValues[indexPath.section].cellAccessoryTypes[indexPath.row]
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.switchItem.addTarget(self,
                                      action: #selector(notificationSwitchChanged(_:)),
                                      for: UIControlEvents.valueChanged)
            
            if self.allowPushNotification == true {
                cell.switchItem.isOn = true
                cell.switchInformation = "On"
            } else {
                cell.switchItem.isOn = false
                cell.switchInformation = "Off"
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCellReuseIdentifier,
                                                     for: indexPath) as! SettingsTableViewCell
            
            
            cell.title = Sections.allValues[indexPath.section].cellTitles[indexPath.row]
            cell.accessoryType = Sections.allValues[indexPath.section].cellAccessoryTypes[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SettingsTableViewCellDefaultHeight
    }
    
    // MARK: - HeaderView
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsHeaderViewReuseIdentifier) as! SettingsHeaderView
        
        headerView.title = Sections.allValues[section].title
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SettingsHeaderViewDefaultHeight
    }
    
    // MARK: - FooterView
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if Sections.allValues[section] == Sections.other {
            return SettingsFooterViewDefaultHeight
        }
        
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if Sections.allValues[section] == Sections.other {
            let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingsFooterViewReuseIdentifier) as! SettingsFooterView
            
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                footerView.title = "All Rights Reserved\nMeetPoint v\(version)"
            }
            
            return footerView
        }
        
        return nil
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = Sections.allValues[indexPath.section]
        
        switch section {
        case .userSettings:
            if indexPath.row == 0 {
                
            } else if indexPath.row == 1 {
                self.presentGeofencePopupDialogView()
            } else if indexPath.row == 2 {
                let viewController = ChangePasswordViewController()
                let navigationController = BaseNavigationController(rootViewController: viewController)
                
                present(navigationController, animated: true, completion: nil)
            } else {
                guard let user = AuthManager().getAuthenticatedUser() else {
                    return
                }
                
                let viewController = EditProfileViewController(withUser: user)
                viewController.delegate = self
                let navigationController = BaseNavigationController(rootViewController: viewController)
                
                present(navigationController, animated: true, completion: nil)
            }
        case .support:
            if indexPath.row == 0 {
                let objectsToShare = ["http://www.meetpointapp.co"]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                activityVC.popoverPresentationController?.sourceView = self.view
                self.present(activityVC, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                if let url = URL(string: "http://itunes.apple.com/us/app/meetpoint-app/id1363547170?mt=8&ign-mpt=uo%3D2") {
                    open(url)
                }
            } else {
                presentMailComposeViewController()
            }
        case .documents:
            let viewController = DocumentsWebViewController(withDocumentType: DocumentType.allValues[indexPath.row])
            let navigationController = BaseNavigationController(rootViewController: viewController)
            
            self.present(navigationController, animated: true, completion: nil)
        case .other:
            presentLogoutAlert()
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileViewControllerDelegate

extension SettingsViewController: EditProfileViewControllerDelegate {
    func editProfileViewControllerDidClose(_ controller: EditProfileViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}
