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
}
