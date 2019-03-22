//
//  AppDelegate.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: Constant.STORYBOARD_LANDING, bundle: Bundle(for: type(of: self))).instantiateInitialViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

