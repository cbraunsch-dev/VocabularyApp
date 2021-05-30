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
    private var mockGameLoop: MockGameLoop!
    private var mockPile: MockGameItemList!
    private var mockBucket: MockGameItemList!
    private var mockBlackItems: MockGameItemList!
    private var mockGreenItems: MockGameItemList!
    private var testee: WordMatchGameController!
    
    override func setUp() {
        super.setUp()
        self.mockDelegate = MockWordMatchGameControllerDelegate()
        self.mockGameLoop = MockGameLoop()
        self.mockPile = MockGameItemList()
        self.mockBucket = MockGameItemList()
        self.mockBlackItems = MockGameItemList()
        self.mockGreenItems = MockGameItemList()
        self.testee = WordMatchGameController(
            gameLoop: mockGameLoop, pile: mockPile, bucket: mockBucket, blackItems: mockBlackItems, greenItems: mockGreenItems)
        self.testee.delegate = mockDelegate
    }
    
    func testStartGame_then_addItemsToPile() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "The best thing ever")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Vanilla", definition: "Also pretty dope")
        let pairs = [pair1, pair2]
        self.testee.vocabularyPairs = pairs
        
        //Arrange
        self.testee.startGame()
        
        //Assert
        XCTAssertEqual(pairs, self.mockPile.addedItems)
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
        XCTAssertEqual([pair1, pair2, pair3, pair4], self.mockBucket.addedItems)
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
        XCTAssertTrue(self.mockBucket.addedItems.isEmpty)
        XCTAssertFalse(self.mockDelegate.bucketWasUpdated)
    }
    
    func testStartGame_then_startGameLoop() {
        //Act
        self.testee.startGame()
        
        //Assert
        XCTAssertTrue(mockGameLoop.didStartGameLoop)
    }
    
    func testUpdate_then_obtainItemsInBuckets() {
        //Act
        self.testee.update()
        
        //Assert
        XCTAssertTrue(mockBucket.didObtainItems)
    }
    
    func testUpdate_when_obtainedItemsInBuckets_then_filterOutItemsNotInPile() {
        //Act
        self.testee.update()
        
        //Assert
        XCTAssertTrue(mockPile.didObtainItemsThatMatch)
    }
    
    func testUpdate_when_noItemsLeftAfterFilteringWithPile_then_spawnBlackItemFromPile() {
        //Arrange
        let randomItemFromPile = VocabularyPairLocalDataModel(wordOrPhrase: "Corndog", definition: "Ugh")
        self.mockPile.matchedItemsStub = [VocabularyPairLocalDataModel]()
        self.mockPile.randomItemsStubs = [[randomItemFromPile]]
        
        //Act
        self.testee.update()
        
        //Assert
        XCTAssertEqual(randomItemFromPile, self.mockDelegate.spawnedPair)
        XCTAssertEqual(UIColor.black, self.mockDelegate.spawnedTextColor)
    }
    
    func testUpdate_when_itemsLeftAfterFilteringWithPile_then_spawnOneOfThoseAsGreenItem() {
        //Arrange
        let randomItemFromPile = VocabularyPairLocalDataModel(wordOrPhrase: "Corndog", definition: "Ugh")
        self.mockPile.matchedItemsStub = [randomItemFromPile]
        
        //Act
        self.testee.update()
        
        //Assert
        XCTAssertEqual(randomItemFromPile, self.mockDelegate.spawnedPair)
        XCTAssertEqual(UIColor.green, self.mockDelegate.spawnedTextColor)
    }
}
