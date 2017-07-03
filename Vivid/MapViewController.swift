//
//  MapViewController.swift
//  Vivid
//
//  Created by Celia Gómez de Villavedón on 23/06/2017.
//  Copyright © 2017 Celia Gómez de Villavedón Pedrosa. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import MapKit


class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBOutlet weak var searchBarView: UIView!
    
    
    // MARK: Properties
    
    let locationManager = CLLocationManager()
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var searchSource: [String]?
    
    //create a completer
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC = MKLocalSearchCompleter()
        sC.delegate = self
        return sC
        
    }()
   
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchBarView.isHidden = true
        //MARK: Call initianLocation method when user disable authorized location
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchAutocomplete()
    }
    
    
    func initialLocation() {
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 8)
        self.mapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = mapView
        
    }
    
    func searchAutocomplete() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        let northEastBoundsCorner = CLLocationCoordinate2D(latitude: 52.650385,
                                                           longitude: 13.730843)
        let southWestBoundsCorner = CLLocationCoordinate2D(latitude: 52.390954,
                                                           longitude: 13.111097)
        let bounds = GMSCoordinateBounds(coordinate: northEastBoundsCorner,
                                         coordinate: southWestBoundsCorner)

        resultsViewController?.autocompleteBounds = bounds
        
        let filter = GMSAutocompleteFilter()
        filter.type = .region
       
        filter.country = "de"
        resultsViewController?.autocompleteFilter = filter
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.hidesNavigationBarDuringPresentation = false
        
  
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

    }

    //MARK: Simple search button
    
    @IBAction func search(_ sender: Any) {
        if searchBarView.isHidden {
            searchBarView.addSubview((searchController?.searchBar)!)
            searchController?.searchBar.sizeToFit()
            searchBarView.isHidden = false
        } else {
            searchBarView.isHidden = true
        }
    }

}

//MARK: Get user location

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        //TODO: If user disable location manually, ask again with an alert (only once)
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        } else {
            initialLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
            
        }
    }
}

// Handle the user's selection.
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        print("Place coordinates: \(String(describing: place.coordinate))")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

//Try searchCompleter

extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //change searchCompleter depends on searchBar's text
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        }
    }
}

extension MapViewController: MKLocalSearchCompleterDelegate {
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
    }
}

