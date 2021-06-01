//
//  HighScoreService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 01.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation

protocol HighScoreService {
    
    // Saves the new score if it is a high score. Returns true if it is a high score.
    func saveHighScore(score: Int) -> Bool
    
    // Gets the currently saved high score
    func getHighScore() -> Int
}

class UserDefaultsHighScoreService: HighScoreService {
    private let key = "High_Score"
    
    func saveHighScore(score: Int) -> Bool {
        let currentScore = UserDefaults.standard.integer(forKey: self.key)
        if score > currentScore {
            UserDefaults.standard.setValue(score, forKey: self.key)
            return true
        }
        return false
    }
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: self.key)
    }
}
