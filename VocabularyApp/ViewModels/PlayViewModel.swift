//
//  PlayViewModel.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 25.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol PlayViewModelInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var pairs: PublishSubject<[VocabularyPairLocalDataModel]> { get }
    var spawnPair: PublishSubject<VocabularyPairLocalDataModel> { get }
    var pairMatched: PublishSubject<VocabularyPairLocalDataModel> { get }
}

protocol PlayViewModelOutputs {
    var itemsRemaining: PublishSubject<String> { get }
    var percentMatched: PublishSubject<String> { get }
}

protocol PlayViewModelType {
    var inputs: PlayViewModelInputs { get }
    var outputs: PlayViewModelOutputs { get }
}

class PlayViewModel: PlayViewModelType, PlayViewModelInputs, PlayViewModelOutputs {
    private let bag = DisposeBag()
    private let snapshot = PublishSubject<PlaySnapshot>()
    
    var inputs: PlayViewModelInputs { return self }
    var outputs: PlayViewModelOutputs { return self }
    
    let viewDidLoad = PublishSubject<Void>()
    let pairs = PublishSubject<[VocabularyPairLocalDataModel]>()
    let spawnPair = PublishSubject<VocabularyPairLocalDataModel>()
    let pairMatched = PublishSubject<VocabularyPairLocalDataModel>()
    let itemsRemaining = PublishSubject<String>()
    let percentMatched = PublishSubject<String>()
    
    init() {
        self.inputs.viewDidLoad
            .withLatestFrom(self.inputs.pairs)
            .map { self.createSnapshot(pairs: $0) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        self.inputs.spawnPair
            .withLatestFrom(self.snapshot)
            .map { $0 |> PlaySnapshot.itemsRemainingLens *~ ($0.itemsRemaining - 1) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        
        self.snapshot
            .map { "Items remaining: \($0.itemsRemaining)" }
            .bind(to: self.outputs.itemsRemaining)
            .disposed(by: self.bag)
    }
    
    private func createSnapshot(pairs: [VocabularyPairLocalDataModel]) -> PlaySnapshot {
        return PlaySnapshot(itemsRemaining: pairs.count, percentMatched: 0.0)
    }
    
    struct PlaySnapshot {
        let itemsRemaining: Int
        let percentMatched: Float
        
        static let itemsRemainingLens = Lens<PlaySnapshot, Int>(
            get: { $0.itemsRemaining },
            set: { itemsRemaining, snapshot in PlaySnapshot(itemsRemaining: itemsRemaining, percentMatched: snapshot.percentMatched)
            }
        )
    }
}
