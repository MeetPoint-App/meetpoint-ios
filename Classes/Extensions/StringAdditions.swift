//
//  StringAdditions.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit


let EmptyString = ""
let NewLineString = "\n"

fileprivate let RequiredSuffix = "*"
fileprivate let AtSuffix = "@"

extension String {
    func requiredSuffix() -> String {
        return self + RequiredSuffix
    }
    
    func atPrefixedString() -> String {
        return AtSuffix + self
    }
    
    public func isValidFirstName() -> Bool {
        let firstNameRegEx = "^[a-zA-ZğüşıöçĞÜŞİÖÇ]+$"
        
        let firstNameTest = NSPredicate(format: "SELF MATCHES %@", firstNameRegEx)
        
        return firstNameTest.evaluate(with: self)
    }
    
    public func isValidLastName() -> Bool {
        let lastNameRegEx = "^[a-zA-ZğüşıöçĞÜŞİÖÇ]+$"
        
        let lastNameTest = NSPredicate(format: "SELF MATCHES %@", lastNameRegEx)
        
        return lastNameTest.evaluate(with: self)
    }
    
    public func isValidUsername() -> Bool {
        let usernameRegEx = "^[A-Z0-9a-zğüşıöçĞÜŞİÖÇ._%+-]+$"
        
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        
        return usernameTest.evaluate(with: self)
    }
    
    public func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
    
    public func isValidPassword() -> Bool {
        return self.count >= 6
    }
    
    public func isNumeric() -> Bool {
        let numericRegEx = "^[0-9]+$"
        
        let numericTest = NSPredicate(format:"SELF MATCHES %@", numericRegEx)
        
        return numericTest.evaluate(with: self)
    }
}
