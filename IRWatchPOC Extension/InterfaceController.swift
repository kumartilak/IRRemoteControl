//
//  InterfaceController.swift
//  IRWatchPOC Extension
//
//  Created by Tilak Kumar on 27/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet weak var connectButton: WKInterfaceButton!
    
    private var remoteKeys: [RemoteKey]?
    
    private var bleManager = BLEManager.shared
    
    private enum BLEState: Equatable {
        case BLEEnabled, BLEDisabled, DeviceConnected, DeviceNotConnected
    }
    
    private var bleCurrentState: BLEState = .BLEDisabled {
        didSet {
            switch bleCurrentState {
            case BLEState.BLEDisabled:
                connectButton.setEnabled(false)
                connectButton.setTitle("Disabled")
            case BLEState.BLEEnabled, BLEState.DeviceNotConnected:
                connectButton.setEnabled(true)
                connectButton.setTitle("Connect")
            case BLEState.DeviceConnected:
                connectButton.setEnabled(false)
                connectButton.setTitle("Connected")
            }
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let remoteKeyDataSource = RemoteKeysDataSource(fileName: "RemoteKeys", type: "json")
        self.remoteKeys = remoteKeyDataSource.remoteKeys
        if let rk = self.remoteKeys {
            table.setNumberOfRows(rk.count, withRowType: "RemoteKeys")
            for index in 0..<table.numberOfRows {
              guard let controller = table.rowController(at: index) as? KeysRowController else { continue }
              controller.remoteKey = rk[index]
            }
        }
        
        //BLE
        self.bleManager.bleManagerDelegate = self
        self.bleManager.setup()
        if (self.bleManager.isInitialized) {
            self.bleCurrentState = BLEState.BLEEnabled
        }
        else {
            self.bleCurrentState = BLEState.BLEDisabled
        }
        
        self.bleManager.bleDeviceConnectionDelegate = self
        if (self.bleManager.isDeviceConnected) {
            self.bleCurrentState = BLEState.DeviceConnected
        }
        else {
            self.bleCurrentState = BLEState.DeviceNotConnected
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if let rks = self.remoteKeys {
            let rk = rks[rowIndex]
            if let ascii = rk.ascii {
                self.bleManager.send(ircode: ascii)
            }
        }
    }
    
    @IBAction func connectButtonClicked() {
        self.bleManager.startConnecting()
    }
}

extension InterfaceController: BLEManagerDelegate {
    func bleManagerInitialized() {
        print("BLEManager initialzed!")
        self.bleCurrentState = .BLEEnabled
    }
    
    func bleManagerFailedInitializing() {
        print("BLEManager failed initializing!")
        self.bleCurrentState = .BLEDisabled
    }
}

extension InterfaceController: BLEDeviceConnectionDelegate {
    func bleManagerConnectedToDevice() {
        self.bleCurrentState = .DeviceConnected
    }
    
    func bleManagerFailedConnectingToDevice() {
        self.bleCurrentState = .DeviceNotConnected
    }
    
    func bleManagerDisconnectedWithDevice() {
        self.bleCurrentState = .DeviceNotConnected
    }
    
    func bleManagerDidSendData() {
        print("BLEManager: Successfully sent ascii code!")
    }
}
