//
//  SetEntity.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift

class SetEntity: Object {
    @objc public dynamic var setID = ""
    @objc public dynamic var name = ""
    let vocabularyPairs = List<VocabularyPairEntity>()
    
    override public static func primaryKey() -> String? {
        return "setID"
    }
}
