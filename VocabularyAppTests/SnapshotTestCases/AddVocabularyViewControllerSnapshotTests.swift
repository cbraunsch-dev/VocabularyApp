//
//  AddVocabularyViewControllerSnapshotTests.swift
//  VocabularyAppTests
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import RxSwift
import RxCocoa
import RxTest
@testable import VocabularyApp

class AddVocabularyViewControllerSnapshotTests: FBSnapshotTestCase, TestDataGenerating {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockImportService: MockImportVocabularyService!
    private var mockLocalSetService: MockSetLocalDataService!
    private var viewModel: AddVocabularyViewModel!
    private var viewController: AddVocabularyViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockImportService = MockImportVocabularyService()
        self.mockLocalSetService = MockSetLocalDataService()
        self.viewModel = AddVocabularyViewModel(importVocabularyService: self.mockImportService, setLocalDataService: self.mockLocalSetService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.viewController = (UIStoryboard(name: StoryboardName.addVocabulary.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "AddVocabularyViewController") as! AddVocabularyViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockImportService = nil
        self.mockLocalSetService = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }
    
    func testViewDidLoad_when_noVocabularyStored_then_onlyShowEntryToImportVocabulary() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        self.viewController.set = SetLocalDataModel(id: "1", name: "Set")
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, SetLocalDataModel(id: "1", name: "My Set"))]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        
        //Act
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testViewDidLoad_when_vocabularyStored_then_displayAlreadyImportedVocabularyPairs() {
        //Arrange
        let alreadyExistingVocabulary = self.createTestVocabularyPairs()
        let set = SetLocalDataModel(id: "1", name: "My Set", vocabularyPairs: alreadyExistingVocabulary)
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
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
    
    func testImportFromFile_then_displayImportedVocabularyPairs() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        self.viewModel.worker = scheduler3
        self.viewModel.main = scheduler3
        self.viewController.set = SetLocalDataModel(id: "1", name: "Set")
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, SetLocalDataModel(id: "1", name: "My Set"))]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        self.mockImportService.importVocabularyStub = scheduler3.createColdObservable([next(100, self.createTestVocabularyPairs())]).asObservable()
        
        //Act
        scheduler3.createColdObservable([next(100, "File")]).asObservable().bind(to: self.viewModel.inputs.importFromFile).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
    
    func testImportFromFile_when_importNotFinishedYet_then_showSpinner() {
        //Arrange
        let scheduler1 = TestScheduler(initialClock: 0)
        let scheduler2 = TestScheduler(initialClock: 0)
        let scheduler3 = TestScheduler(initialClock: 0)
        self.viewModel.worker = scheduler3
        self.viewModel.main = scheduler3
        self.viewController.set = SetLocalDataModel(id: "1", name: "Set")
        self.loadView(of: self.viewController)
        scheduler1.createColdObservable([next(100, SetLocalDataModel(id: "1", name: "My Set"))]).asObservable().bind(to: self.viewModel.inputs.set).disposed(by: self.bag)
        scheduler1.start()
        scheduler2.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        scheduler2.start()
        self.mockImportService.importVocabularyStub = Observable<[VocabularyPairLocalDataModel]>.empty()
        
        //Act
        scheduler3.createColdObservable([next(100, "File")]).asObservable().bind(to: self.viewModel.inputs.importFromFile).disposed(by: self.bag)
        scheduler3.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
