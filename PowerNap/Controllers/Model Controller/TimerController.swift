//
//  TimerController.swift
//  PowerNap
//
//  Created by Devin Singh on 1/14/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import Foundation

protocol TimerDelegate: class {
    func timerSecondTick()
    func timerCompleted()
    func timerStopped()
}

class TimerController {
    
    var timer: Timer?
    var timeRemaining: TimeInterval?
    
    var delegate: TimerDelegate?
    
    var isOn: Bool {
        if timeRemaining != nil {
            return true
        }else{
            return false
        }
    }
    
    func startTimer(_ time: TimeInterval) {
        if !isOn {
            timeRemaining = time
            DispatchQueue.main.async {
                self.secondTick()
                self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
                    self.secondTick()
                })
            }
        }
    }
    
    func secondTick() {
        guard let timeRemaining = timeRemaining else { return }
        if timeRemaining > 0 {
            self.timeRemaining = timeRemaining - 1
            delegate?.timerSecondTick()
        }else{
            timer?.invalidate()
            self.timeRemaining = nil
            delegate?.timerCompleted()
        }
    }
    
    func stopTimer() {
        if isOn {
            timeRemaining = nil
            timer?.invalidate()
            delegate?.timerStopped()
        }
    }
    
    func timeRemainingAsString() -> String {
        let timeRemaining = Int(self.timeRemaining ?? 20*60)
        let minutesLeft = timeRemaining / 60
        // Come back to it later
        let secondsLeft = timeRemaining - (minutesLeft*60)
        
        return String(format: "%02d : %02d", arguments: [minutesLeft, secondsLeft])
    }
}
