//
//  SetsViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 10.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class SetsViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var viewController: SetsViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.viewController = (UIStoryboard(name: StoryboardName.sets.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "SetsViewController") as! SetsViewController)
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.viewController = nil
        self.navigationViewController = nil
    }
    
    func testViewDidLoad() {
        //Arrange/Act
        self.loadView(of: self.viewController)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
