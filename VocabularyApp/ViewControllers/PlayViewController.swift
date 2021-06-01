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
    private let maximumThrowingMagnitude: CGFloat = 100
    
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
        
        self.gameController.vocabularyPairs = self.set!.vocabularyPairs
        self.gameController.delegate = self
        self.gameController.startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if(hitView is UILabel) {
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
                
                // Remove collision behavior from item being dragged
                screenBoundsCollisionBehavior.removeItem(touchedView)
                // Clear out any temporary falling and tossing behaviors
                dynamicAnimator.removeAllBehaviors()
                dynamicAnimator.addBehavior(gravityBehavior)
                dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
                dynamicAnimator.addBehavior(attachmentBehavior!)
                print("Picked up view \(touchedView)")
            }
            
            break
        case .ended:
            if let viewToToss = self.viewBeingDragged {
                print("Toss view \(viewToToss)")
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
                if let matchedPair = self.bucket1.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                    self.gameController.reassignAllBuckets()
                }
            } else if(item.frame.intersects(self.bucket2.frame)) {
                if let matchedPair = self.bucket2.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                    self.gameController.reassignAllBuckets()
                }
            } else if(item.frame.intersects(self.bucket3.frame)) {
                if let matchedPair = self.bucket3.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                    self.gameController.reassignAllBuckets()
                }
            } else if(item.frame.intersects(self.bucket4.frame)) {
                if let matchedPair = self.bucket4.wordWasDroppedIntoBucket(word: item.text!) {
                    self.gameController.pairMatched(pair: matchedPair)
                    self.gameController.reassignAllBuckets()
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
            dynamicAnimator.addBehavior(itemBehavior)
            
            // Add collision behavior
            self.screenBoundsCollisionBehavior.addItem(viewToToss)
            
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
            
            // Add collision behavior
            self.screenBoundsCollisionBehavior.addItem(viewToToss)
            
            // remove the empty behavior after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.dynamicAnimator.removeBehavior(itemBehavior)
            })
        }
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
        let spawnPosX = self.view.frame.size.width / 2 - newLabel.frame.width / 2
        newLabel.frame.origin = CGPoint(x: spawnPosX, y: 0.0)
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
        print("Removed label \(labelToRemove)")
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
