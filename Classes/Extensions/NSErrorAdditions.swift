//
//  NSErrorAdditions.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 18/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import Foundation

let NetworkClientErrorDomain = "NetworkClientErrorDomain"

enum ErrorCode: Int {
    case success                            = 200
    case invalidCredentials                 = 201
    case emailAlreadyTaken                  = 203
    
    case notFound                           = 404
    
    case invalidParameters                  = -1000
    case invalidJSON                        = -1001
    case invalidData                        = -1002
    case noAuthenticatedUser                = -1003
    case unknownError                       = -1004
    
    case photoAccessNotDetermined           = -1005
    case photoAccessRestricted              = -1006
    case photoAccessDenied                  = -1007
    case photoCaptureFailed                 = -1008
    
    case facebookAuthenticationFailed       = -1009
    case facebookPhotoAccessCancelled       = -1010
    
    case locationAccessDenied               = -1011
    case locationAccessRestricted           = -1012
    case locationAccessFailure              = -1013
    
    case foursquareError                    = -1014
}

extension NSError {
    class func inlineErrorWithErrorCode(code: ErrorCode) -> NSError {
        return NSError(domain: NetworkClientErrorDomain, code: code.rawValue, userInfo: nil)
    }
    
    class func inlineErrorWith(Code code: Int?, andMessage message: String?) -> NSError {
        var userInfo: [String : AnyObject]?
        
        var inlineCode: Int!
        var inlineMessage: String! = message
        
        if code == nil {
            inlineCode = ErrorCode.unknownError.rawValue
            
            inlineMessage = "Unknown Error"
        } else {
            inlineCode = code
        }
        
        if let _ = inlineMessage {
            userInfo = [:]
            
            userInfo![NSLocalizedDescriptionKey] = inlineMessage as AnyObject
        }
        
        return NSError(domain: NetworkClientErrorDomain,
                       code: inlineCode,
                       userInfo: userInfo)
    }
}
