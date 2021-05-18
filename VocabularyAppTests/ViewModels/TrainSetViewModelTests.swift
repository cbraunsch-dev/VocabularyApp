//
//  TrainSetViewModelTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 08.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class TrainSetViewModelTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var testee: TrainSetViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.testee = TrainSetViewModel()
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.testee = nil
        super.tearDown()
    }

    func testSelectItem_when_selectedFirstItem_then_practice() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        self.testee.outputs.practice.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([Recorded.next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([Recorded.next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer))
    }
    
    func testSelectItem_when_selctedSecondItem_then_play() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        self.testee.outputs.play.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([Recorded.next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([Recorded.next(100, IndexPath(row: 1, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer))
    }
}
