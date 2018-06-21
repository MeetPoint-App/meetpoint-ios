//
//  RemoteNotification.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import Foundation
import Firebase

enum NotificationType: String {
    case user  = "user"
}

class RemoteNotification {
    var identifier: String?
    var notificationType: String?
    var timestamp: String?
    var message: String?
    var user: User?
    
    // MARK: - Constructors
    
    init() {
        
    }
    
    init(snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any] else {
            return
        }

        if let data = dict["data"] as? [String: Any] {
           self.identifier           = data["identifier"] as? String ?? ""
           self.message              = data["message"] as? String
           self.timestamp            = data["timestamp"] as? String ?? ""
           self.notificationType     = data["type"] as? String ?? ""
        }
    }
}
