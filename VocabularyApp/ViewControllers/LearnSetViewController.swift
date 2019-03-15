//
//  SetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LearnSetViewController: UIViewController, SetManageable, SegueHandlerType {
    private let bag = DisposeBag()
    
    enum SegueIdentifier: String {
        case addVocabulary
    }

    var set: SetLocalDataModel?
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = L10n.Action.learn
        self.tabBarController?.title = self.set?.name
        
        let addButton = UIBarButtonItem(image: UIImage(named: "ImportExport"), style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.tabBarController?.navigationItem.rightBarButtonItem = addButton
        addButton.rx.tap.subscribe(onNext: { self.performSegueWithIdentifier(segueIdentifier: .addVocabulary, sender: self) }).disposed(by: self.bag)
        
        self.infoLabel.text = L10n.Action.AddVocabulary.hint
    }
}
