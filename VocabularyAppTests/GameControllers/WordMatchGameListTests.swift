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
    func testObtainItemsThatMatch_when_listContainsAllItemsOfMatcher_then_returnOnlyMatchingItems() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let testee = WordMatchGameItemList()
        testee.items = [pair1, pair2, pair3, pair4]
        
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
        testee.items = [pair1, pair2, pair3, pair4]
        let pair5 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 5", definition: "Definition 5")
        
        //Act
        let result = testee.obtainItemsThatMatch(matcher: [pair1, pair5])
        
        //Assert
        XCTAssertEqual([pair1], result)
    }
}
