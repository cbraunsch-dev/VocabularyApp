//
//  AddSetViewModelTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class AddSetViewModelTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var testee: AddSetViewModel!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        self.testee = AddSetViewModel()
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.testee = nil
        self.scheduler = nil
    }

    func testSelectItem_then_editName() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editName.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, "")]).asObservable().bind(to: self.testee.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer))
    }

    func testSelectItem_when_nameAlreadySet_then_editAlreadySetName() {
        //Arrange
        let alreadySetName = "Spanish Set"
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(String.self)
        self.testee.outputs.editName.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, alreadySetName)]).asObservable().bind(to: self.testee.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        guard let nameToEdit = self.extractValue(from: observer) else {
            XCTFail("Failed to edit the name")
            return
        }
        XCTAssertEqual(alreadySetName, nameToEdit)
    }
}
