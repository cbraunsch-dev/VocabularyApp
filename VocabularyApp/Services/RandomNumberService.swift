//
//  RandomNumberService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 10.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation

protocol RandomNumberService {
    func generateRandomNumber(topLimit: Int) -> Int
}

class VocabularyAppRandomNumberService: RandomNumberService {
    func generateRandomNumber(topLimit: Int) -> Int {
        return Int.random(in: 0..<topLimit)
    }
}
