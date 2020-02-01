//
//  MainViewModel.swift
//  IRRemotePOC
//
//  Created by Tilak Kumar on 27/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import Foundation
import UIKit

protocol MainViewModelDelegate: class {
    func showError(message: String)
    func changeConnectButton(state: Bool)
    func updateTitle(text: String)
}

class MainViewModel: NSObject {
    fileprivate let kCellKey = "remotekeycell"
    fileprivate let bleManager = BLEManager.shared
    fileprivate let remoteKeys: Array<RemoteKey>?

    weak var viewModelDelegate: MainViewModelDelegate?

    override init() {
        let remoteKeysDatasource = RemoteKeysDataSource(fileName: "RemoteKeys", type: "json")
        remoteKeys = remoteKeysDatasource.remoteKeys
        super.init()
    }
    
    func setup() {
        self.bleManager.bleManagerDelegate = self
        self.bleManager.setup()
        
        if let delegate = self.viewModelDelegate {
            delegate.updateTitle(text: "Disconnected")
        }
    }
    
    func connectToDevice() {
        self.bleManager.bleDeviceConnectionDelegate = self
        self.bleManager.startConnecting()
    }
}

extension MainViewModel: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rk = self.remoteKeys {
            return rk.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:self.kCellKey , for: indexPath)
        cell.textLabel?.text = self.getKeyAt(index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let key = getKeyAt(index: indexPath.row) {
            if let irCodeStr = getValueFor(key: key) {
                BLEManager.shared.send(ircode: irCodeStr)
            }
        }
    }
    
    fileprivate func getKeyAt(index: Int) -> String? {
        if let rk = self.remoteKeys {
            let remoteKey = rk.filter { $0.position == index}.first
            return remoteKey?.key
        }
        return nil
    }
    
    fileprivate func getValueFor(key: String) -> String? {
        if let rk = self.remoteKeys {
            let remoteKey = rk.filter { $0.key == key}.first
            return remoteKey?.ascii
        }
        return nil
    }
}

extension MainViewModel: BLEManagerDelegate {
    func bleManagerInitialized() {
        print("BLE Manager initialized")
    }
    
    func bleManagerFailedInitializing() {
        print("BLE Manager failed initializing")
        if let delegate = self.viewModelDelegate {
            delegate.showError(message: "Error while enabling Bluetooth, please try again!")
        }
    }
}

extension MainViewModel: BLEDeviceConnectionDelegate {
    func bleManagerConnectedToDevice() {
        if let delegate = self.viewModelDelegate {
            delegate.updateTitle(text: "Connected")
            delegate.changeConnectButton(state: false)
        }
    }
    
    func bleManagerFailedConnectingToDevice() {
        if let delegate = self.viewModelDelegate {
            delegate.updateTitle(text: "Disconnected")
            delegate.changeConnectButton(state: true)
        }
    }
    
    func bleManagerDisconnectedWithDevice() {
        if let delegate = self.viewModelDelegate {
            delegate.updateTitle(text: "Disconnected")
            delegate.changeConnectButton(state: true)
        }
    }
    
    func bleManagerDidSendData() {
        print("bleManagerDidSendData")
    }
}
