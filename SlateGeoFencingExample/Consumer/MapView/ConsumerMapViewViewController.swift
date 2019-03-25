//
//  ConsumerMapViewViewController.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 24/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import GoogleMaps
import Reachability

class ConsumerMapViewViewController: UIViewController {

    enum ConnectionStatus : String {
        case insideGeofenceWithWifi     = "Connected via being inside Geofence area and WiFi coverage"
        case outsideGeofenceWithWifi    = "Connected via WiFi coverage but outside of Geofence area"
        case insideGeofenceWithoutWifi  = "Connected via being inside Geofence area but not in WiFi coverage"
        case outsideGeofenceWithoutWifi = "Not connected to any Geofence area"
        
        case notChecked                 = "Please wait..."
    }
    
    //MARK:- IBOutlets
    @IBOutlet weak var vwGoogleMapContainer: UIView!
    @IBOutlet weak var lblConnectionStatus: UILabel!
    @IBOutlet weak var ivConnectionStatus: UIImageView!
    
    //MARK:- Variables
    var locationPayloadBean: LocationPayloadBean?
    var geofenceMarkers: [GMSMarker] = []
    
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
    var userCurrentLocation: CLLocation?
    var isFirstTimeGettingUserLocation: Bool = true
    
    var connectionStatus: ConnectionStatus = .notChecked
    
    /*
     * If currentConnectedGeofenceArea has value it is the geofence that the user is currently inside, if nil user is not inside any geofenced area.
     */
    var currentConnectedGeofenceArea: LocationPointList?
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupMap()
        
        self.setupDataAndDrawGeofences()
        self.startWifiMonitoring()
        self.startGeofenceMonitoring()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setMainThemeWith(alpha: 1.00)
        
        self.getCurrentLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        WifiManager.sharedInstance.listenToUpdateWifiInfo = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Private functions
    private func setupUI() {
        self.navigationItem.title = LocalizedConstant.NAVBAR_TITLE_GEOGATE
        
        let bbiCenterLocation = UIBarButtonItem(image: UIImage(named: "btnCenterLocation"),
                                                style: .plain,
                                                target: self, action: #selector(actCenterLocation(sender:)))
        self.navigationItem.setRightBarButton(bbiCenterLocation, animated: false)
    }
    
    private func setupMap() {
//        self.gmsMapView.delegate = self
        
        do {
            if let styleURL = Bundle.main.url(forResource: "GoogleMapStyle", withExtension: "json") {
                gmsMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to GoogleMapStyle style.json")
            }
        } catch {
            print("One or more of the map styles failed to load. \(error)")
        }
        
        self.vwGoogleMapContainer.addSubview(gmsMapView)
        self.gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.gmsMapView.topAnchor.constraint(equalTo: self.vwGoogleMapContainer.topAnchor),
            self.gmsMapView.leadingAnchor.constraint(equalTo: self.vwGoogleMapContainer.leadingAnchor),
            self.gmsMapView.bottomAnchor.constraint(equalTo: self.vwGoogleMapContainer.bottomAnchor),
            self.gmsMapView.trailingAnchor.constraint(equalTo: self.vwGoogleMapContainer.trailingAnchor)
            ])
        
