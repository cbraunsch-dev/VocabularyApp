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
    
    @IBOutlet var bucket1: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        gravityBehavior = UIGravityBehavior(items: [])
        gravityBehavior.action = {
            /*self.labels.forEach({item in
                let leftSideInBucket = self.bucket1.point(inside: CGPoint(x: item.frame.minX, y: item.frame.midY), with: nil)
                let centerInBucket = self.bucket1.point(inside: CGPoint(x: item.frame.midX, y: item.frame.midY), with: nil)
                let rightSideInBucket = self.bucket1.point(inside: CGPoint(x: item.frame.maxX, y: item.frame.maxY), with: nil)
                if(leftSideInBucket) {
                    print("Left side (\(item.frame.minX), \(item.frame.midY)) of item \(item.text) is in bucket \(DispatchTime.now())")
                }
                if(centerInBucket) {
                    print("Center (\(item.frame.midX), \(item.frame.midY)) of item \(item.text) is in bucket")
                }
                if(rightSideInBucket) {
                    print("Right side (\(item.frame.maxX), \(item.frame.maxY)) of item \(item.text) is in bucket")
                }
                if(leftSideInBucket || centerInBucket || rightSideInBucket) {
                    //print("OMG item \(item.text) is in bucket! \(DispatchTime.now())")
                }
            })*/
        }
        screenBoundsCollisionBehavior = UICollisionBehavior(items: [])
        screenBoundsCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        dynamicAnimator.addBehavior(gravityBehavior)
        dynamicAnimator.addBehavior(screenBoundsCollisionBehavior)
        
        gameRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.runGame()
        }
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
                attachmentBehavior?.action = {
                    self.attachmentBehavior?.items.forEach({itly in
                        let item = itly as! UILabel
                        if(item.frame.intersects(self.bucket1.frame)) {
                            print("Item \(item.text) DANGLING INTERSECTS with bucket \(DispatchTime.now())")
                        }
                    })
                }
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
                itemBehavior.items.forEach { itly in
                    let item = itly as! UILabel
                    if(item.frame.intersects(self.bucket1.frame)) {
                        print("Item \(item.text) TOSSING INTERSECTS with bucket \(DispatchTime.now())")
                    }
                }
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
                itemBehavior.items.forEach { itly in
                    let item = itly as! UILabel
                    if(item.frame.intersects(self.bucket1.frame)) {
                        print("Item \(item.text) DROPPING INTERSECTS with bucket \(DispatchTime.now())")
                    }
                }
            }
            dynamicAnimator.addBehavior(itemBehavior)
            
            // remove the empty behavior after some time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.dynamicAnimator.removeBehavior(itemBehavior)
            })
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
