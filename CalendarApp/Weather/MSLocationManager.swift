//
//  MSLocationManager.swift
//  CalendarApp
//
//  Created by Pawan on 11/15/17.
//  Copyright © 2017 Pawan. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func fetchedUserLocation(_ userLocation: MSLocation)
}

class MSLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var userLocation: MSLocation? = nil
    
    weak var delegate: LocationManagerDelegate?
    
    override init() { }
    
    static let sharedManager : MSLocationManager = {
        let instance = MSLocationManager()
        instance.configure()
        return instance
    }()
    
    func configure() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000  //in metre
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Core Location
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        let currentLocation = locations.last!  //recent is at end
        let lat = String(currentLocation.coordinate.latitude)
        let long = String(currentLocation.coordinate.longitude)
        userLocation = MSLocation(latitude: lat, longitude: long)
        
        guard let location = userLocation else { return  }
        delegate?.fetchedUserLocation(location)
    }
}