        self.userLocationMarker.map = gmsMapView
        self.userLocationMarker.radarMeter = 15
        let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_LOCATION)
        userLocationMarker.iconView = ivMarkerIcon
    }
    
    private func setupDataAndDrawGeofences() {
        StorageTool.loadLocationPayloadBean { (result) in
            switch result {
            case .success(let bean):
                self.locationPayloadBean = bean
            case .failure( _):
                //Use hardcoded value if not new data
                if let jsonData = geofenceJSONString.data(using: .utf8) {
                    do {
                        self.locationPayloadBean = try JSONDecoder().decode(LocationPayloadBean.self, from: jsonData)
                    } catch {
                        self.view.makeToast("Failed to decode JSON")
                    }
                }
            }
        }
        
        if self.locationPayloadBean != nil {
            self.clearMap()
            self.addMarker(bean: self.locationPayloadBean!)
        }
    }
    
    private func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    private func startGeofenceMonitoring() {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            self.view.makeToast("Geofencing is not support on this device.")
            return
        }
        
        if let locPointListBean = locationPayloadBean?.locPointListBean {
            for eachList in locPointListBean {
                if eachList.shapeFlagString == "R" {
                    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: Double(eachList.latitude), longitude: Double(eachList.longitude)), radius: Double(eachList.radius), identifier: String(describing: eachList.locPointID))
                    
                    locationManager.startMonitoring(for: region)
                }
            }
        }
    }
    
    private func startWifiMonitoring() {
        WifiManager.sharedInstance.listenToUpdateWifiInfo = {
            self.checkGeofenceAndWifiCoverage()
        }
    }
    
    private func checkGeofenceAndWifiCoverage() {
        if WifiManager.sharedInstance.isConnectedToWifi {
            
            var isConnectedViaWifi: Bool = false
            var isConnectedViaGeofence: Bool = false
            
            if let unwrappedLocPointListBean = locationPayloadBean?.locPointListBean, locationPayloadBean != nil {
                for eachLocPoint in unwrappedLocPointListBean {
                    //1. Check Wifi
                    if let wifiInfo = eachLocPoint.locationWifiInfo {
                        if wifiInfo.ssid == WifiManager.sharedInstance.currentWifiInfo?.ssid {
                            isConnectedViaWifi = true
                            
                            break;
                        }
                    }
                    //2. Check Geofence
                    if self.currentConnectedGeofenceArea != nil {
                        isConnectedViaGeofence = true
                    }
                }
            }
            
            if isConnectedViaWifi && isConnectedViaGeofence {
                self.connectionStatus = .insideGeofenceWithWifi
            } else if isConnectedViaGeofence && !isConnectedViaWifi {
                self.connectionStatus = .insideGeofenceWithoutWifi
            } else if !isConnectedViaGeofence && isConnectedViaWifi {
                self.connectionStatus = .outsideGeofenceWithWifi
            } else if !isConnectedViaGeofence && !isConnectedViaWifi {
                self.connectionStatus = .outsideGeofenceWithoutWifi
            }
            
            self.updateConnectionStatusLabel()
        } else {
            //Check Geofence only
            //ConnectionStatus.insideGeofenceWithoutWifi
            //ConnectionStatus.outsideGeofenceWithoutWifi
            if self.currentConnectedGeofenceArea != nil {
                self.connectionStatus = .insideGeofenceWithoutWifi
            } else {
                self.connectionStatus = .outsideGeofenceWithoutWifi
            }
            
            self.updateConnectionStatusLabel()
        }
    }
    
    private func updateConnectionStatusLabel() {
        self.lblConnectionStatus.text = self.connectionStatus.rawValue
        
        switch self.connectionStatus {
        case .insideGeofenceWithWifi:
            self.ivConnectionStatus.image = UIImage(named: Constant.IMG_POWER_BTN_ON)
            break;
        case .insideGeofenceWithoutWifi:
            self.ivConnectionStatus.image = UIImage(named: Constant.IMG_PWOER_BTN_YELLOW)
            break;
        case .outsideGeofenceWithWifi:
            self.ivConnectionStatus.image = UIImage(named: Constant.IMG_PWOER_BTN_YELLOW)
            break;
        case .outsideGeofenceWithoutWifi:
            self.ivConnectionStatus.image = UIImage(named: Constant.IMG_POWER_BTN_OFF)
            break;
        case .notChecked:
            self.ivConnectionStatus.image = UIImage(named: Constant.IMG_POWER_BTN_OUTLINE)
            break;
        }
    }
    
    private func checkFirstRetrievedLocationVsGeofencing() {
        if let unwrappedLocPointListBean = locationPayloadBean?.locPointListBean, locationPayloadBean != nil {
            for eachLocPoint in unwrappedLocPointListBean {
                if self.locationManager.location != nil {
                    let locationDistance = CLLocation(latitude: Double(eachLocPoint.latitude), longitude: Double(eachLocPoint.longitude)).distance(from: (self.locationManager.location!))
                    
                    print("Inside Geofence ? \(locationDistance < Double(eachLocPoint.radius))")
                    if locationDistance < Double(eachLocPoint.radius) {
                        self.currentConnectedGeofenceArea = eachLocPoint
                    
                        break;
                    }
                }
            }
            
            self.checkGeofenceAndWifiCoverage()
        }
        
    }
    
    
    
    
    
    
    private func clearMap() {
        if geofenceMarkers.count > 0 {
            for eachMarker in geofenceMarkers {
                eachMarker.map = nil
            }
        }
    }
    
    private func addMarker(bean: LocationPayloadBean) {
        for (_, eachList) in bean.locPointListBean.enumerated() {
            if eachList.shapeFlagString == "R" {
                let customMarker = CustomUserLocationMarker(radius: eachList.radius, latitude: eachList.latitude, longitude:  eachList.longitude)
                let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_PIN)
                customMarker.iconView = ivMarkerIcon
                customMarker.title = eachList.locName
                customMarker.map = self.gmsMapView
                
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
                
                geofenceMarkers.append(gmsMarker)
            }
        }
    }
    
    @objc private func actCenterLocation(sender: UIBarButtonItem) {
        if let userCurrentLocation = userCurrentLocation {
            let camera = GMSCameraPosition.camera(withLatitude: userCurrentLocation.coordinate.latitude, longitude: userCurrentLocation.coordinate.longitude, zoom: cameraZoom)
            self.gmsMapView.animate(to: camera)
        }
    }
}

//MARK:- LocationManagerDelegate
extension ConsumerMapViewViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCurrentLocation = locations.last
        
        userLocationMarker.position = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
        
        if isFirstTimeGettingUserLocation {
            let camera = GMSCameraPosition.camera(withLatitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!, zoom: cameraZoom)
            
            CATransaction.begin()
            CATransaction.setValue(0, forKey: kCATransactionAnimationDuration)
            self.gmsMapView.animate(to: camera)
            CATransaction.commit()
            
            //Check if first location retrieved is inside Geofenced area
            self.checkFirstRetrievedLocationVsGeofencing()
            
            isFirstTimeGettingUserLocation = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Enter Region")
        if let unwrappedLocPointListBean = locationPayloadBean?.locPointListBean, locationPayloadBean != nil {
            for eachLocPoint in unwrappedLocPointListBean {
                if String(describing: eachLocPoint.locPointID) == region.identifier {
                    self.currentConnectedGeofenceArea = eachLocPoint
                    
                    break;
                }
            }
        }
        
        self.checkGeofenceAndWifiCoverage()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exit Region")
        self.currentConnectedGeofenceArea = nil
        
        self.checkGeofenceAndWifiCoverage()
    }
}
