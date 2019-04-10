//
//  TestDataGenerating.swift
//  TaskManagerAppTests
//
//  Created by Chris Braunschweiler on 19.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

protocol TestDataGenerating {}

extension TestDataGenerating {
    func createListOfOrderedNumbers(numberOfItems: Int) -> [Int] {
        var nrs = [Int]()
        for i in 0..<numberOfItems {
            nrs.append(i)
        }
        return nrs
    }
    
    func createEvents<E>(nrOfEvents: Int, event: E) -> [Recorded<Event<E>>] {
        var events = [Recorded<Event<E>>]()
        for _ in 0..<nrOfEvents {
            events.append(next(100, event))
        }
        return events
    }
    
    func createTestSetEntities() -> [SetEntity] {
        let entity1 = SetEntity()
        entity1.setID = "1"
        entity1.name = "Serbian"
        
        let entity2 = SetEntity()
        entity2.setID = "2"
        entity2.name = "Spanish"
        
        let entity3 = SetEntity()
        entity3.setID = "3"
        entity3.name = "Japanese"
        
        return [entity1, entity2, entity3]
    }
    
    func createTestSetEntitiesWithVocabularyPairs() -> [SetEntity] {
        let entity1 = SetEntity()
        entity1.setID = "1"
        entity1.name = "Serbian"
        
        let vocabPair1_1 = VocabularyPairEntity()
        vocabPair1_1.pairID = "1_1"
        vocabPair1_1.definition = "Thank you"
        vocabPair1_1.wordOrPhrase = "Hvala"
        
        let vocabPair1_2 = VocabularyPairEntity()
        vocabPair1_2.pairID = "1_2"
        vocabPair1_2.definition = "Tomorrow"
        vocabPair1_2.wordOrPhrase = "Sutra"
        
        entity1.vocabularyPairs.append(vocabPair1_1)
        entity1.vocabularyPairs.append(vocabPair1_2)
        
        let entity2 = SetEntity()
        entity2.setID = "2"
        entity2.name = "Spanish"
        
        let vocabPair2_1 = VocabularyPairEntity()
        vocabPair2_1.pairID = "2_1"
        vocabPair2_1.definition = "Thank you"
        vocabPair2_1.wordOrPhrase = "Gracias"
        
        let vocabPair2_2 = VocabularyPairEntity()
        vocabPair2_2.pairID = "2_2"
        vocabPair2_2.definition = "Tomorrow"
        vocabPair2_2.wordOrPhrase = "Mañana"
        
        entity2.vocabularyPairs.append(vocabPair2_1)
        entity2.vocabularyPairs.append(vocabPair2_2)
        
        return [entity1, entity2]
    }
    
    func createTestSetEntityWithVocabularyPairs() -> SetEntity {
        let vocabPair1_1 = VocabularyPairEntity()
        vocabPair1_1.pairID = "1_1"
        vocabPair1_1.definition = "Thank you"
        vocabPair1_1.wordOrPhrase = "Hvala"
        
        let vocabPair1_2 = VocabularyPairEntity()
        vocabPair1_2.pairID = "1_2"
        vocabPair1_2.definition = "Tomorrow"
        vocabPair1_2.wordOrPhrase = "Sutra"
        
        let entity1 = SetEntity()
        entity1.setID = "1"
        entity1.name = "Serbian"
        entity1.vocabularyPairs.append(vocabPair1_1)
        entity1.vocabularyPairs.append(vocabPair1_2)
        
        return entity1
    }
    
    func createTestSetLocalDataModels() -> [SetLocalDataModel] {
        let set1 = SetLocalDataModel(id: "1", name: "Serbian")
        let set2 = SetLocalDataModel(id: "2", name: "Spanish")
        let set3 = SetLocalDataModel(id: "3", name: "Japanese")
        return [set1, set2, set3]
    }
    
    func createTestVocabularyPairs() -> [VocabularyPairLocalDataModel] {
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let pair5 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 5", definition: "Definition 5")
        return [pair1, pair2, pair3, pair4, pair5]
    }
}
