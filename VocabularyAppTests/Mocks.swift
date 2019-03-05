//
//  Mocks.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
@testable import VocabularyApp

class MockRealmConfigurationProvider: RealmConfigurationProvider {
    var fetchConfigurationStub: (() -> Realm.Configuration)?
    
    func fetchConfiguration() -> Realm.Configuration {
        if let stub = self.fetchConfigurationStub {
            return stub()
        }
        fatalError("Not stubbed")
    }
}
