//
//  FileContentProvider.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol FileContentProvider {
    func contentsOfFile(at path: String, encoding: String.Encoding) throws -> String
}
