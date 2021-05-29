//
//  BucketViewSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 28.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
import SnapKit
@testable import VocabularyApp

class BucketViewSnapshotTests: FBSnapshotTestCase {

    func testUpdateWithNewPair_when_useDefinition() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: true)
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testUpdateWithNewPair_when_useWordOrPhrase() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 440, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(400)
            make.height.equalTo(250)
        }
        
        testee.updateWith(pair: VocabularyPairLocalDataModel(wordOrPhrase: "Chocolate", definition: "Tasty, delicious goodness"), useDefinition: false)
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }

}
