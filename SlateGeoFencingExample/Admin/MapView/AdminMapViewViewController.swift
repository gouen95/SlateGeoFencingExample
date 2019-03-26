//
//  AdminMapViewViewController.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import GoogleMaps
import Toast_Swift

class AdminMapViewViewController: MasterMapViewViewController {

    //MARK:-
    enum EditingState {
        case radius
        case radiusOngoing
        case polygon
        case polygonOngoing
        
        case existingRadius
        case existingPolygon
        
        case none
    }
    
    //MARK:- IBOutlets
    @IBOutlet weak var vwGoogleMapContainer: UIView!
    
    //MARK:- Variables
    var locationPayloadBean: LocationPayloadBean?
    var editingState = EditingState.none
    
    var editingExistingMarker: GMSMarker?
    
    let btnAddRadius: UIGradientButton = {
        let button = UIGradientButton()
        button.gradientFirstColor = UIColor(hex: Constant.COLOR_ALT_BLUE)
        button.grandientSecondColor = UIColor(hex: Constant.COLOR_MAIN_BLUE)
        button.gradientLocation = 0.5
        button.clipsToBounds = true
        button.setTitle(LocalizedConstant.BUTTON_TITLE_ADDRADIUS, for: .normal)
        return button
    }()
    let btnAddPolygon: UIGradientButton = {
        let button = UIGradientButton()
        button.gradientFirstColor = UIColor(hex: Constant.COLOR_ALT_BLUE)
        button.grandientSecondColor = UIColor(hex: Constant.COLOR_MAIN_BLUE)
        button.gradientLocation = 0.5
        button.clipsToBounds = true
        button.setTitle(LocalizedConstant.BUTTON_TITLE_ADDPOLIGON, for: .normal)
        return button
    }()
    let vwAddRadius: MapViewAddRadius = {
        let view = MapViewAddRadius()
        return view
    }()
    let vwAddPolygon: MapViewAddPolygon = {
        let view = MapViewAddPolygon()
        return view
    }()
    
    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        self.setupDataAndDrawMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setMainThemeWith(alpha: 1.00)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Override functions
    internal override func setupMap() {
        super.setupMap()
        
        super.gmsMapView.delegate = self
        
        self.vwGoogleMapContainer.addSubview(gmsMapView)
        self.gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.gmsMapView.topAnchor.constraint(equalTo: self.vwGoogleMapContainer.topAnchor),
            self.gmsMapView.leadingAnchor.constraint(equalTo: self.vwGoogleMapContainer.leadingAnchor),
            self.gmsMapView.bottomAnchor.constraint(equalTo: self.vwGoogleMapContainer.bottomAnchor),
            self.gmsMapView.trailingAnchor.constraint(equalTo: self.vwGoogleMapContainer.trailingAnchor)
            ])
        
        //Setup LongPressGesture
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(sender:)))
        longGesture.minimumPressDuration = 0.75
        longGesture.delegate = self
        self.gmsMapView.addGestureRecognizer(longGesture)
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
        
        let buttonStackView = UIStackView()
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 30
        buttonStackView.addArrangedSubview(btnAddRadius)
        buttonStackView.addArrangedSubview(btnAddPolygon)
        self.view.addSubview(buttonStackView)
        
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30),
            buttonStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
            buttonStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30),
            buttonStackView.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        buttonStackView.layoutIfNeeded()
        btnAddPolygon.layer.cornerRadius = btnAddPolygon.frame.height / 2
        btnAddRadius.layer.cornerRadius = btnAddRadius.frame.height / 2
        btnAddPolygon.clipsToBounds = true
        btnAddRadius.clipsToBounds = true
        
        btnAddPolygon.addTarget(self, action: #selector(self.actAddPolygon(sender:)), for: .touchUpInside)
        btnAddRadius.addTarget(self, action: #selector(self.actAddRadius(sender:)), for: .touchUpInside)
    }
    
    private func setupDataAndDrawMap() {
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

    private func addShowPolygonConfigurationScreen() {
        if self.vwAddPolygon.superview == nil {
            self.view.addSubview(self.vwAddPolygon)
            
            self.vwAddPolygon.delegate = self
            
            self.vwAddPolygon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.vwAddPolygon.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.vwAddPolygon.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.vwAddPolygon.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 240),
                self.vwAddPolygon.heightAnchor.constraint(equalToConstant: 240)
                ])
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.35) {
                self.vwAddPolygon.transform = CGAffineTransform(translationX: 0, y: -(self.vwAddPolygon.frame.height))
            }
        } else {
            UIView.animate(withDuration: 0.35) {
                self.vwAddPolygon.transform = CGAffineTransform(translationX: 0, y: -(self.vwAddPolygon.frame.height))
            }
        }
    }
    
    private func addShowRadiusConfigurationScreen() {
        if self.vwAddRadius.superview == nil {
            self.view.addSubview(self.vwAddRadius)
            
            self.vwAddRadius.delegate = self
            
            self.vwAddRadius.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.vwAddRadius.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.vwAddRadius.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.vwAddRadius.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 270),
                self.vwAddRadius.heightAnchor.constraint(equalToConstant: 270)
                ])
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.35) {
                self.vwAddRadius.transform = CGAffineTransform(translationX: 0, y: -(self.vwAddRadius.frame.height))
            }
        } else {
            UIView.animate(withDuration: 0.35) {
                self.vwAddRadius.transform = CGAffineTransform(translationX: 0, y: -(self.vwAddRadius.frame.height))
            }
        }
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != .began {
            return
        }
        
        switch editingState {
        case .polygonOngoing :
            let touchPoint = sender.location(in: self.gmsMapView)
            let touchPointCoordinate: CLLocationCoordinate2D = self.gmsMapView.projection.coordinate(for: touchPoint)
            
            editingPolygonPaths?.add(touchPointCoordinate)
            
            self.vwAddPolygon.locationPointList?.polygonLocPoint?.append(PolygonLocationPoint(latitude: Float((touchPointCoordinate.latitude)), longitude: Float((touchPointCoordinate.longitude))))
            
            //Insert lines
            self.drawEditingPolygon()
            
        case .polygon:
            let touchPoint = sender.location(in: self.gmsMapView)
            let touchPointCoordinate: CLLocationCoordinate2D = self.gmsMapView.projection.coordinate(for: touchPoint)
            
            editingPolygonPaths = GMSMutablePath()
            editingPolygonPaths?.removeLastCoordinate()
            editingPolygonPaths?.add(touchPointCoordinate)
            
            
            var polyLocPoint: [PolygonLocationPoint] = []
            for i in UInt(0)...(editingPolygonPaths?.count())! - 1 {
                polyLocPoint.append(PolygonLocationPoint(latitude: Float((editingPolygonPaths?.coordinate(at: i).latitude)!), longitude: Float((editingPolygonPaths?.coordinate(at: i).longitude)!)))
            }
            
            let payloadBean = LocationPayloadBean(responseCode: nil,
                                                  responseMsg: nil,
                                                  locPointListBean: [LocationPointList(locPointID: Int(Date.timeIntervalSinceReferenceDate * 10000),
                                                                                       locName: "",
                                                                                       locDesc: nil,
                                                                                       latitude: Float(touchPointCoordinate.latitude),
                                                                                       longitude: Float(touchPointCoordinate.longitude),
                                                                                       shapeFlagString: "P",
                                                                                       radius: 0,
                                                                                       polygonLocPoint: polyLocPoint,
                                                                                       locationWifiInfo: WifiManager.sharedInstance.currentWifiInfo)])
            
            //Insert lines
            self.drawEditingPolygon()
            
            //Move camera to newly added marker
            self.gmsMapView.animate(toLocation: touchPointCoordinate)
            
            //Add/Show configuration screen
            self.addShowPolygonConfigurationScreen()
            
            self.vwAddPolygon.locationPointList = payloadBean.locPointListBean[0]
            self.vwAddPolygon.txtSSID.text = payloadBean.locPointListBean[0].locationWifiInfo?.ssid
            self.vwAddPolygon.txtBSSID.text = payloadBean.locPointListBean[0].locationWifiInfo?.bssid
            self.vwAddPolygon.txtSSIDDATA.text = payloadBean.locPointListBean[0].locationWifiInfo?.ssidData
            
            editingState = .polygonOngoing
            
            break;
        case .radiusOngoing:
            break;
        case .radius:
            //Add pin+radius
            let touchPoint = sender.location(in: self.gmsMapView)
            let touchPointCoordinate: CLLocationCoordinate2D = self.gmsMapView.projection.coordinate(for: touchPoint)
            
            let payloadBean = LocationPayloadBean(responseCode: nil,
                                           responseMsg: nil,
                                           locPointListBean: [LocationPointList(locPointID: Int(Date.timeIntervalSinceReferenceDate * 10000),
                                                                                locName: "",
                                                                                locDesc: nil,
                                                                                latitude: Float(touchPointCoordinate.latitude),
                                                                                longitude: Float(touchPointCoordinate.longitude),
                                                                                shapeFlagString: "R",
                                                                                radius: 200,
                                                                                polygonLocPoint: nil,
                                                                                locationWifiInfo: WifiManager.sharedInstance.currentWifiInfo)])
            
            self.addMarker(bean: payloadBean)
            
            //Move camera to newly added marker
            self.gmsMapView.animate(toLocation: touchPointCoordinate)
            
            //Add/Show configuration screen
            self.addShowRadiusConfigurationScreen()
            
            self.vwAddRadius.locationPointList = payloadBean.locPointListBean[0]
            self.vwAddRadius.txtSSID.text = payloadBean.locPointListBean[0].locationWifiInfo?.ssid
            self.vwAddRadius.txtBSSID.text = payloadBean.locPointListBean[0].locationWifiInfo?.bssid
            self.vwAddRadius.txtSSIDDATA.text = payloadBean.locPointListBean[0].locationWifiInfo?.ssidData
            
            editingState = .radiusOngoing
        case .none:
            return
        default:
            return
        }
    }
    
    var editingPolygonPaths: GMSMutablePath?
    var editingPolygon: CustomPolygonLocationMarker?
    var editingMarkers: [GMSMarker] = []
    private func drawEditingPolygon() {
        if editingPolygon == nil {
            let coord = CLLocationCoordinate2D(latitude: (editingPolygonPaths?.coordinate(at: 0).latitude)!, longitude: (editingPolygonPaths?.coordinate(at: 0).longitude)!)
            editingPolygon = CustomPolygonLocationMarker(position: coord)
            let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_PIN)
            editingPolygon?.iconView = ivMarkerIcon
            
            editingPolygon?.path = editingPolygonPaths
            
            editingPolygon?.map = gmsMapView
        } else {
            let last = (editingPolygonPaths?.count())! - 1
            let coord = CLLocationCoordinate2D(latitude: (editingPolygonPaths?.coordinate(at: last).latitude)!, longitude: (editingPolygonPaths?.coordinate(at: last).longitude)!)
            let editingMarker = GMSMarker(position: coord)
            let ivMarkerIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            ivMarkerIcon.image = UIImage(named: Constant.IMG_ICON_PIN)
            editingMarker.iconView = ivMarkerIcon
            
            editingMarker.map = gmsMapView
            
            editingMarkers.append(editingMarker)
            
            editingPolygon?.path = editingPolygonPaths
        }
    }
    
    @objc private func actAddPolygon(sender: UIButton) {
        self.editingState = .polygon
        self.hideButtons(bool: true)
        self.view.makeToast(LocalizedConstant.MSG_LONGPRESS)
    }
    
    @objc private func actAddRadius(sender: UIButton) {
        self.editingState = .radius
        self.hideButtons(bool: true)
        self.view.makeToast(LocalizedConstant.MSG_LONGPRESS)
    }
    
    private func hideButtons(bool: Bool) {
        btnAddRadius.isHidden = bool
        btnAddPolygon.isHidden = bool
    }
    
    private func resetMarkers() {
        for eachMarker in geofenceMarkers {
            eachMarker.map = nil
        }
        geofenceMarkers.removeAll()
    }
}

