//
//  SetNavigationController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit

class SetManageableNavigationController: UINavigationController, SetManageable, WorkflowCapable, WorkflowInterested {
    var workflowDelegate: WorkflowInterested? {
        didSet {
            guard let topVC = self.topViewController else {
                return
            }
            guard var workflowCapable = topVC as? WorkflowCapable else {
                return
            }
            workflowCapable.workflowDelegate = self.workflowDelegate
        }
    }
    
    var set: SetLocalDataModel? {
        didSet {
            if let topVC = self.topViewController {
                var vcThatManagesSets = topVC as! SetManageable
                vcThatManagesSets.set = self.set
            }
        }
    }
    
    func didFinishWorkflow(actionToPerform: WorkflowCompletionAction) {
        self.workflowDelegate?.didFinishWorkflow(actionToPerform: actionToPerform)
    }
}
