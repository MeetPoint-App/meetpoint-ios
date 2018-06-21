//
//  User.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 21/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class User {
    var uuid: String?
    var username: String?
    var fullName: String?
    var email: String?
    var profileImage: UIImage?
    var profileImageUrl: String?
    var createdTimestamp: NSNumber?
    
    var followerCount: Int?
    var followingCount: Int?
    var activityCount: Int?
    
    var isSelected: Bool?
    var isFollowing: Bool?
    var fcmToken: String?
    
    // MARK: - Constructors
    
    init() {
        
    }
    
    init(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else {
            return
        }
        
        self.uuid = snapshot.key
        self.username           = dict["username"] as? String ?? ""
        self.profileImageUrl    = dict["profileImageUrl"] as? String
        self.fullName           = dict["fullName"] as? String ?? ""
        self.email              = dict["email"] as? String ?? ""
        self.followerCount      = dict["followerCount"] as? Int ?? 0
        self.followingCount     = dict["followingCount"] as? Int ?? 0
        self.activityCount      = dict["activityCount"] as? Int ?? 0
        self.fcmToken           = dict["fcmToken"] as? String ?? ""
    }
    
    init(dictionary: [String: Any]) {
        self.uuid               = dictionary["uuid"] as? String
        self.username           = dictionary["username"] as? String
        self.profileImageUrl    = dictionary["profileImageUrl"] as? String
        self.fullName           = dictionary["fullName"] as? String
        self.email              = dictionary["email"] as? String
        self.createdTimestamp   = dictionary["timestamp"] as? NSNumber
        self.followerCount      = dictionary["followerCount"] as? Int
        self.followingCount     = dictionary["followingCount"] as? Int
        self.activityCount      = dictionary["activityCount"] as? Int
        self.fcmToken           = dictionary["fcmToken"] as? String
    }

    // MARK: - Dictionary Representation
    
    func dictionaryRepresentation() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        
        if uuid != nil {
            dictionary["uuid"] = uuid as AnyObject?
        }
        
        if username != nil {
            dictionary["username"] = username as AnyObject?
        }
        
        if fullName != nil {
            dictionary["fullName"] = fullName as AnyObject?
        }
        
        if email != nil {
            dictionary["email"] = email as AnyObject?
        }
        
        if profileImageUrl != nil {
            dictionary["profileImageUrl"] = profileImageUrl as AnyObject?
        }
        
        if createdTimestamp != nil {
            dictionary["timestamp"] = createdTimestamp as AnyObject?
        }
        
        if followerCount != nil {
            dictionary["followerCount"] = followerCount as AnyObject?
        }
        
        if followingCount != nil {
            dictionary["followingCount"] = followingCount as AnyObject?
        }
        
        if activityCount != nil {
            dictionary["activityCount"] = activityCount as AnyObject?
        }
        
        if fcmToken != nil {
            dictionary["fcmToken"] = fcmToken as AnyObject?
        }
        
        return dictionary
    }
}
