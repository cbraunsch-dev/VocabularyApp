//
//  TitleValueTableSection.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct TitleValueTableSection: TableSection {
    let items: [TitleValueTableItem]
    let title: String?
    let footer: String?
}
