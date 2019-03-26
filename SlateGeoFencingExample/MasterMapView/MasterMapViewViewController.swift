//
//  MasterMapViewViewController.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 26/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import GoogleMaps

class MasterMapViewViewController: UIViewController {
    //MARK:- Variables
    var gmsMapView: GMSMapView = {
        let mapView = GMSMapView()
        return mapView
    }()
    var userLocationMarker: CustomUserLocationMarker = {
        let marker = CustomUserLocationMarker()
        return marker
    }()
    var locationManager: CLLocationManager = {
        return CLLocationManager()
    }()
    var geofenceMarkers: [GMSMarker] = []
    var userCurrentLocation: CLLocation?
    var isFirstTimeGettingUserLocation: Bool = true
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getCurrentLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.locationManager.stopUpdatingLocation()
        
        for eachMonitoredRegion in self.locationManager.monitoredRegions {
            self.locationManager.stopMonitoring(for: eachMonitoredRegion)
        }
    }
    
    //MARK:- Private functions
    internal func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    internal func setupMap(){
        do {
            if let styleURL = Bundle.main.url(forResource: "GoogleMapStyle", withExtension: "json") {
                gmsMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to GoogleMapStyle style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        self.userLocationMarker.map = gmsMapView
        self.userLocationMarker.radarMeter = 15
        let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_LOCATION)
        userLocationMarker.iconView = ivMarkerIcon
    }
    
    internal func addMarker(bean: LocationPayloadBean) {
        for (index, eachList) in bean.locPointListBean.enumerated() {
            if eachList.shapeFlagString == "R" {
                let customMarker = CustomUserLocationMarker(radius: eachList.radius, latitude: eachList.latitude, longitude:  eachList.longitude)
                let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_PIN)
                customMarker.iconView = ivMarkerIcon
                customMarker.title = eachList.locName
                customMarker.map = self.gmsMapView
                
                customMarker.userData = index
                
                geofenceMarkers.append(customMarker)
            } else {
                let gmsMarker = CustomPolygonLocationMarker(position: CLLocationCoordinate2D(latitude: Double(eachList.latitude), longitude: Double(eachList.longitude)))
                let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_PIN)
                gmsMarker.iconView = ivMarkerIcon
                gmsMarker.title = eachList.locName
                gmsMarker.map = self.gmsMapView
                
                let mutablePath = GMSMutablePath()
                if let polygonPoints = eachList.polygonLocPoint {
                    for eachPolygonPoint in polygonPoints {
                        mutablePath.add(CLLocationCoordinate2D(latitude: Double(eachPolygonPoint.latitude), longitude: Double(eachPolygonPoint.longitude)))
                    }
                }
                gmsMarker.path = mutablePath
                
                gmsMarker.userData = index
                
                geofenceMarkers.append(gmsMarker)
            }
        }
    }
    
    @objc internal func actCenterLocation(sender: UIBarButtonItem) {
        if let userCurrentLocation = userCurrentLocation {
            let camera = GMSCameraPosition.camera(withLatitude: userCurrentLocation.coordinate.latitude, longitude: userCurrentLocation.coordinate.longitude, zoom: cameraZoom)
            self.gmsMapView.animate(to: camera)
        }
    }
    
    internal func clearMap() {
        if geofenceMarkers.count > 0 {
            for eachMarker in geofenceMarkers {
                eachMarker.map = nil
            }
        }
    }
}
