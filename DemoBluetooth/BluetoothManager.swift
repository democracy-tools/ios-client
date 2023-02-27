import Foundation
import CoreBluetooth
import CoreLocation

enum Constants: String {
    case SERVICE_UUID = "4DF91029-B356-463E-9F48-BAB077BF3EF5"
}

protocol BluetoothManagerDelegate: AnyObject {
    func peripheralsDidUpdate()
}

protocol BluetoothManager {
    var peripherals: Dictionary<UUID, CBPeripheral> { get }
    var delegate: BluetoothManagerDelegate? { get set }
    func startAdvertising(with name: String)
    func startScanning()
    func setLocation(with location: CLLocationCoordinate2D)
}

class CoreBluetoothManager: NSObject, BluetoothManager {
    // MARK: - Public properties
    weak var delegate: BluetoothManagerDelegate?
    private(set) var peripherals = Dictionary<UUID, CBPeripheral>() {
        didSet {
            delegate?.peripheralsDidUpdate()
        }
    }
    private(set) var logs = Logs()
    
    // MARK: - Public methods
    func startAdvertising(with name: String) {
        self.name = name
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func setLocation(with location: CLLocationCoordinate2D) {
        locationCoordinate = location
    }
    
    // MARK: - Private properties
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    private var name: String?
    private var locationCoordinate: CLLocationCoordinate2D?
}

extension CoreBluetoothManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }

            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            var advertisingData: [String : Any] = [
                CBAdvertisementDataServiceUUIDsKey: [uuid]
            ]

            if let name = self.name {
                advertisingData[CBAdvertisementDataLocalNameKey] = name
            }
            self.peripheralManager?.startAdvertising(advertisingData)
        } else {
            #warning("handle other states")
        }
    }
}

extension CoreBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {

            if central.isScanning {
                central.stopScan()
            }

//            let uuid = CBUUID(string: Constants.SERVICE_UUID.rawValue)
            central.scanForPeripherals(withServices: [])
        } else {
            #warning("Error handling")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {

        let original = Date()
        let dateRoundedToMin = Date(timeIntervalSinceReferenceDate: (original.timeIntervalSinceReferenceDate / 60.0).rounded(.toNearestOrEven) * 60.0)
        
        if let latitude = locationCoordinate?.latitude, let longitude = locationCoordinate?.longitude {
            if let name = peripheral.name {
                let logKey = LogKey(latitude: roundLoc(latitude),
                                    longitude: roundLoc(longitude),
                                    deviceName: name,
                                    timestamp: dateRoundedToMin.timeIntervalSince1970)
                
                let logEntry = LogEntry(timestamp: Date())
                
                if logs[logKey] == nil {
                    logs[logKey] = logEntry
                    updateServer(logKey: logKey)
                }
            }
        }

//        peripherals[peripheral.identifier] = peripheral
    }

    func roundLoc(_ d: Double) -> Double {
        return Double(round(10000 * d) / 10000)
    }
}

