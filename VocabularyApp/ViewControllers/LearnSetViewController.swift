//
//  SetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit

class LearnSetViewController: UIViewController, SetManageable {

    var set: SetLocalDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.set?.name
    }
}
