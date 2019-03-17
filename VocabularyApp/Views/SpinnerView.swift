//
//  SpinnerView.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 17.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SpinnerView: UIView {
    
    private let size = 50
    private let bag = DisposeBag()
    
    let animating = PublishSubject<Bool>()
    var isAnimating: Bool {
        didSet {
            self.animationRunning = isAnimating
            if isAnimating {
                self.alpha = CGFloat(1)
                self.startAnimating()
            } else {
                self.alpha = CGFloat(0)
                self.stopAnimating()
            }
        }
    }
    
    private var animationRunning = false    //Needed to restore the animation state when the app resumes from the background since animations are stopped when an app enters the background state
    
    init() {
        self.isAnimating = false
        super.init(frame: CGRect.zero)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.isAnimating = false
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        self.isAnimating = false
        super.init(frame: frame)
        self.setupView()
    }
    
    private func setupView() {
        //Hidden by default
        self.alpha = 0
        
        animating.distinctUntilChanged().subscribe(onNext: { animating in
            let startAlpha = animating ? 0 : 1
            let endAlpha = animating ? 1 : 0
            let startScale: CGFloat = animating ? 0.5 : 1.0
            let endScale: CGFloat = animating ? 1.0 : 0.5
            
            self.alpha = CGFloat(startAlpha)
            self.transform = CGAffineTransform(scaleX: startScale, y: startScale)
            
            UIView.animate(withDuration: AnimationConstants.appearanceDuration, animations: {
                self.alpha = CGFloat(endAlpha)
                self.transform = CGAffineTransform(scaleX: endScale, y: endScale)
            }, completion: { _ in
                if !animating {
                    self.stopAnimating()
                }
            })
            if animating {
                self.startAnimating()
            }
            self.animationRunning = animating
        }).disposed(by: bag)
        
        //Listen for when the app becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func appDidBecomeActive() {
        self.resumeAnimationIfNecessary()
    }
    
    override func didMoveToWindow() {
        self.resumeAnimationIfNecessary()
    }
    
    private func resumeAnimationIfNecessary() {
        //If the animation was running before, resume it
        if self.animationRunning {
            self.startAnimating()
        }
    }
    
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = UIColor.red.cgColor
        layer.lineWidth = 3
        setPath()
    }
    
    private func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.7),
                Pose(0.6, 0.500, 0.5),
                Pose(0.6, 1.000, 0.3),
                Pose(0.6, 1.500, 0.1),
                Pose(0.2, 1.875, 0.1),
                Pose(0.2, 2.250, 0.3),
                Pose(0.2, 2.625, 0.5),
                Pose(0.2, 3.000, 0.7),
            ]
        }
    }
    
    private func startAnimating() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = type(of: self).poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(start * 2 * CGFloat(Double.pi))
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
    }
    
    private func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = CAAnimationCalculationMode.linear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    private func stopAnimating() {
        layer.removeAllAnimations()
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: self.size, height: self.size)
        }
    }
}
