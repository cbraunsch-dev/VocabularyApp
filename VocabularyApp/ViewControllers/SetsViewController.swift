//
//  SetsViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 10.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit

class SetsViewController: UIViewController, SegueHandlerType {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    var dismissableViewController: UIViewController?
    var setToShow: SetLocalDataModel?
    
    enum SegueIdentifier: String {
        case addSet
        case showSet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Title.sets
        self.infoIcon.image = self.infoIcon.image?.withRenderingMode(.alwaysTemplate)
        self.infoIcon.tintColor = UIColor.darkGray
        self.infoLabel.text = L10n.Action.AddSet.hint
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = self.segueIdentifierForSegue(segue: segue) else {
            return
        }
        switch identifier {
        case .addSet:
            let navigationController = segue.destination as! UINavigationController
            let targetVC = navigationController.topViewController as! AddSetViewController
            targetVC.delegate = self
            self.dismissableViewController = targetVC
            break
        case .showSet:
            let tabController = segue.destination as! SetTabBarController
            tabController.set = self.setToShow
            break
        }
    }
}

extension SetsViewController: AddSetViewControllerDelegate {
    func didSaveSet(set: SetLocalDataModel) {
        self.dismissableViewController?.dismiss(animated: true, completion: {
            //Open the set we just created
            self.setToShow = set
            self.performSegueWithIdentifier(segueIdentifier: .showSet, sender: self)
        })
    }
}
