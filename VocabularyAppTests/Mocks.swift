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

class MockWordMatchGameControllerDelegate: WordMatchGameControllerDelegate {
    var bucketWasUpdated = false
    var bucketVocabDictionary = [String: VocabularyPairLocalDataModel]()
    var spawnedPair: VocabularyPairLocalDataModel?
    var spawnedTextColor: UIColor?
    var removedPair: VocabularyPairLocalDataModel?
    var updatedPair: VocabularyPairLocalDataModel?
    var updatedColor: UIColor?
    var didCallGameOver = false
    
    func spawnPair(pair: VocabularyPairLocalDataModel, color: UIColor, useDefinition: Bool) {
        self.spawnedPair = pair
        self.spawnedTextColor = color
    }
    
    func removePair(pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        self.removedPair = pair
    }
    
    func updatePair(pair: VocabularyPairLocalDataModel, with color: UIColor, useDefinition: Bool) {
        self.updatedPair = pair
        self.updatedColor = color
    }
    
    func updateBucket(bucketId: BucketId, with pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        bucketWasUpdated = true
        bucketVocabDictionary[bucketId.rawValue] = pair
    }
    
    func verifyThatBucket(with bucketId: BucketId, wasUpdatedWith pair: VocabularyPairLocalDataModel) -> Bool {
        return bucketVocabDictionary[bucketId.rawValue] == pair
    }
    
    func gameOver() {
        self.didCallGameOver = true
    }
}

class MockGameItemList: GameItemList {
    var randomItemsStubs: [[VocabularyPairLocalDataModel]]?
    var indexOfCurrentInvocation = 0
    var items = [VocabularyPairLocalDataModel]()
    var didObtainItems = false
    var didObtainItemsThatMatch = false
    var matchedItemsStub: [VocabularyPairLocalDataModel]? = nil
    var addedItems = [VocabularyPairLocalDataModel]()
    var removedItem: VocabularyPairLocalDataModel?
    
    func randomItems(nrOfItems: Int) -> [VocabularyPairLocalDataModel] {
        if let stubs = randomItemsStubs {
            guard indexOfCurrentInvocation < stubs.count else {
                fatalError("Invoked the mock too many times. Either invoke it fewer times or provide more stubs")
            }
            let stub = stubs[self.indexOfCurrentInvocation]
            self.indexOfCurrentInvocation = indexOfCurrentInvocation + 1
            return stub
        }
        return [VocabularyPairLocalDataModel]()
    }
    
    func obtainItems() -> [VocabularyPairLocalDataModel] {
        self.didObtainItems = true
        return [VocabularyPairLocalDataModel]()
    }
    
    func obtainItemsThatMatch(matcher: [VocabularyPairLocalDataModel]) -> [VocabularyPairLocalDataModel] {        
        self.didObtainItemsThatMatch = true
        if let stub = self.matchedItemsStub {
            return stub
        }
        return [VocabularyPairLocalDataModel]()
    }
    
    func addItem(item: VocabularyPairLocalDataModel) {
        self.addedItems.append(item)
    }
    
    func removeItem(item: VocabularyPairLocalDataModel) {
        self.removedItem = item
    }
}

class MockGameLoop: GameLoop {
    var didStartGameLoop = false
    var delegate: GameLoopDelegate?
    
    func start() {
        didStartGameLoop = true
    }
}

class MockGameController: GameController {
    func startGame() {
        
    }
    
    func pairMatched(pair: VocabularyPairLocalDataModel) {
        
    }
    
    func requestPairForBucket(bucketId: BucketId) {
        
    }
    
    func reassignAllBuckets() {
        
    }
    
    var vocabularyPairs: [VocabularyPairLocalDataModel] = [VocabularyPairLocalDataModel]()
    var delegate: WordMatchGameControllerDelegate?
}

class MockHighScoreService: HighScoreService {
    var saveHighScoreStub: Bool?
    var highScoreStub: Int?
    
    func saveHighScore(score: Int) -> Bool {
        if let stub = self.saveHighScoreStub {
            return stub
        }
        return false
    }
    
    func getHighScore() -> Int {
        if let stub = self.highScoreStub {
            return stub
        }
        return 0
    }
}
