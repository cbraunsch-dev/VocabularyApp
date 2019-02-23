//
//  AddSetViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol AddSetViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var selectItem: PublishSubject<IndexPath> { get }
    var saveButtonTaps: PublishSubject<Void> { get }
    var setName: PublishSubject<String> { get }
}

protocol AddSetViewModelOutputs {
    var sections: PublishSubject<[TitleValueTableSection]> { get }
    var saveButtonEnabled: PublishSubject<Bool> { get }
    var editName: PublishSubject<String> { get }
}

protocol AddSetViewModelType {
    var inputs: AddSetViewModelInputs { get }
    var outputs: AddSetViewModelOutputs { get }
}

class AddSetViewModel: AddSetViewModelType, AddSetViewModelInputs, AddSetViewModelOutputs {
    private let bag = DisposeBag()
    
    var inputs: AddSetViewModelInputs { return self }
    var outputs: AddSetViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let selectItem = PublishSubject<IndexPath>()
    let saveButtonTaps = PublishSubject<Void>()
    let setName = PublishSubject<String>()
    let sections = PublishSubject<[TitleValueTableSection]>()
    let saveButtonEnabled = PublishSubject<Bool>()
    let editName = PublishSubject<String>()
    
    init() {
        self.inputs.viewDidLoad
            .withLatestFrom(self.inputs.setName)
            .map { self.createSections(setName: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.inputs.viewDidLoad
            .withLatestFrom(self.inputs.setName)
            .map { return $0.count > 0 }
            .bind(to: self.outputs.saveButtonEnabled)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.inputs.setName)
            .map { return $0 }
            .bind(to: self.outputs.editName)
            .disposed(by: self.bag)
        self.inputs.setName
            .map { self.createSections(setName: $0) }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.inputs.setName
            .map { return $0.count > 0 }
            .bind(to: self.outputs.saveButtonEnabled)
            .disposed(by: self.bag)
    }
    
    private func createSections(setName: String) -> [TitleValueTableSection] {
        let item = TitleValueTableItem(title: L10n.Action.AddSet.name, action: GenericTableItemAction.none, value: setName, hint: "", type: GenericItemType.edit)
        let section = TitleValueTableSection(items: [item], title: L10n.ViewController.AddSet.hint, footer: nil)
        return [section]
    }
}
