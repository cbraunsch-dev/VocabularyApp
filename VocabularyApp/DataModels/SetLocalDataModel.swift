//
//  SetLocalDataModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct SetLocalDataModel: Equatable {
    let id: String
    let name: String
    let vocabularyPairs: [VocabularyPairLocalDataModel]
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
        self.vocabularyPairs = [VocabularyPairLocalDataModel]()
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.vocabularyPairs = [VocabularyPairLocalDataModel]()
    }
    
    init(id: String, name: String, vocabularyPairs: [VocabularyPairLocalDataModel]) {
        self.id = id
        self.name = name
        self.vocabularyPairs = vocabularyPairs
    }
    
    static func ==(lhs: SetLocalDataModel, rhs: SetLocalDataModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.vocabularyPairs == rhs.vocabularyPairs
    }
    
    static let vocabularyPairsLens = Lens<SetLocalDataModel, [VocabularyPairLocalDataModel]>(
        get: { $0.vocabularyPairs },
        set: { pairs, set in SetLocalDataModel(id: set.id, name: set.name, vocabularyPairs: pairs) }
    )
}
