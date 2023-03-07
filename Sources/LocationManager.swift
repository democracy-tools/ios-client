//
//  LocationManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManagerDidUpdate()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    weak var delegate: LocationManagerDelegate?
    
    private let manager: CLLocationManager
    private(set) var coordinate: CLLocationCoordinate2D?
    
    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinate = location.coordinate
        delegate?.locationManagerDidUpdate()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return print("Location services not authorized") }
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else { return print("Monitoring is not available") }
        guard CLLocationManager.isRangingAvailable() else { return print("Ranging is not available") }
        manager.startUpdatingLocation()
    }
}

