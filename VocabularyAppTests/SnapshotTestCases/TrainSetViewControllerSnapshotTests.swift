//
//  TrainSetViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 08.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class TrainSetViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var viewModel: TrainSetViewModel!
    private var viewController: TrainSetViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.viewModel = TrainSetViewModel()
        self.viewController = (UIStoryboard(name: StoryboardName.trainSet.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "TrainSetViewController") as! TrainSetViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }
    
    func testViewDidLoad_then_showOptions() {
        //Arrange/Act
        self.loadView(of: self.viewController)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
