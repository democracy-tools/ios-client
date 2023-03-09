//
//  MockLocationManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 09/03/2023.
//

import CoreLocation

#if targetEnvironment(simulator)
class LocationManagerMock: LocationManager {
    weak var delegate: LocationManagerDelegate?
    var coordinate: CLLocationCoordinate2D?

    func start() {
        startReporting()
    }
    
    private func startReporting() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.reportLocation()
        }
    }
    
    private func reportLocation() {
        print("Received location update")
        var coords = CLLocationCoordinate2D(latitude: 32.073435, longitude: 34.790360)
        coords.latitude += Double.random(in: -0.001...0.001)
        coords.longitude += Double.random(in: -0.001...0.001)
        self.coordinate = coords
        delegate?.locationManagerDidUpdate()
    }
}
#endif
