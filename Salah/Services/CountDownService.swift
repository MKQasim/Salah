//
//  CountDownService.swift
//  Salah
//
//  Created by Qassim on 12/29/23.
//

import Foundation

public class CountDownTimer {
    var remainingTime: TimeInterval
    var timer: Timer?
    var timeUpdateHandler: ((String) -> Void)?

    init(remainingTime: TimeInterval) {
        self.remainingTime = remainingTime
    }

    func startTimer(completion: @escaping (String) -> Void) {
        timeUpdateHandler = completion

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                let formattedTime = self.formatTime(from: self.remainingTime)
                self.timeUpdateHandler?(formattedTime)
            } else {
                timer.invalidate()
                self.timeUpdateHandler?("00:00:00")
                print("Countdown finished!")
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func formatTime(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func startCountdownTimer(with timeDifference: Double, completion: @escaping (String) -> Void) {
        print("Time difference in seconds: \(timeDifference)")
        self.remainingTime = timeDifference
        self.startTimer(completion: completion)
    }
}
