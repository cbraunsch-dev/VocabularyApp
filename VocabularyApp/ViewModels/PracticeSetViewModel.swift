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
    private let numberOfCards = 10
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
            .withLatestFrom(self.inputs.set)
            .map { self.createInitialSnapshot(set: $0) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.showNextPair
            .withLatestFrom(self.snapshot)
            .map { self.createSnapshotWithNextWordOrPhrase(snapshot: $0) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.showValue
            .withLatestFrom(self.snapshot)
            .map { self.createSnapshotWithDefinition(snapshot: $0) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        
        self.snapshot
            .map { $0.showingDefinition ? $0.currentVocabPair.definition : $0.currentVocabPair.wordOrPhrase }
            .bind(to: self.outputs.text)
            .disposed(by: self.bag)
    }
    
    private func createInitialSnapshot(set: SetLocalDataModel) -> PracticeSetSnapshot {
        let vocabPair = VocabularyPairLocalDataModel(wordOrPhrase: L10n.ViewController.PracticeSet.hint1, definition: L10n.ViewController.PracticeSet.hint2)
        let vocabPairs = self.grabRandomVocabPairs(from: set)
        return PracticeSetSnapshot(index: 0, currentVocabPair: vocabPair, showingDefinition: false, vocabPairs: vocabPairs)
    }
    
    private func grabRandomVocabPairs(from set: SetLocalDataModel) -> [VocabularyPairLocalDataModel] {
        var pairs = [VocabularyPairLocalDataModel]()
        for _ in 0..<self.numberOfCards {
            let randomIndex = Int.random(in: 0..<set.vocabularyPairs.count)
            let pair = set.vocabularyPairs[randomIndex]
            pairs.append(pair)
        }
        return pairs
    }
    
    private func createSnapshotWithNextWordOrPhrase(snapshot: PracticeSetSnapshot) -> PracticeSetSnapshot {
        let updatedIndex = snapshot |> PracticeSetSnapshot.indexLens *~ (snapshot.index + 1)
        let updatedVocabPair = updatedIndex |> PracticeSetSnapshot.currentVocabPairLens *~ (updatedIndex.vocabPairs[updatedIndex.index])
        return updatedVocabPair
    }
    
    private func createSnapshotWithDefinition(snapshot: PracticeSetSnapshot) -> PracticeSetSnapshot {
        return snapshot |> PracticeSetSnapshot.showingDefinitionLens *~ true
    }
}

struct PracticeSetSnapshot {
    let index: Int
    let currentVocabPair: VocabularyPairLocalDataModel
    let showingDefinition: Bool
    let vocabPairs: [VocabularyPairLocalDataModel]
    
    static let indexLens = Lens<PracticeSetSnapshot, Int>(
        get: { $0.index },
        set: { index, snapshot in PracticeSetSnapshot(index: index, currentVocabPair: snapshot.currentVocabPair, showingDefinition: snapshot.showingDefinition, vocabPairs: snapshot.vocabPairs) }
    )
    
    static let currentVocabPairLens = Lens<PracticeSetSnapshot, VocabularyPairLocalDataModel>(
        get: { $0.currentVocabPair },
        set: { currentVocabPair, snapshot in PracticeSetSnapshot(index: snapshot.index, currentVocabPair: currentVocabPair, showingDefinition: snapshot.showingDefinition, vocabPairs: snapshot.vocabPairs) }
    )
    
    static let showingDefinitionLens = Lens<PracticeSetSnapshot, Bool>(
        get: { $0.showingDefinition },
        set: { showingDefinition, snapshot in PracticeSetSnapshot(index: snapshot.index, currentVocabPair: snapshot.currentVocabPair, showingDefinition: showingDefinition, vocabPairs: snapshot.vocabPairs) }
    )
}
