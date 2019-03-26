//
//  RealmSetLocalDataService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 05.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class RealmSetLocalDataService: RealmLocalDataService, SetLocalDataService {
    private let bag = DisposeBag()
    
    //TODO: Read out vocab pairs
    func readAll() -> Observable<[SetLocalDataModel]> {
        return Observable<[SetLocalDataModel]>.create { observer in
            do {
                let realm = try self.obtainRealm()
                let data = realm.objects(SetEntity.self)
                let sets = Array(data)
                let emittableData = sets.map { entity -> SetLocalDataModel in
                    let vocabPairCollection = entity.vocabularyPairs.map { VocabularyPairLocalDataModel(id: $0.pairID, wordOrPhrase: $0.wordOrPhrase, definition: $0.definition) }
                    let pairs = [VocabularyPairLocalDataModel](vocabPairCollection)
                    return SetLocalDataModel(id: entity.setID, name: entity.name, vocabularyPairs: pairs)
                }
                observer.onNext(emittableData)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    func getItemById(with id: String) -> Observable<SetLocalDataModel?> {
        return Observable<SetLocalDataModel?>.create { observer in
            do {
                let sets = try self.findSets(with: id)
                guard let set = sets.first else {
                    observer.onNext(nil)
                    return Disposables.create()
                }
                let vocabPairCollection = set.vocabularyPairs.map { VocabularyPairLocalDataModel(id: $0.pairID, wordOrPhrase: $0.wordOrPhrase, definition: $0.definition) }
                let pairs = [VocabularyPairLocalDataModel](vocabPairCollection)
                let emittableData = SetLocalDataModel(id: set.setID, name: set.name, vocabularyPairs: pairs)
                observer.onNext(emittableData)
            } catch {
                observer.onError(error)
            }
            return Disposables.create()
        }
    }
    
    private func findSets(with id: String) throws -> Results<SetEntity> {
        let realm = try self.obtainRealm()
        let predicate = NSPredicate(format: "setID = %@", id)
        let sets = realm.objects(SetEntity.self).filter(predicate)
        return sets
    }
    
    func save(item: SetLocalDataModel) -> Observable<Void> {
        return Observable<Void>.create { observer in
            do {
                let realm = try self.obtainRealm()
                let set = SetEntity()
                set.setID = item.id
                set.name = item.name
                item.vocabularyPairs.forEach { pair in
                    let pairEntity = VocabularyPairEntity()
                    pairEntity.pairID = pair.id
                    pairEntity.definition = pair.definition
                    pairEntity.wordOrPhrase = pair.wordOrPhrase
                    set.vocabularyPairs.append(pairEntity)
                }
                try realm.write(transaction: {
                    realm.add(set, update: true)
                }, completion:  {
                    observer.onNext(())
                })
            } catch DataAccessorError.failedToAccessDatabase {
                observer.onError(DataAccessorError.failedToAccessDatabase)
            } catch {
                //The only recoverable errors in Realm are when we've run out of disk space
                observer.onError(DataAccessorError.outOfDiskSpace)
            }
            return Disposables.create()
        }
    }
    
    func removeItem(with id: String) -> Observable<Void> {
        return Observable<Void>.create { observer in
            do {
                let realm = try self.obtainRealm()
                guard let foundItem = try self.findSets(with: id).first else {
                    observer.onError(DataAccessorError.itemToDeleteNotFound)
                    return Disposables.create()
                }
                try realm.write(transaction: {
                    realm.delete(foundItem)
                }, completion: {
                    observer.onNext(())
                })
            } catch DataAccessorError.failedToAccessDatabase {
                observer.onError(DataAccessorError.failedToAccessDatabase)
            } catch {
                observer.onError(DataAccessorError.outOfDiskSpace)
            }
            return Disposables.create()
        }
    }
}
