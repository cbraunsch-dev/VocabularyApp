//
//  PracticeSetViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 09.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class PracticeSetViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockRandomNumberService: MockRandomNumberService!
    private var viewModel: PracticeSetViewModel!
    private var viewController: PracticeSetViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockRandomNumberService = MockRandomNumberService()
        self.viewModel = PracticeSetViewModel(randomNumberService: self.mockRandomNumberService)
        self.viewController = (UIStoryboard(name: StoryboardName.practiceSet.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "PracticeSetViewController") as! PracticeSetViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockRandomNumberService = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }

    func testViewDidLoad_then_showHintMessageInFlashCard() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
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
    
    func testShowNextPair_then_showWordOrPhraseOfNextVocabularyPair() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.showNextPair).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testShowNextPair_when_alreadyViewedLastPair_then_showWordOrPhraseOfFirstPair() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        self.mockRandomNumberService.generateRandomNumberStubs = self.createListOfOrderedNumbers(numberOfItems: vocabPairs.count)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        let showNextPairEvents = self.createEvents(nrOfEvents: vocabPairs.count, event: ())
        scheduler3.createColdObservable(showNextPairEvents).asObservable().bind(to: self.viewModel.inputs.showNextPair).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    //TODO: testShowNextPair_when_wordOrPhraseVeryLong
    
    func testShowValue_then_showDefinitionOfCurrentVocabularyPair() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Act
        scheduler3.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.showValue).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testShowValue_when_firstShowedNextPair_then_showDefinitionOfCurrentVocabularyPair() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        let scheduler4 = TestScheduler(initialClock: 0)
        let vocabPairs = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "Serbian", vocabularyPairs: vocabPairs)
        self.viewController.set = set
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, set)]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        scheduler3.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.showNextPair).disposed(by: self.bag)
        scheduler3.start()
        
        //Act
        scheduler4.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.showValue).disposed(by: self.bag)
        scheduler4.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
