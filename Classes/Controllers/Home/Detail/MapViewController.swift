//
//  MapViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 20/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import CoreLocation
import MapKit

class MapViewController: BaseViewController {
    
    fileprivate var activity: Activity?
    
    fileprivate var mapView: MKMapView!
    
    fileprivate let regionRadius: CLLocationDistance = 1000
    
    fileprivate var pinAnnotationView: MKPinAnnotationView!
    fileprivate var pointAnnotation: ActivityPointAnnotation!
    
    // MARK: - Constructors
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(WithActivity activity: Activity) {
        super.init()
        self.activity = activity
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.title = "Map"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView.newAutoLayout()
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        let insets = UIEdgeInsetsMake(0.0, 0.0, defaultBottomInset(), 0.0)
        mapView.autoPinEdgesToSuperviewEdges(with: insets)
        
        if let activity = activity {
            guard let lat = activity.latitude, let lon = activity.longitude else {
                return
            }
            
            centerMapOnLocation(CLLocation(latitude: lat, longitude: lon))
            
            pointAnnotation = ActivityPointAnnotation()
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            
            if let primaryAddress = activity.primaryAddress {
                pointAnnotation.title = primaryAddress
            }
            
            if let secondaryAddress = activity.secondaryAddress {
                pointAnnotation.subtitle = secondaryAddress
            }
            
            pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
            mapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }
    
    // MARK: - Interface
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight
    }
    
    // MARK: - Helpers
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        let pointAnnotation = annotation as! ActivityPointAnnotation
        annotationView?.image = pointAnnotation.pointAnnotationImage
        
        
        let detailButton = UIButton(type: UIButtonType.detailDisclosure)
        annotationView?.rightCalloutAccessoryView = detailButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        
        guard let lat = activity?.latitude, let lon = activity?.longitude else {
            return
        }
        
        let alertController = UIAlertController(title: nil, message: "Navigation", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.default, handler: { (_) in
            if UIApplication.shared.canOpenURL(URL(string:"https://maps.google.com")!) {
                UIApplication.shared.open(URL(string:
                    "https://maps.google.com/?q=@\(lat),\(lon)")!, options: [:], completionHandler: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.default, handler: { (_) in
            let url = "http://maps.apple.com/maps?saddr=\(lat),\(lon)"
            UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
        }))
        
//        alertController.addAction(UIAlertAction(title: "Augmented Reality Navigation", style: UIAlertActionStyle.default, handler: { (_) in
//            self.showPopupWith(Title: "Error", andMessage: "Your device is not supporting Augmented Reality!")
//        }))
//        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
