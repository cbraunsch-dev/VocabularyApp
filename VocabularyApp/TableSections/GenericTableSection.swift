//
//  GenericTableSection.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct GenericTableSection: TableSection {
    let items: [GenericTableItem]
    let title: String?
    let footer: String?
}
