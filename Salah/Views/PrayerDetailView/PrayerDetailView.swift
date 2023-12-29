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
    @State var selectedLocation: Location?
    // MARK: View States
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var remTime = "00:00:00"
    @State private var targetDate: Date?
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 10) {
                if selectedPrayer != nil {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.green)
                            .font(.title2)
                            .fontWeight(.black)
                        
                        Text("Next Prayer in : \(remTime)")
                            .font(.title2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("\(nextSalah)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("\(timeNow)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .onReceive(timer) { _ in updateTime() }
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .frame(minWidth: 140)
            
            PrayerSunSection(sunTimes: $sunTimes)
            PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
            PrayerTomorowSection(selectedLocation: $selectedLocation)
            PrayerWeeklySectionView(selectedLocation: selectedLocation  ?? Location())
        }
        .padding(.top, 10)
        .padding([.leading, .trailing])
        .onAppear {
            Task {
                await setUpView()
                startTimer()
                
            }
            
        }
    }
    
    private func setUpView() async {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            sunTimes = []
            remTime = "00:00:00"
            await PrayerTimeHelper.shared.getSalahTimings(location: selectedLocation ?? Location()) { location in
                guard let location = location, let nextPrayer = location.nextPrayer, let name = nextPrayer.name, let time = nextPrayer.time else { return }
                
                //                if location.prayerTimings?.count == 0{
                //                    getNextPrayerTime()
                //                }
                selectedLocation = location
                todayPrayersTimes = location.todayPrayerTimings ?? []
                tomorrowPrayerTimes = location.tomorrowPrayerTimings ?? []
                sunTimes = location.todaySunTimings ?? []
                nextSalah = "\(name) at \(nextPrayer.formatDateString(time))"
                selectedPrayer = nextPrayer
                timeNow = "\(Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: location.offSet ?? 0.0, calendarIdentifier: .islamicCivil)?.formattedString ?? "")"
                targetDate = nextPrayer.time
                let startDate = Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: selectedLocation?.offSet ?? 0.0, calendarIdentifier: .islamicCivil)?.date ?? Date()
                updateTimer(startDate, targetDate ?? Date())
            }
            if let cal = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                tomorrowPrayerTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, timeZone: selectedLocation?.offSet ?? 0.0, date: Date())
                isUpdate = false
            }
        }
    }
    
    private func getNextPrayerTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let nextPrayerTime = Date.timeZoneDifference(offsetOfTimeZone: selectedLocation?.offSet ?? 0.0)
        
        for prayer in todayPrayersTimes {
            let prayerDateFormatter = DateFormatter()
            prayerDateFormatter.dateFormat = "yyyy/MM/dd"
            let addedCurrentDate = prayerDateFormatter.string(from: nextPrayerTime ??  Date()) + " " + "\(prayer.time)" + ":00"
            
            if let prayerTime = dateFormatter.date(from: addedCurrentDate) {
                if prayerTime > nextPrayerTime {
                    print(prayerTime)
                    nextSalah = "\(prayer.name) at \(prayer.time)"
                    selectedPrayer = prayer
                    targetDate = prayerTime
                    return
                }
            }
        }
        
        if nextSalah.isEmpty {
            nextSalah = "\(tomorrowPrayerTimes[0].name) at \(tomorrowPrayerTimes[0].time)"
            selectedPrayer = todayPrayersTimes.first
            let dateTime = Date.timeZoneDifference(offsetOfTimeZone: selectedLocation?.offSet ?? 0.0)
            print("Date Time :",dateTime)
            let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)+1) \("\(todayPrayersTimes[0].time)")"
            let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
            targetDate = convertedString
            //            newStartTimer()
        }
    }
    
    private func updateTime() {
        let timeZoneOffset = selectedLocation?.offSet
        let startDate = Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: timeZoneOffset ?? 0.0, calendarIdentifier: .islamicCivil)?.date ?? Date()
        guard let targetDate = targetDate else { return }
        updateTimer(startDate, targetDate)
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let targetDate = self.targetDate else { return }
            remainingTime = max(targetDate.timeIntervalSinceNow, 0)
            if remainingTime == 0 {
                // Timer reached zero
                //                $timer.invalidate
            }
        }
        .fire()
    }
    
    func updateTimer(_ startDate: Date, _ endDate: Date) {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)
        
        if let hours = components.hour, let minutes = components.minute, let seconds = components.second {
            let hoursCom = max(hours, 0)
            let minutesCom = max(minutes, 0)
            let secondsCom = max(seconds, 0)
            
            print(components)
            remTime = String(format: "%02d:%02d:%02d", hoursCom, minutesCom, secondsCom)
            print("Remaining time: \(remTime)")
            
            // Check if the end date is reached
            if startDate >= endDate {
                timer.upstream.connect().cancel()
            }
        }
    }
}


//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}

extension Date {
    func startCountdownTimer(to endDate: Date, onUpdate: @escaping (String) -> Void) {
        TimerManager.shared.startTimer(between: self, and: endDate, onUpdate: onUpdate)
    }
}

// TimerManager class
class TimerManager {
    static let shared = TimerManager()

    private var timer: Timer?
    private var onUpdate: ((String) -> Void)?
    private var remainingTime: TimeInterval = 0

    private init() {}

    func startTimer(between startDate: Date, and endDate: Date, onUpdate: @escaping (String) -> Void) {
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


private func formatTime(from timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) / 3600
    let minutes = Int(timeInterval) / 60 % 60
    let seconds = Int(timeInterval) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
}

// Usage in ContentView
struct ContentView1: View {
    @State private var countdownValue: String = "00:00:00"
    
    var body: some View {
        VStack {
            Text("Countdown View: \(countdownValue)")
                .onAppear {
                    let startDate = Date() // Replace this with your start date
                    let endDate = startDate.addingTimeInterval(3600) // Replace this with your end date
                    
                    startDate.startCountdownTimer(to: endDate) { newValue in
                        countdownValue = newValue
                    }
                }
        }
    }
}
