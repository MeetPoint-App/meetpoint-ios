//
//  UIFontAdditions.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

extension UIFont {
    
    // MARK: - Montserrat Font
    
    public class func montserratRegularFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: size)!
    }
    
    public class func montserratLightFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Light", size: size)!
    }
    
    public class func montserratMediumFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Medium", size: size)!
    }
    
    public class func montserratSemiboldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Semibold", size: size)!
    }
    
    public class func montserratBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size)!
    }
    
    public class func montserratExtraBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-ExtraBold", size: size)!
    }
    
    public class func montserratBlackFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-BlackBold", size: size)!
    }
    
    // MARK: - Proxima Nova
    
    public class func proximaNovaBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont(name: "ProximaNova-Bold", size: size)!
    }
}
