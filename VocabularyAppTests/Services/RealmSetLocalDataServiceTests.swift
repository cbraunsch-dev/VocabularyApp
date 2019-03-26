//
//  RealmSetLocalDataServiceTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 05.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RealmSwift
import RxTest
import RxSwift
@testable import VocabularyApp

class RealmSetLocalDataServiceTests: XCTestCase, AssertionDataExtractionCapable, TestDataGenerating {
    private let bag = DisposeBag()
    private var mockConfigurationProvider: MockRealmConfigurationProvider!
    private var testee: RealmSetLocalDataService!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.mockConfigurationProvider = MockRealmConfigurationProvider()
        var configuration = Realm.Configuration.defaultConfiguration
        configuration.inMemoryIdentifier = self.name
        self.mockConfigurationProvider.fetchConfigurationStub = { return configuration }
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        self.testee = RealmSetLocalDataService(configurationProvider: self.mockConfigurationProvider)
        self.scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        self.mockConfigurationProvider = nil
        self.testee = nil
        self.scheduler = nil
        super.tearDown()
    }
    
    func testReadAll_when_noExistingItems_then_returnEmptyList() {
        //Arrange
        let observer = self.scheduler.createObserver([SetLocalDataModel].self)
        
        //Act
        self.testee.readAll().subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to return a result")
            return
        }
        XCTAssertEqual(0, result.count, "Expected an empty list")
    }
    
    func testReadAll_when_existingItems_then_returnItems() {
        //Arrange
        let observer = self.scheduler.createObserver([SetLocalDataModel].self)
        let existingData = self.createTestSetEntities()
        let testRealm = try! Realm()
        try! testRealm.write {
            existingData.forEach {
                testRealm.add($0)
            }
        }
        
        //Act
        self.testee.readAll().subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to return a result")
            return
        }
        XCTAssertEqual(existingData.count, result.count, "Returned incorrect number of items")
        existingData.forEach { existingItem in
            let itemExists = result.contains(where: { item in
                item.id == existingItem.setID && item.name == existingItem.name
            })
            XCTAssertTrue(itemExists, "Failed to find already existing item")
        }
    }
    
    func testReadAll_when_existingItemsWithVocabularyPairs_then_returnItemsWithPairs() {
        //Arrange
        let observer = self.scheduler.createObserver([SetLocalDataModel].self)
        let existingData = self.createTestSetEntitiesWithVocabularyPairs()
        let testRealm = try! Realm()
        try! testRealm.write {
            existingData.forEach {
                testRealm.add($0)
            }
        }
        
        //Act
        self.testee.readAll().subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to return a result")
            return
        }
        XCTAssertEqual(existingData.count, result.count, "Returned incorrect number of items")
        existingData.forEach { existingItem in
            let itemExists = result.contains(where: { item in
                item.id == existingItem.setID && item.name == existingItem.name
            })
            XCTAssertTrue(itemExists, "Failed to find already existing item")
            existingItem.vocabularyPairs.forEach { existingPair in
                let pairExists = result.contains(where: { item in
                    return item.vocabularyPairs.contains(where: { resultPair in
                        return resultPair.wordOrPhrase == existingPair.wordOrPhrase && resultPair.definition == existingPair.definition && resultPair.id == existingPair.pairID })
                })
                XCTAssertTrue(pairExists, "Failed to read out stored vocabulary pairs")
            }
        }
    }
    
    func testGetItemById_when_itemDoesNotExist_then_returnNil() {
        //Arrange
        let observer = self.scheduler.createObserver(SetLocalDataModel?.self)
        
        //Act
        self.testee.getItemById(with: "0").subscribe(observer).disposed(by: self.bag)
        
        //Assert
        XCTAssertNil(self.extractValue(from: observer) ?? nil, "Did not expect to find an item")
    }
    
    func testGetItemById_when_itemExists_then_returnItem() {
        //Arrange
        let idToSearchFor = "123"
        let observer = self.scheduler.createObserver(SetLocalDataModel?.self)
        let existingItem = SetEntity()
        existingItem.setID = idToSearchFor
        existingItem.name = "Vietnamese"
        let testRealm = try! Realm()
        try! testRealm.write {
            testRealm.add(existingItem)
        }
        
        //Act
        self.testee.getItemById(with: idToSearchFor).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to return a result")
            return
        }
        XCTAssertEqual(existingItem.setID, result?.id)
        XCTAssertEqual(existingItem.name, result?.name)
    }
    
    func testGetItemById_when_existingItemWithVocabularyPairs_then_returnItemWithPairs() {
        //Arrange
        let idToSearchFor = "123"
        let observer = self.scheduler.createObserver(SetLocalDataModel?.self)
        let existingItem = self.createTestSetEntityWithVocabularyPairs()
        existingItem.setID = idToSearchFor
        let testRealm = try! Realm()
        try! testRealm.write {
            testRealm.add(existingItem)
        }
        
        //Act
        self.testee.getItemById(with: idToSearchFor).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to return a result")
            return
        }
        XCTAssertEqual(existingItem.setID, result?.id)
        XCTAssertEqual(existingItem.name, result?.name)
        existingItem.vocabularyPairs.forEach { existingPair in
            guard let pairExists = result?.vocabularyPairs.contains(where: { item in
                return item.wordOrPhrase == existingPair.wordOrPhrase && item.definition == existingPair.definition && item.id == existingPair.pairID }
                ) else {
                    XCTFail("Failed to find vocabulary pair")
                    return
            }
            XCTAssertTrue(pairExists, "Failed to read out stored vocabulary pairs")
        }
    }
    
    func testSaveItem_when_itemNotAlreadyExists_then_saveNewItem() {
        //Arrange
        let idThatWasSaved = "1"
        let nameThatWasSaved = "Spanish"
        let observer = self.scheduler.createObserver(Void.self)
        let newItem = SetLocalDataModel(id: idThatWasSaved, name: nameThatWasSaved)
        
        //Act
        self.testee.save(item: newItem).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        let testRealm = try! Realm()
        let results = testRealm.objects(SetEntity.self)
        if results.count == 1 {
            XCTAssertTrue(results.contains(where: ) { $0.setID == idThatWasSaved }, "Failed to save set ID")
            XCTAssertTrue(results.contains(where: ) { $0.name == nameThatWasSaved }, "Failed to save set name")
        } else {
            XCTFail("Saved incorrect number of items")
        }
    }
    
    func testSaveItem_when_itemAlreadyExists_then_updateExistingItem() {
        //Arrange
        let idToUpdate = "3"
        let newName = "Klingon"
        let observer = self.scheduler.createObserver(Void.self)
        let existingItem = SetEntity()
        existingItem.setID = idToUpdate
        existingItem.name = "Vietnamese"
        let testRealm = try! Realm()
        try! testRealm.write {
            testRealm.add(existingItem)
        }
        let itemToSave = SetLocalDataModel(id: existingItem.setID, name: newName)
        
        //Act
        self.testee.save(item: itemToSave).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        let results = testRealm.objects(SetEntity.self)
        if results.count == 1 {
            XCTAssertTrue(results.contains(where: ) { $0.setID == idToUpdate }, "Failed to update item with correct ID")
            XCTAssertTrue(results.contains(where: ) { $0.name == newName }, "Failed to update set with new name")
        } else {
            XCTFail("Saved incorrect number of items")
        }
    }
    
    //TODO: testSaveItem_when_itemContainsVocabularyPairs_then_savePairs
    
    func testRemoveItem_when_itemDoesNotExist_then_doNothing() {
        //Arrange
        let idToRemove = "4"
        let existingID = "1"
        let existingName = "Vietamese"
        let observer = self.scheduler.createObserver(Void.self)
        let existingItem = SetEntity()
        existingItem.setID = existingID
        existingItem.name = existingName
        let testRealm = try! Realm()
        try! testRealm.write {
            testRealm.add(existingItem)
        }
        
        //Act
        self.testee.removeItem(with: idToRemove).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        let results = testRealm.objects(SetEntity.self)
        if results.count == 1 {
            XCTAssertTrue(results.contains(where: ) { $0.setID == existingID }, "The previously existing ID no longer exists")
            XCTAssertTrue(results.contains(where: ) { $0.name == existingName }, "The previously existing name no longer exists")
        } else {
            XCTFail("Incorrect number of items")
        }
    }
    
    func testRemoveItem_when_itemExists_then_removeItem() {
        //Arrange
        let existingID = "1"
        let existingName = "Vietamese"
        let observer = self.scheduler.createObserver(Void.self)
        let existingItem = SetEntity()
        existingItem.setID = existingID
        existingItem.name = existingName
        let testRealm = try! Realm()
        try! testRealm.write {
            testRealm.add(existingItem)
        }
        
        //Act
        self.testee.removeItem(with: existingID).subscribe(observer).disposed(by: self.bag)
        
        //Assert
        let results = testRealm.objects(SetEntity.self)
        XCTAssertEqual(0, results.count, "Failed to remove existing item")
    }
}
