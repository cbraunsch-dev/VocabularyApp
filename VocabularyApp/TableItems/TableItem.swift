//
//  TableItem.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol TableItem {
    var title: String { get }
    var action: TableItemAction { get }
}
