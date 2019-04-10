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

class MockSetLocalDataService: SetLocalDataService {
    var didReadAll = false
    var readAllStub: Observable<[SetLocalDataModel]>?
    var didGetItemById = false
    var getItemByIdStub: Observable<SetLocalDataModel?>?
    var didSaveItem = false
    var savedItem: SetLocalDataModel? = nil
    var saveItemStub: Observable<Void>?
    var didRemoveItem = false
    var removeItemStub: Observable<Void>?
    
    func readAll() -> Observable<[SetLocalDataModel]> {
        self.didReadAll = true
        if let stub = self.readAllStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func getItemById(with id: String) -> Observable<SetLocalDataModel?> {
        self.didGetItemById = true
        if let stub = self.getItemByIdStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func save(item: SetLocalDataModel) -> Observable<Void> {
        self.didSaveItem = true
        self.savedItem = item
        if let stub = self.saveItemStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
    
    func removeItem(with id: String) -> Observable<Void> {
        self.didRemoveItem = true
        if let stub = self.removeItemStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
}

class MockFileContentProvider: FileContentProvider {
    var contentsOfFileStub: String?
    var didCallContentsOfFile = false
    
    func contentsOfFile(at path: String, encoding: String.Encoding) throws -> String {
        self.didCallContentsOfFile = true
        if let stub = self.contentsOfFileStub {
            return stub
        }
        return ""
    }
}

class MockImportVocabularyService: ImportVocabularyService {
    var filePathUsedForImport: String?
    var didImportVocabulary = false
    var importVocabularyStub: Observable<[VocabularyPairLocalDataModel]>?
    
    func importVocabulary(at filePath: String) -> Observable<[VocabularyPairLocalDataModel]> {
        self.didImportVocabulary = true
        self.filePathUsedForImport = filePath
        if let stub = self.importVocabularyStub {
            return stub
        }
        fatalError("Method not stubbed")
    }
}

class MockRandomNumberService: RandomNumberService {
    var generateRandomNumberStub: Int?
    var generateRandomNumberStubs: [Int]?
    var indexOfCurrentInvocation = 0
    
    func generateRandomNumber(topLimit: Int) -> Int {
        if let stubs = generateRandomNumberStubs {
            guard indexOfCurrentInvocation < stubs.count else {
                fatalError("Invoked the mock too many times. Either invoke it fewer times or provide more stubs")
            }
            let stub = stubs[self.indexOfCurrentInvocation]
            self.indexOfCurrentInvocation = indexOfCurrentInvocation + 1
            return stub
        }
        guard let stub = self.generateRandomNumberStub else {
            return 0
        }
        return stub
    }
}
