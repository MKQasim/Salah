//
//  CountDownService.swift
//  Salah
//
//  Created by Qassim on 12/29/23.
//

import SwiftUI

extension Date {
    func startCountdownTimer(
        from startDate: Date,
        to endDate: Date,
        onUpdate: @escaping (String) -> Void
    ) {
        TimerManager().startTimer(
            between: startDate,
            endDate: endDate,
            onUpdate: onUpdate
        )
    }
}

class TimerManager {
//    static let shared = TimerManager()

    var timer: Timer?
    private var onUpdate: ((String) -> Void)?
    private var remainingTime: TimeInterval = 0

    init() {}

    func startTimer(between startDate: Date, endDate: Date, onUpdate: @escaping (String) -> Void) {
        stopTimer() // Stop any existing timer before starting a new one

        self.onUpdate = onUpdate

        let timeDifference = endDate.timeIntervalSince(startDate)
        remainingTime = max(endDate.timeIntervalSinceNow - startDate.timeIntervalSinceNow, 0)

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .common)
        updateTimer() // Update immediately to avoid delay in displaying countdown
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    @objc private func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1

            let formattedTime = formatTime(from: remainingTime)
            onUpdate?(formattedTime)
        } else {
            stopTimer()
        }
    }

    private func formatTime(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
