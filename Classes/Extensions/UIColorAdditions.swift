//
//  UIColorAdditions.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Helper Functions
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    // MARK: - Background Color
    
    public class func primaryBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    public class func secondaryBackgroundColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    public class func dropDownButtonBackgroundColor() -> UIColor {
        return hexStringToUIColor(hex: "#F2F2F2")
    }
    
    public class func primaryButtonBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    public class func secondaryButtonBackgroundColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A523")
    }
    
    public class func goingButtonSelectedColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    public class func interestedButtonSelectedColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    public class func facebookButtonBackgroundColor() -> UIColor {
        return hexStringToUIColor(hex: "#3B5998")
    }
    
    // MARK: - Text Color
    
    public class func primaryDarkTextColor() -> UIColor {
        return hexStringToUIColor(hex: "#4A4A4A")
    }
    
    public class func secondaryDarkTextColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A523")
    }
    
    public class func primaryLightTextColor() -> UIColor {
        return hexStringToUIColor(hex: "#A8A8A8")
    }
    
    public class func secondaryLightTextColor() -> UIColor {
        return UIColor.white
    }

    public class func primaryButtonTitleColor() -> UIColor {
        return UIColor.primaryDarkTextColor()
    }
    
    public class func secondaryButtonTitleColor() -> UIColor {
        return UIColor.white
    }
    
    public class func customRedColor() -> UIColor {
        return hexStringToUIColor(hex: "#F52406")
    }
    
    // MARK: - Separator Color
    
    public class func listSeparatorColor() -> UIColor {
        return hexStringToUIColor(hex: "#A8A8A8").withAlphaComponent(0.6)
    }
    
    public class func segmentedControlSeparatorColor() -> UIColor {
        return hexStringToUIColor(hex: "#A8A8A8").withAlphaComponent(0.6)
    }
    
    // MARK: - Tint Color
    
    public class func defaultTintColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    public class func segmentedControlTintColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    // MARK: - Navigation Controller Color
    
    public class func primaryNavigationComponentColor() -> UIColor {
        return hexStringToUIColor(hex: "#4A4A4A")
    }
    
    // MARK: - Text Field Color
    
    public class func textFieldActiveColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    public class func textFieldInactiveColor() -> UIColor {
        return hexStringToUIColor(hex: "#BDBDBD")
    }
    
    // MARK: - Button Color
    
    public class func overlayButtonBackgroundColor() -> UIColor {
        return hexStringToUIColor(hex: "#F6A623")
    }
    
    // MARK: - Border Color
    
    public class func dropDownButtonBorderColor() -> UIColor {
        return hexStringToUIColor(hex: "#E3E3E3")
    }
    
    // MARK: - Tab Bar
    
    public class func tabBarPrimarySelectedTextColor() -> UIColor {
        return UIColor.white
    }
    
    public class func tabBarPrimaryBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    public class func tabBarSecondaryBackgroundColor() -> UIColor {
        return UIColor.black
    }
}
