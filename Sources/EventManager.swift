//
//  EventManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 06/03/2023.
//

import Foundation
import CoreBluetooth
import CoreLocation

class EventManager: StoreSubscriber, BluetoothManagerDelegate, LocationManagerDelegate {
    let model: Model
    let bluetoothManager: BluetoothManager
    let locationManager: LocationManager
    
    private var pendingPeripherals: [CBPeripheral] = []
    private var isSending = false

    init(model: Model, bluetoothManager: BluetoothManager, locationManager: LocationManager) {
        self.model = model
        self.bluetoothManager = bluetoothManager
        self.locationManager = locationManager
        
        self.bluetoothManager.delegate = self
        self.locationManager.delegate = self
    }
    
    func storeDidUpdate() {
        sendEventsIfNeeded()
    }
    
    func sendEventsIfNeeded() {
        guard !isSending else { return print("Event sending already in progress") }
        guard case let events = model.state.event.events, !events.isEmpty else { return print("No events to send") }
        
        Task.background {
            await self.sendEvents(events, from: self.model.state.client.deviceId)
        }
    }
    
    func sendEvents(_ events: [Event], from deviceId: String) async {
        isSending = true
        defer {
            isSending = false
        }
        do {
            try await Network.sendEvents(events, from: deviceId)
            
            print("Successfully sent \(events.count) events")
            let eventIds = events.map { $0.id }
            model.dispatch(Actions.RemoveEvents(eventIds: eventIds))
            model.save()
        } catch {
            print("Event sending failed: \(error)")
        }
    }
    
    func addEventsIfNeeded() {
        guard let location = locationManager.coordinate else { return print("Location is not ready yet") }
        
        var events: [Event] = []
        while let peripheral = popNamedPeripheral(), let name = peripheral.name {
            let id = NSUUID().uuidString
            let event = Event(id: id, date: Date(), name: name, latitude: location.latitude, longitude: location.longitude)
            events.append(event)
        }
        
        model.dispatch(Actions.AddEvents(events: events))
        model.save()
    }
    
    func popNamedPeripheral() -> CBPeripheral? {
        guard !pendingPeripherals.isEmpty else { return nil }
        guard let index = pendingPeripherals.firstIndex(where: { $0.name != nil }) else {
            print("No peripheral with name found out of \(pendingPeripherals.count) peripherals")
            return nil
        }
        return pendingPeripherals.remove(at: index)
    }
    
    func bluetoothManagerDidDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any]) {
        pendingPeripherals.append(peripheral)
        addEventsIfNeeded()
    }
    
    func locationManagerDidUpdate() {
        addEventsIfNeeded()
    }
}
