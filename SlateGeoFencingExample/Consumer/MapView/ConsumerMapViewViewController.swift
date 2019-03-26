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

class ConsumerMapViewViewController: MasterMapViewViewController {

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
    var connectionStatus: ConnectionStatus = .notChecked
    
    /*
     * If currentConnectedGeofenceArea has value it is the geofence that the user is currently inside, if nil user is not inside any geofenced area.
     */
    var currentConnectedGeofenceArea: LocationPointList?
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        self.setupDataAndDrawGeofences()
        self.startWifiMonitoring()
        self.startGeofenceMonitoring()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setMainThemeWith(alpha: 1.00)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        WifiManager.sharedInstance.listenToUpdateWifiInfo = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Override functions
    internal override func setupMap() {
        super.setupMap()
        
        self.vwGoogleMapContainer.addSubview(gmsMapView)
        self.gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.gmsMapView.topAnchor.constraint(equalTo: self.vwGoogleMapContainer.topAnchor),
            self.gmsMapView.leadingAnchor.constraint(equalTo: self.vwGoogleMapContainer.leadingAnchor),
            self.gmsMapView.bottomAnchor.constraint(equalTo: self.vwGoogleMapContainer.bottomAnchor),
            self.gmsMapView.trailingAnchor.constraint(equalTo: self.vwGoogleMapContainer.trailingAnchor)
            ])
    }
    
    internal override func getCurrentLocation() {
        super.getCurrentLocation()
        
        self.locationManager.delegate = self
    }
    
    //MARK:- Private functions
    private func setupUI() {
        self.navigationItem.title = LocalizedConstant.NAVBAR_TITLE_GEOGATE
        
        let bbiCenterLocation = UIBarButtonItem(image: UIImage(named: "btnCenterLocation"),
                                                style: .plain,
                                                target: self, action: #selector(actCenterLocation(sender:)))
        self.navigationItem.setRightBarButton(bbiCenterLocation, animated: false)
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
