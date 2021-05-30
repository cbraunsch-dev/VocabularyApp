//
//  GameItemList.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 30.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation

protocol GameItemList {
    var items: [VocabularyPairLocalDataModel] { get set }
    func randomItems(nrOfItems: Int) -> [VocabularyPairLocalDataModel]
    func addItem(item: VocabularyPairLocalDataModel)
    func obtainItems() -> [VocabularyPairLocalDataModel]
    func obtainItemsThatMatch(matcher: [VocabularyPairLocalDataModel]) -> [VocabularyPairLocalDataModel]
}

class WordMatchGameItemList: GameItemList {
    var items  = [VocabularyPairLocalDataModel]()
    
    func randomItems(nrOfItems: Int) -> [VocabularyPairLocalDataModel] {
        var randomPairs = [VocabularyPairLocalDataModel]()
        var tempItems = items
        for _ in 1...nrOfItems {
            let randomIndex = Int.random(in: 0..<tempItems.count)
            let randomPair = tempItems[randomIndex]
            randomPairs.append(randomPair)
            tempItems.remove(at: randomIndex)
        }
        
        return randomPairs
    }
    
    func obtainItems() -> [VocabularyPairLocalDataModel] {
        return items
    }
    
    func obtainItemsThatMatch(matcher: [VocabularyPairLocalDataModel]) -> [VocabularyPairLocalDataModel] {
        return items.filter { item in
            return matcher.contains(item)
        }
    }
    
    func addItem(item: VocabularyPairLocalDataModel) {
        self.items.append(item)
    }
}
