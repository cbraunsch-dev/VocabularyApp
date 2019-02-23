//
//  AddSetViewControllerSnapshotTests.swift
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

class AddSetViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var viewModel: AddSetViewModel!
    private var viewController: AddSetViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.viewModel = AddSetViewModel()
        self.viewController = (UIStoryboard(name: StoryboardName.sets.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "AddSetViewController") as! AddSetViewController)
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

    func testViewDidLoad_when_noNameSpecified() {
        //Arrange/Act
        self.loadView(of: self.viewController)
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testViewDidLoad_when_nameSpecified() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.loadView(of: self.viewController)
        
        //Act
        scheduler1.createColdObservable([next(100, "My set")]).asObservable().bind(to: self.viewModel.inputs.setName).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testSetName_then_showNameAndEnabeSaveButton() {
        //Arrange
        self.loadView(of: self.viewController)
        
        //Act
        self.scheduler.createColdObservable([next(100, "My new set")]).asObservable().bind(to: self.viewModel.inputs.setName).disposed(by: self.bag)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
