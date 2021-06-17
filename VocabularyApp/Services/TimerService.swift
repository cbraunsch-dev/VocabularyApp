//
//  TimerService.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 17.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import Foundation

protocol TimerService {
    func startTimer(duration: Float, completion: @escaping () -> Void)
}

class NSTimerService: TimerService {
    private var timer: Timer?
    
    func startTimer(duration: Float, completion: @escaping () -> Void) {
        if let alreadyStartedTimer = self.timer {
            alreadyStartedTimer.invalidate()
        }
        self.timer = Timer.init(timeInterval: TimeInterval(duration), repeats: false, block: { _ in
            completion()
        })
    }
}
