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
            print("\(NSDate().timeIntervalSince1970) Start hovering over bucket: \(self.bucketId)")
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.lightGray
            }, completion: {_ in
            })
        }
    }
    
    func stopHoveringOver() {
        if(self.hoveringOverBucket) {
            self.hoveringOverBucket = false
            print("\(NSDate().timeIntervalSince1970) Stop hovering over bucket: \(self.bucketId)")
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
            return oldPair
        }
        return nil
    }

    private func setupView() {
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.font = UIFont.systemFont(ofSize: FontConstants.xLarge)
        self.text.textColor = UIColor.black
        self.text.textAlignment = .center
        self.text.numberOfLines = 0
        
        self.addSubview(self.text)
        
        self.text.snp.makeConstraints { make in
            make.left.equalTo(self).offset(LayoutConstants.buX2)
            make.top.equalTo(self).offset(LayoutConstants.buX2)
            make.bottom.equalTo(self).offset(-LayoutConstants.buX2)
            make.right.equalTo(self).offset(-LayoutConstants.buX2)
        }
    }
}

protocol BucketViewDelegate {
    func requestPairForBucket(bucketId: BucketId)
}
