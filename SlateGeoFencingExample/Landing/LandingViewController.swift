//
//  LandingViewController.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    //MARK:- IBOutlets
    @IBOutlet weak var ivSlateLogo: UIImageView!
    @IBOutlet weak var btnLoginAsAdmin: UIButton!
    @IBOutlet weak var btnLoginAsConsumer: UIButton!
    
    //MARK:- Variables
    let logoCenterYConstraintIdentifier = "slateLogoCenterY" //Configured in storyboard

    //MARK:- Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.animateLogo()
    }
    
    //MARK:- IBActions
    @IBAction func actAdmin(_ sender: UIButton) {
        
    }
    
    @IBAction func actConsumer(_ sender: UIButton) {
        
    }
    
    //MARK:- Private functions
    private func setupUI() {
        btnLoginAsAdmin.titleLabel?.font = UIFont(sourceSansFontType: .semiBold, size: 30)
        btnLoginAsConsumer.titleLabel?.font = UIFont(sourceSansFontType: .semiBold, size: 30)
        
        btnLoginAsAdmin.setTitleColor(.white, for: .normal)
        btnLoginAsConsumer.setTitleColor(.white, for: .normal)
        
        btnLoginAsAdmin.setTitle(LocalizedConstant.BUTTON_TITIE_ADMIN, for: .normal)
        btnLoginAsConsumer.setTitle(LocalizedConstant.BUTTON_TITIE_CONSUMER, for: .normal)
    }
    
    private func animateLogo() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
            for eachConstraint in self.view.constraints {
                if eachConstraint.identifier == self.logoCenterYConstraintIdentifier {
                    _ = eachConstraint.setMultiplier(multiplier: 0.6)
                    self.view.setNeedsUpdateConstraints()
                    
                    UIView.animate(withDuration: 0.35, animations: { [unowned self] in
                        self.view.layoutIfNeeded()
                    }) { (finished) in
    
                    }
                }
            }
        }
    }
}
