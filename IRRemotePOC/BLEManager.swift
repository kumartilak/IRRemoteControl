//
//  BLEManager.swift
//  IRRemotePOC
//
//  Created by Tilak Kumar on 24/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate: class {
    func bleManagerInitialized()
    func bleManagerFailedInitializing()
}

protocol BLEDeviceConnectionDelegate: class {
    func bleManagerConnectedToDevice()
    func bleManagerFailedConnectingToDevice()
    func bleManagerDisconnectedWithDevice()
    func bleManagerDidSendData()
}

class BLEManager: NSObject {
    private override init() { }
    fileprivate let kPrimaryServiceUUID = CBUUID(string: "FFE0")
    fileprivate let kWriteCharacteristicsUUID = CBUUID(string: "FFE1")
    fileprivate var centralManager: CBCentralManager?
    fileprivate var peripheral: CBPeripheral?
    fileprivate var payload: Data?
    
    static let shared = BLEManager()
    weak var bleManagerDelegate: BLEManagerDelegate?
    weak var bleDeviceConnectionDelegate: BLEDeviceConnectionDelegate?
    
    var isDeviceConnected: Bool {
        if let p = peripheral {
            return p.state == .connected
        }
        else {
            return false
        }
    }
    
    var isInitialized: Bool {
        if let cm = centralManager {
            return cm.state == .poweredOn
        }
        else {
            return false
        }
    }
    
    func setup() {
        if !isInitialized {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
    }
    
    func startConnecting() {
        self.centralManager?.scanForPeripherals(withServices: [kPrimaryServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    func send(ircode: String) {
        if isDeviceConnected {
            self.payload = ircode.hexadecimal()
            self.peripheral!.delegate = self
            self.peripheral!.discoverServices([kPrimaryServiceUUID])
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            if let delegate = self.bleManagerDelegate {
                delegate.bleManagerInitialized()
            }
        case .resetting, .unauthorized, .unknown, .unsupported, .poweredOff:
            if let delegate = self.bleManagerDelegate {
                delegate.bleManagerFailedInitializing()
            }
        @unknown default:
            if let delegate = self.bleManagerDelegate {
                delegate.bleManagerFailedInitializing()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        centralManager?.connect(peripheral, options: nil)
        centralManager?.stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if (peripheral.state == .connected) {
            if let delegate = self.bleDeviceConnectionDelegate {
                delegate.bleManagerConnectedToDevice()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let delegate = self.bleDeviceConnectionDelegate {
            delegate.bleManagerFailedConnectingToDevice()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let delegate = self.bleDeviceConnectionDelegate {
            delegate.bleManagerDisconnectedWithDevice()
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if (service.isPrimary && service.uuid.uuidString == kPrimaryServiceUUID.uuidString) {
                peripheral.discoverCharacteristics([kWriteCharacteristicsUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics ?? [] {
            if characteristic.uuid.uuidString == kWriteCharacteristicsUUID.uuidString {
                if characteristic.properties.contains(CBCharacteristicProperties.write) || characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                    if let pl = self.payload {
                        peripheral.writeValue(pl, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        if descriptor.characteristic.uuid.uuidString == kWriteCharacteristicsUUID.uuidString {
            if let delegate = self.bleDeviceConnectionDelegate {
                delegate.bleManagerDidSendData()
            }
        }
    }
}
