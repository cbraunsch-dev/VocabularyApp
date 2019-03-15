//
//  VocabularyPairLocalDataModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct VocabularyPairLocalDataModel: Equatable {
    let wordOrPhrase: String
    let definition: String
    
    static func ==(lhs: VocabularyPairLocalDataModel, rhs: VocabularyPairLocalDataModel) -> Bool {
        return lhs.wordOrPhrase == rhs.wordOrPhrase &&
            lhs.definition == rhs.definition
    }
}
