//
//  SetsViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 10.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit

class SetsViewController: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.sets
        self.infoIcon.image = self.infoIcon.image?.withRenderingMode(.alwaysTemplate)
        self.infoIcon.tintColor = UIColor.darkGray
        self.infoLabel.text = L10n.Action.AddSet.hint
    }
}
