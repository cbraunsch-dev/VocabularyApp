//
//  LocalDataAccessor.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 04.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol SetDataAccessor {
    func readAll() -> Observable<[SetLocalDataModel]>
    
    func getItemById(with id: String) -> Observable<SetLocalDataModel?>
    
    func save(item: SetLocalDataModel) -> Observable<Void>
    
    func removeItem(with id: String) -> Observable<Void>
}
