//
//  WordMatchGameListTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 30.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
@testable import VocabularyApp

class WordMatchGameListTests: XCTestCase {
    let anyString = ""
    
    func testRandomItems_when_noItems_then_returnEmptyList() {
        //Arrange
        let anyNr = 1
        let testee = WordMatchGameItemList()
        
        //Act
        let result = testee.randomItems(nrOfItems: anyNr)
        
        //Assert
        XCTAssertTrue(result.isEmpty)
    }
    
    func testRandomItems_when_lessItemsThanRequested_then_returnAllItems() {
        //Arrange
        let testee = WordMatchGameItemList()
        testee.addItem(item: VocabularyPairLocalDataModel(wordOrPhrase: anyString, definition: anyString))
        testee.addItem(item: VocabularyPairLocalDataModel(wordOrPhrase: anyString, definition: anyString))
        
        //Act
        let result = testee.randomItems(nrOfItems: 3)
        
        //Assert
        XCTAssertEqual(2, result.count)
    }
    
    func testRandomItems_when_moreItemsThanRequested_then_returnRequestedNumberOfItems() {
        //Arrange
        let testee = WordMatchGameItemList()
        testee.addItem(item: VocabularyPairLocalDataModel(wordOrPhrase: anyString, definition: anyString))
        testee.addItem(item: VocabularyPairLocalDataModel(wordOrPhrase: anyString, definition: anyString))
        testee.addItem(item: VocabularyPairLocalDataModel(wordOrPhrase: anyString, definition: anyString))
        
        //Act
        let result = testee.randomItems(nrOfItems: 2)
        
        //Assert
        XCTAssertEqual(2, result.count)
    }
    
    func testObtainItemsThatMatch_when_listContainsAllItemsOfMatcher_then_returnOnlyMatchingItems() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let testee = WordMatchGameItemList()
        testee.addItem(item: pair1)
        testee.addItem(item: pair2)
        testee.addItem(item: pair3)
        testee.addItem(item: pair4)
        
        //Act
        let result = testee.obtainItemsThatMatch(matcher: [pair1, pair3])
        
        //Assert
        XCTAssertEqual([pair1, pair3], result)
    }
    
    func testObtainItemsThatMatch_when_listContainsSomeItemsOfMatcher_then_returnOnlyMatchingItems() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let testee = WordMatchGameItemList()
        testee.addItem(item: pair1)
        testee.addItem(item: pair2)
        testee.addItem(item: pair3)
        testee.addItem(item: pair4)
        let pair5 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 5", definition: "Definition 5")
        
        //Act
        let result = testee.obtainItemsThatMatch(matcher: [pair1, pair5])
        
        //Assert
        XCTAssertEqual([pair1], result)
    }
    
    func testRemoveItem_when_itemExists_then_removeItemFromList() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let testee = WordMatchGameItemList()
        testee.addItem(item: pair1)
        testee.addItem(item: pair2)
        testee.addItem(item: pair3)
        testee.addItem(item: pair4)
        
        //Act
        testee.removeItem(item: pair2)
        
        //Assert
        XCTAssertEqual([pair1, pair3, pair4], testee.obtainItems())
    }
    
    func testRemoveItem_when_itemDoesNotExist_then_dontRemoveAnythingFromList() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let testee = WordMatchGameItemList()
        testee.addItem(item: pair1)
        testee.addItem(item: pair2)
        testee.addItem(item: pair3)
        
        //Act
        testee.removeItem(item: pair4)
        
        //Assert
        XCTAssertEqual([pair1, pair2, pair3], testee.obtainItems())
    }
}
