//
//  CustomPolygonLocationMarker.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 23/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomPolygonLocationMarker: GMSMarker {
    
    //MARK:- Variables
    var customPolygon: GMSPolygon?
    var path: GMSPath? {
        didSet {
            customPolygon?.path = self.path
        }
    }
    
    override init() {
        super.init()
        
        customPolygon = GMSPolygon(path: path)
        customPolygon?.fillColor = UIColor(hex: Constant.COLOR_MAIN_BLUE).withAlphaComponent(0.5)
        customPolygon?.strokeColor = UIColor(white: 0.9, alpha: 0.5)
        customPolygon?.strokeWidth = 1
    }
    
    override var map: GMSMapView? {
        willSet {
            if CLLocationCoordinate2DIsValid(self.position) {
                DispatchQueue.main.async { 
                    self.customPolygon?.map = newValue
                }
            }
        }
    }
}

