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
    
    private let ThrowingThreshold: CGFloat = 100
    private let ThrowingVelocityPadding: CGFloat = 300
    private let maximumThrowingMagnitude: CGFloat = 450
    
    private var gameRunning = false
    private var timeBetweenSpawns = 1000
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var gravityBehavior: UIGravityBehavior!
    private var screenBoundsCollisionBehavior: UICollisionBehavior!
    private var attachmentBehavior: UIAttachmentBehavior? = nil
    
    private var viewBeingDragged: UIView? = nil
    private var labels = [UILabel]()
    
    var gameController: WordMatchGameController!
    
    @IBOutlet var bucket1: BucketView!
    @IBOutlet var bucket2: BucketView!
    @IBOutlet var bucket3: BucketView!
    @IBOutlet var bucket4: BucketView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Give buckets their IDs
        bucket1.bucketId = BucketId.bucket1
        bucket2.bucketId = BucketId.bucket2
        bucket3.bucketId = BucketId.bucket3
        bucket4.bucketId = BucketId.bucket4
        bucket1.delegate = self
        bucket2.delegate = self
        bucket3.delegate = self
        bucket4.delegate = self
        
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
        
        self.gameController.vocabularyPairs = self.set!.vocabularyPairs
        self.gameController.delegate = self
        self.gameController.startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if(hitView is UILabel) {
                print("Touched a label!")
                self.viewBeingDragged = hitView
            }
        }
    }
    
    @IBAction
    func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            // TODO: Could move calculation of location to where I detect the touched view. But for now this is good enough. It might make the detection of where the anchor point on the touched word is a bit more accurate though.
            let location = sender.location(in: sender.view)
            if let touchedView = self.viewBeingDragged {
                // Prepare UI Kit dynamics
                let pointInViewThatWasTouched = sender.location(in: touchedView)
                let centerOffset = UIOffset(horizontal: pointInViewThatWasTouched.x - touchedView.bounds.midX, vertical: pointInViewThatWasTouched.y - touchedView.bounds.midY)
                attachmentBehavior = UIAttachmentBehavior(item: touchedView, offsetFromCenter: centerOffset, attachedToAnchor: location)
                dynamicAnimator.addBehavior(attachmentBehavior!)
            }
            
            break
        case .ended:
            if let viewToToss = self.viewBeingDragged {
                tossView(viewToToss: viewToToss, sender: sender)
            }
            
            self.viewBeingDragged = nil
            break
        default:
            if let availableAttachmentBehavior = self.attachmentBehavior {
                availableAttachmentBehavior.anchorPoint = sender.location(in: self.view)
            }
            break
        }
    }
    
    fileprivate func checkForItemCollisionsWithBucket(itemBehavior: UIDynamicItemBehavior) {
        itemBehavior.items.forEach { it in
            let item = it as! UILabel
            if(item.frame.intersects(self.bucket1.frame)) {
                print("Item \(item.text) INTERSECTS with bucket 1 \(DispatchTime.now())")
                if let matchedPair = self.bucket1.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                }
            } else if(item.frame.intersects(self.bucket2.frame)) {
                print("Item \(item.text) INTERSECTS with bucket 2 \(DispatchTime.now())")
                if let matchedPair = self.bucket2.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                }
            } else if(item.frame.intersects(self.bucket3.frame)) {
                print("Item \(item.text) INTERSECTS with bucket 3 \(DispatchTime.now())")
                if let matchedPair = self.bucket3.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                }
            } else if(item.frame.intersects(self.bucket4.frame)) {
                print("Item \(item.text) INTERSECTS with bucket 4 \(DispatchTime.now())")
                if let matchedPair = self.bucket4.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                }
            }
        }
    }
    
    private func tossView(viewToToss: UIView, sender: UIPanGestureRecognizer) {
        // Reset UI Kit dynamics
        dynamicAnimator.removeAllBehaviors()
        dynamicAnimator.addBehavior(gravityBehavior)
        dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
        
        // Add a push behavior to toss the view
        let velocity = sender.velocity(in: view)
        let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
        if magnitude > ThrowingThreshold {
            let clampedMagnitude = magnitude / ThrowingVelocityPadding > maximumThrowingMagnitude ? maximumThrowingMagnitude : magnitude / ThrowingVelocityPadding
            let pushBehavior = UIPushBehavior(items: [viewToToss], mode: .instantaneous)
            pushBehavior.pushDirection = CGVector(dx: velocity.x / 10, dy: velocity.y / 10)
            pushBehavior.magnitude = clampedMagnitude
            dynamicAnimator.addBehavior(pushBehavior)

            // Give it a little spin
            let angle = Int(arc4random_uniform(20)) - 10
            let itemBehavior = UIDynamicItemBehavior(items: [viewToToss])
            itemBehavior.friction = 0.2
            itemBehavior.allowsRotation = true
            itemBehavior.addAngularVelocity(CGFloat(angle), for: viewToToss)
            itemBehavior.action = {
                self.checkForItemCollisionsWithBucket(itemBehavior: itemBehavior)
            }
            dynamicAnimator.addBehavior(itemBehavior)
            
            // remove the push and rotation behaviors after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.dynamicAnimator.removeBehavior(pushBehavior)
                self.dynamicAnimator.removeBehavior(itemBehavior)
            })
        } else {
            // Attach more or less an empty behavior to it but use that behavior to track whether
            // the item has collided with a bucket
            let itemBehavior = UIDynamicItemBehavior(items: [viewToToss])
            itemBehavior.action = {
                self.checkForItemCollisionsWithBucket(itemBehavior: itemBehavior)
            }
            dynamicAnimator.addBehavior(itemBehavior)
            
            // remove the empty behavior after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.dynamicAnimator.removeBehavior(itemBehavior)
            })
        }
    }
    
    private func runGame() {
        
    }
    
    private func spawnLabel() {
        let newLabel = UILabel()
        newLabel.text = self.pickRandomWord()
        newLabel.sizeToFit()
        newLabel.isUserInteractionEnabled = true    // Needed, otherwise we can't "grab" the view by touching it
        self.view.addSubview(newLabel)
        self.labels.append(newLabel)
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

extension PlayViewController: WordMatchGameControllerDelegate {
    func spawnPair(pair: VocabularyPairLocalDataModel, color: UIColor, useDefinition: Bool) {
        let newLabel = UILabel()
        if(useDefinition) {
            newLabel.text = pair.definition
        } else {
            newLabel.text = pair.wordOrPhrase
        }
        newLabel.textColor = color
        newLabel.sizeToFit()
        newLabel.isUserInteractionEnabled = true    // Needed, otherwise we can't "grab" the view by touching it
        self.view.addSubview(newLabel)
        self.labels.append(newLabel)
        self.gravityBehavior.addItem(newLabel)
        self.screenBoundsCollisionBehavior.addItem(newLabel)
    }
    
    func removePair(pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        guard let indexOfItemToRemove = self.labels.firstIndex(where: { item in
            if(useDefinition) {
                return item.text == pair.definition
            } else {
                return item.text == pair.wordOrPhrase
            }
        }) else {
            return
        }
        let labelToRemove = self.labels[indexOfItemToRemove]
        self.gravityBehavior.removeItem(labelToRemove)
        self.screenBoundsCollisionBehavior.removeItem(labelToRemove)
        labelToRemove.removeFromSuperview()
        self.labels.remove(at: indexOfItemToRemove)
    }
    
    func updatePair(pair: VocabularyPairLocalDataModel, with color: UIColor, useDefinition: Bool) {
        guard let itemToUpdate = self.labels.first(where: { item in
            if(useDefinition) {
                return item.text == pair.definition
            } else {
                return item.text == pair.wordOrPhrase
            }
        }) else {
            return
        }
        itemToUpdate.textColor = color
    }
    
    func updateBucket(bucketId: BucketId, with pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        switch bucketId {
        case .bucket1:
            bucket1.updateWith(pair: pair, useDefinition: useDefinition)
            break
        case .bucket2:
            bucket2.updateWith(pair: pair, useDefinition: useDefinition)
            break
        case .bucket3:
            bucket3.updateWith(pair: pair, useDefinition: useDefinition)
            break
        case .bucket4:
            bucket4.updateWith(pair: pair, useDefinition: useDefinition)
            break
        }
    }
    
    
}

extension PlayViewController: BucketViewDelegate {
    func requestPairForBucket(bucketId: BucketId) {
        self.gameController.requestPairForBucket(bucketId: bucketId)
    }
}

enum BucketId: String {
    case bucket1 = "Bucket 1"
    case bucket2 = "Bucket 2"
    case bucket3 = "Bucket 3"
    case bucket4 = "Bucket 4"
}
