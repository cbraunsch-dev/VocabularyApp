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

class SetsViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockSetLocalDataService: MockSetLocalDataService!
    private var viewModel: SetsViewModel!
    private var viewController: SetsViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockSetLocalDataService = MockSetLocalDataService()
        self.viewModel = SetsViewModel(setLocalDataService: self.mockSetLocalDataService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.viewController = (UIStoryboard(name: StoryboardName.sets.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "SetsViewController") as! SetsViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockSetLocalDataService = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }
    
    func testViewDidLoad_when_noSets_then_showEmptyView() {
        //Arrange
        self.mockSetLocalDataService.readAllStub = self.scheduler.createColdObservable([next(100, [SetLocalDataModel]())]).asObservable()
        
        //Act
        self.loadView(of: self.viewController)
        self.scheduler.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testViewDidLoad_when_sets_then_showSetsInTableView() {
        //Arrange
        let sets = self.createTestSetLocalDataModels()
        self.mockSetLocalDataService.readAllStub = self.scheduler.createColdObservable([next(100, sets)]).asObservable()
        
        //Act
        self.loadView(of: self.viewController)
        self.scheduler.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testDidAddSet_then_showSetsInTableView() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.mockSetLocalDataService.readAllStub = scheduler1.createColdObservable([next(100, [SetLocalDataModel]())]).asObservable()
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler1.start()
        let sets = self.createTestSetLocalDataModels()
        self.mockSetLocalDataService.readAllStub = scheduler2.createColdObservable([next(100, sets)]).asObservable()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.didAddSet).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
