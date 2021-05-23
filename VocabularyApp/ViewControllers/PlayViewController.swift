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
    private var attachmentBehavior: UIAttachmentBehavior? = nil
    
    private var viewBeingDragged: UIView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        gravityBehavior = UIGravityBehavior(items: [])
        screenBoundsCollisionBehavior = UICollisionBehavior(items: [])
        screenBoundsCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(gravityBehavior)
        dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
        
       // self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        gameRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.runGame()
        }
    }
    
    @IBAction
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            // Find view that I touched
            let view = sender.view
            let location = sender.location(in: sender.view)
            let childView = view?.hitTest(location, with: nil)
            if childView is UILabel {
                print("Touching label, I guess")
                self.viewBeingDragged = childView
            }
            
            if let touchedView = self.viewBeingDragged {
                // Prepare UI Kit dynamics
                let pointInViewThatWasTouched = sender.location(in: touchedView)
                let centerOffset = UIOffset(horizontal: pointInViewThatWasTouched.x - touchedView.bounds.midX, vertical: pointInViewThatWasTouched.y - touchedView.bounds.midY)
                attachmentBehavior = UIAttachmentBehavior(item: touchedView, offsetFromCenter: centerOffset, attachedToAnchor: location)
                dynamicAnimator.addBehavior(attachmentBehavior!)
            }
            
            break
        case .ended:
            // Reset UI Kit dynamics
            dynamicAnimator.removeAllBehaviors()
            dynamicAnimator.addBehavior(gravityBehavior)
            dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
            
            self.viewBeingDragged = nil
            break
        default:
            if let availableAttachmentBehavior = self.attachmentBehavior {
                availableAttachmentBehavior.anchorPoint = sender.location(in: self.view)
            }
            break
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
        newLabel.isUserInteractionEnabled = true    // Needed, otherwise we can't "grab" the view by touching it
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
