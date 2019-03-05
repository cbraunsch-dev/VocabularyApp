//
//  SetLocalDataModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct SetLocalDataModel {
    let id: String
    let name: String
    
    init(name: String) {
        self.id = UUID().uuidString
        self.name = name
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
