//
//  AppDelegate.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 10/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Fabric
import Crashlytics
import GooglePlaces
import FBSDKLoginKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var mainViewController: MainViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info-Development", ofType: "plist")
        #else
        let firebaseConfig = Bundle.main.path(forResource: "GoogleService-Info-Production", ofType: "plist")
        #endif
        
        guard let options = FirebaseOptions(contentsOfFile: firebaseConfig!) else {
            fatalError("Invalid Firebase configuration file.")
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure(options: options)
        
        Fabric.with([Crashlytics.self])
        
        GMSPlacesClient.provideAPIKey("AIzaSyBdeTAGknbuCB9qazbl-PONTBRmdJvEPgg")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        mainViewController = MainViewController()
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
        
        
        //        let rectShape = CAShapeLayer()
        //        rectShape.bounds = (window?.bounds)!
        //        rectShape.position = (window?.center)!
        //        rectShape.path = UIBezierPath(roundedRect: (window?.bounds)!,
        //                                      byRoundingCorners: [.bottomLeft , .bottomRight , .topLeft, .topRight],
        //                                      cornerRadii: CGSize(width: 12.0, height: 12.0)).cgPath
        //
        //        window?.layer.mask = rectShape
        //
        
        application.applicationIconBadgeNumber = 0
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(app,
                                                                                  open: url,
                                                                                  sourceApplication: options[.sourceApplication] as? String,
                                                                                  annotation: options[.annotation])

        return handled
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        guard let type = userInfo["type"] as? String, let identifier = userInfo["identifier"] as? String else {
            return
        }
        
        var viewControllers = mainViewController.activeNavigationController?.viewControllers
        
        switch type {
        case "user":
            DatabaseManager.sharedManager.getUserWith(identifier, completion: { (user, error) in
                
                guard let user = user else {
                    return
                }
                
                let profileViewController = ProfileViewController(withUser: user)
                viewControllers?.append(profileViewController)
                
                self.mainViewController.activeNavigationController?.setViewControllers(viewControllers!,
                                                                                       animated: true)
                
                completionHandler()
            })
        case "activity":
            DatabaseManager.sharedManager.getActivity(identifier, completion: { (error, activity) in
                guard let activity = activity else {
                    return
                }
                
                let activityDetailViewController = ActivityDetailViewController(withActivity: activity)
                viewControllers?.append(activityDetailViewController)
                
                self.mainViewController.activeNavigationController?.setViewControllers(viewControllers!, animated: true)
                
                completionHandler()
            })
            
        default:
            break
        }
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
}
