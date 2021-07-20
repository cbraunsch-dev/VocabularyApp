//
//  PlayViewController.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 18.05.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PlayViewController: UIViewController, SetManageable {
    var viewModel: PlayViewModelType!
    var set: SetLocalDataModel?
    
    private let disposeBag = DisposeBag()
    
    private let ThrowingThreshold: CGFloat = 100
    private let ThrowingVelocityPadding: CGFloat = 300
    private let maximumThrowingMagnitude: CGFloat = 100
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var gravityBehavior: UIGravityBehavior!
    private var screenBoundsCollisionBehavior: UICollisionBehavior!
    private var attachmentBehavior: UIAttachmentBehavior? = nil
    
    private var viewBeingDragged: UIView? = nil
    private var labels = [FlashCardView]()
    
    var gameController: GameController!
    var highScoreService: HighScoreService!
    
    @IBOutlet var bucket1: BucketView!
    @IBOutlet var bucket2: BucketView!
    @IBOutlet var bucket3: BucketView!
    @IBOutlet var bucket4: BucketView!
    @IBOutlet var highScoreLabel: UILabel!
    @IBOutlet var bottomBrick: UIView!
    @IBOutlet var itemsRemainingLabel: UILabel!
    @IBOutlet var percentMatchedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.outputs.itemsRemaining.subscribe(onNext: { nrRemaining in
            self.itemsRemainingLabel.text = nrRemaining
        }).disposed(by: self.disposeBag)
        self.viewModel.outputs.percentMatched.subscribe(onNext: { percentMatched in
            self.percentMatchedLabel.text = percentMatched
        }).disposed(by: self.disposeBag)
        
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
        screenBoundsCollisionBehavior.addItem(bottomBrick)
        
        self.gameController.vocabularyPairs = self.set!.vocabularyPairs
        self.gameController.delegate = self
        self.gameController.startGame()
        
        self.viewModel.inputs.pairs.onNext(self.set!.vocabularyPairs)
        self.viewModel.inputs.viewDidLoad.onNext(())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)
            if(hitView is FlashCardView) {
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
                    // TODO: check if word hovering over bucket
                    self.checkIfWordHoveringOverBuckets(itemBehavior: self.attachmentBehavior!)
                }
                
                // Remove collision behavior from item being dragged
                screenBoundsCollisionBehavior.removeItem(touchedView)
                dynamicAnimator.addBehavior(attachmentBehavior!)
            }
            break
        case .ended:
            if let viewToToss = self.viewBeingDragged {
                print("Toss view \(viewToToss)")
                tossView(viewToToss: viewToToss, sender: sender)
            }
            
            self.viewBeingDragged = nil
            if let availableAttachmetBehavior = self.attachmentBehavior {
                self.dynamicAnimator.removeBehavior(availableAttachmetBehavior)
                self.attachmentBehavior = nil
            }
            break
        default:
            if let availableAttachmentBehavior = self.attachmentBehavior {
                availableAttachmentBehavior.anchorPoint = sender.location(in: self.view)
            }
            break
        }
    }
    
    fileprivate func checkForItemCollisionsWithBucket(item: FlashCardView) {
        let intersectionBucket1 = item.frame.intersection(self.bucket1.frame).size
        let intersectionBucket2 = item.frame.intersection(self.bucket2.frame).size
        let intersectionBucket3 = item.frame.intersection(self.bucket3.frame).size
        let intersectionBucket4 = item.frame.intersection(self.bucket4.frame).size
        
        // Find biggest intersection
        var bucketThatWasHit: BucketView? = nil
        var biggestIntersection = CGSize.zero
        if self.areaBiggerThanTarget(area: intersectionBucket1, target: biggestIntersection) {
            biggestIntersection = intersectionBucket1
            bucketThatWasHit = bucket1
        }
        if self.areaBiggerThanTarget(area: intersectionBucket2, target: biggestIntersection) {
            biggestIntersection = intersectionBucket2
            bucketThatWasHit = bucket2
        }
        if self.areaBiggerThanTarget(area: intersectionBucket3, target: biggestIntersection) {
            biggestIntersection = intersectionBucket3
            bucketThatWasHit = bucket3
        }
        if self.areaBiggerThanTarget(area: intersectionBucket4, target: biggestIntersection) {
            biggestIntersection = intersectionBucket4
            bucketThatWasHit = bucket4
        }
        if let hitBucket = bucketThatWasHit {
            if let matchedPair = hitBucket.wordWasDroppedIntoBucket(word: item.text.text!) {
                self.gameController.pairMatched(pair: matchedPair)
                self.gameController.reassignAllBuckets()
                self.viewModel.inputs.pairMatched.onNext(matchedPair)
            }
        }
    }
    
    private func areaBiggerThanTarget(area: CGSize, target: CGSize) -> Bool {
        return (area.width * area.height) > (target.width * target.height)
    }
    
    fileprivate func checkIfWordHoveringOverBuckets(itemBehavior: UIAttachmentBehavior) {
        itemBehavior.items.forEach { it in
            let item = it as! FlashCardView
            if(item.frame.intersects(self.bucket1.frame)) {
                self.bucket1.startHoveringOver()
            } else {
                self.bucket1.stopHoveringOver()
            }
            
            if(item.frame.intersects(self.bucket2.frame)) {
                self.bucket2.startHoveringOver()
            } else {
                self.bucket2.stopHoveringOver()
            }
            
            if(item.frame.intersects(self.bucket3.frame)) {
                self.bucket3.startHoveringOver()
            } else {
                self.bucket3.stopHoveringOver()
            }
            
            if(item.frame.intersects(self.bucket4.frame)) {
                self.bucket4.startHoveringOver()
            } else {
                self.bucket4.stopHoveringOver()
            }
        }
    }
    
    private func tossView(viewToToss: UIView, sender: UIPanGestureRecognizer) {
        // Stop the hovering effects
        self.bucket1.stopHoveringOver()
        self.bucket2.stopHoveringOver()
        self.bucket3.stopHoveringOver()
        self.bucket4.stopHoveringOver()
        
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
            // Add collision behavior
            self.screenBoundsCollisionBehavior.addItem(viewToToss)
            
            // Check for collision with bucket
            if let tossedLabel = viewToToss as? FlashCardView {
                self.checkForItemCollisionsWithBucket(item: tossedLabel)
            }
        }
    }
}

