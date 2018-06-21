//
//  AuthManager.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 4.03.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging

let UserAuthenticationNotification    = "UserAuthenticationNotification"
let UserLogoutNotification            = "UserLogoutNotification"

let AuthenticatedUserKey              = "AuthenticatedUser"

class AuthManager {
    static let sharedManager = AuthManager()
    
    let auth: Auth
    
    // MARK: - Constructors
    
    init() {
        auth = Auth.auth()
    }
    
    // MARK: - Functions
    
    func login(_ email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                
                completion(error)
                
                return
            }
            
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            guard let fcmToken = Messaging.messaging().fcmToken else {
                return
            }
            
            DatabaseManager.sharedManager.updateFcmToken(uid, token: fcmToken, completion: { (error) in
                DatabaseManager.sharedManager.getUserWith(uid, completion: { (user, error) in
                    if let error = error {
                        
                        completion(error)
                        
                        return
                    }
                    
                    guard let user = user else {
                        return
                    }
                    
                    self.storeAsAuthenticatedUser(user)
                    
                    completion(nil)
                })
            })
        }
    }
    
    func signUp(_ email: String, password: String, user: User, completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { (signedUser, error) in
            if let error = error {
                
                completion(error)
                
                return
            }
            
            guard let uid = signedUser?.uid else {
                return
            }
            
            let user = user
            user.uuid = uid
            
            if let profileImage = user.profileImage {
                StorageManager.sharedManager.uploadProfileImage(profileImage, uid: uid, completion: { (url, error) in
                    if let error = error {
                        
                        completion(error)
                        
                        return
                    }
                    
                    guard let url = url else {
                        return
                    }
                    
                    user.profileImageUrl = url
                    
                    Router.users.reference.updateChildValues([uid: user.dictionaryRepresentation()], withCompletionBlock: { (error, reference) in
                        if let error = error {
                            
                            completion(error)
                            
                            return
                        }
                        
                        self.storeAsAuthenticatedUser(user)
                        
                        completion(nil)
                    })
                })
            } else {
                Router.users.reference.updateChildValues([uid: user.dictionaryRepresentation()], withCompletionBlock: { (error, reference) in
                    if let error = error {
                        
                        completion(error)
                        
                        return
                    }
                    
                    self.storeAsAuthenticatedUser(user)
                    
                    completion(nil)
                })
            }
        }
    }
    
    func connectWithFacebook(_ result: AnyObject, credentials: AuthCredential, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let error = error {
                
                completion(error)
                
                return
            }
            
            guard let authenticatedUser = user else {
                return
            }
            
            let uid = authenticatedUser.uid
            
            Router.user(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                //If user Sign Up before
                if snapshot.hasChildren() {
                    guard let fcmToken = Messaging.messaging().fcmToken else {
                        return
                    }
                    
                    DatabaseManager.sharedManager.updateFcmToken(uid, token: fcmToken, completion: { (error) in
                        DatabaseManager.sharedManager.getUserWith(uid, completion: { (user, error) in
                            if let error = error {
                                
                                completion(error)
                                
                                return
                            }
                            
                            guard let user = user else {
                                return
                            }
                            
                            self.storeAsAuthenticatedUser(user)
                            
                            completion(nil)
                        })
                    })
                } else {
                    let user = User()
                    user.createdTimestamp = Date().timeIntervalSince1970 as NSNumber
                    user.activityCount = 0
                    user.followerCount = 0
                    user.followingCount = 0
                    user.fcmToken = Messaging.messaging().fcmToken
                    user.uuid = uid
                    
                    if let email = result.value(forKey: "email") as? String {
                        user.email = email
                        user.username = email.components(separatedBy: "@")[0]
                    }
                    
                    if let fullName = result.value(forKey: "name") as? String {
                        user.fullName = fullName
                    }
                    
                    let isSilhouette = result.value(forKeyPath: "picture.data.is_silhouette") as? Bool
                    
                    if isSilhouette != nil && isSilhouette == false,
                        let url = result.value(forKeyPath: "picture.data.url") as? String {
                        user.profileImageUrl = url
                    }
                    
                    Router.users.reference.updateChildValues([uid: user.dictionaryRepresentation()], withCompletionBlock: { (error, reference) in
                        if let error = error {
                            
                            completion(error)
                            
                            return
                        }
                        
                        self.storeAsAuthenticatedUser(user)
                        
                        completion(nil)
                    })
                }
            })
        })
    }
    
    func isUsernameAvailable(_ username: String, completion: @escaping(_ isAvailable: Bool) -> Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        Router.users.reference.queryOrdered(byChild: "username").queryStarting(atValue: username).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                var isAvailable = true
                
                for snap in snapshots {
                    if let dict = snap.value as? [String: Any], let name = dict["username"] as? String {
                        if name == username {
                            isAvailable = false
                        }
                    }
                }
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                completion(isAvailable)
            }
        }) { (error) in
            
        }
    }
    
    func hasAuthenticatedUser() -> Bool {
        if getAuthenticatedUser() != nil {
            return true
        }
        
        return false
    }
    
    func getAuthenticatedUser() -> User? {
        if let dictionary = UserDefaults.standard.dictionary(forKey: AuthenticatedUserKey) {
            let authenticatedUser = User(dictionary: dictionary)
            
            return authenticatedUser
        }
        
        return nil
    }
    
    func removeAuthenticatedUser() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: UserLogoutNotification), object: nil)
        }
        
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: AuthenticatedUserKey)
        userDefaults.synchronize()
        
        DatabaseManager.sharedManager.deleteFcmToken(uid) { (error) in
            print("FCM token not deleted!")
        }
        
        do {
            try auth.signOut()
        } catch {
            print(error)
        }
    }
    
    func storeAsAuthenticatedUser(_ user: User) {
        if let _ = Auth.auth().currentUser?.uid {
            let userDefaults = UserDefaults.standard
            userDefaults.set(user.dictionaryRepresentation(), forKey: AuthenticatedUserKey)
            userDefaults.synchronize()
        }
    }
    
    func updateAuthenticatedUser(_ completion: (() -> ())?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        DatabaseManager.sharedManager.getUserWith(uid) { (user, error) in
            guard let user = user else {
                return
            }
            
            self.storeAsAuthenticatedUser(user)
            
            if let completion = completion {
                completion()
            }
        }
    }
}
