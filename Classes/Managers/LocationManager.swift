//
//  LocationManager.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 09/11/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

class LocationManager: NSObject {
    static let sharedManager = LocationManager()
    
    fileprivate var locationManager: CLLocationManager!
    
    fileprivate var authorizationCompletion: ((Bool, NSError?) -> Void)?
    fileprivate var currentLocationCompletion: ((CLLocation?, NSError?) -> Void)!
    
    fileprivate var currentLocation: CLLocation?
    
    // MARK: - Constructor
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    // MARK: - Access
    
    func requestLocationAccessPermission(completion: @escaping (Bool, NSError?) -> Void) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            completion(true, nil)
            
            return
        }
        
        authorizationCompletion = completion
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAuthorizationStatus(completion: @escaping (CLAuthorizationStatus) -> Void) {
        let status = CLLocationManager.authorizationStatus()
        
        completion(status)
    }
    
    // MARK: - Location
    
    func requestCurrentLocation(completion: @escaping (CLLocation?, NSError?) -> Void) {
        currentLocation = nil
        
        currentLocationCompletion = completion
        
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Helper Methods
    
    fileprivate class func deniedError() -> NSError {
        let errorCode = ErrorCode.locationAccessDenied.rawValue
        let errorMessage = "You have denied access to your current location. You should go to Application Settings in order to use this functionality."
        
        let inlineError = NSError.inlineErrorWith(Code: errorCode,
                                                  andMessage: errorMessage)
        
        return inlineError
    }
    
    fileprivate class func restrictedError() -> NSError {
        let errorCode = ErrorCode.locationAccessRestricted.rawValue
        let errorMessage = "Your location access is restricted. You should go to Application Settings in order to use this functionality."
        
        let inlineError = NSError.inlineErrorWith(Code: errorCode,
                                                  andMessage: errorMessage)
        
        return inlineError
    }
    
    fileprivate class func failureError() -> NSError {
        let errorCode = ErrorCode.locationAccessFailure.rawValue
        let errorMessage = "Unable to retrieve any locations."
        
        let inlineError = NSError.inlineErrorWith(Code: errorCode,
                                                  andMessage: errorMessage)
        
        return inlineError
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let completion = authorizationCompletion else {
            return
        }
        
        switch status {
        case .denied:
            completion(false, LocationManager.deniedError())
        case .restricted:
            completion(false, LocationManager.restrictedError())
        case .authorizedWhenInUse:
            completion(true, nil)
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let completion = currentLocationCompletion else {
            return
        }
        
        completion(nil, LocationManager.failureError())
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let completion = currentLocationCompletion else {
            return
        }
        
        if currentLocation == nil {
            if let location = locations.first {
                currentLocation = location
                
                completion(location, nil)
            } else {
                completion(nil, LocationManager.failureError())
            }
        }
        
        locationManager.stopUpdatingLocation()
    }
}
