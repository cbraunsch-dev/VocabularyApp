//
//  TableSection.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol TableSection {
    associatedtype Item: TableItem
    var items: [Item] { get }
    var title: String? { get }
    var footer: String? { get }
}
