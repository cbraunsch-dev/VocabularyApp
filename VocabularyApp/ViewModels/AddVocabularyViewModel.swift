//
//  AddVocabularyViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AddVocabularyViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var set: PublishSubject<SetLocalDataModel> { get }
    var selectItem: PublishSubject<IndexPath> { get }
    var importFromFile: PublishSubject<String> { get }
    var saveButtonTaps: PublishSubject<Void> { get }
}

protocol AddVocabularyViewModelOutputs: ErrorEmissionCapable {
    var sections: PublishSubject<[TitleValueTableSection]> { get }
    var openFileBrowser: PublishSubject<Void> { get }
    var spinnerAnimating: PublishSubject<Bool> { get }
    var saveButtonEnabled: PublishSubject<Bool> { get }
    var setSaved: PublishSubject<Void> { get }
}

protocol AddVocabularyViewModelType {
    var inputs: AddVocabularyViewModelInputs { get }
    var outputs: AddVocabularyViewModelOutputs { get }
}

class AddVocabularyViewModel: AddVocabularyViewModelType, AddVocabularyViewModelInputs, AddVocabularyViewModelOutputs, SchedulingCapable, ErrorBindable {
    private let bag = DisposeBag()
    private let importVocabularyService: ImportVocabularyService
    private let setLocalDataService: SetLocalDataService
    private let resultConverter: ResultConverter
    private let importVocabularyResult = PublishSubject<OperationResult<[VocabularyPairLocalDataModel]>>()
    private let saveSetResult = PublishSubject<OperationResult<Void>>()
    private let snapshot = PublishSubject<SetLocalDataModel>()
    private let selectedTableItemAction = PublishSubject<TableItemAction>()
    
    let viewDidLoad = PublishSubject<Void>()
    let set = PublishSubject<SetLocalDataModel>()
    let selectItem = PublishSubject<IndexPath>()
    let importFromFile = PublishSubject<String>()
    let saveButtonTaps = PublishSubject<Void>()
    let sections = PublishSubject<[TitleValueTableSection]>()
    let openFileBrowser = PublishSubject<Void>()
    let spinnerAnimating = PublishSubject<Bool>()
    let saveButtonEnabled = PublishSubject<Bool>()
    let setSaved = PublishSubject<Void>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    var inputs: AddVocabularyViewModelInputs { return self }
    var outputs: AddVocabularyViewModelOutputs { return self }
    
    var main: SchedulerType = MainScheduler.instance
    var worker: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)
    
    init(importVocabularyService: ImportVocabularyService, setLocalDataService: SetLocalDataService, resultConverter: ResultConverter) {
        self.importVocabularyService = importVocabularyService
        self.setLocalDataService = setLocalDataService
        self.resultConverter = resultConverter
        
        self.inputs.viewDidLoad
            .withLatestFrom(self.inputs.set)
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.viewDidLoad
            .map { _ in false }
            .bind(to: self.outputs.saveButtonEnabled)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.outputs.sections) { (selection: $0, sections: $1) }
            .map { $0.sections[$0.selection.section].items[$0.selection.row].action }
            .bind(to: self.selectedTableItemAction)
            .disposed(by: self.bag)
        self.inputs.importFromFile
            .map { _ in true }
            .bind(to: self.outputs.spinnerAnimating)
            .disposed(by: self.bag)
        self.inputs.importFromFile
            .flatMapLatest { file -> Observable<OperationResult<[VocabularyPairLocalDataModel]>> in
                let operation = self.importVocabularyService.importVocabulary(at: file)
                    .subscribeOn(self.worker)
                    .observeOn(self.main)
                return self.resultConverter.convert(result: operation)
            }.bind(to: self.importVocabularyResult)
            .disposed(by: self.bag)
        self.inputs.saveButtonTaps
            .withLatestFrom(self.snapshot)
            .flatMapLatest { snapshot -> Observable<OperationResult<Void>> in
                let operation = self.setLocalDataService.save(item: snapshot)
                return self.resultConverter.convert(result: operation)
            }.bind(to: self.saveSetResult)
            .disposed(by: self.bag)
        
        self.selectedTableItemAction
            .filter { $0 is AddVocabularyItemAction }.map { $0 as! AddVocabularyItemAction }
            .filter { $0 == AddVocabularyItemAction.importFromCsv }
            .map { _ in return }
            .bind(to: self.outputs.openFileBrowser)
            .disposed(by: self.bag)
        self.importVocabularyResult
            .map { _ in false }
            .bind(to: self.outputs.spinnerAnimating)
            .disposed(by: self.bag)
        self.importVocabularyResult
            .map { _ in true }
            .bind(to: self.outputs.saveButtonEnabled)
            .disposed(by: self.bag)
        self.importVocabularyResult
            .filter { $0.resultValue != nil }.map { $0.resultValue! }
            .withLatestFrom(self.snapshot) { (vocabPairs: $0, snapshot: $1) }
            .map { $0.snapshot |> SetLocalDataModel.vocabularyPairsLens *~ $0.vocabPairs }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.snapshot
            .map { self.createSections(set: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        
        self.bindError(of: self.importVocabularyResult, disposedWith: self.bag)
        self.bindError(of: self.saveSetResult, disposedWith: self.bag)
    }
    
    private func createSections(set: SetLocalDataModel) -> [TitleValueTableSection] {
        let importItem = TitleValueTableItem(title: L10n.Action.ImportVocabulary.csv, action: AddVocabularyItemAction.importFromCsv, value: "", hint: "", type: AddVocabularyItemType.actionItem)
        let importSection = TitleValueTableSection(items: [importItem], title: nil, footer: nil)
        
        let vocabularyItems = set.vocabularyPairs.map { pair -> TitleValueTableItem in
            return TitleValueTableItem(title: pair.wordOrPhrase, action: GenericTableItemAction.none, value: pair.definition, hint: "", type: AddVocabularyItemType.vocabularyPair)
        }
        let vocabularySection = TitleValueTableSection(items: vocabularyItems, title: nil, footer: nil)
        
        return [importSection, vocabularySection]
    }
}

enum AddVocabularyItemAction: TableItemAction {
    case importFromCsv
}

enum AddVocabularyItemType: TableItemType {
    case actionItem
    case vocabularyPair
}
