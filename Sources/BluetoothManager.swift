//
//  BluetoothManager.swift
//  CountMeIn
//
//  Created by Gil Shapira on 06/03/2023.
//

import Foundation
import CoreBluetooth

private let serviceId = CBUUID(string: "F4C514A0-9E6B-46E6-A787-E7475BCCD36E")

protocol BluetoothManagerDelegate: AnyObject {
    func bluetoothManagerDidDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String: Any])
}

class BluetoothManager: NSObject {
    weak var delegate: BluetoothManagerDelegate?
    
    private var name = ""
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?

    func start(deviceId: String) {
        name = deviceId
        startAdvertising()
        startScanning()
    }
    
    private func startAdvertising() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
    }

    private func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

extension BluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return print("Peripheral is in invalid state: \(peripheral.state)") }
        
        if peripheral.isAdvertising {
            print("Stopping BLE advertisements")
            peripheral.stopAdvertising()
        }

        print("Starting BLE advertisements")
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceId],
            CBAdvertisementDataLocalNameKey: name,
        ])
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return print("Central is in invalid state: \(central.state)") }

        if central.isScanning {
            print("Stopping BLE scanning")
            central.stopScan()
        }

        print("Starting BLE scanning")
        central.scanForPeripherals(withServices: [serviceId])
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral)")
        delegate?.bluetoothManagerDidDiscoverPeripheral(peripheral, advertisementData: advertisementData)
    }
}

