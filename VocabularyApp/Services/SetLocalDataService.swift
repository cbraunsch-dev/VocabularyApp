//
//  SetLocalDataService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 05.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol SetLocalDataService {
    func readAll() -> Observable<[SetLocalDataModel]>
    
    func getItemById(with id: String) -> Observable<SetLocalDataModel?>
    
    func save(item: SetLocalDataModel) -> Observable<Void>
    
    func removeItem(with id: String) -> Observable<Void>
}
