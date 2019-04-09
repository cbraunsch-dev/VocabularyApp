//
//  UIView+Extension.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 09.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