extension AdminMapViewViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if editingState == .none {
            editingExistingMarker = marker
            if let index = marker.userData as? Int {
                let locationPointList = self.locationPayloadBean?.locPointListBean[index]
                
                if locationPointList?.shapeFlagString == "R" {
                    editingState = .existingRadius
                    
                    self.addShowRadiusConfigurationScreen()
                    self.vwAddRadius.tag = index
                    
                    self.vwAddRadius.locationPointList = locationPointList
                    
                    self.vwAddRadius.txtTitle.text = locationPointList?.locName
                    self.vwAddRadius.txtDesc.text = locationPointList?.locDesc
                    self.vwAddRadius.txtSSID.text = locationPointList?.locationWifiInfo?.ssid
                    self.vwAddRadius.txtBSSID.text = locationPointList?.locationWifiInfo?.bssid
                    self.vwAddRadius.txtSSIDDATA.text = locationPointList?.locationWifiInfo?.ssidData
                    self.vwAddRadius.slider.value = (locationPointList?.radius)! / 1000
                    self.vwAddRadius.lblRadiusM.text = "\((locationPointList?.radius)!)m"
                } else {
                    editingState = .existingPolygon
                    
                    self.addShowPolygonConfigurationScreen()
                    self.vwAddPolygon.tag = index
                    
                    self.vwAddPolygon.locationPointList = locationPointList
                    
                    self.vwAddPolygon.txtTitle.text = locationPointList?.locName
                    self.vwAddPolygon.txtDesc.text = locationPointList?.locDesc
                    self.vwAddPolygon.txtSSID.text = locationPointList?.locationWifiInfo?.ssid
                    self.vwAddPolygon.txtBSSID.text = locationPointList?.locationWifiInfo?.bssid
                    self.vwAddPolygon.txtSSIDDATA.text = locationPointList?.locationWifiInfo?.ssidData
                }
            }
        }
        
        return true
    }
}

