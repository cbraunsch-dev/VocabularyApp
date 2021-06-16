//
//  BucketFeedbackViewSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 16.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
import SnapKit
@testable import VocabularyApp

class BucketFeedbackViewSnapshotTests: FBSnapshotTestCase {

    func testShowSuccess() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketFeedbackView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(250)
            make.height.equalTo(250)
        }
        
        //Act
        testee.showSuccess()
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
    
    func testShowFailure() {
        //Arrange
        self.recordMode = false
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        containerView.backgroundColor = UIColor.white
        let testee = BucketFeedbackView(frame: CGRect.zero)
        containerView.addSubview(testee)
        testee.snp.makeConstraints { make in
            make.centerX.equalTo(containerView)
            make.centerY.equalTo(containerView)
            make.width.equalTo(250)
            make.height.equalTo(250)
        }
        
        //Act
        testee.showFailure()
        
        //Act//Assert
        FBSnapshotVerifyView(containerView)
    }
}
