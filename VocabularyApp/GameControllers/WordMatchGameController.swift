//
//  WordMatchGameController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 29.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation
import UIKit

class WordMatchGameController {
    private var pile: GameItemList
    var vocabularyPairs = [VocabularyPairLocalDataModel]()
    var delegate: WordMatchGameControllerDelegate? = nil
    
    init(pile: GameItemList,
         bucket: [VocabularyPairLocalDataModel],
         blackItems: [VocabularyPairLocalDataModel],
         greenItems: [VocabularyPairLocalDataModel]) {
        self.pile = pile
    }
    
    func startGame() {
        self.pile.items = self.vocabularyPairs
        let randomItemsFromPile = pile.randomItems(nrOfItems: 4)
        guard randomItemsFromPile.count == 4 else {
            return
        }
        delegate?.updateBucket(bucketId: BucketId.bucket1, with: randomItemsFromPile[0], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket2, with: randomItemsFromPile[1], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket3, with: randomItemsFromPile[2], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket4, with: randomItemsFromPile[3], useDefinition: true)
    }
    
    func pairMatched(pair: VocabularyPairLocalDataModel) {
        
    }
    
    func requestPairForBucket(bucketId: BucketId) {
        
    }
}

protocol WordMatchGameControllerDelegate {
    func spawnText(text: String, color: UIColor)
    
    func removeText(text: String)
    
    func updateText(text: String, with color: UIColor)
    
    func updateBucket(bucketId: BucketId, with pair: VocabularyPairLocalDataModel, useDefinition: Bool)
}
