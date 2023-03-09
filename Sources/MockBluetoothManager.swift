//
//  MockBluetoothManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 09/03/2023.
//

import Foundation

#if targetEnvironment(simulator)
class BluetoothManagerMock: BluetoothManager {
    weak var delegate: BluetoothManagerDelegate?
    
    private var name = ""

    func start(deviceId: String) {
        name = deviceId
        startReporting()
    }
    
    private func startReporting() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.reportPeripheral()
        }
    }
    
    private func reportPeripheral() {
        let peripheral = MockPeripheral()
        print("Discovered peripheral: \(peripheral)")
        delegate?.bluetoothManagerDidDiscoverPeripheral(peripheral, advertisementData: [:])
    }

    private class MockPeripheral: Peripheral {
        var name: String? = String(NSUUID().uuidString.prefix(8))
    }
}
#endif
