//
//  CountDownService.swift
//  Salah
//
//  Created by Qassim on 12/29/23.
//

extension Date {
    func startCountdownTimer(
        from startDate: Date,
        to endDate: Date,
        getNextPrayerAndSetTimer: (() -> (startDate: Date?, endDate: Date?))? = nil,
        onUpdate: @escaping (String) -> Void
    ) {
        TimerManager.shared.startTimer(
            between: startDate,
            endDate: endDate,
            getNextPrayerAndSetTimer: getNextPrayerAndSetTimer ?? {
                return (nil, nil)
            },
            onUpdate: onUpdate
        )
    }
}
// TimerManager class
class TimerManager {
    static let shared = TimerManager()

    private var timer: Timer?
    private var onUpdate: ((String) -> Void)?
    private var remainingTime: TimeInterval = 0
    private var getNextPrayerAndSetTimer: (() -> (startDate: Date?, endDate: Date?))?

    private init() {}

    func startTimer(between startDate: Date, endDate: Date, getNextPrayerAndSetTimer: @escaping (() -> (startDate: Date?, endDate: Date?)), onUpdate: @escaping (String) -> Void) {
        stopTimer() // Stop any existing timer before starting a new one

        self.onUpdate = onUpdate
        self.getNextPrayerAndSetTimer = getNextPrayerAndSetTimer

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

            // Get the next prayer time and endDate
            if let (startDate, endDate) = getNextPrayerAndSetTimer?(), let startDate = startDate, let endDate = endDate {
                // Calculate remaining time till the endDate
                let timeDifference = Int(endDate.timeIntervalSince(Date()))
                remainingTime = TimeInterval(max(timeDifference, 0))

                // Start the timer again if there's remaining time
                if remainingTime > 0 {
                    startTimer(between: startDate, endDate: endDate, getNextPrayerAndSetTimer: getNextPrayerAndSetTimer ?? { return (nil, nil) }, onUpdate: onUpdate!)
                }
            }
        }
    }

    private func formatTime(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
