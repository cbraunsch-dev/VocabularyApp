//
//  BucketView.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 28.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import UIKit

class BucketView: UIView {
    var bucketId: BucketId?
    var delegate: BucketViewDelegate?
    let text = UILabel()
    var timerService = appContainer.resolve(TimerService.self)
    private let feedbackView = BucketFeedbackView()
    private var pair: VocabularyPairLocalDataModel!
    public private(set) var hoveringOverBucket: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func startHoveringOver() {
        if(!self.hoveringOverBucket) {
            self.hoveringOverBucket = true
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.lightGray
            }, completion: {_ in
            })
        }
    }
    
    func stopHoveringOver() {
        if(self.hoveringOverBucket) {
            self.hoveringOverBucket = false
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.white
            }, completion: {_ in
            })
        }
    }
    
    func updateWith(pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        self.pair = pair
        if(useDefinition) {
            text.text = pair.definition
        } else {
            text.text = pair.wordOrPhrase
        }
    }
    
    // Returns the pair that matched with the word. If no match was found, nil is returned
    func wordWasDroppedIntoBucket(word: String) -> VocabularyPairLocalDataModel? {
        let oldPair = self.pair
        if(word == self.pair.definition || word == self.pair.wordOrPhrase) {
            self.delegate?.requestPairForBucket(bucketId: self.bucketId!)
            self.feedbackView.showSuccess()
            self.feedbackView.alpha = 1
            self.timerService?.startTimer(duration: 1.0, completion: {
                self.feedbackView.alpha = 0
            })
            return oldPair
        }
        self.feedbackView.showFailure()
        self.feedbackView.alpha = 1
        self.timerService?.startTimer(duration: 1.0, completion: {
            self.feedbackView.alpha = 0
        })
        return nil
    }

    private func setupView() {
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.font = UIFont.systemFont(ofSize: FontConstants.xLarge)
        self.text.textColor = UIColor.black
        self.text.textAlignment = .center
        self.text.numberOfLines = 0
        self.feedbackView.alpha = 0
        
        self.addSubview(self.text)
        self.addSubview(self.feedbackView)
        
        self.text.snp.makeConstraints { make in
            make.left.equalTo(self).offset(LayoutConstants.buX2)
            make.top.equalTo(self).offset(LayoutConstants.buX2)
            make.bottom.equalTo(self).offset(-LayoutConstants.buX2)
            make.right.equalTo(self).offset(-LayoutConstants.buX2)
        }
        self.feedbackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
}

protocol BucketViewDelegate {
    func requestPairForBucket(bucketId: BucketId)
}
