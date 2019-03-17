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
    var selectItem: PublishSubject<IndexPath> { get }
    var importFromFile: PublishSubject<String> { get }
}

protocol AddVocabularyViewModelOutputs: ErrorEmissionCapable {
    var sections: PublishSubject<[TitleValueTableSection]> { get }
    var openFileBrowser: PublishSubject<Void> { get }
    var spinnerAnimating: PublishSubject<Bool> { get }
}

protocol AddVocabularyViewModelType {
    var inputs: AddVocabularyViewModelInputs { get }
    var outputs: AddVocabularyViewModelOutputs { get }
}

class AddVocabularyViewModel: AddVocabularyViewModelType, AddVocabularyViewModelInputs, AddVocabularyViewModelOutputs, SchedulingCapable, ErrorBindable {
    private let bag = DisposeBag()
    private let importVocabularyService: ImportVocabularyService
    private let resultConverter: ResultConverter
    private let importVocabularyResult = PublishSubject<OperationResult<[VocabularyPairLocalDataModel]>>()
    
    let viewDidLoad = PublishSubject<Void>()
    let selectItem = PublishSubject<IndexPath>()
    let importFromFile = PublishSubject<String>()
    let sections = PublishSubject<[TitleValueTableSection]>()
    let openFileBrowser = PublishSubject<Void>()
    let spinnerAnimating = PublishSubject<Bool>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    var inputs: AddVocabularyViewModelInputs { return self }
    var outputs: AddVocabularyViewModelOutputs { return self }
    
    var main: SchedulerType = MainScheduler.instance
    var worker: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)
    
    init(importVocabularyService: ImportVocabularyService, resultConverter: ResultConverter) {
        self.importVocabularyService = importVocabularyService
        self.resultConverter = resultConverter
        
        self.inputs.viewDidLoad
            .map { self.createSections(vocabularyPairs: [VocabularyPairLocalDataModel]()) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.outputs.sections) { (selection: $0, sections: $1) }
            .map { $0.sections[$0.selection.section].items[$0.selection.row].action as! AddVocabularyItemAction }
            .filter { $0 == AddVocabularyItemAction.importFromCsv }
            .map { _ in return }
            .bind(to: self.outputs.openFileBrowser)
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
        
        self.importVocabularyResult
            .map { _ in false }
            .bind(to: self.outputs.spinnerAnimating)
            .disposed(by: self.bag)
        self.importVocabularyResult
            .filter { $0.resultValue != nil }
            .map { self.createSections(vocabularyPairs: $0.resultValue!) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
    }
    
    private func createSections(vocabularyPairs: [VocabularyPairLocalDataModel]) -> [TitleValueTableSection] {
        let importItem = TitleValueTableItem(title: L10n.Action.ImportVocabulary.csv, action: AddVocabularyItemAction.importFromCsv, value: "", hint: "", type: AddVocabularyItemType.actionItem)
        let importSection = TitleValueTableSection(items: [importItem], title: nil, footer: nil)
        
        let vocabularyItems = vocabularyPairs.map { pair -> TitleValueTableItem in
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
