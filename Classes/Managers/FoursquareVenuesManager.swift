//
//  FoursquareVenuesManager.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 18/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import ObjectMapper

fileprivate let ClientIdentifier    = "1DSAIYK1DH50GGO1IP3DLFHHEQCKXOM4XBEOZBDW35VIARA2"
fileprivate let ClientSecret        = "40YNMLDUOALFIR4WLHZ12VQ4MBXA5YG2ED3UARL1CZ250TCW"

fileprivate let BaseURL             = "https://api.foursquare.com/v2"
fileprivate let VenueSearchPath     = "/venues/search"

fileprivate let VersionDateFormat   = "yyyyMMdd"

class FoursquareVenuesManager: NSObject {
    internal class func searchVenuesAround(Location location: CLLocation,
                                           QueryString query: String?,
                                           completion: @escaping ([FoursquareVenue]?, NSError?) -> Void) {
        var parameters = [String: Any]()
        
        parameters["client_id"] = ClientIdentifier
        parameters["client_secret"] = ClientSecret
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = VersionDateFormat
        
        let versionString = dateFormatter.string(from: Date())
        parameters["v"] = versionString
        
        let locationString = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        parameters["ll"] = locationString
        
        if let query = query {
            parameters["query"] = query
            parameters["intent"] = "checkin"
        }
        
        Alamofire.request(BaseURL + VenueSearchPath, method: HTTPMethod.get, parameters: parameters, headers: nil).responseJSON { (response) in
            
            if let error = response.error {
                completion(nil, error as NSError)
            } else {
                guard let data = response.data else {
                    let inlineError = NSError.inlineErrorWithErrorCode(code: ErrorCode.invalidParameters)
                    
                    completion(nil, inlineError)
                    
                    return
                }
                
                guard let jsonObject = data.jsonObjectRepresentation() as? [String: AnyObject] else {
                    let inlineError = NSError.inlineErrorWithErrorCode(code: ErrorCode.invalidJSON)
                    
                    completion(nil, inlineError)
                    
                    return
                }
                
                guard let meta = jsonObject["meta"] as! [String: AnyObject]? else {
                    let inlineError = NSError.inlineErrorWithErrorCode(code: ErrorCode.unknownError)
                    
                    completion(nil, inlineError)
                    
                    return
                }
                
                guard let code = meta["code"] as? Int else {
                    let inlineError = NSError.inlineErrorWithErrorCode(code: ErrorCode.unknownError)
                    
                    completion(nil, inlineError)
                    
                    return
                }
                
                if code != 200 {
                    let errorCode = ErrorCode.foursquareError.rawValue
                    var errorMessage = "Unknown Error"
                    
                    if let message = meta["errorDetail"] as? String {
                        errorMessage = message
                    }
                    
                    let inlineError = NSError.inlineErrorWith(Code: errorCode,
                                                              andMessage: errorMessage)
                    
                    completion(nil, inlineError)
                    
                    return
                }
                
                let response = jsonObject["response"] as! [String: AnyObject]
                
                let venues = Mapper<FoursquareVenue>().mapArray(JSONArray: response["venues"] as! [[String : Any]])
                
                completion(venues, nil)
            }
        }
    }
}
