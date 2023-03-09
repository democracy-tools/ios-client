//
//  LocationManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManagerDidUpdate()
}

protocol LocationManager: AnyObject {
    var delegate: LocationManagerDelegate? { get set }
    var coordinate: CLLocationCoordinate2D? { get }
    func start()
}

class LocationManagerImpl: NSObject, LocationManager, CLLocationManagerDelegate {
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
        print("Received location update")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return print("Location services not authorized") }
        guard CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) else { return print("Monitoring is not available") }
        guard CLLocationManager.isRangingAvailable() else { return print("Ranging is not available") }
        print("Location status is authorized (\(status.rawValue)")
        manager.startUpdatingLocation()
    }
}
