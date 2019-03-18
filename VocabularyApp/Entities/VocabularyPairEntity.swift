//
//  VocabularyPairEntity.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 18.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift

class VocabularyPairEntity: Object {
    @objc public dynamic var pairID = ""
    @objc public dynamic var wordOrPhrase = ""
    @objc public dynamic var definition = ""
    
    override public static func primaryKey() -> String? {
        return "pairID"
    }
}
