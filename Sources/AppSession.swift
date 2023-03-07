//
//  AppSession.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class AppSession {
    let model: Model
    let coordinator: AppCoordinator
    let bluetoothManager: BluetoothManager
    let locationManager: LocationManager
    let eventManager: EventManager
    
    init() {
        model = Model()
        coordinator = AppCoordinator(model: model)
        bluetoothManager = BluetoothManager()
        locationManager = LocationManager()
        eventManager = EventManager(model: model, bluetoothManager: bluetoothManager, locationManager: locationManager)
    }
    
    func start() {
        model.load()
        coordinator.start()
        locationManager.start()
        bluetoothManager.start(deviceId: model.state.client.deviceId)
    }
    
    // Lifecycle
    
    func pause() {
        coordinator.pause()
    }
    
    func resume() {
        coordinator.resume()
    }
}
