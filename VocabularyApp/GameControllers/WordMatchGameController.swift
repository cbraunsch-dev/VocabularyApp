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
    private var gameLoop: GameLoop
    private let pile: GameItemList
    private let bucket: GameItemList
    private let greenItems: GameItemList
    private let blackItems: GameItemList
    var vocabularyPairs = [VocabularyPairLocalDataModel]()
    var delegate: WordMatchGameControllerDelegate? = nil
    
    init(gameLoop: GameLoop,
         pile: GameItemList,
         bucket: GameItemList,
         blackItems: GameItemList,
         greenItems: GameItemList) {
        self.gameLoop = gameLoop
        self.pile = pile
        self.bucket = bucket
        self.greenItems = greenItems
        self.blackItems = blackItems
        self.gameLoop.delegate = self
    }
    
    func startGame() {
        self.vocabularyPairs.forEach { pair in
            self.pile.addItem(item: pair)
        }
        let randomItemsFromPile = pile.randomItems(nrOfItems: 4)
        guard randomItemsFromPile.count == 4 else {
            return
        }
        self.bucket.addItem(item: randomItemsFromPile[0])
        self.bucket.addItem(item: randomItemsFromPile[1])
        self.bucket.addItem(item: randomItemsFromPile[2])
        self.bucket.addItem(item: randomItemsFromPile[3])
        delegate?.updateBucket(bucketId: BucketId.bucket1, with: randomItemsFromPile[0], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket2, with: randomItemsFromPile[1], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket3, with: randomItemsFromPile[2], useDefinition: true)
        delegate?.updateBucket(bucketId: BucketId.bucket4, with: randomItemsFromPile[3], useDefinition: true)
        self.gameLoop.start()
    }
    
    func pairMatched(pair: VocabularyPairLocalDataModel) {
        self.delegate?.removePair(pair: pair, useDefinition: false)
        self.greenItems.removeItem(item: pair)
    }
    
    func requestPairForBucket(bucketId: BucketId) {
        if let blackItem = self.blackItems.randomItems(nrOfItems: 1).first {
            self.delegate?.updateBucket(bucketId: bucketId, with: blackItem, useDefinition: true)
            self.delegate?.updatePair(pair: blackItem, with: .green, useDefinition: false)
            self.blackItems.removeItem(item: blackItem)
            self.greenItems.addItem(item: blackItem)
        } else if let itemFromPile = self.pile.randomItems(nrOfItems: 1).first {
            self.delegate?.updateBucket(bucketId: bucketId, with: itemFromPile, useDefinition: true)
        }
    }
}

extension WordMatchGameController: GameLoopDelegate {
    func update() {
        let bucketItems = self.bucket.obtainItems()
        let matchingItemsInPile = self.pile.obtainItemsThatMatch(matcher: bucketItems)
        if(matchingItemsInPile.count > 0) {
            // The item still exists in our pile of items that we can take so make it green
            let indexOfRandomItem = Int.random(in: 0..<matchingItemsInPile.count)
            let randomMatch = matchingItemsInPile[indexOfRandomItem]
            self.pile.removeItem(item: randomMatch)
            self.greenItems.addItem(item: randomMatch)
            self.delegate?.spawnPair(pair: randomMatch, color: UIColor.green, useDefinition: false)
        } else {
            // The item has already been taken from our pile so take a different random item from the pile and make it black
            guard let randomItemFromPile = self.pile.randomItems(nrOfItems: 1).first else {
                return
            }
            self.pile.removeItem(item: randomItemFromPile)
            self.blackItems.addItem(item: randomItemFromPile)
            self.delegate?.spawnPair(pair: randomItemFromPile, color: UIColor.black, useDefinition: false)
        }
    }
}

protocol WordMatchGameControllerDelegate {
    func spawnPair(pair: VocabularyPairLocalDataModel, color: UIColor, useDefinition: Bool)
    
    func removePair(pair: VocabularyPairLocalDataModel, useDefinition: Bool)
    
    func updatePair(pair: VocabularyPairLocalDataModel, with color: UIColor, useDefinition: Bool)
    
    func updateBucket(bucketId: BucketId, with pair: VocabularyPairLocalDataModel, useDefinition: Bool)
}
