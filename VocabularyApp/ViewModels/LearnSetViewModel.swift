//
//  LearnSetViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 05.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol LearnSetViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var set: PublishSubject<SetLocalDataModel> { get }
    var didAddVocabulary: PublishSubject<Void> { get }
}

protocol LearnSetViewModelOutputs: ErrorEmissionCapable {
    var emptyViewVisible: PublishSubject<Bool> { get }
    var tableViewVisible: PublishSubject<Bool> { get }
    var sections: PublishSubject<[TitleValueTableSection]> { get }
}

protocol LearnSetViewModelType {
    var inputs: LearnSetViewModelInputs { get }
    var outputs: LearnSetViewModelOutputs { get }
}

class LearnSetViewModel: LearnSetViewModelType, LearnSetViewModelInputs, LearnSetViewModelOutputs, ErrorBindable {
    private let bag = DisposeBag()
    private let setLocalDataService: SetLocalDataService
    private let resultConverter: ResultConverter
    private let loadSetResult = PublishSubject<OperationResult<SetLocalDataModel?>>()
    private let loadedSet = PublishSubject<SetLocalDataModel?>()
    private let snapshot = PublishSubject<SetLocalDataModel>()
    
    var inputs: LearnSetViewModelInputs { return self }
    var outputs: LearnSetViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let set = PublishSubject<SetLocalDataModel>()
    let didAddVocabulary = PublishSubject<Void>()
    let emptyViewVisible = PublishSubject<Bool>()
    let tableViewVisible = PublishSubject<Bool>()
    let sections = PublishSubject<[TitleValueTableSection]>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    init(setLocalDataService: SetLocalDataService, resultConverter: ResultConverter) {
        self.setLocalDataService = setLocalDataService
        self.resultConverter = resultConverter
        
        self.inputs.viewDidLoad
            .withLatestFrom(self.inputs.set)
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.didAddVocabulary
            .withLatestFrom(self.inputs.set)
            .flatMapLatest { set -> Observable<OperationResult<SetLocalDataModel?>> in
                let operation = self.setLocalDataService.getItemById(with: set.id)
                return self.resultConverter.convert(result: operation)
            }.bind(to: self.loadSetResult)
            .disposed(by: self.bag)
        
        self.loadSetResult
            .filter { $0.resultValue != nil }.map { $0.resultValue! }
            .bind(to: self.loadedSet)
            .disposed(by: self.bag)
        self.loadedSet
            .filter { $0 != nil }.map { $0! }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.loadedSet
            .filter { $0 == nil }
            .map { _ in (errorOccurred: true, title: L10n.Error.error, message: L10n.Error.setNotFound) }
            .bind(to: self.outputs.error)
            .disposed(by: self.bag)
        self.snapshot
            .map { self.createSections(set: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        
        self.outputs.sections
            .map { $0.count == 0 }
            .bind(to: self.outputs.emptyViewVisible)
            .disposed(by: self.bag)
        self.outputs.sections
            .map { $0.count > 0 }
            .bind(to: self.outputs.tableViewVisible)
            .disposed(by: self.bag)
        
        self.bindError(of: self.loadSetResult, disposedWith: self.bag)
    }
    
    private func createSections(set: SetLocalDataModel) -> [TitleValueTableSection] {
        let vocabularyItems = set.vocabularyPairs.map { pair -> TitleValueTableItem in
            return TitleValueTableItem(title: pair.wordOrPhrase, action: GenericTableItemAction.none, value: pair.definition, hint: "", type: GenericItemType.standard)
        }
        guard vocabularyItems.count > 0 else {
            return [TitleValueTableSection]()
        }
        let vocabularySection = TitleValueTableSection(items: vocabularyItems, title: nil, footer: nil)
        return [vocabularySection]
    }
}
