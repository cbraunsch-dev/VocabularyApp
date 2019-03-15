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

class AddVocabularyViewControllerSnapshotTests: FBSnapshotTestCase {
    private let bag = DisposeBag()
    private var scheduler: TestScheduler!
    private var mockImportService: MockImportVocabularyService!
    private var viewModel: AddVocabularyViewModel!
    private var viewController: AddVocabularyViewController!
    private var navigationViewController: UINavigationController!
    
    override func setUp() {
        super.setUp()
        self.setupSnapshotTest()
        self.recordMode = false
        self.scheduler = TestScheduler(initialClock: 0)
        self.mockImportService = MockImportVocabularyService()
        self.viewModel = AddVocabularyViewModel(importVocabularyService: self.mockImportService, resultConverter: VocabularyAppResultConverter(errorMessageService: LocalizedErrorMessageService()))
        self.viewController = (UIStoryboard(name: StoryboardName.addVocabulary.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: "AddVocabularyViewController") as! AddVocabularyViewController)
        self.viewController.viewModel = self.viewModel
        self.navigationViewController = UINavigationController()
        self.navigationViewController.pushViewController(self.viewController, animated: false)
    }
    
    override func tearDown() {
        self.scheduler = nil
        self.mockImportService = nil
        self.viewModel = nil
        self.viewController = nil
        self.navigationViewController = nil
    }
    
    func testViewDidLoad_when_noVocabularyStored_then_onlyShowEntryToImportVocabulary() {
        //Arrange
        self.loadView(of: self.viewController)
        
        //Act
        self.scheduler.createColdObservable([next(100, ())]).asObservable().bind(to: self.viewModel.inputs.viewDidLoad).disposed(by: self.bag)
        self.scheduler.start()
        
        //Assert
        verifyViewController(viewController: self.navigationViewController)
    }
}
