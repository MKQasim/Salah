//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState: LocationState
    let currentDate = Date()
    @State var selectedLocation: Location
    
    // MARK: View States
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remTime = "00:00:00"
    @State private var timer: Timer?
        
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(spacing: 10) {
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title2)
                                .fontWeight(.black)
                            
                            Text("Next Prayer in: \(remTime)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Image(systemName: "clock.arrow.circlepath").font(.title2)
                            .foregroundColor(.orange)
                        Text("\(nextSalah)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "calendar").font(.title2)
                            .foregroundColor(.blue)
                        Text("\(timeNow)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    }
                    .onAppear {
                        setUpView()
                        startTimer()
                    }
                }
                .padding()
                .background(Color.gray)
                .cornerRadius(20)
                .frame(minWidth: 140)
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
                PrayerTomorowSection(prayerTimes: $tomorrowPrayerTimes)
                PrayerWeeklySectionView(selectedLocation: selectedLocation)
            }
            .padding(.top, 10)
            .padding([.leading, .trailing])
        }
    }

    private func setUpView() {
        if isUpdate {
            PrayerTimeHelper.shared.getSalahTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, offSet: selectedLocation.offSet ?? 0.0, completion: { location in
                guard let location = location else { return  }
             
                selectedLocation = location
                todayPrayersTimes = location.prayerTimings ?? []
                nextSalah = "\(location.nextPrayer?.name ?? "") at \(location.nextPrayer?.time ?? "")"
                let countdownTimer = CountdownTimer(remainingTime: 0)
                countdownTimer.startCountdownTimer(with: location.timeDeferance ?? 0.0) { formattedTime in
                    print("Remaining Time: \(formattedTime)")
                    remTime = formattedTime
                    // Update UI or perform actions with the formattedTime
                }
                guard let timeZone = location.timeZone else { return  }
                let currentDate = PrayerTimeHelper.shared.currentTime(for: timeZone, dateFormatString: "yyyy MMM d HH:mm").0
                timeNow = currentDate ?? ""
                todayPrayersTimes = location.prayerTimings ?? []
            })
            
            sunTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, timeZone: selectedLocation.offSet ?? 0.0)
            
            if var cal = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                cal.dateByAdding(timeZoneOffset: selectedLocation.offSet ?? 0)
                PrayerTimeHelper.shared.getSalahTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, offSet: selectedLocation.offSet ?? 0.0, date: currentDate, completion: { location in
                    guard let location = location else { return  }
                       selectedLocation = location
                    print(selectedLocation.offSet)
                     tomorrowPrayerTimes = location.prayerTimings ?? []
                })
            }
            
            isUpdate = false
        }
        
    }

      func startTimer() {
          self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeAndRemainingTime()
        }
          self.timer?.fire()
    }

    private func updateTimeAndRemainingTime() {
        let endDate = PrayerTimeHelper.shared.targetDate
        
        let hours = selectedLocation.offSet ?? 0.0 // get the hours from GMT as a Double
        let secondsFromGMT = Int(hours * 3600) // convert hours to seconds and cast to Int
        let timeZone = TimeZone(secondsFromGMT: secondsFromGMT) // create a TimeZone object
        
        guard let timeZone = timeZone else {
            // Handle the case where timeZone is nil
            // You might want to show an error message or handle this situation accordingly
            return
        }
        
        let currentDate = PrayerTimeHelper.shared.currentTime(for: timeZone, dateFormatString: "yyyy MMM d HH:mm").0
       
        timeNow = currentDate ?? ""
        
//        PrayerTimeHelper.shared.findNextPrayerTime(now: startDate ?? Date(), selectedLocation: selectedLocation) { nextPrayer in
//            if let nextPrayer = nextPrayer {
//                if let name = nextPrayer.name as? String, let time = nextPrayer.time as? String {
//                    self.nextSalah = "\(name) at \(time)"
//                }
//            }
//        }
        
        selectedPrayer = PrayerTimeHelper.shared.selectedPrayer
        
//        PrayerTimeHelper.shared.calculateRemainingTimeUntilNextPrayer(now: startDate ?? Date(), selectedLocation: selectedLocation) { remainingTime in
//            self.remTime = remainingTime ?? ""
//        }
    }

}


//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}



import Foundation

class CountdownTimer {
    var remainingTime: TimeInterval
    var timer: Timer?
    var timeUpdateHandler: ((String) -> Void)?

    init(remainingTime: TimeInterval) {
        self.remainingTime = remainingTime
    }

    func startTimer(completion: @escaping (String) -> Void) {
        timeUpdateHandler = completion

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {  timer in
//            guard let strongSelf = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                let timeComponents = self.getTimeComponents(from: self.remainingTime)
                let formattedTime = self.formatTimeComponents(timeComponents)
                self.timeUpdateHandler?(formattedTime)
            } else {
                timer.invalidate()
                self.timeUpdateHandler?("00:00:00") // Notify completion with finished time
                print("Countdown finished!")
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func getTimeComponents(from timeDifference: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(timeDifference) / 3600
        let minutes = Int(timeDifference) / 60 % 60
        let seconds = Int(timeDifference) % 60

        return (hours, minutes, seconds)
    }

    func formatTimeComponents(_ timeComponents: (hours: Int, minutes: Int, seconds: Int)) -> String {
        let formattedHours = String(format: "%02d", timeComponents.hours)
        let formattedMinutes = String(format: "%02d", timeComponents.minutes)
        let formattedSeconds = String(format: "%02d", timeComponents.seconds)

        return "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
    }

    func startCountdownTimer(with timeDifference: TimeInterval, completion: @escaping (String) -> Void) {
     
        print("Time difference in seconds: \(timeDifference)")
        self.remainingTime = timeDifference
        self.startTimer(completion: completion)
    }
    
}
