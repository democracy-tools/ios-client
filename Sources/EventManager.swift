//
//  EventManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 06/03/2023.
//

import Foundation

class EventManager: StoreSubscriber, BluetoothManagerDelegate, LocationManagerDelegate {
    let model: Model
    let bluetoothManager: BluetoothManager
    let locationManager: LocationManager
    
    private var pendingPeripherals: [Peripheral] = []
    private var isSending = false

    init(model: Model, bluetoothManager: BluetoothManager, locationManager: LocationManager) {
        self.model = model
        self.bluetoothManager = bluetoothManager
        self.locationManager = locationManager
        
        self.model.subscribe(self)
        self.bluetoothManager.delegate = self
        self.locationManager.delegate = self
    }
    
    func storeDidUpdate() {
        sendEventsIfNeeded()
    }
    
    func sendEventsIfNeeded() {
        guard !isSending else { return print("Event sending already in progress") }
        guard case let events = model.state.event.events, !events.isEmpty else { return print("No events to send") }
        sendEvents(events, from: model.state.client.deviceId)
    }
    
    func sendEvents(_ events: [Event], from deviceId: String) {
        isSending = true
        Task.background {
            do {
                try await Network.sendEvents(events, from: deviceId)
                await MainActor.run {
                    self.didFinishSendingEvents(events)
                }
            } catch {
                await MainActor.run {
                    self.didFailSendingEvents(error)
                }
            }
        }
    }
    
    func didFinishSendingEvents(_ events: [Event]) {
        print("Successfully sent \(events.count) events")
        model.dispatch(Actions.RemoveEvents(eventIds: events.map { $0.id }))
        model.save()
        isSending = false
    }
    
    func didFailSendingEvents(_ error: Error) {
        print("Fail to send events: \(error)")
        isSending = false
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
    
    func popNamedPeripheral() -> Peripheral? {
        guard !pendingPeripherals.isEmpty else { return nil }
        guard let index = pendingPeripherals.firstIndex(where: { $0.name != nil }) else {
            print("No peripheral with name found out of \(pendingPeripherals.count) peripherals")
            return nil
        }
        return pendingPeripherals.remove(at: index)
    }
    
    func bluetoothManagerDidDiscoverPeripheral(_ peripheral: Peripheral, advertisementData: [String: Any]) {
        pendingPeripherals.append(peripheral)
        addEventsIfNeeded()
    }
    
    func locationManagerDidUpdate() {
        addEventsIfNeeded()
    }
}
