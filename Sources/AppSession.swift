//
//  AppSession.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class AppSession: AppCoordinatorDelegate {
    let model: Model
    let coordinator: AppCoordinator
    let bluetoothManager: BluetoothManager
    let locationManager: LocationManager
    let eventManager: EventManager
    
    init() {
        model = Model()
        coordinator = AppCoordinator(model: model)
        #if targetEnvironment(simulator)
        bluetoothManager = BluetoothManagerMock()
        locationManager = LocationManagerMock()
        #else
        bluetoothManager = BluetoothManagerImpl()
        locationManager = LocationManagerImpl()
        #endif
        eventManager = EventManager(model: model, bluetoothManager: bluetoothManager, locationManager: locationManager)
        
        coordinator.delegate = self
    }
    
    func start() {
        model.load()
        coordinator.start()
    }
    
    // Lifecycle
    
    func pause() {
        coordinator.pause()
    }
    
    func resume() {
        coordinator.resume()
    }
    
    // AppCoordinatorDelegate
    
    var started = false
    
    func coordinatorDidStartReporting(_ coordinator: AppCoordinator) {
        guard !started else { return print("Already started reporting") }
        started = true
        locationManager.start()
        bluetoothManager.start(deviceId: model.state.client.deviceId)
    }
}
