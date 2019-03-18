//
//  VocabularyPairLocalDataModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct VocabularyPairLocalDataModel: Equatable {
    let id: String
    let wordOrPhrase: String
    let definition: String
    
    init(wordOrPhrase: String, definition: String) {
        self.id = UUID().uuidString
        self.wordOrPhrase = wordOrPhrase
        self.definition = definition
    }
    
    static func ==(lhs: VocabularyPairLocalDataModel, rhs: VocabularyPairLocalDataModel) -> Bool {
        return   lhs.id == rhs.id &&
            lhs.wordOrPhrase == rhs.wordOrPhrase &&
            lhs.definition == rhs.definition
    }
}
