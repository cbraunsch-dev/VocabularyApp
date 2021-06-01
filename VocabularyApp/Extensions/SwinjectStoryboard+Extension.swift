//
//  SwinjectStoryboard+Extension.swift
//  TaskManagerApp
//
//  Created by Chris Braunschweiler on 11.01.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import SwinjectStoryboard
import Swinject

extension SwinjectStoryboard {
    @objc class func setup() {
        defaultContainer.storyboardInitCompleted(SetsViewController.self) { r, c in
            c.viewModel = appContainer.resolve(SetsViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(AddSetViewController.self) { r, c in
            c.viewModel = appContainer.resolve(AddSetViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(AddVocabularyViewController.self) { r, c in
            c.viewModel = appContainer.resolve(AddVocabularyViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(LearnSetViewController.self) { r, c in
            c.viewModel = appContainer.resolve(LearnSetViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(TrainSetViewController.self) { r, c in
            c.viewModel = appContainer.resolve(TrainSetViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(PracticeSetViewController.self) { r, c in
            c.viewModel = appContainer.resolve(PracticeSetViewModelType.self)!
        }
        defaultContainer.storyboardInitCompleted(PlayViewController.self) { r, c in
            c.gameController = appContainer.resolve(GameController.self)!
            c.highScoreService = appContainer.resolve(HighScoreService.self)!
        }
    }
}
