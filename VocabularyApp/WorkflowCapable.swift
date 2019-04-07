//
//  WorkflowCapable.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 07.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol WorkflowCapable {
    var workflowDelegate: WorkflowInterested? { get set }
}
