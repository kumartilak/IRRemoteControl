//
//  KeysRowController.swift
//  IRWatchPOC Extension
//
//  Created by Tilak Kumar on 29/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import WatchKit

class KeysRowController: NSObject {
    @IBOutlet var remoteKeyLabel: WKInterfaceLabel!
    var remoteKey: RemoteKey? {
      didSet {
        guard let rk = remoteKey else { return }
        remoteKeyLabel.setText(rk.key)
      }
    }
}
