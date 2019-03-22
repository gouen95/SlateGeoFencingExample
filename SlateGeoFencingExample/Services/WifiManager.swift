//
//  WIFISSIDManager.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

extension UIDevice {
    var WiFiSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
}

class WIFISSIDManager {
    
}
