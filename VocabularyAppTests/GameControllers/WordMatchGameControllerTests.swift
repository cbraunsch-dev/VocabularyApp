//
//  WordMatchGameControllerTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 30.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
@testable import VocabularyApp

class WordMatchGameControllerTests: XCTestCase {
    private var mockDelegate: MockWordMatchGameControllerDelegate!
    private var testee: WordMatchGameController!
    private var mockPile: MockGameItemList!
    private var bucket = [VocabularyPairLocalDataModel]()
    private var blackItems = [VocabularyPairLocalDataModel]()
    private var greenItems = [VocabularyPairLocalDataModel]()
    
    override func setUp() {
        super.setUp()
        self.mockDelegate = MockWordMatchGameControllerDelegate()
        self.mockPile = MockGameItemList()
        self.testee = WordMatchGameController(pile: mockPile, bucket: bucket, blackItems: blackItems, greenItems: greenItems)
        self.testee.delegate = mockDelegate
    }
    
    func testStartGame_when_pileHasEnoughItems_then_updateAllBucketsWithDifferentTextsFromPile() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "The best thing ever")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Vanilla", definition: "Also pretty dope")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Corndog", definition: "Ultra weird")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Nugget", definition: "Depends...")
        self.mockPile.randomItemsStubs = [[pair1, pair2, pair3, pair4]]
        
        //Act
        self.testee.startGame()
        
        //Assert
        XCTAssertTrue(self.mockDelegate.verifyThatBucket(with: BucketId.bucket1, wasUpdatedWith: pair1))
        XCTAssertTrue(self.mockDelegate.verifyThatBucket(with: BucketId.bucket2, wasUpdatedWith: pair2))
        XCTAssertTrue(self.mockDelegate.verifyThatBucket(with: BucketId.bucket3, wasUpdatedWith: pair3))
        XCTAssertTrue(self.mockDelegate.verifyThatBucket(with: BucketId.bucket4, wasUpdatedWith: pair4))
    }
    
    func testStartGame_when_pileDoesNotHaveEnoughItems_then_dontUpdateBuckets() {
        //Arrange
        self.mockPile.randomItemsStubs = [[VocabularyPairLocalDataModel]()]
        
        //Act
        self.testee.startGame()
        
        //Assert
        XCTAssertFalse(self.mockDelegate.bucketWasUpdated)
    }
    
    // TODO: testStartGame_then_startGameLoop
}
