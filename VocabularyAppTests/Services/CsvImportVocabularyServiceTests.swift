//
//  CsvImportVocabularyServiceTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
@testable import VocabularyApp

class CsvImportVocabularyServiceTests: XCTestCase {
    private var mockFileContentProvider: MockFileContentProvider!
    private var testee: CsvImportVocabularyService!
    
    override func setUp() {
        super.setUp()
        self.mockFileContentProvider = MockFileContentProvider()
        self.testee = CsvImportVocabularyService(fileContentProvider: self.mockFileContentProvider)
    }

    override func tearDown() {
        self.mockFileContentProvider = nil
        self.testee = nil
        super.tearDown()
    }

    func testImportVocabulary_when_csvContainsMultipleEntries_then_returnCorrectNumberOfPairs() {
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
        
        //Act/Assert
        do {
            let result = try self.testee.importVocabulary(at: "SomePath")
            
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
        } catch {
            XCTFail("An error occurred while trying to import the vocabulary from CSV")
        }
    }
    
    func testImportVocabulary_when_csvContainsSingleEntry_then_returnOnePair() {
        //Arrange
        let expectedNumberOfPairs = 1
        let word = "Hvala"
        let definition = "Thank you"
        let csv = "Hvala,Thank you"
        self.mockFileContentProvider.contentsOfFileStub = csv
        
        //Act/Assert
        do {
            let result = try self.testee.importVocabulary(at: "SomePath")
            
            guard result.count == expectedNumberOfPairs else {
                XCTFail("Imported incorrect number of vocabulary pairs")
                return
            }
            XCTAssertEqual(word, result[0].wordOrPhrase)
            XCTAssertEqual(definition, result[0].definition)
        } catch {
            XCTFail("An error occurred while trying to import the vocabulary from CSV")
        }
    }
    
    func testImportVocabulary_when_csvContainsNoEntries_then_returnError() {
        //Arrange
        self.mockFileContentProvider.contentsOfFileStub = ""
        
        //Act/Assert
        do {
            _ = try self.testee.importVocabulary(at: "SomePath")
            XCTFail("Expected an error")
        } catch {
            guard let importError = error as? CsvImportVocabularyError else {
                XCTFail("Incorrect type of error")
                return
            }
            XCTAssertEqual(CsvImportVocabularyError.incorrectNumberOfColumns, importError)
        }
    }
    
    func testImportVocabulary_when_csvContainsIncorrectNumberOfColumns_then_returnError() {
        //Arrange
        let csv = "Hvala,Thank you\nŠteta,A pity,Hello\nIznenaditi,Surprise\nOgledalo,Mirror\nOpasan,Dangerous"
        self.mockFileContentProvider.contentsOfFileStub = csv
        
        //Act/Assert
        do {
            _ = try self.testee.importVocabulary(at: "SomePath")
            XCTFail("Expected an error")
        } catch {
            guard let importError = error as? CsvImportVocabularyError else {
                XCTFail("Incorrect type of error")
                return
            }
            XCTAssertEqual(CsvImportVocabularyError.incorrectNumberOfColumns, importError)
        }
    }
}
