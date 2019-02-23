//
//  IoCContainer.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 23.02.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import Swinject

let appContainer: Container = {
    let container = Container()
    
    container.register(AddSetViewModelType.self) { r in
        AddSetViewModel(
        )
    }
    
    return container
}()
