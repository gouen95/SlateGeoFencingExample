//
//  UIView+Autolayout.swift
//  try123
//
//  Created by "" on 24/12/2018.
//  Copyright © 2018 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
        
        if size.width != 0 {
            self.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        if size.height != 0 {
            self.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func anchorSize(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func fillToSuperview(bySafeArea: Bool) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.anchor(top: bySafeArea ? self.superview?.safeAreaLayoutGuide.topAnchor :self.superview?.topAnchor,
                    leading: bySafeArea ? self.superview?.safeAreaLayoutGuide.leadingAnchor : self.superview?.leadingAnchor,
                    bottom: bySafeArea ? self.superview?.safeAreaLayoutGuide.bottomAnchor : self.superview?.bottomAnchor,
                    trailing: bySafeArea ? self.superview?.safeAreaLayoutGuide.trailingAnchor : self.superview?.trailingAnchor)
    }
}
