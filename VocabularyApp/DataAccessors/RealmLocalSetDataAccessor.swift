//
//  RealmLocalSetDataAccessor.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class RealmLocalSetDataAccessor: LocalDataAccessor, SetDataAccessor {
    private let bag = DisposeBag()
    
    func readAll() -> Observable<[SetLocalDataModel]> {
        return Observable<[SetLocalDataModel]>.create { observer in
            do {
                let realm = try self.obtainRealm()
                let data = realm.objects(SetEntity.self)
                let sets = Array(data)
                let emittableData = sets.map { entity in
                    return SetLocalDataModel(id: entity.setID, name: entity.name)
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
                let emittableData = SetLocalDataModel(id: set.setID, name: set.name)
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
