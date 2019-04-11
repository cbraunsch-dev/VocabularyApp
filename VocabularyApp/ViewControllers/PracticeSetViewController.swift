//
//  PracticeSetViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 09.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PracticeSetViewController: UIViewController, SetManageable {

    private let bag = DisposeBag()
    
    var set: SetLocalDataModel?
    var viewModel: PracticeSetViewModelType!
    
    @IBOutlet weak var flashCardView: FlashCardView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = L10n.Action.practice
        
        self.doneButton.rx.tap
            .subscribe(onNext: { self.dismiss(animated: true, completion: nil) })
            .disposed(by: self.bag)
        self.viewModel.outputs.text
            .subscribe(onNext: { text in
                UIView.animate(withDuration: AnimationConstants.appearanceDuration, animations: {
                    self.flashCardView.text.text = text
                })
            }).disposed(by: self.bag)
        
        self.viewModel.inputs.set.onNext(self.set!)
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    @IBAction func didSwipeLeft(_ sender: Any) {
        self.viewModel.inputs.showNextPair.onNext(())
    }
    
    @IBAction func didSwipeUp(_ sender: Any) {
        self.viewModel.inputs.showValue.onNext(())
    }
}
