//
//  SetNavigationController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

class SetManageableNavigationController: UINavigationController, SetManageable {
    var set: SetLocalDataModel? {
        didSet {
            if let topVC = self.topViewController {
                var vcThatManagesSets = topVC as! SetManageable
                vcThatManagesSets.set = self.set
            }
        }
    }
}
