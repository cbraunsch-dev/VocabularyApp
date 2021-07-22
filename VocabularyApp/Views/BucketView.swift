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
    
    // TODO: Just return a boolean instead of a pair here because we no longer need the pair
    // Returns the pair that matched with the word. If no match was found, nil is returned
    func wordWasDroppedIntoBucket(word: VocabularyPairLocalDataModel) -> VocabularyPairLocalDataModel? {
        let oldPair = self.pair
        if(word.wordOrPhrase == self.pair.wordOrPhrase || word.definition == self.pair.definition) {
            self.delegate?.requestPairForBucket(bucketId: self.bucketId!)
            self.feedbackView.showSuccess()
            self.showFeedbackView()
            self.timerService?.startTimer(duration: 1.0, completion: {
                self.hideFeedbackView()
            })
            return oldPair
        }
        self.feedbackView.showFailure()
        self.showFeedbackView()
        self.timerService?.startTimer(duration: 1.0, completion: {
            self.hideFeedbackView()
        })
        return nil
    }
    
    private func showFeedbackView() {
        self.feedbackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            self.feedbackView.alpha = 1
            self.feedbackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: {_ in
        })
    }
    
    private func hideFeedbackView() {
        self.feedbackView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        UIView.animate(withDuration: 0.3, animations: {
            self.feedbackView.alpha = 0
            self.feedbackView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: {_ in
        })
    }

    private func setupView() {
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.font = UIFont.systemFont(ofSize: FontConstants.xLarge)
        self.text.textColor = UIColor.black
        self.text.textAlignment = .center
        self.text.numberOfLines = 0
        self.text.adjustsFontSizeToFitWidth = true
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
        
        // Draw dashed line around view
        let border = CAShapeLayer()
        border.strokeColor = UIColor.black.cgColor
        border.lineDashPattern = [2, 2]
        border.frame = self.bounds
        border.fillColor = nil
        border.path = UIBezierPath(rect: self.bounds).cgPath
        self.layer.addSublayer(border)
    }
}

protocol BucketViewDelegate {
    func requestPairForBucket(bucketId: BucketId)
}
