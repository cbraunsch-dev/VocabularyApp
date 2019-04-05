//
//  AddVocabularyViewModelTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class AddVocabularyViewModelTests: XCTestCase, AssertionDataExtractionCapable, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockImportService: MockImportVocabularyService!
    private var mockLocalSetService: MockSetLocalDataService!
    private var testee: AddVocabularyViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockImportService = MockImportVocabularyService()
        self.mockLocalSetService = MockSetLocalDataService()
        self.testee = AddVocabularyViewModel(importVocabularyService: self.mockImportService, setLocalDataService: self.mockLocalSetService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.testee.worker = self.scheduler
        self.testee.main = self.scheduler
    }

    override func tearDown() {
        self.scheduler = nil
        self.mockImportService = nil
        self.mockLocalSetService = nil
        self.testee = nil
        super.tearDown()
    }

    func testSelectItem_when_selectedFirstItem_then_openFileBrowser() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        self.testee.outputs.openFileBrowser.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, SetLocalDataModel(id: "1", name: "My Set"))]).asObservable().bind(to: self.testee.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer))
    }
    
    func testSelectitem_when_selectedItemInSecondSection_then_dontOpenFileBrowser() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        self.testee.outputs.openFileBrowser.subscribe(observer).disposed(by: self.bag)
        let alreadyExistingVocabulary = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "My Set", vocabularyPairs: alreadyExistingVocabulary)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.testee.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, IndexPath(row: 0, section: 1))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        XCTAssertNil(self.extractValue(from: observer))
    }
    
    func testSaveButtonTaps_then_saveSet() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let scheduler4 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        let importedVocabularyPairs = self.createTestVocabularyPairs()
        let expectedSetToBeSaved = SetLocalDataModel(id: "123", name: "My Set", vocabularyPairs: importedVocabularyPairs)
        self.mockLocalSetService.saveItemStub = scheduler3.createColdObservable([next(100, ())]).asObservable()
        self.testee.outputs.openFileBrowser.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, SetLocalDataModel(id: expectedSetToBeSaved.id, name: expectedSetToBeSaved.name))]).asObservable().bind(to: self.testee.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        self.mockImportService.importVocabularyStub = scheduler3.createColdObservable([next(100, importedVocabularyPairs)]).asObservable()
        self.testee.worker = scheduler3
        self.testee.main = scheduler3
        scheduler3.createColdObservable([next(100, "SomeFile")]).asObservable().bind(to: self.testee.inputs.importFromFile).disposed(by: self.bag)
        scheduler3.start()
        
        //Act
        scheduler4.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.saveButtonTaps).disposed(by: self.bag)
        scheduler4.start()
        
        //Assert
        XCTAssertEqual(expectedSetToBeSaved, self.mockLocalSetService.savedItem)
    }
}
