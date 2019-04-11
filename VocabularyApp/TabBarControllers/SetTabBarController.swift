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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.children[0].tabBarItem = UITabBarItem(title: L10n.Action.learn, image: UIImage(named: "List"), tag: 0)
        self.children[1].tabBarItem = UITabBarItem(title: L10n.Action.train, image: UIImage(named: "Work"), tag: 1)
    }
}
