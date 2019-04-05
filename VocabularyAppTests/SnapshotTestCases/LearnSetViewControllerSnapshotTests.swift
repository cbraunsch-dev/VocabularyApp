//
//  LearnSetViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 05.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class LearnSetViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockLocalSetService: MockSetLocalDataService!
    private var viewModel: LearnSetViewModel!
    private var viewController: LearnSetViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockLocalSetService = MockSetLocalDataService()
        self.viewModel = LearnSetViewModel(setLocalDataService: self.mockLocalSetService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.viewController = (UIStoryboard(name: StoryboardName.learnSet.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "LearnSetViewController") as! LearnSetViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockLocalSetService = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }

    func testViewDidLoad_when_setHasNoVocabulary_then_showHint() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let set = SetLocalDataModel(id: "1", name: "My Set")
        self.viewController.set = set
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }

    func testViewDidLoad_when_setHasVocabulary_then_showVocabulary() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "My Set", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testDidAddVocabulary_when_setHasVocabulary_then_showVocabulary() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let initialSet = SetLocalDataModel(id: "1", name: "My Set")
        self.viewController.set = initialSet
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, initialSet)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        let vocabPairs = self.createTestVocabularyPairs()
        let updatedSet: SetLocalDataModel? = SetLocalDataModel(id: "1", name: "My Set", vocabularyPairs: vocabPairs)
        self.mockLocalSetService.getItemByIdStub = scheduler3.createColdObservable([next(100, updatedSet)]).asObservable()
        scheduler3.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.didAddVocabulary).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
