//
//  TrainSetViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 08.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TrainSetViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var selectItem: PublishSubject<IndexPath> { get }
}

protocol TrainSetViewModelOutputs {
    var sections: PublishSubject<[GenericTableSection]> { get }
    var practice: PublishSubject<Void> { get }
    var play: PublishSubject<Void> { get }
}

protocol TrainSetViewModelType {
    var inputs: TrainSetViewModelInputs { get }
    var outputs: TrainSetViewModelOutputs { get }
}

class TrainSetViewModel: TrainSetViewModelType, TrainSetViewModelInputs, TrainSetViewModelOutputs {
    private let bag = DisposeBag()
    private let selectedTableItemAction = PublishSubject<TableItemAction>()
    
    var inputs: TrainSetViewModelInputs { return self }
    var outputs: TrainSetViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let selectItem = PublishSubject<IndexPath>()
    let sections = PublishSubject<[GenericTableSection]>()
    let practice = PublishSubject<Void>()
    let play = PublishSubject<Void>()
    
    init() {
        self.inputs.viewDidLoad
            .map { self.createSections() }
            .bind(to: self.outputs.sections)
            .disposed(by: self.bag)
        self.inputs.selectItem
            .withLatestFrom(self.outputs.sections) { (selection: $0, sections: $1) }
            .map { $0.sections[$0.selection.section].items[$0.selection.row].action }
            .bind(to: self.selectedTableItemAction)
            .disposed(by: self.bag)
        
        self.selectedTableItemAction
            .filter { $0 is TrainSetItemAction }.map { $0 as! TrainSetItemAction }
            .filter { $0 == TrainSetItemAction.practice }
            .map { _ in return }
            .bind(to: self.outputs.practice)
            .disposed(by: self.bag)
        self.selectedTableItemAction
            .filter { $0 is TrainSetItemAction }.map { $0 as! TrainSetItemAction }
            .filter { $0 == TrainSetItemAction.play }
            .map { _ in return }
            .bind(to: self.outputs.play)
            .disposed(by: self.bag)
    }
    
    private func createSections() -> [GenericTableSection] {
        let practiceItem = GenericTableItem(title: L10n.Action.practice, action: TrainSetItemAction.practice)
        let playItem = GenericTableItem(title: L10n.Action.play, action: TrainSetItemAction.play)
        let section = GenericTableSection(items: [practiceItem, playItem], title: nil, footer: nil)
        return [section]
    }
}

enum TrainSetItemAction: TableItemAction {
    case practice
    case play
}
