//
//  SearchLocationViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 8.04.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import MapKit
import PureLayout
import CoreLocation
import GooglePlaces

class SearchLocationViewController: BaseViewController {
    weak var delegate: SearchLocationViewControllerDelegate!
    
    fileprivate var locations: [Location] = []
    
    fileprivate var searchTextField: LocationSearchTextField!
    fileprivate var mapView: MKMapView!
    
    fileprivate var collectionView: UICollectionView!
    
    fileprivate var collectionViewLayout: SliderCollectionViewLayout!
    
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var selectedLocationIndex: Int = 0
    
    fileprivate var pageWidth: CGFloat {
        return self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    
    fileprivate var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        title = "Search Location"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField = LocationSearchTextField.newAutoLayout()
        searchTextField.shouldShowShadowOnBottom = true
        searchTextField.delegate = self
        
        view.addSubview(searchTextField)
        
        searchTextField.autoPin(toTopLayoutGuideOf: self, withInset: 0.0)
        searchTextField.autoPinEdge(toSuperviewEdge: ALEdge.left)
        searchTextField.autoPinEdge(toSuperviewEdge: ALEdge.right)
        searchTextField.autoSetDimension(ALDimension.height,
                                         toSize: LocationSearchTextFieldDefaultHeight)
        
        
        mapView = MKMapView.newAutoLayout()
        mapView.tintColor = UIColor.defaultTintColor()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.isScrollEnabled = false
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)
        
        mapView.autoPinEdgesToSuperviewEdges()
        
        
        collectionView = UICollectionView(frame: CGRect.zero,
                                          collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(SearchLocationCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: SearchLocationCollectionViewCellReuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        collectionView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        collectionView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        collectionView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                   withInset: 20.0)
        collectionView.autoSetDimension(ALDimension.height,
                                        toSize: SearchLocationCollectionViewCellSize.height)
        
        collectionViewLayout = SliderCollectionViewLayout.configureLayout(collectionView: collectionView,
                                                                          itemSize: SearchLocationCollectionViewCellSize, minimumLineSpacing: 0.0)
        
        LocationManager.sharedManager.requestCurrentLocation { (location, error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                
                return
            }
            
            guard let location = location else {
                return
            }
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center,
                                            span: span)
            
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Interface
    
    override func shouldShowShadowUnderNavigationBar() -> Bool {
        return false
    }
    
    // MARK: - Configure
    
    fileprivate func configure(SearchLocationCollectionViewCell cell: SearchLocationCollectionViewCell,
                               withIndexPath indexPath: IndexPath) {
        if indexPath.item >= locations.count {
            return
        }
        
        let location = locations[indexPath.item]
        
        if let primaryAddress = location.primaryAddress {
            cell.title = primaryAddress
        }
        
        if let photo = location.photo {
            cell.imageView.image = photo
        } else {
            cell.imageView.image = UIImage()
        }
    }
    
    // MARK: - Actions
    
    override func backButtonTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        selectedLocationIndex = Int(self.contentOffset / self.pageWidth)
        
        goToSeletedLocation()
    }
    
    // MARK: - Helpers
    
    fileprivate func goToSeletedLocation() {
        if selectedLocationIndex >= locations.count {
            return
        }
        
        let location = locations[selectedLocationIndex]
        
        if let latitude = location.latitude, let longitude = location.longitude {
            mapView.removeAnnotations(mapView.annotations)
            
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center,
                                            span: span)
            
            self.mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = center
            
            if let title = location.primaryAddress {
                annotation.title = title
            }
            
            if let subtitle = location.secondaryAddress {
                annotation.subtitle = subtitle
            }
            
            mapView.addAnnotation(annotation)
        }
    }
}

// MARK: - LocationSearchTextFieldDelegate

extension SearchLocationViewController: LocationSearchTextFieldDelegate {
    func locationSearchTextFieldEditingChanged(_ textField: LocationSearchTextField) {
        
    }
    
    func locationSearchTextFieldShouldReturn(_ textField: LocationSearchTextField) -> Bool {
        locations = []
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        
        let client = GMSPlacesClient()
        
        activityIndicator.startAnimating()
        
        if textField.text.isEmpty {
            
            self.showPopupWith(Title: "Opps", andMessage: "No results.")
            self.activityIndicator.stopAnimating()
            
            return true
        }
        
        client.autocompleteQuery(textField.text, bounds: nil, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                self.activityIndicator.stopAnimating()
                
                return
            }
            
            if let results = results {
                if results.count == 0 {
                    self.showPopupWith(Title: "Opps", andMessage: "No results.")
                    self.activityIndicator.stopAnimating()
                }
                
                for result in results {
                    let location = Location()
                    location.placeId = result.placeID
                    location.primaryAddress = result.attributedPrimaryText.string
                    location.secondaryAddress = result.attributedSecondaryText?.string
                    
                    guard let placeId = result.placeID else {
                        return
                    }
                    
                    self.locations.append(location)
                    
                    GMSPlacesClient.shared().lookUpPlaceID(placeId, callback: { (place, error) in
                        if let error = error {
                            
                            self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                            self.activityIndicator.stopAnimating()
                            
                            return
                        }
                        
                        if let place = place {
                            let coordinate = place.coordinate
                            
                            location.latitude = coordinate.latitude
                            location.longitude = coordinate.longitude
                        }
                        
                        if self.locations.count == results.count {
                            self.goToSeletedLocation()
                            self.activityIndicator.stopAnimating()
                            self.collectionView.reloadData()
                        }
                    })
                    
                    GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeId, callback: { (photos, error) in
                        if let error = error {
                            
                            self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                            self.activityIndicator.stopAnimating()
                            
                            return
                        }
                        
                        if let firstPhoto = photos?.results.first {
                            GMSPlacesClient.shared().loadPlacePhoto(firstPhoto, callback: { (photo, error) in
                                if let error = error {
                                    
                                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                                    self.activityIndicator.stopAnimating()
                                    
                                    return
                                }
                                
                                location.photo = photo
                                
                                self.collectionView.reloadData()
                            })
                        }
                    })
                }
            }
        })
        
        return true
    }
}

// MARK: - UICollectionViewDelegate

extension SearchLocationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= self.locations.count {
            return
        }
        
        let location = locations[indexPath.item]
        
        self.dismiss(animated: true, completion: nil)
        
        delegate.searchLocationViewController(self, withSelectedLocation: location)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchLocationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchLocationCollectionViewCellReuseIdentifier,
                                                      for: indexPath) as! SearchLocationCollectionViewCell
        
        configure(SearchLocationCollectionViewCell: cell, withIndexPath: indexPath)
        
        return cell
    }
}

// MARK: - MKMapViewDelegate

extension SearchLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annotationView.canShowCallout = true
        annotationView.animatesDrop = true
        annotationView.annotation = annotation
        annotationView.pinTintColor = UIColor.defaultTintColor()
        
        return annotationView
    }
}

// MARK: - SearchLocationViewControllerDelegate

protocol SearchLocationViewControllerDelegate: NSObjectProtocol {
    func searchLocationViewController(_ viewController: SearchLocationViewController,
                                      withSelectedLocation location: Location)
}

