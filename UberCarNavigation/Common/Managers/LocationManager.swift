//
//  LocationManager.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//

import CoreLocation
import Foundation
import UIKit
import Combine

class LocationManager: NSObject {
    
    // MARK: - Shared Property
    static var shared = LocationManager()
    
    // MARK: - Properties
    var lastLocation: CLLocation?
    var locations: [CLLocation] = []
    var previousLocation: CLLocation?
    
    /// define immutable `locationUpdate` property so that subscriber can only read from it.
    private(set) lazy var locationUpdate = currentLocationSubject.eraseToAnyPublisher()
    
    // MARK: - Private Properties
    private var cancellables: [AnyCancellable] = []
    private let currentLocationSubject = PassthroughSubject<CLLocation, Never>()
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    private lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        _locationManager.requestAlwaysAuthorization()
        _locationManager.requestWhenInUseAuthorization()
        _locationManager.distanceFilter = 3.0
        _locationManager.activityType = .automotiveNavigation
        _locationManager.startUpdatingLocation()
        return _locationManager
    }()
    
    private func setupBackgroundTask() {
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            if let backgroundTaskIdentifier = self.backgroundTaskIdentifier {
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        })
    }
    
    func startUpdatingLocation() {
        setupBackgroundTask()
       if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        if let backgroundTaskIdentifier = self.backgroundTaskIdentifier {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.first else { return }
        
        guard location.timestamp.timeIntervalSinceNow < 10 || location.horizontalAccuracy > 0 else {
            print("invalid location received")
            return
        }
        
        self.locations.append(location)
        previousLocation = lastLocation
        lastLocation = location
        currentLocationSubject.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse || status == .authorizedWhenInUse{
            startUpdatingLocation()
        }
    }
}
