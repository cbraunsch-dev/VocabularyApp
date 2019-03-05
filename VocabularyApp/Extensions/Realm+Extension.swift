//
//  Realm+Extension.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 05.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    func write(transaction block: @escaping () -> Void, completion: () -> Void) throws {
        try write(block)
        completion()
    }
}
