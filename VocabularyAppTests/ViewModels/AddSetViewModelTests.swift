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
    private var mockSetLocalDataService: MockSetLocalDataService!
    private var testee: AddSetViewModel!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        self.mockSetLocalDataService = MockSetLocalDataService()
        self.testee = AddSetViewModel(setLocalDataService: self.mockSetLocalDataService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockSetLocalDataService = nil
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
    
    func testSaveButtonTaps_then_saveData() {
        //Arrange
        let alreadySetName = "Spanish Set"
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.mockSetLocalDataService.saveItemStub = Observable<Void>.empty()
        scheduler1.createColdObservable([next(100, alreadySetName)]).asObservable().bind(to: self.testee.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertTrue(self.mockSetLocalDataService.didSaveItem)
        XCTAssertEqual(alreadySetName, self.mockSetLocalDataService.savedItem?.name)
    }
    
    func testSaveButtonTaps_when_saveFailed_then_emitError() {
        //Arrange
        let alreadySetName = "Spanish Set"
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver((errorOccurred: Bool, title: String, message: String).self)
        self.testee.outputs.error.subscribe(observer).disposed(by: self.bag)
        self.mockSetLocalDataService.saveItemStub = scheduler2.createColdObservable([error(100, DataAccessorError.failedToAccessDatabase)]).asObservable()
        scheduler1.createColdObservable([next(100, alreadySetName)]).asObservable().bind(to: self.testee.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer), "Failed to emit error")
    }
    
    func testSaveButtonTaps_when_savedData_then_emitThatSetWasSaved() {
        //Arrange
        let setName = "Spanish Set"
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(SetLocalDataModel.self)
        self.testee.outputs.setSaved.subscribe(observer).disposed(by: self.bag)
        self.mockSetLocalDataService.saveItemStub = scheduler2.createColdObservable([next(100, ())]).asObservable()
        scheduler1.createColdObservable([next(100, setName)]).asObservable().bind(to: self.testee.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        guard let savedSet = self.extractValue(from: observer) else {
            XCTFail("Failed to emit that set was saved")
            return
        }
        XCTAssertEqual(setName, savedSet.name)
    }
}
