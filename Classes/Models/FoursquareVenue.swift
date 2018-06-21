//
//  FoursquareVenue.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 18/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import ObjectMapper

class FoursquareVenue: NSObject, Mappable {
    var identifier: String?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var distance: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        identifier          <- map["id"]
        name                <- map["name"]
        latitude            <- map["location.lat"]
        longitude           <- map["location.lng"]
        distance            <- map["location.distance"]
    }
    
    func distanceString() -> String? {
        guard let distance = distance else {
            return nil
        }
        
        if distance < 1000 {
            return "\(distance)M"
        }
        
        let distanceString = NSString(format: "%.1f", (CGFloat(distance) / 1000))
        
        return "\(distanceString)Km"
    }
}
