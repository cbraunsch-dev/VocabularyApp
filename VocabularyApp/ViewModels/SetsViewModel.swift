//
//  SetsViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SetsViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var didAddSet: PublishSubject<Void> { get }
    var selectItem: PublishSubject<IndexPath> { get }
}

protocol SetsViewModelOutputs: ErrorEmissionCapable {
    var emptyViewVisible: PublishSubject<Bool> { get }
    var tableViewVisible: PublishSubject<Bool> { get }
    var sections: PublishSubject<[GenericTableSection]> { get }
    var openSet: PublishSubject<SetLocalDataModel> { get }
}

protocol SetsViewModelType {
    var inputs: SetsViewModelInputs { get }
    var outputs: SetsViewModelOutputs { get }
}

class SetsViewModel: SetsViewModelType, SetsViewModelInputs, SetsViewModelOutputs, ErrorBindable {
    private let bag = DisposeBag()
    private let setLocalDataService: SetLocalDataService
    private let resultConverter: ResultConverter
    private let setsResult = PublishSubject<OperationResult<[SetLocalDataModel]>>()
    private let sets = PublishSubject<[SetLocalDataModel]>()
    private let loadSets = PublishSubject<Void>()
    
    let viewDidLoad = PublishSubject<Void>()
    let didAddSet = PublishSubject<Void>()
    let selectItem = PublishSubject<IndexPath>()
    let emptyViewVisible = PublishSubject<Bool>()
    let tableViewVisible = PublishSubject<Bool>()
    let sections = PublishSubject<[GenericTableSection]>()
    let openSet = PublishSubject<SetLocalDataModel>()
    let error = PublishSubject<(errorOccurred: Bool, title: String, message: String)>()
    
    var inputs: SetsViewModelInputs { return self }
    var outputs: SetsViewModelOutputs { return self }
    
    init(setLocalDataService: SetLocalDataService, resultConverter: ResultConverter) {
        self.setLocalDataService = setLocalDataService
        self.resultConverter = resultConverter
        
        self.inputs.viewDidLoad
            .bind(to: self.loadSets)
            .disposed(by: self.bag)
        self.inputs.didAddSet
            .bind(to: self.loadSets)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.outputs.sections) { (selection: $0, sections: $1) }
            .map { (input: (selection: IndexPath, sections: [GenericTableSection])) -> GenericTableItem in
                let section = input.sections[input.selection.section]
                let item = section.items[input.selection.row]
                return item
            }
            .map { item -> SetLocalDataModel? in
                switch item.action {
                case SetsTableItemAction.selectSet(let set):
                    return set
                default:
                    return nil
                }
            }.filter { $0 != nil }
            .map { $0! }
            .bind(to: self.outputs.openSet)
            .disposed(by: self.bag)
        
        self.loadSets
            .flatMapLatest { _ -> Observable<OperationResult<[SetLocalDataModel]>> in
                let operation = self.setLocalDataService.readAll()
                return self.resultConverter.convert(result: operation)
            }.bind(to: self.setsResult)
            .disposed(by: self.bag)
        self.setsResult
            .filter { $0.resultValue != nil }
            .map { $0.resultValue! }
            .bind(to: self.sets)
            .disposed(by: self.bag)
        self.sets
            .map { self.createSections(sets: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.sets
            .map { $0.count == 0 }
            .bind(to: self.outputs.emptyViewVisible)
            .disposed(by: self.bag)
        self.sets
            .map { $0.count > 0 }
            .bind(to: self.outputs.tableViewVisible)
            .disposed(by: self.bag)
        
        self.bindError(of: self.setsResult, disposedWith: self.bag)
    }
    
    private func createSections(sets: [SetLocalDataModel]) -> [GenericTableSection] {
        let items = sets.map { set -> GenericTableItem in
            let item = GenericTableItem(title: set.name, action: SetsTableItemAction.selectSet(set: set))
            return item
        }
        let section = GenericTableSection(items: items, title: nil, footer: nil)
        return [section]
    }
    
    enum SetsTableItemAction: TableItemAction {
        case selectSet(set: SetLocalDataModel)
    }
}
