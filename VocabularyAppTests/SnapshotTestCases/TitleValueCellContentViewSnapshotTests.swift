//
//  TitleValueCellContentViewSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class TitleValueCellContentViewSnapshotTests: FBSnapshotTestCase {
    func test_when_noValueText() {
        //Arrange
        let testee = TitleValueCellContentView(frame: CGRect(x: 0, y: 0, width: 640, height: 140))
        testee.title.text = "Name"
        
        //Act//Assert
        FBSnapshotVerifyView(testee)
    }
    
    func test_when_valueText() {
        //Arrange
        let testee = TitleValueCellContentView(frame: CGRect(x: 0, y: 0, width: 640, height: 140))
        testee.title.text = "Name"
        testee.value.text = "Buy cookies"
        
        //Act//Assert
        FBSnapshotVerifyView(testee)
    }
}
