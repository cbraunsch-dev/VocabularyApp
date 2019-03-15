//
//  ImportFromCsvService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol ImportVocabularyService {
    func importVocabulary(at filePath: String) throws -> [VocabularyPairLocalDataModel]
}

class CsvImportVocabularyService: ImportVocabularyService {
    private let fileContentProvider: FileContentProvider
    
    init(fileContentProvider: FileContentProvider) {
        self.fileContentProvider = fileContentProvider
    }
    
    func importVocabulary(at filePath: String) throws -> [VocabularyPairLocalDataModel] {
        let csv = try self.fileContentProvider.contentsOfFile(at: filePath, encoding: .utf8)
        var pairs = [VocabularyPairLocalDataModel]()
        let rows = csv.components(separatedBy: "\n")
        guard rows.count > 0 else {
            throw CsvImportVocabularyError.noData
        }
        for row in rows {
            let columns = row.components(separatedBy: ",")
            guard columns.count == 2 else {
                throw CsvImportVocabularyError.incorrectNumberOfColumns
            }
            let wordOrPhrase = columns[0]
            let definition = columns[1]
            let pair = VocabularyPairLocalDataModel(wordOrPhrase: wordOrPhrase, definition: definition)
            pairs.append(pair)
        }
        return pairs
    }
}
