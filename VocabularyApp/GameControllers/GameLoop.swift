//
//  GameLoop.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 30.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation

protocol GameLoop{
    var delegate: GameLoopDelegate? { get set }
    
    func start()
}

protocol GameLoopDelegate {
    func update()
}

class WordMatchGameLoop: GameLoop {
    private var gameRunning = false
    
    var delegate: GameLoopDelegate? = nil
    
    func start() {
        gameRunning = true
        DispatchQueue.global(qos: .userInitiated).async {
            while(self.gameRunning) {
                Thread.sleep(forTimeInterval: 3)
                DispatchQueue.main.async {
                    self.delegate?.update()
                }
            }
        }
    }
}
