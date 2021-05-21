//
//  PlayViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 18.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import UIKit


class PlayViewController: UIViewController, SetManageable {

    var set: SetLocalDataModel?
    
    private var gameRunning = false
    private var timeBetweenSpawns = 1000
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var gravityBehavior: UIGravityBehavior!
    private var screenBoundsCollisionBehavior: UICollisionBehavior!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        gravityBehavior = UIGravityBehavior(items: [])
        screenBoundsCollisionBehavior = UICollisionBehavior(items: [])
        screenBoundsCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(gravityBehavior)
        dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
        
        gameRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.runGame()
        }
    }
    
    private func runGame() {
        while(gameRunning) {
            DispatchQueue.main.async {
                self.spawnLabel()
            }
            
            Thread.sleep(forTimeInterval: 3)
        }
    }
    
    private func spawnLabel() {
        let newLabel = UILabel()
        newLabel.text = self.pickRandomWord()
        newLabel.sizeToFit()
        self.view.addSubview(newLabel)
        self.gravityBehavior.addItem(newLabel)
        self.screenBoundsCollisionBehavior.addItem(newLabel)
    }
    
    private func pickRandomWord() -> String {
        guard let availableSet = self.set else {
            return "No words available"
        }
        let randomIndex = Int.random(in: 0..<availableSet.vocabularyPairs.count)
        let randomWord = availableSet.vocabularyPairs[randomIndex].wordOrPhrase
        return randomWord
    }
}
