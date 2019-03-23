//
//  ExtensionUINavigationBar.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2019 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit
import PINCache

extension UINavigationBar {
    func setTransparent() {
        self.tintColor = .white //Font color
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
    }
    
    func setMainThemeWith(alpha: CGFloat) {
        self.tintColor = .white //Font color
        
        var croppedImgBackground: UIImage?
        
        if let cachedImgBackground = PINCache.shared().object(forKey: "croppedImgBackground") as? UIImage {
            croppedImgBackground = cachedImgBackground
        } else {
            let statusBarAndNavBarHeight = UIApplication.shared.statusBarFrame.height + self.frame.height
            let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarAndNavBarHeight)
            
            croppedImgBackground = UIImage(named: Constant.IMG_BACKGROUND)?.resizeImage(targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)).crop(with: rect)
            
            PINCache.shared().setObject(croppedImgBackground!, forKey: "croppedImgBackground")
        }
        
        setBackgroundImage(croppedImgBackground?.image(alpha: min(0.998, alpha))?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch), for: .default)
        
        self.shadowImage = UIImage()
        self.isTranslucent = true
        
        self.barStyle = .blackOpaque
        
        if self.subviews.count > 0 && NSStringFromClass(type(of: self.subviews[0])) == "_UIBarBackground" {
            self.subviews[0].alpha = 1
            
            if self.subviews[0].subviews.count > 0 {
                for eachImageView in self.subviews[0].subviews {
                    if eachImageView is UIImageView && eachImageView.frame.origin.y == 0 {
                        eachImageView.contentMode = .scaleAspectFill
                        eachImageView.clipsToBounds = true
                    }
                }
            }
        }
        
        self.barTintColor = UIColor.white
    }
}
