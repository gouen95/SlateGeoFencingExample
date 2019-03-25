//
//  ExtensionUINavigationController.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

extension UINavigationController {
    //OVERRIDING EXTENSION FOR PREFERREDSTATUSBARSTYLE IN EVERY VIEWCONTROLLER
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
