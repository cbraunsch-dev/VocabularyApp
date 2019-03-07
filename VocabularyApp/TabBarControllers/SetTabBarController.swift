//
//  SetTabBarController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

class SetTabBarController: UITabBarController, SetManageable {
    var set: SetLocalDataModel? {
        didSet {
            self.children.forEach({ child in
                var childThatUsesSets = child as! SetManageable
                childThatUsesSets.set = self.set
            })
        }
    }
}
