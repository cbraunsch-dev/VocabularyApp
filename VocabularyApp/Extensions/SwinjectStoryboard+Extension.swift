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
    }
}
