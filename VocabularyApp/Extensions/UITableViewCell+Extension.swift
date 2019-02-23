//
//  UITableViewCell+Extension.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 14.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell: ReusableView {
    func customAccessoryView(image: UIImage?) -> UIView? {
        let templateImage = image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        let accessoryImage = UIImageView(image: templateImage)
        accessoryImage.tintColor = UIColor.lightGray
        return accessoryImage
    }
}
