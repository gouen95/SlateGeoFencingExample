//
//  CustomUserLocationMarker.swift
//  SmartCity_ConsumerApp
//
//  Created by Brandon Wong Ka Seng on 21/06/2018.
//  Copyright © 2018 Brandon Wong Ka Seng. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomUserLocationMarker: GMSMarker {
    
    //MARK:- Variables
    var customCircle: GMSCircle?
    var radarMeter: Double? {
        didSet {
            customCircle?.radius = radarMeter!
        }
    }
    
    override init() {
        super.init()
        
        self.radarMeter = 130
        customCircle = GMSCircle(position: CLLocationCoordinate2D(latitude: 37.35, longitude: -122.0), radius: radarMeter!)
        customCircle?.fillColor = UIColor(hex: Constant.COLOR_TITLE_LIGHTBLUE).withAlphaComponent(0.5)
        customCircle?.strokeColor = UIColor(white: 0.9, alpha: 0.5)
        customCircle?.strokeWidth = 1
    }
    
    override var position: CLLocationCoordinate2D {
        didSet {
            customCircle?.position = position
            
            if customCircle?.map == nil && CLLocationCoordinate2DIsValid(self.position) {
                customCircle?.map = self.map
            }
        }
    }
    
    override var map: GMSMapView? {
        didSet {
            if CLLocationCoordinate2DIsValid(self.position) {
                customCircle?.map = map
            }
        }
    }
}
