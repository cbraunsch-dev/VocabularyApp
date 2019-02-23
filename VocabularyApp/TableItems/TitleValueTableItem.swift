//
//  TitleValueTableItem.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

struct TitleValueTableItem: TableItem {
    let title: String
    let action: TableItemAction
    let value: String
    let hint: String
    let type: TableItemType
}
