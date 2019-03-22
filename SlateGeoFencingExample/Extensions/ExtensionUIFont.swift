//
//  ExtensionUIFont.swift
//  SlateGeoFencingExample
//
//  Created by BrandonWong on 22/03/2019.
//  Copyright © 2018 Silverlake Mobility Ecosystem Sdn Bhd. All rights reserved.
//

import UIKit

extension UIFont {
    enum SourceSansFontType: String {
        case light              = "SourceSansPro-Light"
        case boldItalic         = "SourceSansPro-BoldItalic"
        case lightItalic        = "SourceSansPro-LightItalic"
        case regular            = "SourceSansPro-Regular"
        case italic             = "SourceSansPro-Italic"
        case extraLight         = "SourceSansPro-ExtraLight"
        case blackItalic        = "SourceSansPro-BlackItalic"
        case semiBoldItalic     = "SourceSansPro-SemiBoldItalic"
        case bold               = "SourceSansPro-Bold"
        case semiBold           = "SourceSansPro-SemiBold"
        case black              = "SourceSansPro-Black"
        case extraLightItalic   = "SourceSansPro-ExtraLightItalic"
    }
    
    convenience init(sourceSansFontType: SourceSansFontType, size: CGFloat) {
        self.init(name: sourceSansFontType.rawValue, size: size)!
    }
}