//MARK:- LocationManagerDelegate
extension AdminMapViewViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.userCurrentLocation = locations.last
        
        userLocationMarker.position = CLLocationCoordinate2D(latitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!)
        
        if isFirstTimeGettingUserLocation {
            let camera = GMSCameraPosition.camera(withLatitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!, zoom: cameraZoom)
            
            CATransaction.begin()
            CATransaction.setValue(0, forKey: kCATransactionAnimationDuration)
            self.gmsMapView.animate(to: camera)
            CATransaction.commit()
            
            isFirstTimeGettingUserLocation = false
        }
    }
}

extension AdminMapViewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension AdminMapViewViewController: MapViewAddRadiusDelegate {
    func addRadius(view: MapViewAddRadius, didPressOnSave: UIButton) {
        if view.txtTitle.text == nil || (view.txtTitle.text?.count)! < 1 {
            self.view.makeToast(LocalizedConstant.MSG_FILL_IN_TITLE)
            return
        }
        
        if view.txtSSID.text == nil || (view.txtSSID.text?.count)! < 1 {
            self.view.makeToast(LocalizedConstant.MSG_FILL_IN_SSID)
            return
        }
        
        if self.locationPayloadBean != nil && view.locationPointList != nil {
            self.resetMarkers()
            
            if editingState != .existingRadius {
                self.locationPayloadBean!.locPointListBean.append(view.locationPointList!)
            } else {
                self.locationPayloadBean!.locPointListBean[view.tag] = view.locationPointList!
            }
                
            self.addMarker(bean: self.locationPayloadBean!)
            
            let encodedObject = try? JSONEncoder().encode(self.locationPayloadBean!)
            UserDefaults.standard.set(String(data: encodedObject!, encoding: .utf8), forKey: String(describing: type(of: LocationPayloadBean.self)))
            
            view.clearAllLabel()
        }
        
        UIView.animate(withDuration: 0.35) {
            self.vwAddRadius.transform = .identity
        }
        
        self.hideButtons(bool: false)
        editingState = .none
    }
    
