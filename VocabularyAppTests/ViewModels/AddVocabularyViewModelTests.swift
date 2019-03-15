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

class AddVocabularyViewModelTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockImportService: MockImportVocabularyService!
    private var testee: AddVocabularyViewModel!
    
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockImportService = MockImportVocabularyService()
        self.testee = AddVocabularyViewModel(importVocabularyService: self.mockImportService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
    }

    override func tearDown() {
        self.scheduler = nil
        self.mockImportService = nil
        self.testee = nil
        super.tearDown()
    }

    func testSelectItem_when_selectedFirstItem_then_openFileBrowser() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let observer = scheduler2.createObserver(Void.self)
        self.testee.outputs.openFileBrowser.subscribe(observer).disposed(by: self.bag)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.testee.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, IndexPath(row: 0, section: 0))]).asObservable().bind(to: self.testee.inputs.selectItem).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        XCTAssertNotNil(self.extractValue(from: observer))
    }
}
