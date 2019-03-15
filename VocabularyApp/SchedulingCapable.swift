//
//  SchedulingCapable.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 15.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import RxSwift

protocol SchedulingCapable {
    var worker: SchedulerType { get set }
    var main: SchedulerType { get set }
}
