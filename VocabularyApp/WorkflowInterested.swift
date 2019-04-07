//
//  WorkflowInterested.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol WorkflowInterested {
    func didFinishWorkflow(actionToPerform: WorkflowCompletionAction)
}

protocol WorkflowCompletionAction {}

enum GenericWorkflowCompletionAction: WorkflowCompletionAction {
    case nothing
}