extension PlayViewController: WordMatchGameControllerDelegate {
    func spawnPair(pair: VocabularyPairLocalDataModel, color: UIColor, useDefinition: Bool) {
        let newLabel = FlashCardView()
        newLabel.translatesAutoresizingMaskIntoConstraints = false
        if(useDefinition) {
            newLabel.text.text = pair.definition
        } else {
            newLabel.text.text = pair.wordOrPhrase
        }
        newLabel.text.numberOfLines = 0
        newLabel.updateColor(color: color)
        newLabel.text.font = UIFont.systemFont(ofSize: FontConstants.large)
        let spawnPosX = self.view.frame.size.width / 2 - newLabel.frame.width / 2
        newLabel.frame.origin = CGPoint(x: spawnPosX, y: 0.0)
        newLabel.isUserInteractionEnabled = true    // Needed, otherwise we can't "grab" the view by touching it
        self.view.addSubview(newLabel)
        
        // Limit width of flash cards
        newLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(200)
        }
        newLabel.setNeedsLayout()
        newLabel.layoutIfNeeded()
        
        self.labels.append(newLabel)
        self.gravityBehavior.addItem(newLabel)
        self.screenBoundsCollisionBehavior.addItem(newLabel)
        self.viewModel.inputs.spawnPair.onNext(pair)
    }
    
    func removePair(pair: VocabularyPairLocalDataModel, useDefinition: Bool) {
        guard let indexOfItemToRemove = self.labels.firstIndex(where: { item in
            if(useDefinition) {
                return item.text.text == pair.definition
            } else {
                return item.text.text == pair.wordOrPhrase
            }
        }) else {
            return
        }
        let labelToRemove = self.labels[indexOfItemToRemove]
        UIView.animate(withDuration: 0.5, animations: {
            labelToRemove.alpha = 0
        }, completion: {_ in
            self.gravityBehavior.removeItem(labelToRemove)
            self.screenBoundsCollisionBehavior.removeItem(labelToRemove)
            labelToRemove.removeFromSuperview()
            self.labels.remove(at: indexOfItemToRemove)
        })
    }
    
    func updatePair(pair: VocabularyPairLocalDataModel, with color: UIColor, useDefinition: Bool) {
        guard let itemToUpdate = self.labels.first(where: { item in
            if(useDefinition) {
                return item.text.text == pair.definition
            } else {
                return item.text.text == pair.wordOrPhrase
            }
        }) else {
            return
        }
        itemToUpdate.updateColor(color: color)
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
    
    func gameOver() {
        let nrOfLabelsLeft = self.labels.count
        if self.highScoreService.saveHighScore(set: self.set!, score: nrOfLabelsLeft) {
            self.highScoreLabel.text = "New high score: \(self.highScoreService.getHighScore(set: self.set!))"
            self.highScoreLabel.alpha = 1
        } else {
            self.highScoreLabel.text = "Your score: \(nrOfLabelsLeft). Current high score: \(self.highScoreService.getHighScore(set: self.set!))"
            self.highScoreLabel.alpha = 1
        }
        
        // Hide buckets
        self.bucket1.alpha = 0
        self.bucket2.alpha = 0
        self.bucket3.alpha = 0
        self.bucket4.alpha = 0
        
        self.gameController.pauseGame()
        
        self.labels.forEach { label in
            label.alpha = 0
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
