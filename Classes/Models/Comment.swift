//
//  Comment.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 22/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Firebase

class Comment {
    var identifier: String?
    var user: User?
    var uuid: String?
    var commentText: String?
    var createdTimestamp: Double?
    var isOwnComment: Bool?
    
    // MARK: - Constructors
    
    init() {
        
    }
    
    init(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else {
            return
        }
        
        self.identifier = snapshot.key
        self.uuid = dict["uuid"] as? String
        self.commentText = dict["commentText"] as? String ?? ""
        self.createdTimestamp = dict["createdTimestamp"] as? Double
    }
    
    // MARK: - Dictionary Representation
    
    func dictionaryRepresentation() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        
        if identifier != nil {
            dictionary["identifier"] = identifier as AnyObject?
        }

        if createdTimestamp != nil {
            dictionary["createdTimestamp"] = createdTimestamp as AnyObject?
        }
        
        if commentText != nil {
            dictionary["commentText"] = commentText as AnyObject?
        }
        
        if uuid != nil {
            dictionary["uuid"] = uuid as AnyObject?
        }
        
        return dictionary
    }
}
