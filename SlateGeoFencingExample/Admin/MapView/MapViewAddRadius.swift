//
//  MapViewAddRadius.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 23/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

protocol MapViewAddRadiusDelegate {
    func addRadius(view: MapViewAddRadius, didPressOnSave: UIButton)
    func addRadius(view: MapViewAddRadius, didPressOnCancel: UIButton)
    func addRadius(view: MapViewAddRadius, sliderDidChanged value: Float)
}

class MapViewAddRadius: UIView, NibLoadable {

    //MARK:- IBOutlets
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblRadiusM: UILabel!
    @IBOutlet weak var txtSSID: UITextField!
    @IBOutlet weak var txtBSSID: UITextField!
    @IBOutlet weak var txtSSIDDATA: UITextField!
    
    //MARK:- Variables
    var delegate: MapViewAddRadiusDelegate?
    var locationPointList: LocationPointList? 
    
    //MARK:- Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        self.common_init()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.fromNib()
        self.common_init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.fromNib()
        self.common_init()
    }
    
    //MARK:- Private functions
    private func common_init() {
        slider.addTarget(self, action: #selector(self.actSliderChanged(_:)), for: .valueChanged)
    }
    
    func clearAllLabel() {
        locationPointList = nil
        
        txtTitle.text = nil
        txtDesc.text = nil
        slider.value = 0.2
        lblRadiusM.text = "200m"
        txtSSID.text = nil
        txtBSSID.text = nil
        txtSSIDDATA.text = nil
    }
    
    //MARK:- IBActions
    @IBAction func actSave(_ sender: UIButton) {
        locationPointList?.locName = self.txtTitle.text ?? ""
        locationPointList?.locDesc = self.txtDesc.text
        locationPointList?.locationWifiInfo = WifiInfo(ssid: self.txtSSID.text, bssid: self.txtBSSID.text, ssidData: self.txtSSIDDATA.text)
        
        delegate?.addRadius(view: self, didPressOnSave: sender)
    }
    @IBAction func actCancel(_ sender: UIButton) {
        delegate?.addRadius(view: self, didPressOnCancel: sender)
        
        self.clearAllLabel()
    }
    @objc private func actSliderChanged(_ sender: UISlider) {
        delegate?.addRadius(view: self, sliderDidChanged: sender.value)
        
        lblRadiusM.text = "\(String(format: "%.0f", sender.value * 1000))m"
        
        locationPointList?.radius = Float(String(format: "%.0f", sender.value * 1000))!
    }
}
