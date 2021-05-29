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
    container.register(FileContentProvider.self) { _ in
        return String()
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
    container.register(ImportVocabularyService.self) { r in
        CsvImportVocabularyService(
            fileContentProvider: r.resolve(FileContentProvider.self)!
        )
    }
    container.register(RandomNumberService.self) { _ in
        VocabularyAppRandomNumberService()
    }
    container.register(GameItemList.self) { _ in
        WordMatchGameItemList()
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
    container.register(AddVocabularyViewModelType.self) { r in
        AddVocabularyViewModel(
            importVocabularyService: r.resolve(ImportVocabularyService.self)!,
            setLocalDataService: r.resolve(SetLocalDataService.self)!,
            resultConverter: r.resolve(ResultConverter.self)!
        )
    }
    container.register(LearnSetViewModelType.self) { r in
        LearnSetViewModel(
            setLocalDataService: r.resolve(SetLocalDataService.self)!,
            resultConverter: r.resolve(ResultConverter.self)!
        )
    }
    container.register(TrainSetViewModelType.self) { _ in
        TrainSetViewModel()
    }
    container.register(PracticeSetViewModelType.self) { r in
        PracticeSetViewModel(
            randomNumberService: r.resolve(RandomNumberService.self)!
        )
    }
    container.register(WordMatchGameController.self) { r in
        WordMatchGameController(pile: r.resolve(GameItemList.self)!,
                                bucket: [VocabularyPairLocalDataModel](),
                                blackItems: [VocabularyPairLocalDataModel](),
                                greenItems: [VocabularyPairLocalDataModel]()
        )
    }
    
    return container
}()
