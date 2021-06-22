//
//  BucketViewSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 28.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
import SnapKit
@testable import VocabularyApp

class BucketViewSnapshotTests: FBSnapshotTestCase {

    func testUpdateWithNewPair_when_useDefinition() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        
        //Act
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: true)
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testUpdateWithNewPair_when_useWordOrPhrase() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        
        //Act
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }

    func testStartHoveringOver() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        
        //Act
        testee.startHoveringOver()
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testStopHoveringOver() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        testee.startHoveringOver()
        
        //Act
        testee.stopHoveringOver()
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testWordWasDroppedIntoBucket_when_thereIsAMatch() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        
        //Act
        _ = testee.wordWasDroppedIntoBucket(word: "Chocolate")
        
        //Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testWordWasDroppedIntoBucket_when_thereIsAMatchAndTimerHasExpired() {
        //Arrange
        self.recordMode = false
        let timerService = MockTimerService()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        testee.timerService = timerService
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        _ = testee.wordWasDroppedIntoBucket(word: "Chocolate")
        
        // Act
        timerService.executeCompletionBlock()
        
        // Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testWordWasDroppedIntoBucket_when_thereIsNoMatch() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        
        //Act
        _ = testee.wordWasDroppedIntoBucket(word: "Corndog")
        
        //Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testWordWasDroppedIntoBucket_when_thereIsNoMatchAndTimerHasExpired() {
        //Arrange
        self.recordMode = false
        let timerService = MockTimerService()
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        testee.timerService = timerService
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        _ = testee.wordWasDroppedIntoBucket(word: "Corndog")
        
        //Act
        timerService.executeCompletionBlock()
        
        //Assert
        FBSnapshotVerifyView(containerView)
    }
}
