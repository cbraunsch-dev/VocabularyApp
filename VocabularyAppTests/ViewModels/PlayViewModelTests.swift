//
//  PlayViewModelTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 29.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class PlayViewModelTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var testee: PlayViewModel!
    private let pair1 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 1", definition: "Definition 1")
    private let pair2 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 2", definition: "Definition 2")
    private let pair3 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 3", definition: "Definition 3")
    private let pair4 = VocabularyPairLocalDataModel(wordOrPhrase: "Word 4", definition: "Definition 4")
    private var pairs = [VocabularyPairLocalDataModel]()
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.testee = PlayViewModel()
        pairs.append(contentsOf: [pair1, pair2, pair3, pair4])
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        scheduler1.createColdObservable([Recorded.next(100, pairs)]).asObservable().bind(to: self.testee.inputs.pairs).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([Recorded.next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.testee = nil
        super.tearDown()
    }

    func testSpawnPair_then_updateItemsRemaining() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.itemsRemaining.subscribe(observer).disposed(by: self.bag)
        
        //Act
        scheduler1.createColdObservable([Recorded.next(100, pair1)]).asObservable().bind(to: self.testee.inputs.spawnPair).disposed(by: self.bag)
        scheduler1.start()
        
        //Assert
        guard let itemsRemaining = self.extractValue(from: observer) else {
            XCTFail("Nothing was emitted")
            return
        }
        XCTAssertEqual("Items remaining: \(pairs.count - 1)", itemsRemaining)
    }
    
    // TODO: When should game actually end? Some amount of time after we spawned last item?
    //  Or the first time we match something after we've spawned the last item? That probably
    //  makes the most sense tbh
    
    func testPairMatched_then_updatePercentMatched() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.percentMatched.subscribe(observer).disposed(by: self.bag)
        
        //Act
        scheduler1.createColdObservable([Recorded.next(100, pair1)]).asObservable().bind(to: self.testee.inputs.pairMatched).disposed(by: self.bag)
        scheduler1.start()
        
        //Assert
        guard let percentMatched = self.extractValue(from: observer) else {
            XCTFail("Nothing was emitted")
            return
        }
        XCTAssertEqual("Matched: 25%", percentMatched)
    }
}
