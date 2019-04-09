//
//  PracticeSetViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 09.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PracticeSetViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var set: PublishSubject<SetLocalDataModel> { get }
    var showValue: PublishSubject<Void> { get }
    var showNextPair: PublishSubject<Void> { get }
}

protocol PracticeSetViewModelOutputs {
    var text: PublishSubject<String> { get }
}

protocol PracticeSetViewModelType {
    var inputs: PracticeSetViewModelInputs { get }
    var outputs: PracticeSetViewModelOutputs { get }
}

class PracticeSetViewModel: PracticeSetViewModelType, PracticeSetViewModelInputs, PracticeSetViewModelOutputs {
    private let bag = DisposeBag()
    private let snapshot = PublishSubject<PracticeSetSnapshot>()
    
    var inputs: PracticeSetViewModelInputs { return self }
    var outputs: PracticeSetViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let set = PublishSubject<SetLocalDataModel>()
    let showValue = PublishSubject<Void>()
    let showNextPair = PublishSubject<Void>()
    let text = PublishSubject<String>()
    
    init() {
        self.inputs.viewDidLoad
            .map { self.createInitialSnapshot() }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        
        self.snapshot
            .map { $0.showingDefinition ? $0.currentVocabPair.definition : $0.currentVocabPair.wordOrPhrase }
            .bind(to: self.outputs.text)
            .disposed(by: self.bag)
    }
    
    private func createInitialSnapshot() -> PracticeSetSnapshot {
        let vocabPair = VocabularyPairLocalDataModel(wordOrPhrase: L10n.ViewController.PracticeSet.hint1, definition: L10n.ViewController.PracticeSet.hint2)
        return PracticeSetSnapshot(currentVocabPair: vocabPair, showingDefinition: false)
    }
}

struct PracticeSetSnapshot {
    let currentVocabPair: VocabularyPairLocalDataModel
    let showingDefinition: Bool
    
    static let currentVocabPairLens = Lens<PracticeSetSnapshot, VocabularyPairLocalDataModel>(
        get: { $0.currentVocabPair },
        set: { currentVocabPair, snapshot in PracticeSetSnapshot(currentVocabPair: currentVocabPair, showingDefinition: snapshot.showingDefinition) }
    )
    
    static let showingDefinitionLens = Lens<PracticeSetSnapshot, Bool>(
        get: { $0.showingDefinition },
        set: { showingDefinition, snapshot in PracticeSetSnapshot(currentVocabPair: snapshot.currentVocabPair, showingDefinition: showingDefinition) }
    )
}
