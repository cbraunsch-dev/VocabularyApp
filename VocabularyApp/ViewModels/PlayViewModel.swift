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
        self.inputs.pairMatched
            .withLatestFrom(self.snapshot)
            .map { $0 |> PlaySnapshot.numberMatchedLens *~ ($0.numberMatched + 1) }
            .bind(to: self.snapshot)
            .disposed(by: self.bag)
        
        self.snapshot
            .map { "Items remaining: \($0.itemsRemaining)" }
            .bind(to: self.outputs.itemsRemaining)
            .disposed(by: self.bag)
        self.snapshot
            .map { self.calculatePercentage(itemsMatched: $0.numberMatched, totalNrOfItems: $0.totalNrOfItems) }
            .map { "Matched: \($0)%" }
            .bind(to: self.outputs.percentMatched)
            .disposed(by: self.bag)
    }
    
    private func calculatePercentage(itemsMatched: Int, totalNrOfItems: Int) -> Int {
        let matchedFloat = Float(itemsMatched)
        let totalFloat = Float(totalNrOfItems)
        let percentage = matchedFloat / totalFloat
        return Int(100 * percentage)
    }
    
    private func createSnapshot(pairs: [VocabularyPairLocalDataModel]) -> PlaySnapshot {
        return PlaySnapshot(totalNrOfItems: pairs.count, itemsRemaining: pairs.count, numberMatched: 0)
    }
    
    struct PlaySnapshot {
        let totalNrOfItems: Int
        let itemsRemaining: Int
        let numberMatched: Int
        
        static let itemsRemainingLens = Lens<PlaySnapshot, Int>(
            get: { $0.itemsRemaining },
            set: { itemsRemaining, snapshot in PlaySnapshot(totalNrOfItems: snapshot.totalNrOfItems, itemsRemaining: itemsRemaining, numberMatched: snapshot.numberMatched)
            }
        )
        
        static let numberMatchedLens = Lens<PlaySnapshot, Int>(
            get: { $0.numberMatched },
            set: { percentMatched, snapshot in PlaySnapshot(totalNrOfItems: snapshot.totalNrOfItems, itemsRemaining: snapshot.itemsRemaining, numberMatched: percentMatched)
            }
        )
    }
}
