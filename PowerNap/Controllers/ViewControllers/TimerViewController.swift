//
//  TimerViewController.swift
//  PowerNap
//
//  Created by Devin Singh on 1/14/20.
//  Copyright © 2020 Devin Singh. All rights reserved.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController {
    
    let myTimer = TimerController()
    fileprivate let userNotificationIdentifier = "timerNotification"
    
    // MARK: - Outlets
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        myTimer.delegate = self
    }
    
    // MARK: - Actions
    
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
        } else {
            myTimer.startTimer(10)
            scheduleNotification()
        }
        updateViews()
    }
    
    func updateViews() {
        updateTimerTextLabel()
        if myTimer.isOn {
            startButton.setTitle("Stop Timer", for: .normal)
        } else {
            startButton.setTitle("Start Nap", for: .normal)
        }
    }
    
    func updateTimerTextLabel() {
        timerLabel.text = myTimer.timeRemainingAsString()
    }
    
    func resetTimer() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            let timerLocalNotificationRequest = requests.filter({$0.identifier == self.userNotificationIdentifier})
            guard let timerNotificationRequest = timerLocalNotificationRequest.last, let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger, let fireDate = trigger.nextTriggerDate() else {return}
            
            self.myTimer.stopTimer()
            self.myTimer.startTimer(fireDate.timeIntervalSinceNow)
        }
    }
    
    func setupAlertController() {
        var snoozeTextField: UITextField?
        let alert = UIAlertController(title: "Wake up", message: "Need some more ZzZzZzZ", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Choose how long to snooze"
            textField.keyboardType = .numberPad
            snoozeTextField = textField
        }
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let snoozeTimeText = snoozeTextField?.text, let time = TimeInterval(snoozeTimeText) else {return}
            self.myTimer.startTimer(time)
            self.updateViews()
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (_) in
            self.updateViews()
        }
        
        alert.addAction(snoozeAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scheduleNotification() {
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Wakey wakey"
        notificationContent.body = "Eggs and bakey"
        
        guard let timeRemaining = myTimer.timeRemaining else {return}
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Failed to request \(error)")
            }
        }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }
}

extension TimerViewController: TimerDelegate {
    func timerSecondTick() {
        updateTimerTextLabel()
    }
    
    func timerCompleted() {
        updateViews()
        setupAlertController()
        
    }
    
    func timerStopped() {
        updateViews()
        cancelNotification()
    }
}
