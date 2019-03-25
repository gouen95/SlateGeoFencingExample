//
//  WifiManager.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import Reachability

extension UIDevice {
    var WifiSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    
    var WifiBSSID: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeyBSSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    
    var WifiSSIDData: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
        let key = kCNNetworkInfoKeySSIDData as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else { continue }
            return interfaceInfo[key] as? String
        }
        return nil
    }
}

class WifiManager: NSObject {
    
    //MARK:- Singleton
    static let sharedInstance = WifiManager()
    
    //MARK:- Variable
    var reachability: Reachability!
    
    private(set) var currentWifiInfo: WifiInfo?
    var isConnectedToWifi: Bool = false
    
    var listenToUpdateWifiInfo: (()->())?
    
    private override init() {
        super.init()
        
        self.reachability = Reachability()
        self.registerListener()
    }
    
    private func getWifiInfo() -> WifiInfo? {
        if let ssid =  UIDevice().WifiSSID {
            return WifiInfo(ssid: ssid, bssid: UIDevice().WifiBSSID, ssidData: UIDevice().WifiSSIDData)
        } else {
            return nil
        }
    }
    
    private func registerListener() {
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.isConnectedToWifi = true
                self.currentWifiInfo = self.getWifiInfo()
            } else {
                self.isConnectedToWifi = false
                self.currentWifiInfo = nil
            }
            
            self.listenToUpdateWifiInfo?()
        }
        
        reachability.whenUnreachable = { _ in
            self.isConnectedToWifi = false
            self.currentWifiInfo = nil
            
            
            self.listenToUpdateWifiInfo?()
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            
        }
    }
}

struct WifiInfo: Codable {
    var ssid: String?
    var bssid: String?
    var ssidData: String?
    
    init(ssid: String?, bssid: String?, ssidData: String?) {
        self.ssid = ssid
        self.bssid = bssid
        self.ssidData = ssidData
    }
}
