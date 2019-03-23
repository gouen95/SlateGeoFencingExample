//
//  UIGradientButton.swift
//  SmartCity_ConsumerApp
//
//  Created by Brandon Wong Ka Seng on 07/06/2018.
//  Copyright © 2018 Brandon Wong Ka Seng. All rights reserved.
//

import UIKit

@IBDesignable class UIGradientButton: UIButton {
    var gradientLayer: CAGradientLayer?
    
    @IBInspectable var gradientFirstColor: UIColor = UIColor(hex: Constant.COLOR_ALT_BLUE) {
        didSet {
            gradientLayer?.colors = [gradientFirstColor.cgColor, grandientSecondColor.cgColor]
        }
    }
    
    @IBInspectable var grandientSecondColor: UIColor = UIColor(hex: Constant.COLOR_MAIN_BLUE) {
        didSet {
            gradientLayer?.colors = [gradientFirstColor.cgColor, grandientSecondColor.cgColor]
        }
    }
    
    @IBInspectable var gradientStartPoint: CGPoint = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            gradientLayer?.startPoint = gradientStartPoint
        }
    }
    
    @IBInspectable var gradientEndPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            gradientLayer?.endPoint = gradientEndPoint
        }
    }
    
    @IBInspectable var gradientLocation: CGFloat = 0.7 {
        didSet {
            gradientLayer?.locations = [gradientLocation] as [NSNumber]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [gradientFirstColor.cgColor, grandientSecondColor.cgColor]
        gradientLayer?.startPoint = gradientStartPoint
        gradientLayer?.endPoint = gradientEndPoint
        gradientLayer?.locations = [ gradientLocation ] as [NSNumber]
        gradientLayer?.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer!, at: 0)
    }

}
