//
//  GameItemList.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 30.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation

protocol GameItemList {
    func randomItems(nrOfItems: Int) -> [VocabularyPairLocalDataModel]
    func addItem(item: VocabularyPairLocalDataModel)
    func obtainItems() -> [VocabularyPairLocalDataModel]
    func obtainItemsThatMatch(matcher: [VocabularyPairLocalDataModel]) -> [VocabularyPairLocalDataModel]
    func removeItem(item: VocabularyPairLocalDataModel)
}

class WordMatchGameItemList: GameItemList {
    private var items  = [VocabularyPairLocalDataModel]()
    
    func randomItems(nrOfItems: Int) -> [VocabularyPairLocalDataModel] {
        guard !items.isEmpty else {
            return [VocabularyPairLocalDataModel]()
        }
        var randomPairs = [VocabularyPairLocalDataModel]()
        var tempItems = items
        let nrOfItemsToGet = nrOfItems < items.count ? nrOfItems : items.count
        for _ in 1...nrOfItemsToGet {
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
    
    func removeItem(item: VocabularyPairLocalDataModel) {
        self.items.removeAll(where: { it in
            it == item
        })
    }
}
