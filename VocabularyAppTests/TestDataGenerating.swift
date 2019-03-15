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
@testable import VocabularyApp

protocol TestDataGenerating {}

extension TestDataGenerating {
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
