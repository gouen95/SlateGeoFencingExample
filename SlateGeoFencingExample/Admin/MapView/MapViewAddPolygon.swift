//
//  MapViewAddPolygon.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 23/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

protocol MapViewAddPolygonDelegate {
    func addPolygon(view: MapViewAddPolygon, didPressOnSave: UIButton)
    func addPolygon(view: MapViewAddPolygon, didPressOnCancel: UIButton)
}

class MapViewAddPolygon: UIView, NibLoadable {

    //MARK:- IBOutlets
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var txtSSID: UITextField!
    @IBOutlet weak var txtBSSID: UITextField!
    @IBOutlet weak var txtSSIDDATA: UITextField!
    
    //MARK:- Variables
    var delegate: MapViewAddPolygonDelegate?
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
    }
    
    func clearAllLabel() {
        locationPointList = nil
        
        txtTitle.text = nil
        txtDesc.text = nil
        txtSSID.text = nil
        txtBSSID.text = nil
        txtSSIDDATA.text = nil
    }
    
    //MARK:- IBActions
    @IBAction func actSave(_ sender: UIButton) {
        locationPointList?.locName = self.txtTitle.text ?? ""
        locationPointList?.locDesc = self.txtDesc.text
        locationPointList?.locationWifiInfo = WifiInfo(ssid: self.txtSSID.text, bssid: self.txtBSSID.text, ssidData: self.txtSSIDDATA.text)
        
        delegate?.addPolygon(view: self, didPressOnSave: sender)
    }
    @IBAction func actCancel(_ sender: UIButton) {
        delegate?.addPolygon(view: self, didPressOnCancel: sender)
        
        self.clearAllLabel()
    }

}
