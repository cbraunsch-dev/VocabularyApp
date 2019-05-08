//
//  CsvImportVocabularyServiceTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
@testable import VocabularyApp
import RxTest
import RxSwift

class CsvImportVocabularyServiceTests: XCTestCase, AssertionDataExtractionCapable {
    private let bag = DisposeBag()
    private var mockFileContentProvider: MockFileContentProvider!
    private var testee: CsvImportVocabularyService!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        self.mockFileContentProvider = MockFileContentProvider()
        self.testee = CsvImportVocabularyService(fileContentProvider: self.mockFileContentProvider)
        self.scheduler = TestScheduler(initialClock: 0)
    }

    override func tearDown() {
        self.mockFileContentProvider = nil
        self.testee = nil
        self.scheduler = nil
        super.tearDown()
    }

    func testImportVocabulary_when_csvContainsMultipleEntries_then_emitCorrectNumberOfPairs() {
        //Arrange
        let expectedNumberOfPairs = 5
        let word1 = "Hvala"
        let definition1 = "Thank you"
        let word2 = "Šteta"
        let definition2 = "A pity"
        let word3 = "Iznenaditi"
        let definition3 = "Surprise"
        let word4 = "Ogledalo"
        let definition4 = "Mirror"
        let word5 = "Opasan"
        let definition5 = "Dangerous"
        let csv = "Hvala,Thank you\nŠteta,A pity\nIznenaditi,Surprise\nOgledalo,Mirror\nOpasan,Dangerous"
        self.mockFileContentProvider.contentsOfFileStub = csv
        let observer = self.scheduler.createObserver([VocabularyPairLocalDataModel].self)
        
        //Act
        self.testee.importVocabulary(at: "SomePath").subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to emit result")
            return
        }
        guard result.count == expectedNumberOfPairs else {
            XCTFail("Imported incorrect number of vocabulary pairs")
            return
        }
        XCTAssertEqual(word1, result[0].wordOrPhrase)
        XCTAssertEqual(definition1, result[0].definition)
        XCTAssertEqual(word2, result[1].wordOrPhrase)
        XCTAssertEqual(definition2, result[1].definition)
        XCTAssertEqual(word3, result[2].wordOrPhrase)
        XCTAssertEqual(definition3, result[2].definition)
        XCTAssertEqual(word4, result[3].wordOrPhrase)
        XCTAssertEqual(definition4, result[3].definition)
        XCTAssertEqual(word5, result[4].wordOrPhrase)
        XCTAssertEqual(definition5, result[4].definition)
       
    }
    
    func testImportVocabulary_when_csvContainsSingleEntry_then_emitOnePair() {
        //Arrange
        let expectedNumberOfPairs = 1
        let word = "Hvala"
        let definition = "Thank you"
        let csv = "Hvala,Thank you"
        self.mockFileContentProvider.contentsOfFileStub = csv
        let observer = self.scheduler.createObserver([VocabularyPairLocalDataModel].self)
        
        //Act
        self.testee.importVocabulary(at: "SomePath").subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let result = self.extractValue(from: observer) else {
            XCTFail("Failed to emit result")
            return
        }
        guard result.count == expectedNumberOfPairs else {
            XCTFail("Imported incorrect number of vocabulary pairs")
            return
        }
        XCTAssertEqual(word, result[0].wordOrPhrase)
        XCTAssertEqual(definition, result[0].definition)
    }
    
    func testImportVocabulary_when_csvContainsNoEntries_then_emitError() {
        //Arrange
        self.mockFileContentProvider.contentsOfFileStub = ""
        let observer = self.scheduler.createObserver([VocabularyPairLocalDataModel].self)
        
        //Act
        self.testee.importVocabulary(at: "SomePath").subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let error = self.extractError(from: observer) else {
            XCTFail("Expected an error")
            return
        }
        guard let importError = error as? CsvImportVocabularyError else {
            XCTFail("Incorrect type of error")
            return
        }
        switch importError {
        case .incorrectNumberOfColumns(_):
            //Test passes
            break
        default:
            XCTFail("Incorrect import error")
            break
        }
    }
    
    func testImportVocabulary_when_csvContainsIncorrectNumberOfColumns_then_emitError() {
        //Arrange
        let csv = "Hvala,Thank you\nŠteta,A pity,Hello\nIznenaditi,Surprise\nOgledalo,Mirror\nOpasan,Dangerous"
        self.mockFileContentProvider.contentsOfFileStub = csv
        let observer = self.scheduler.createObserver([VocabularyPairLocalDataModel].self)
        
        //Act
        self.testee.importVocabulary(at: "SomePath").subscribe(observer).disposed(by: self.bag)
        
        //Assert
        guard let error = self.extractError(from: observer) else {
            XCTFail("Expected an error")
            return
        }
        guard let importError = error as? CsvImportVocabularyError else {
            XCTFail("Incorrect type of error")
            return
        }
        switch importError {
        case .incorrectNumberOfColumns(_):
            //Test passes
            break
        default:
            XCTFail("Incorrect import error")
            break
        }
    }
}
