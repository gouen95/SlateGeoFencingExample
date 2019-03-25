//
//  LocationPayloadBean.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import Foundation

struct LocationPayloadBean: Codable {
    var responseCode: String?
    var responseMsg: String?
    
    var locPointListBean: [LocationPointList]
    
    init(responseCode: String?, responseMsg: String?, locPointListBean: [LocationPointList]) {
        self.responseCode = responseCode
        self.responseMsg = responseMsg
        self.locPointListBean = locPointListBean
    }
}

struct LocationPointList: Codable {
    var locPointID: Int
    var locName: String
    var locDesc: String?
    
    var latitude: Float
    var longitude: Float
    var shapeFlagString: String //P or R, P = polygon, R = radius
    var radius: Float
    
    var polygonLocPoint: [PolygonLocationPoint]?
    
    var locationWifiInfo: WifiInfo?
    
    init(locPointID: Int, locName: String, locDesc: String?, latitude: Float, longitude: Float, shapeFlagString: String, radius: Float, polygonLocPoint: [PolygonLocationPoint]?, locationWifiInfo: WifiInfo?) {
        self.locPointID = locPointID
        self.locName = locName
        self.locDesc = locDesc
        self.latitude = latitude
        self.longitude = longitude
        self.shapeFlagString = shapeFlagString
        self.radius = radius
        self.polygonLocPoint = polygonLocPoint
        self.locationWifiInfo = locationWifiInfo
    }
}

struct PolygonLocationPoint: Codable {
    var latitude: Float
    var longitude: Float
    
    init(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
