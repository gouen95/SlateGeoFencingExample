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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setTransparent()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- IBActions
    @IBAction func actAdmin(_ sender: UIButton) {
        let mapVC = UIStoryboard(name: Constant.STORYBOARD_MAPVIEW, bundle: Bundle(for: type(of: self))).instantiateInitialViewController() as! MapViewViewController
        
        self.navigationController?.pushViewController(mapVC, animated: true)
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
        
        btnLoginAsAdmin.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        btnLoginAsConsumer.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        btnLoginAsAdmin.layer.cornerRadius = btnLoginAsAdmin.frame.height / 2.5
        btnLoginAsConsumer.layer.cornerRadius = btnLoginAsConsumer.frame.height / 2.5
        
        btnLoginAsAdmin.layer.borderWidth = 1.5
        btnLoginAsConsumer.layer.borderWidth = 1.5
        
        btnLoginAsAdmin.layer.borderColor = UIColor.white.cgColor
        btnLoginAsConsumer.layer.borderColor = UIColor.white.cgColor
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
