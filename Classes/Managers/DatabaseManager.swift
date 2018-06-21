//
//  DatabaseManager.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 4.03.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import GeoFire

class DatabaseManager {
    
    // MARK: - Singleton
    
    static let sharedManager = DatabaseManager()
    
    // MARK: - User
    
    func getUserWith(_ uid: String, completion: @escaping (_ user: User?, _ error: Error?) -> Void) {
        
        showApplicationNetworkActivityIndicator()
        
        Router.user(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let user = User(snapshot: snapshot)
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(user, nil)
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    func getTopUsers(completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User]! = []
        
        showApplicationNetworkActivityIndicator()
        
        Router.topUsers.reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                users = []
                
                for snapshot in snapshotArray {
                    let key = snapshot.key
                    
                    self.getUserWith(key, completion: { (user, error) in
                        if let error = error {
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(nil, error)
                            
                            return
                        }
                        
                        users.append(user!)
                        
                        if snapshot == snapshotArray.last {
                            users = users.sorted {
                                $0.fullName! < $1.fullName!
                            }
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(users, nil)
                        }
                    })
                }
            }
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    func getNewestUsers(completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User] = []
        
        showApplicationNetworkActivityIndicator()
        
        Router.users.reference.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                users = []
                
                for snapshot in snapshotArray {
                    users.append(User(snapshot: snapshot))
                }
                
                users = users.reversed()
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil)
            }
            
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    func getAllUsers(_ selectedUsers: [User], completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User] = []
        
        showApplicationNetworkActivityIndicator()
        
        Router.users.reference.queryOrdered(byChild: "fullName").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                users = []
                
                for snapshot in snapshotArray {
                    let user = User(snapshot: snapshot)
                    
                    let contains = selectedUsers.contains(where: { (u) -> Bool in
                        u.uuid == user.uuid
                    })
                    
                    user.isSelected = contains == true
                    
                    users.append(user)
                }
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil)
            }
            
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    // MARK: - Search
    
    func deleteSearchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.searches(uid: uid).reference.removeValue()
        
        hideApplicationNetworkActivityIndicator()
    }
    
    func saveSearchHistoryWith(User user: User) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let timestamp: NSNumber = Date().timeIntervalSince1970 as NSNumber
        let dictionary = ["timestamp": timestamp]
        
        showApplicationNetworkActivityIndicator()
        
        Router.searches(uid: uid).reference.child(user.uuid!).updateChildValues(dictionary)
        
        hideApplicationNetworkActivityIndicator()
    }
    
    func getSearchHistory(completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User]! = []
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.searches(uid: uid).reference.queryOrdered(byChild: "timestamp").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                users = []
                
                if snapshotArray.count == 0 {
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(users, nil)
                    
                    return
                }
                
                for snapshot in snapshotArray.reversed() {
                    let key = snapshot.key
                    
                    self.getUserWith(key, completion: { (user, error) in
                        if let error = error {
                            
                            completion(nil, error)
                            
                            return
                        }
                        
                        users.append(user!)
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(users, nil)
                    })
                }
            }
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    func getSearchResult(_ text: String, completion: @escaping (_ users: [User]?,_ error: Error?) -> Void) {
        var users: [User]! = []
        
        showApplicationNetworkActivityIndicator()
        
        Router.users.reference.queryOrdered(byChild: "fullName").queryStarting(atValue: text).queryEnding(atValue: "\(text)\u{f8ff}").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                users = []
                
                for snapshot in snapshotArray {
                    
                    users.append(User(snapshot: snapshot))
                }
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil)
            }
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    // MARK: - Follow/Unfollow
    
    func isFollowing(_ uid: String, completion: @escaping (_ isFollowing: Bool) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.followings(uid: authenticatedUserUid).reference.child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            if let isFollowing = snapshot.value as? Bool, isFollowing == true {
                
                completion(true)
                
                return
            }
            
            completion(false)
        })
    }
    
    func follow(_ uid: String, completion: @escaping(_ error: Error?) -> ()) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Router.BaseDatabaseReference
        
        let values = ["Following/\(authenticatedUserUid)/\(uid)": true, "Follower/\(uid)/\(authenticatedUserUid)": true]
        
        showApplicationNetworkActivityIndicator()
        
        reference.updateChildValues(values) { (error, reference) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            if let error = error {
                completion(error)
                
                return
            }
            
            self.updateFollowerFollowingCount(uid, completion: { (error) in
                completion(error)
            })
        }
    }
    
    func unfollow(_ uid: String, completion: @escaping(_ error: Error?) -> ()) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let reference = Router.BaseDatabaseReference
        
        // I used NSNull() to remove yellow warning!
        let values: [String: Any] = ["Following/\(authenticatedUserUid)/\(uid)": NSNull(), "Follower/\(uid)/\(authenticatedUserUid)": NSNull()]
        
        showApplicationNetworkActivityIndicator()
        
        reference.updateChildValues(values) { (error, reference) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            if let error = error {
                completion(error)
                
                return
            }
            
            self.updateFollowerFollowingCount(uid, completion: { (error) in
                completion(error)
            })
        }
    }
    
    func getFollowersCount(_ uid: String, _ completion: @escaping(_ followerCount: Int?) -> Void) {
        showApplicationNetworkActivityIndicator()
        
        Router.followers(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(Int(snapshot.childrenCount))
        })
    }
    
    func getFollowingsCount(_ uid: String, _ completion: @escaping(_ followingCount: Int?) -> Void) {
        
        showApplicationNetworkActivityIndicator()
        
        Router.followings(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(Int(snapshot.childrenCount))
        })
    }
    
    fileprivate func updateFollowerFollowingCount(_ uid: String, completion: @escaping (_ error: Error?) -> Void) {
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.followings(uid: authenticatedUserUid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let currentFollowingCount = snapshot.childrenCount
            
            Router.followers(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                let currentFollowerCount = snapshot.childrenCount
                
                let values = ["Users/\(uid)/followerCount": currentFollowerCount, "Users/\(authenticatedUserUid)/followingCount": currentFollowingCount]
                
                Router.BaseDatabaseReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                    AuthManager().updateAuthenticatedUser(nil)
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(error)
                })
                
            })
        })
    }
    
    func getFollowings(_ uid: String,
                       parameter: String?,
                       completion: @escaping (_ users: [User]?, _ error: Error?, _ parameter: String?) -> Void) {
        
        let reference = Router.followings(uid: uid).reference
        
        var paginationParameter: String?
        var users: [User] = []
        
        var query = reference.queryOrderedByKey()
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter).queryLimited(toLast: 16)
        } else {
            query = query.queryLimited(toLast: 15)
        }
        
        showApplicationNetworkActivityIndicator()
        
        query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            snapshotArray.reverse()
            
            if parameter != nil && snapshotArray.count < 16 {
                paginationParameter = nil
            } else if snapshotArray.count < 15 {
                paginationParameter = nil
            }
            
            if snapshotArray.count > 0  && parameter != nil {
                snapshotArray.removeFirst()
            }
            
            if snapshotArray.count == 0 {
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil, paginationParameter)
            }
            
            for snapshot in snapshotArray {
                let key = snapshot.key
                
                self.getUserWith(key, completion: { (user, error) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, error, paginationParameter)
                        
                        return
                    }
                    
                    users.append(user!)
                    
                    if users.count == snapshotArray.count {
                        paginationParameter = snapshotArray.last?.key
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(users, nil, paginationParameter)
                    }
                })
            }
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error, paginationParameter)
        }
    }
    
    func getAllFollowersOfAuthenticatedUser(_ selectedUsers: [User], completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User] = []
        
        showApplicationNetworkActivityIndicator()
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Router.followers(uid: authenticatedUserUid).reference.queryOrdered(byChild: "fullName").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                
                if snapshotArray.count == 0 {
                    completion(users, nil)
                    self.hideApplicationNetworkActivityIndicator()
                }
                
                for snapshot in snapshotArray {
                    let key = snapshot.key
                    
                    self.getUserWith(key, completion: { (user, error) in
                        if let error = error {
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(nil, error)
                            
                            return
                        }
                        
                        let contains = selectedUsers.contains(where: { (u) -> Bool in
                            u.uuid == user?.uuid
                        })
                        
                        user?.isSelected = contains == true
                        
                        users.append(user!)
                        
                        if users.count == snapshotArray.count {
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(users, nil)
                        }
                    })
                }
            }
        }) { (error) in
            completion(nil, error)
            
            self.hideApplicationNetworkActivityIndicator()
        }
    }
    
    func getFollowers(_ uid: String,
                      parameter: String?,
                      completion: @escaping (_ users: [User]?, _ error: Error?, _ parameter: String?) -> Void) {
        
        let reference = Router.followers(uid: uid).reference
        
        var paginationParameter: String?
        var users: [User] = []
        
        var query = reference.queryOrderedByKey()
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter).queryLimited(toLast: 16)
        } else {
            query = query.queryLimited(toLast: 15)
        }
        
        showApplicationNetworkActivityIndicator()
        
        query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            snapshotArray.reverse()
            
            if parameter != nil && snapshotArray.count < 16 {
                paginationParameter = nil
            } else if snapshotArray.count < 15 {
                paginationParameter = nil
            }
            
            if snapshotArray.count > 0  && parameter != nil {
                snapshotArray.removeFirst()
            }
            
            if snapshotArray.count == 0 {
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil, paginationParameter)
            }
            
            for snapshot in snapshotArray {
                let key = snapshot.key
                
                self.getUserWith(key, completion: { (user, error) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, error, paginationParameter)
                        
                        return
                    }
                    
                    users.append(user!)
                    
                    if users.count == snapshotArray.count {
                        paginationParameter = snapshotArray.last?.key
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(users, nil, paginationParameter)
                    }
                })
            }
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error, paginationParameter)
        }
    }
    
    // MARK: - Profile
    
    func updateProfile(_ dictionary: [String : [String : AnyObject]], completion: @escaping (_ error: Error?) -> Void) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        if let email = dictionary[uid]?["email"] as? String {
            Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
                if error != nil {
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(error)
                    
                    return
                }
                
                Router.users.reference.updateChildValues(dictionary, withCompletionBlock: { (error, reference) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error)
                        
                        return
                    }
                    
                    AuthManager().updateAuthenticatedUser(nil)
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(nil)
                })
            })
        }
    }
    
    func getActivitiesOfUser(_ uid: String,
                             parameter: Double?,
                             completion: @escaping (_ user: [Activity]?, _ error: Error?, _ parameter: Double?) -> Void) {
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Router.userActivities(uid: uid).reference
        
        var paginationParameter: Double?
        var activities: [Activity] = []
        var query = reference.queryOrdered(byChild: "createdTimestamp")
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter).queryLimited(toLast: 5)
        } else {
            query = query.queryLimited(toLast: 4)
        }
        
        showApplicationNetworkActivityIndicator()
        
        self.getUserWith(uid) { (user, error) in
            if let error = error {
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, error, nil)
                
                return
            }
            
            query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                snapshotArray.reverse()
                
                if parameter != nil && snapshotArray.count < 5 {
                    paginationParameter = nil
                } else if snapshotArray.count < 4 {
                    paginationParameter = nil
                }
                
                if snapshotArray.count > 0  && parameter != nil {
                    snapshotArray.removeFirst()
                }
                
                if snapshotArray.count == 0 {
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(activities, nil, paginationParameter)
                }
                
                for snapshot in snapshotArray {
                    self.isParticipated(snapshot.key, completion: { (isParticipated) in
                        let activity = Activity(snapshot: snapshot)
                        activity.user = user
                        activity.isOwnActivity = uid == authenticatedUserUid
                        activity.isParticipated = isParticipated
                        activities.append(activity)
                        
                        if snapshot == snapshotArray.last {
                            paginationParameter = activities.last?.createdTimestamp
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(activities, nil, paginationParameter)
                        }
                    })
                }
            }) { (error) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, error, nil)
            }
        }
    }
    
    // MARK: - Activity
    
    func getActivityCount(_ uid: String, _ completion: @escaping(_ followerCount: Int?) -> Void) {
        
        showApplicationNetworkActivityIndicator()
        
        Router.userActivities(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(Int(snapshot.childrenCount))
        })
    }
    
    func createPrivateActivity(_ selectedUsers: [User], dictionary: [String: AnyObject], _ completion: @escaping (_ error: Error?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let activityIdentifier = Router.BaseDatabaseReference.childByAutoId().key
        
        var values = [String: Any]()
        var dict = dictionary
        
        var users = [String: Any]()
        
        for user in selectedUsers {
            values["UsersPrivateActivities/\(user.uuid!)/\(activityIdentifier)"] = true
            users["\(user.uuid!)"] = true as AnyObject
        }
        
        dict["InvitedUsers"] = users as AnyObject
        
        values["AllActivities/\(activityIdentifier)"] = dict
        values["UsersPrivateActivities/\(authenticatedUserUid)/\(activityIdentifier)"] = true
        
        showApplicationNetworkActivityIndicator()
        
        Router.BaseDatabaseReference.updateChildValues(values) { (error, reference) in
            if let error = error {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error)
                
                return
            }
            
            self.updateActivityCount(authenticatedUserUid, completion: { (error) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                if let error = error {
                    
                    completion(error)
                    
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    func createPublicActivity(_ dictionary: [String: AnyObject], _ completion: @escaping (_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let activityIdentifier = Router.BaseDatabaseReference.childByAutoId().key
        
        let values = ["AllActivities/\(activityIdentifier)": dictionary, "UserActivities/\(uid)/\(activityIdentifier)": dictionary]
        
        if let latitude = dictionary["latitude"] as? Double, let longitude = dictionary["longitude"] as? Double {
            let geoFire = GeoFire(firebaseRef: Router.nearMe.reference)
            geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: activityIdentifier)
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.BaseDatabaseReference.updateChildValues(values) { (error, reference) in
            if let error = error {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error)
                
                return
            }
            
            self.updateActivityCount(uid, completion: { (error) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                if let error = error {
                    
                    completion(error)
                    
                    return
                }
                
                completion(nil)
            })
        }
    }
    
    fileprivate func updateActivityCount(_ uid :String, completion: @escaping (_ error: Error?) -> Void) {
        
        showApplicationNetworkActivityIndicator()
        
        Router.userActivities(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let currentActivityCount = snapshot.childrenCount
            
            let values = ["activityCount": currentActivityCount]
            
            Router.user(uid: uid).reference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                if let error = error {
                    
                    completion(error)
                    
                    return
                }
                
                AuthManager().updateAuthenticatedUser(nil)
                
                completion(nil)
            })
        })
    }
    
    func deleteActivity(_ identifier: String, completion: @escaping(_ error: Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.getActivity(identifier) { (error, activity) in
            if let error = error {
                completion(error)
                
                return
            }
            
            guard let activity = activity else {
                return
            }
            
            var values = ["UserActivities/\(uid)/\(identifier)": NSNull(),
                          "AllActivities/\(identifier)": NSNull(),
                          "NearMe/\(identifier)": NSNull(),
                          "Comment/\(identifier)": NSNull()]
            
            if let invitedUsers = activity.invitedUsers {
                for user in invitedUsers {
                    values["UsersPrivateActivities/\(user.key)/\(identifier)"] = NSNull()
                }
                
                values["UsersPrivateActivities/\(uid)/\(identifier)"] = NSNull()
            }
            
            self.showApplicationNetworkActivityIndicator()
            
            Router.BaseDatabaseReference.updateChildValues(values) { (error, reference) in
                if let error = error {
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(error)
                    
                    return
                }
                
                self.updateActivityCount(uid, completion: { (error) in
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(error)
                })
            }
        }
    }
    
    func getActivitiesOfUser(_ uid: String,
                             completion: @escaping (_ user: [Activity]?, _ error: Error?) -> Void) {
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        var activities: [Activity] = []
        
        self.getUserWith(uid) { (user, error) in
            if error == nil {
                
                self.showApplicationNetworkActivityIndicator()
                
                Router.userActivities(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                        activities = []
                        
                        if snapshotArray.count == 0 {
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(activities, nil)
                        }
                        
                        for snapshot in snapshotArray {
                            self.isParticipated(snapshot.key, completion: { (isParticipated) in
                                let activity = Activity(snapshot: snapshot)
                                activity.identifier = snapshot.key
                                activity.user = user
                                activity.isOwnActivity = uid == authenticatedUserUid
                                
                                activity.isParticipated = isParticipated
                                
                                activities.append(activity)
                                
                                if activities.count == snapshotArray.count {
                                    activities.sort(by: { (p1, p2) -> Bool in
                                        return p1.createdTimestamp! > p2.createdTimestamp!
                                    })
                                    
                                    self.hideApplicationNetworkActivityIndicator()
                                    
                                    completion(activities, nil)
                                }
                            })
                        }
                    }
                }) { (error) in
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(nil, error)
                }
            } else {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, error)
            }
        }
    }
    
    func getActivityOfUser(_ uid: String, activityIdentifier: String, completion: @escaping(_ error: Error?, _ activity: Activity?) -> Void) {
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Router.activity(identifier: activityIdentifier).reference.observeSingleEvent(of: DataEventType.value, with: {snapshot in
            
            if snapshot.hasChildren() {
                self.getUserWith(uid) { (user, error) in
                    if let error = error {
                        completion(error, nil)
                        
                        return
                    }
                    
                    self.showApplicationNetworkActivityIndicator()
                    
                    Router.activity(identifier: activityIdentifier).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                        
                        let activity = Activity(snapshot: snapshot)
                        activity.user = user
                        activity.isOwnActivity = authenticatedUserUid == uid
                        
                        self.isParticipated(activity.identifier!, completion: { (isParticipated) in
                            activity.isParticipated = isParticipated
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(nil, activity)
                        })
                    }) { (error) in
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error, nil)
                    }
                }
            } else {
                let error = NSError.inlineErrorWith(Code: ErrorCode.unknownError.rawValue, andMessage: "Activity not found!")
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error as Error, nil)
            }
        })
    }
    
    // MARK: - Comment
    
    func createComment(_ dictionary: [String: AnyObject], activity: Activity, completion: @escaping (_ error: Error?) -> Void) {
        guard let activityIdentifier = activity.identifier else {
            return
        }
        
        guard let user = activity.user, let uid = user.uuid else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.activity(identifier: activityIdentifier).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.hasChildren() {
                Router.comment(identifier: activityIdentifier).reference.childByAutoId().updateChildValues(dictionary) { (error, reference) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error)
                        
                        return
                    }
                    
                    self.updateCommentCount(uid, activity: activity, completion: { (error) in
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error)
                    })
                }
            } else {
                let error = NSError.inlineErrorWith(Code: ErrorCode.notFound.rawValue, andMessage: "Activity not found!")
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error as Error)
            }
        })
    }
    
    func deleteComment(_ activity: Activity, commentIdentifier: String, completion: @escaping (_ error: Error?) -> Void) {
        guard let activityIdentifier = activity.identifier else {
            return
        }
        
        guard let user = activity.user, let uid = user.uuid else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        let reference = Router.comment(identifier: activityIdentifier).reference
        
        reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if snapshot.hasChild(commentIdentifier) {
                reference.child(commentIdentifier).removeValue { (error, reference) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error)
                        
                        return
                    }
                    
                    self.updateCommentCount(uid, activity: activity, completion: { (error) in
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(error)
                    })
                }
            } else {
                let error = NSError.inlineErrorWith(Code: ErrorCode.notFound.rawValue, andMessage: "Comment/Activity not found!")
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error)
            }
        })
    }
    
    fileprivate func updateCommentCount(_ uid :String, activity: Activity, completion: @escaping (_ error: Error?) -> Void) {
        guard let activityIdentifier = activity.identifier else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.comment(identifier: activityIdentifier).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let currentCommentCount = snapshot.childrenCount
            
            var values = ["AllActivities/\(activityIdentifier)/commentCount": currentCommentCount ]
            
            if activity.isPrivate == false {
                values["UserActivities/\(uid)/\(activityIdentifier)/commentCount"] = currentCommentCount
            }
            
            Router.BaseDatabaseReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error)
            })
        })
    }
    
    // MARK: - Feed
    
    func getLatestActivities(_ parameter: String?, completion: @escaping (_ error: Error?, _ activities: [Activity]?, _ parameter: String?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Router.allActivities.reference
        
        var paginationParameter: String?
        var activities: [Activity] = []
        
        var identifiers = [String]()
        
        var query = reference.queryOrderedByKey()
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter)
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.followings(uid: authenticatedUserUid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                
                var followingUids = Set<String>()
                followingUids.insert(authenticatedUserUid)
                
                for snapshot in snapshotArray {
                    followingUids.insert(snapshot.key)
                }
                
                query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    snapshotArray.reverse()
                    
                    if parameter != nil && snapshotArray.count < 6 {
                        paginationParameter = nil
                    } else if snapshotArray.count < 5 {
                        paginationParameter = nil
                    }
                    
                    if snapshotArray.count > 0  && parameter != nil {
                        snapshotArray.removeFirst()
                    }
                    
                    if snapshotArray.count == 0 {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, activities, paginationParameter)
                        
                        return
                    }
                    
                    for snapshot in snapshotArray {
                        
                        guard let dict = snapshot.value as? [String: Any] else {
                            return
                        }
                        
                        guard let uid = dict["uuid"] as? String else {
                            return
                        }
                        
                        guard let isPrivate = dict["isPrivate"] as? Bool else {
                            return
                        }
                        
                        if followingUids.contains(uid) && isPrivate == false {
                            
                            if identifiers.count <= 4 {
                                identifiers.append(snapshot.key)
                            }
                        }
                        
                        if (snapshotArray.count <= 5 && snapshotArray.count == identifiers.count) || (identifiers.count == 5) {
                            break
                        }
                    }
                    
                    if identifiers.count == 0 {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, activities, paginationParameter)
                        
                        return
                    }
                    
                    for identifier in identifiers {
                        self.getActivity(identifier, completion: { (error, activity) in
                            if let error = error {
                                
                                self.hideApplicationNetworkActivityIndicator()
                                
                                completion(error, nil, paginationParameter)
                                
                                return
                            }
                            
                            activities.append(activity!)
                            
                            if identifiers.count == activities.count {
                                
                                activities.sort(by: { (p1, p2) -> Bool in
                                    return p1.createdTimestamp! > p2.createdTimestamp!
                                })
                                
                                paginationParameter = identifiers.last
                                
                                self.hideApplicationNetworkActivityIndicator()
                                
                                completion(nil, activities, paginationParameter)
                            }
                        })
                    }
                }, withCancel: { (error) in
                    self.hideApplicationNetworkActivityIndicator()
                    completion(error, nil, nil)
                })
            }
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            completion(error, nil, nil)
        }
    }
    
    func getDiscoverActivities(_ parameter: String?, completion: @escaping (_ error: Error?, _ activities: [Activity]?, _ parameter: String?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Router.allActivities.reference
        
        var paginationParameter: String?
        var activities: [Activity] = []
        
        var identifiers = [String]()
        
        var query = reference.queryOrderedByKey()
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter)
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.followings(uid: authenticatedUserUid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] {
                
                var followingUids = Set<String>()
                followingUids.insert(authenticatedUserUid)
                
                for snapshot in snapshotArray {
                    followingUids.insert(snapshot.key)
                }
                
                query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
                    
                    snapshotArray.reverse()
                    
                    if parameter != nil && snapshotArray.count < 6 {
                        paginationParameter = nil
                    } else if snapshotArray.count < 5 {
                        paginationParameter = nil
                    }
                    
                    if snapshotArray.count > 0  && parameter != nil {
                        snapshotArray.removeFirst()
                    }
                    
                    if snapshotArray.count == 0 {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, activities, paginationParameter)
                        
                        return
                    }
                    
                    for snapshot in snapshotArray {
                        
                        guard let dict = snapshot.value as? [String: Any] else {
                            return
                        }
                        
                        guard let uid = dict["uuid"] as? String else {
                            return
                        }
                        
                        guard let isPrivate = dict["isPrivate"] as? Bool else {
                            return
                        }
                        
                        if !followingUids.contains(uid) && isPrivate == false {
                            
                            if identifiers.count <= 4 {
                                identifiers.append(snapshot.key)
                            }
                        }
                        
                        if (snapshotArray.count <= 5 && snapshotArray.count == identifiers.count) || (identifiers.count == 5) {
                            break
                        }
                    }
                    
                    if identifiers.count == 0 {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, activities, paginationParameter)
                        
                        return
                    }
                    
                    for identifier in identifiers {
                        self.getActivity(identifier, completion: { (error, activity) in
                            if let error = error {
                                
                                self.hideApplicationNetworkActivityIndicator()
                                
                                completion(error, nil, paginationParameter)
                                
                                return
                            }
                            
                            activities.append(activity!)
                            
                            if identifiers.count == activities.count {
                                
                                activities.sort(by: { (p1, p2) -> Bool in
                                    return p1.createdTimestamp! > p2.createdTimestamp!
                                })
                                
                                paginationParameter = identifiers.last
                                
                                self.hideApplicationNetworkActivityIndicator()
                                
                                completion(nil, activities, paginationParameter)
                            }
                        })
                    }
                }, withCancel: { (error) in
                    self.hideApplicationNetworkActivityIndicator()
                    completion(error, nil, nil)
                })
            }
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            completion(error, nil, nil)
        }
    }
    
    func getPrivateActivities(_ parameter: String?, completion: @escaping (_ error: Error?, _ activities: [Activity]?, _ parameter: String?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let reference = Router.usersPrivateActivities(uid: authenticatedUserUid).reference
        
        var paginationParameter: String?
        var activities: [Activity] = []
        
        var identifiers = [String]()
        
        var query = reference.queryOrderedByKey()
        
        if let parameter = parameter {
            query = query.queryEnding(atValue: parameter)
        }
        
        showApplicationNetworkActivityIndicator()
        
        query.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if !snapshot.hasChildren() {
                completion(nil, activities, nil)
                
                self.hideApplicationNetworkActivityIndicator()
                
                return
            }
            
            guard var snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            snapshotArray.reverse()
            
            if parameter != nil && snapshotArray.count < 6 {
                paginationParameter = nil
            } else if snapshotArray.count < 5 {
                paginationParameter = nil
            }
            
            if snapshotArray.count > 0  && parameter != nil {
                snapshotArray.removeFirst()
            }
            
            if snapshotArray.count == 0 {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, activities, paginationParameter)
                
                return
            }
            
            for snapshot in snapshotArray {
                if identifiers.count <= 4 {
                    identifiers.append(snapshot.key)
                }
                
                if (snapshotArray.count <= 5 && snapshotArray.count == identifiers.count) || (identifiers.count == 5) {
                    break
                }
            }
            
            for identifier in identifiers {
                self.getActivity(identifier, completion: { (error, activity) in
                    if let error = error {
                        
                        completion(error, nil, nil)
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        return
                    }
                    
                    guard let activity = activity else {
                        return
                    }
                    
                    activities.append(activity)
                    
                    if activities.count == identifiers.count {
                        
                        activities.sort(by: { (p1, p2) -> Bool in
                            return p1.createdTimestamp! > p2.createdTimestamp!
                        })
                        
                        completion(nil, activities, identifiers.last!)
                        
                        self.hideApplicationNetworkActivityIndicator()
                    }
                })
            }
        }) { (error) in
            completion(error, nil, nil)
            
            self.hideApplicationNetworkActivityIndicator()
        }
    }
    
    func getActivity(_ identifier: String,
                     completion: @escaping (_ error: Error?, _ activity: Activity?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        let reference = Router.activity(identifier: identifier).reference
        
        reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if snapshot.hasChildren() {
                reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                    
                    guard let dict = snapshot.value as? [String: Any] else {
                        return
                    }
                    
                    guard let uid = dict["uuid"] as? String else {
                        return
                    }
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    self.getUserWith(uid, completion: { (user, error) in
                        if let error = error {
                            completion(error, nil)
                            
                            return
                        }
                        
                        self.isParticipated(snapshot.key, completion: { (isParticipated) in
                            let activity = Activity(snapshot: snapshot)
                            activity.user = user
                            activity.isOwnActivity = uid == authenticatedUserUid
                            activity.isParticipated = isParticipated
                            
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(nil, activity)
                        })
                    })
                }) { (error) in
                    
                    self.hideApplicationNetworkActivityIndicator()
                    
                    completion(error, nil)
                }
            } else {
                let error = NSError.inlineErrorWith(Code: ErrorCode.unknownError.rawValue, andMessage: "Activity not found!")
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(error, nil)
            }
            
        })
    }
    
    // MARK: - Participant
    
    func participate(_ activity: Activity, state: InteractiveActionButtonState, type: InteractiveActionButtonType, completion: @escaping (_ currentParticipantCount: UInt?, _ error: Error?) -> Void) {
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let identifier = activity.identifier else {
            return
        }
        
        guard let uid = activity.user?.uuid else {
            return
        }
        
        let value: Int?
        if state == InteractiveActionButtonState.default {
            value = nil
        } else {
            value = type.hashValue
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.activity(identifier: identifier).reference.observeSingleEvent(of: DataEventType.value, with: { snapshot in
            if snapshot.hasChildren() {
                Router.participant(identifier: identifier).reference.child(authenticatedUserUid).child("type").setValue(value) { (error, reference) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, error)
                        
                        return
                    }
                    
                    self.updateParticipantCount(activity, uid: uid, completion: { (count, error) in
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(count, error)
                    })
                }
            } else {
                let error = NSError.inlineErrorWith(Code: ErrorCode.unknownError.rawValue, andMessage: "Activity not found!")
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, error)
            }
        })
    }
    
    func updateParticipantCount(_ activity: Activity, uid: String, completion: @escaping(_ currentParticipantCount: UInt?, _ error: Error?) -> Void) {
        
        guard let identifier = activity.identifier else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.participant(identifier: identifier).reference.queryOrdered(byChild: "type").queryEqual(toValue: 0).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let currentParticipantCount = snapshot.childrenCount
            
            var values = ["AllActivities/\(identifier)/participantCount": currentParticipantCount]
            
            if activity.isPrivate == false {
                values["UserActivities/\(uid)/\(identifier)/participantCount"] = currentParticipantCount
            }
            
            Router.BaseDatabaseReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(currentParticipantCount, error)
            })
        }) { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        }
    }
    
    func isParticipated(_ identifier: String, completion: @escaping (Int?) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.participant(identifier: identifier).reference.child(authenticatedUserUid).child("type").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            guard let type = snapshot.value as? Int else {
                completion(nil)
                
                return
            }
            
            completion(type)
        })
    }
    
    func getParticipantList(_ identifier: String, type: Int, completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        var users: [User] = []
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.participant(identifier: identifier).reference.queryOrdered(byChild: "type").queryEqual(toValue: type).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            if snapshotArray.count == 0 {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(users, nil)
                
                return
            }
            
            for snapshot in snapshotArray {
                self.getUserWith(snapshot.key, completion: { (user, error) in
                    if let error = error {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(nil, error)
                        
                        return
                    }
                    
                    users.append(user!)
                    
                    if snapshotArray.count == users.count {
                        
                        self.hideApplicationNetworkActivityIndicator()
                        
                        completion(users, nil)
                    }
                })
            }
        }, withCancel: { (error) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(nil, error)
        })
    }
    
    // MARK: - Report
    
    func reportActivity(_ activity: Activity, completion: @escaping (_ error: Error?) -> Void) {
        guard let identifier = activity.identifier else {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let values = [uid: true]
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.reportActivity(identifier: identifier).reference.updateChildValues(values) { (error, reference) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(error)
        }
    }
    
    func reportComment(_ comment: Comment, completion: @escaping (_ error: Error?) -> Void) {
        guard let identifier = comment.identifier else {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let values = [uid: true]
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.reportComment(identifier: identifier).reference.updateChildValues(values) { (error, reference) in
            self.hideApplicationNetworkActivityIndicator()
            
            completion(error)
        }
    }
    
    func reportUser(_ user: User, completion: @escaping (_ error: Error?) -> Void) {
        guard let identifier = user.uuid else {
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let values = [uid: true]
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.reportUser(uid: identifier).reference.updateChildValues(values) { (error, reference) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            completion(error)
        }
    }
    
    // MARK: - FCM Token
    
    func deleteFcmToken(_ uid: String, completion: @escaping( _ error: Error?) -> Void) {
        Router.user(uid: uid).reference.child("fcmToken").removeValue { (error, reference) in
            completion(error)
        }
    }
    
    func updateFcmToken(_ uid: String, token: String, completion: @escaping( _ error: Error?) -> Void) {
        Router.user(uid: uid).reference.child("fcmToken").setValue(token) { (error, reference) in
            completion(error)
        }
    }
    
    // MARK: - Notifications
    
    func getUserNotifications(_ completion: @escaping(_ error: Error?, _ notifications: [RemoteNotification]?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        var notifications = [RemoteNotification]()
        
        self.showApplicationNetworkActivityIndicator()
        
        Router.userNotifications(uid: uid).reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let snapshotArray = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            
            if snapshotArray.count == 0 {
                
                self.hideApplicationNetworkActivityIndicator()
                
                completion(nil, notifications)
                
                return
            }
            
            var count = 0
            
            for snapshot in snapshotArray {
                
                guard let dict = snapshot.value as? [String: Any] else {
                    return
                }
                
                let notification = RemoteNotification(snapshot: snapshot)
                
                if let data = dict["data"] as? [String: Any], let identifier = data["identifier"] as? String {
                    self.getUserWith(identifier, completion: { (user, error) in
                        if let error = error {
                            self.hideApplicationNetworkActivityIndicator()
                            
                            completion(error, nil)
                            
                            return
                        }
                        
                        self.isFollowing(identifier, completion: { (isFollowing) in
                            user?.isFollowing = isFollowing
                            notification.user = user
                            
                            if let username = user?.username {
                                notification.message = username.atPrefixedString() + notification.message!
                            }
                            
                            self.isFollower(identifier, completion: { (isFollower) in
                                count += 1
                                
                                if isFollower == true {
                                    notifications.append(notification)
                                }
                                
                                if count == snapshotArray.count {
                                    self.hideApplicationNetworkActivityIndicator()
                                    
                                    notifications.sort(by: { (p1, p2) -> Bool in
                                        return p1.timestamp! > p2.timestamp!
                                    })
                                    
                                    completion(nil, notifications)
                                }
                            })
                        })
                    })
                }
            }
            
            completion(nil, nil)
        }) { (error) in
            self.hideApplicationNetworkActivityIndicator()
            
            completion(error, nil)
        }
    }
    
    func isFollower(_ uid: String, completion: @escaping (_ isFollower: Bool) -> Void) {
        
        guard let authenticatedUserUid = Auth.auth().currentUser?.uid else {
            return
        }
        
        showApplicationNetworkActivityIndicator()
        
        Router.followers(uid: authenticatedUserUid).reference.child(uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
            self.hideApplicationNetworkActivityIndicator()
            
            if let isFollower = snapshot.value as? Bool, isFollower == true {
                completion(true)
                
                return
            }
            
            completion(false)
        })
    }
    
    // MARK: - Helpers
    
    func showApplicationNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func hideApplicationNetworkActivityIndicator() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