    func addRadius(view: MapViewAddRadius, didPressOnCancel: UIButton) {
        UIView.animate(withDuration: 0.35) {
            self.vwAddRadius.transform = .identity
        }
        
        self.hideButtons(bool: false)
        
        if editingState == .radiusOngoing {
            if let lastAddedMarker = geofenceMarkers.last {
                lastAddedMarker.map = nil
            }
            geofenceMarkers.removeLast()
        }
        
        editingState = .none
    }
    
    func addRadius(view: MapViewAddRadius, sliderDidChanged value: Float) {
        let str = String(format: "%.0f", value * 1000)
        
        if editingState == .existingRadius {
            (editingExistingMarker as? CustomUserLocationMarker)?.radarMeter = Double(str)
        }
        
        if editingState == .radiusOngoing {
            if let lastAddedMarker = geofenceMarkers.last as? CustomUserLocationMarker {
                lastAddedMarker.radarMeter = Double(str)
            }
        }
    }
}

extension AdminMapViewViewController: MapViewAddPolygonDelegate {
    func addPolygon(view: MapViewAddPolygon, didPressOnSave: UIButton) {
        if view.txtTitle.text == nil || (view.txtTitle.text?.count)! < 1 {
            self.view.makeToast(LocalizedConstant.MSG_FILL_IN_TITLE)
            return
        }
        
        if view.txtSSID.text == nil || (view.txtSSID.text?.count)! < 1 {
            self.view.makeToast(LocalizedConstant.MSG_FILL_IN_SSID)
            return
        }
        
        for eachEditingMarker in self.editingMarkers {
            eachEditingMarker.map = nil
        }
        self.editingMarkers.removeAll()
        
        editingPolygon?.map = nil
        self.editingPolygon = nil
        self.editingPolygonPaths = nil
        
        if self.locationPayloadBean != nil && view.locationPointList != nil {
            self.resetMarkers()
            
            if editingState != .existingPolygon {
                self.locationPayloadBean!.locPointListBean.append(view.locationPointList!)
            } else {
                self.locationPayloadBean!.locPointListBean[view.tag] = view.locationPointList!
            }
            
            self.addMarker(bean: self.locationPayloadBean!)
            
            let encodedObject = try? JSONEncoder().encode(self.locationPayloadBean!)
            UserDefaults.standard.set(String(data: encodedObject!, encoding: .utf8), forKey: String(describing: type(of: LocationPayloadBean.self)))
            
            view.clearAllLabel()
        }
        
        UIView.animate(withDuration: 0.35) {
            self.vwAddPolygon.transform = .identity
        }
        
        self.hideButtons(bool: false)
        editingState = .none
    }
    
    func addPolygon(view: MapViewAddPolygon, didPressOnCancel: UIButton) {
        UIView.animate(withDuration: 0.35) {
            self.vwAddPolygon.transform = .identity
        }
        
        self.hideButtons(bool: false)
        
        if editingState == .polygonOngoing {
            for eachEditingMarker in self.editingMarkers {
                eachEditingMarker.map = nil
            }
            self.editingMarkers.removeAll()
            
            //        editingPolygon?.customPolygon?.map = nil
            editingPolygon?.map = nil
            self.editingPolygon = nil
            self.editingPolygonPaths = nil
        }
        
        editingState = .none
    }
}
