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
    
    container.register(RealmConfigurationProvider.self) { _ in
        VocabularyAppRealmConfigurationProvider()
    }
    
    container.register(ResultConverter.self) { r in
        VocabularyAppResultConverter(
            errorMessageService: r.resolve(ErrorMessageService.self)!
        )
    }
    
    container.register(ErrorMessageService.self) { _ in
        LocalizedErrorMessageService()
    }
    container.register(SetLocalDataService.self) { r in
        RealmSetLocalDataService(
            configurationProvider: r.resolve(RealmConfigurationProvider.self)!
        )
    }
    
    container.register(SetsViewModelType.self) { r in
        SetsViewModel(
            setLocalDataService: r.resolve(SetLocalDataService.self)!,
            resultConverter: r.resolve(ResultConverter.self)!
        )
    }
    container.register(AddSetViewModelType.self) { r in
        AddSetViewModel(
            setLocalDataService: r.resolve(SetLocalDataService.self)!,
            resultConverter: r.resolve(ResultConverter.self)!
        )
    }
    
    return container
}()
