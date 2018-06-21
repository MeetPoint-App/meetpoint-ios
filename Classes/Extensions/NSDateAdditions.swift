//
//  NSDateAdditions.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 19/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

extension NSDate {
    public class func timePassedSinceDate(_ date: NSDate) -> String {
        let secondsPassed = -1 * date.timeIntervalSinceNow

        if secondsPassed < 60 {
            return "Just now"
        }
        
        if secondsPassed < (60 * 60) {
            let time = Int(secondsPassed / 60)
            
            if time == 1 {
                return "\(time) minute ago"
            }
            
            return "\(time) minutes ago"
        }
        
        if secondsPassed < (60 * 60 * 24) {
            let time = Int(secondsPassed / ( 60 * 60))
            
            if time == 1 {
                return "\(time) hour ago"
            }
            
            return "\(time) hours ago"
        }
        
        if secondsPassed < (60 * 60 * 24 * 7) {
            let time = Int(secondsPassed / (60 * 60 * 24))
            
            if time == 1 {
                return "\(time) day ago"
            }
            
            return "\(time) days ago"
        }
        
        let time = Int(secondsPassed / (60 * 60 * 24 * 7))
        
        if time == 1 {
            return "\(time) week ago"
        }
        
        return "\(time) weeks ago"
    }
    
    public class func dayDifference(_ interval : TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en")
        
        let calendar = NSCalendar.current
        let date = Date(timeIntervalSince1970: interval)
        
        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            
            return "Today, \(dateFormatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            dateFormatter.dateFormat = "HH:mm"
            
            return "Tomorrow, \(dateFormatter.string(from: date))"
        } else {
            let seconds = date.timeIntervalSinceNow
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en")

            if seconds < 0 {
                dateFormatter.dateFormat = "dd/MM/yyyy"
                
                return dateFormatter.string(from: date as Date)
            }
            
            let day = Int(seconds / (60 * 60 * 24))
    
            if day > 7 {
                dateFormatter.dateFormat = "dd/MM/yyyy"
            } else {
                dateFormatter.dateFormat = "EEEE, HH:mm"
            }
            
            return dateFormatter.string(from: date as Date)
        }
    }
}
