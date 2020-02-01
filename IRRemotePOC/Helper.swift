//
//  Helper.swift
//  IRRemotePOC
//
//  Created by Tilak Kumar on 27/01/20.
//  Copyright © 2020 Tilak Kumar. All rights reserved.
//

import Foundation

extension String {

func hexadecimal() -> Data? {
    var data = Data(capacity: count / 2)

    let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
    regex.enumerateMatches(in: self, options: [], range: NSMakeRange(0, count)) { match, flags, stop in
        let byteString = (self as NSString).substring(with: match!.range)
        var num = UInt8(byteString, radix: 16)!
        data.append(&num, count: 1)
    }

    guard data.count > 0 else {
        return nil
    }

    return data
 }
}
