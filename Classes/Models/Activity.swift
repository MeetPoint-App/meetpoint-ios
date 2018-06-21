//
//  Activity.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 21/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

let FeedUpdateNotification = "FeedUpdateNotification"

class Activity {
    
    var identifier: String?
    var isOwnActivity: Bool?
    var user: User?
    var uuid: String?
    var description: String?
    var location: CLLocation?
    var latitude: Double?
    var longitude: Double?
    var primaryAddress: String?
    var secondaryAddress: String?
    var createdTimestamp: Double?
    var activityTimestamp: Double?
    var commentCount: Int?
    var participantCount: Int?
    var maximumParticipant: Int?
    var coverImage: UIImage?
    var coverImageUrl: String?
    var isParticipated: Int?
    var isPrivate: Bool?
    var invitedUsers: [String: Bool]?
    
    // MARK: - Constructors
    
    init() {
        
    }
    
    init(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else {
            return
        }
        
        self.identifier = snapshot.key
        self.description = dict["description"] as? String ?? ""
        self.longitude = dict["longitude"] as? Double
        self.latitude = dict["latitude"] as? Double
        self.primaryAddress = dict["primaryAddress"] as? String ?? ""
        self.secondaryAddress = dict["secondaryAddress"] as? String ?? ""
        self.createdTimestamp = dict["createdTimestamp"] as? Double
        self.activityTimestamp = dict["activityTimestamp"] as? Double
        self.commentCount = dict["commentCount"] as? Int
        self.participantCount = dict["participantCount"] as? Int
        self.maximumParticipant = dict["maximumParticipant"] as? Int
        self.coverImageUrl = dict["coverImageUrl"] as? String
        self.uuid = dict["uuid"] as? String
        self.isPrivate = dict["isPrivate"] as? Bool
        self.invitedUsers = dict["InvitedUsers"] as? [String: Bool]
    }
    
    // MARK: - Dictionary Representation
    
    func dictionaryRepresentation() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        
        if identifier != nil {
            dictionary["identifier"] = identifier as AnyObject?
        }
        
        if uuid != nil {
            dictionary["uuid"] = uuid as AnyObject?
        }
        
        if description != nil {
            dictionary["description"] = description as AnyObject?
        }
    
        if latitude != nil {
            dictionary["latitude"] = latitude as AnyObject?
        }
        
        if longitude != nil {
            dictionary["longitude"] = longitude as AnyObject?
        }
        
        if primaryAddress != nil {
            dictionary["primaryAddress"] = primaryAddress as AnyObject?
        }
        
        if secondaryAddress != nil {
            dictionary["secondaryAddress"] = secondaryAddress as AnyObject?
        }
        
        if createdTimestamp != nil {
            dictionary["createdTimestamp"] = createdTimestamp as AnyObject?
        }
        
        if activityTimestamp != nil {
            dictionary["activityTimestamp"] = activityTimestamp as AnyObject?
        }
        
        if commentCount != nil {
            dictionary["commentCount"] = commentCount as AnyObject?
        }
        
        if participantCount != nil {
            dictionary["participantCount"] = participantCount as AnyObject?
        }
        
        if maximumParticipant != nil {
            dictionary["maximumParticipant"] = maximumParticipant as AnyObject?
        }
        
        if coverImageUrl != nil {
            dictionary["coverImageUrl"] = coverImageUrl as AnyObject?
        }
        
        if isPrivate != nil {
            dictionary["isPrivate"] = isPrivate as AnyObject?
        }
        
        return dictionary
    }
}
