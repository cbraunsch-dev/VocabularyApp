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
    func saveHighScore(set: SetLocalDataModel, score: Int) -> Bool
    
    // Gets the currently saved high score
    func getHighScore(set: SetLocalDataModel) -> Int
}

class UserDefaultsHighScoreService: HighScoreService {
    private let key = "High_Score"
    
    func saveHighScore(set: SetLocalDataModel, score: Int) -> Bool {
        let scoreKey = "\(set.name)-\(self.key)"
        let currentScore = UserDefaults.standard.integer(forKey: scoreKey)
        if score < currentScore || currentScore == 0 {
            UserDefaults.standard.setValue(score, forKey: scoreKey)
            return true
        }
        return false
    }
    
    func getHighScore(set: SetLocalDataModel) -> Int {
        let scoreKey = "\(set.name)-\(self.key)"
        return UserDefaults.standard.integer(forKey: scoreKey)
    }
}
