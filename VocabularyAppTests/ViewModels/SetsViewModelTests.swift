//
//  SetsViewModelTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 11.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class SetsViewModelTests: XCTestCase, AssertionDataExtractionCapable, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockSetLocalDataService: MockSetLocalDataService!
    private var testee: SetsViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockSetLocalDataService = MockSetLocalDataService()
        self.testee = SetsViewModel(setLocalDataService: self.mockSetLocalDataService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockSetLocalDataService = nil
        self.testee = nil
    }
    
    func testSelectItem_then_openSet() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let indexToSelect = IndexPath(row: 1, section: 0)
        let sets = self.createTestSetLocalDataModels()
        let setToSelect = sets[indexToSelect.row]
        let observer = self.scheduler.createObserver(SetLocalDataModel.self)
        self.testee.outputs.openSet.subscribe(observer).disposed(by: self.bag)
        self.mockSetLocalDataService.readAllStub = scheduler1.createColdObservable([next(100, sets)]).asObservable()
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, indexToSelect)]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertEqual(setToSelect, self.extractValue(from: observer))
    }
}
