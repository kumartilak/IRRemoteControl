//
//  RemoteKeysDataSource.swift
//  IRRemotePOC
//
//  Created by Tilak Kumar on 29/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import Foundation

enum WatchActionType: String {
    case kMessageField = "Field", kConnectAction = "Connect", kKeyPressed = "KeyPressed", kGetConnectionStatus = "ConnectionStatus", kConnectionStatusConnected = "Connected", kConnectionStatusDisconnected = "NotConnected"
}

class RemoteKeysDataSource {
    var remoteKeys: Array<RemoteKey>?
    
    init(fileName: String, type: String) {
        let json = readJSONFromFile(fileName: fileName, type: type)
        if let data = json {
            do {
                let decoder = JSONDecoder()
                let itemsModel = try decoder.decode(RemoteKeysData.self, from: data)
                remoteKeys = itemsModel.remoteKeys
            }
            catch {
                print("Error info: \(error)")
            }
        }
    }
}


func readJSONFromFile(fileName: String, type: String) -> Data?
{
    var json: Data?
    if let path = Bundle.main.path(forResource: fileName, ofType: type) {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            // Getting data from JSON file using the file URL
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            json = data
        } catch {
            // Handle error here
            print("Exception")
        }
    }
    return json
}

struct RemoteKeysData: Codable {
    var remoteKeys: Array<RemoteKey>
    
    private enum CodingKeys: String, CodingKey {
        case remoteKeys = "LG"
    }
    
    init(keys: Array<RemoteKey>) {
        self.remoteKeys = keys
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let keys = try values.decode(Array<RemoteKey>.self, forKey: .remoteKeys)
        self.init(keys: keys)
    }
}

struct RemoteKey: Codable{
    var key: String?
    var ascii: String?
    var position: Int?
    
    private enum CodingKeys: String, CodingKey {
           case key = "key"
           case position = "position"
           case ascii = "ascii"
    }
    
    init(key: String, position: Int, ascii: String) {
        self.key = key
        self.position = position
        self.ascii = ascii
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let key = try values.decode(String.self, forKey: .key)
        let ascii = try values.decode(String.self, forKey: .ascii)
        let position = try values.decode(Int.self, forKey: .position)

        self.init(key: key, position: position, ascii: ascii)
    }
}
