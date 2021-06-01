//
//  PlayViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 01.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class PlayViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private var viewController: PlayViewController!
    private var navigationViewController: UINavigationController!
    private var mockGameController: MockGameController!
    private var mockHighScoreService: MockHighScoreService!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.mockGameController = MockGameController()
        self.mockHighScoreService = MockHighScoreService()
        self.viewController = (UIStoryboard(name: StoryboardName.play.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "PlayViewController") as! PlayViewController)
        self.viewController.gameController = self.mockGameController
        self.viewController.highScoreService = self.mockHighScoreService
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.mockGameController = nil
        self.viewController = nil
        self.navigationViewController = nil
    }

    func testUpdateBucket_when_textsNotSuperLong() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        
        //Act
        self.viewController.updateBucket(bucketId: .bucket1, with: pair1, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket2, with: pair2, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket3, with: pair3, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket4, with: pair4, useDefinition: true)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testUpdateBucket_when_textsSuperLong() {
        //Arrange
        let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Super duper very long Word 1", definition: "Super duper very long Definition 1")
        let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Super duper very long Word 2", definition: "Super duper very long Definition 2")
        let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Super duper very long Word 3", definition: "Super duper very long Definition 3")
        let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Super duper very long Word 4", definition: "Super duper very long Definition 4")
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        
        //Act
        self.viewController.updateBucket(bucketId: .bucket1, with: pair1, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket2, with: pair2, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket3, with: pair3, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket4, with: pair4, useDefinition: true)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testGameOver_when_noNewHighScore() {
        // Arrange
        let pair = VocabularyPairLocalDataModel(wordOrPhrase: "Word", definition: "Defintion")
        self.mockHighScoreService.saveHighScoreStub = false
        self.mockHighScoreService.highScoreStub = 1337
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        self.viewController.updateBucket(bucketId: .bucket1, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket2, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket3, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket4, with: pair, useDefinition: true)
        
        // Act
        self.viewController.gameOver()
        
        // Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testGameOver_when_newHighScore() {
        // Arrange
        let pair = VocabularyPairLocalDataModel(wordOrPhrase: "Word", definition: "Defintion")
        self.mockHighScoreService.saveHighScoreStub = true
        self.mockHighScoreService.highScoreStub = 1337
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        self.viewController.updateBucket(bucketId: .bucket1, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket2, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket3, with: pair, useDefinition: true)
        self.viewController.updateBucket(bucketId: .bucket4, with: pair, useDefinition: true)
        
        // Act
        self.viewController.gameOver()
        
        // Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
