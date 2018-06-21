//
//  Router.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 4.03.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import Foundation
import Firebase

enum Router {
    static let BaseDatabaseReference = Database.database().reference()
    
    case user(uid: String)
    case users
    case activity(identifier: String)
    case userActivities(uid: String)
    case usersPrivateActivities(uid: String)
    case allActivities
    case topUsers
    case searches(uid: String)
    case followings(uid: String)
    case followers(uid: String)
    case nearMe
    case comment(identifier: String)
    case participant(identifier: String)
    case reportActivity(identifier: String)
    case reportComment(identifier: String)
    case reportUser(uid: String)
    case notifications
    case userNotifications(uid: String)
    
    var reference: DatabaseReference {
        switch self {
        case .users:
            return Router.BaseDatabaseReference.child("Users")
        case .user(let uid):
            return Router.users.reference.child(uid)
        case .activity(let identifier):
            return Router.allActivities.reference.child(identifier)
        case .allActivities:
            return Router.BaseDatabaseReference.child("AllActivities")
        case .userActivities(let uid):
            return Router.BaseDatabaseReference.child("UserActivities").child(uid)
        case .usersPrivateActivities(let uid):
            return Router.BaseDatabaseReference.child("UsersPrivateActivities").child(uid)
        case .topUsers:
            return Router.BaseDatabaseReference.child("TopUsers")
        case .searches(let uid):
            return Router.BaseDatabaseReference.child("Searches").child(uid)
        case .followings(let uid):
            return Router.BaseDatabaseReference.child("Following").child(uid)
        case .followers(let uid):
            return Router.BaseDatabaseReference.child("Follower").child(uid)
        case .nearMe:
            return Router.BaseDatabaseReference.child("NearMe")
        case .comment(let identifier):
            return Router.BaseDatabaseReference.child("Comment").child(identifier)
        case .participant(let identifier):
            return Router.BaseDatabaseReference.child("Participant").child(identifier)
        case .reportActivity(let identifier):
            return Router.BaseDatabaseReference.child("ReportActivity").child(identifier)
        case .reportComment(let identifier):
            return Router.BaseDatabaseReference.child("ReportComment").child(identifier)
        case .reportUser(let uid):
            return Router.BaseDatabaseReference.child("ReportComment").child(uid)
        case .notifications:
            return Router.BaseDatabaseReference.child("Notifications")
        case .userNotifications(let uid):
            return Router.notifications.reference.child("UserNotifications").child(uid)
        }
    }
}
