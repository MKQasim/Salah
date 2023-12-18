//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    let currentDate = Date()
    let city: Cities
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
    @State private var targetDate: Date = Date()
    
    @State private var timer2:Timer?
    
    var body: some View {
        ScrollView {
            VStack{
                VStack(spacing:10) {
                    HStack{
                        Image(systemName: "clock").font(.title2)
                            .foregroundColor(.blue)
                        Text("Now : \(timeNow)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .fontWeight(.black)
                            .onReceive(timer) { _ in updateTime() }
                    }
                    HStack{
                        Image(systemName: "clock.arrow.circlepath").font(.title3)
                            .foregroundColor(.orange)
                        Text("Next Salah : \(nextSalah)")
                            .font(.title3)
                            .fontWeight(.black)
                    }
                    .frame(maxWidth: .infinity,alignment:.leading)
                    
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title3)
                                .fontWeight(.black)
                            
                            
                            Text("Comming in : \(remTime)")
                                .font(.title3)
                                .fontWeight(.black)
                            
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .cornerRadius(20)
                .frame(minWidth: 140)
                PrayerHeaderSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(prayerTimes: $todayPrayersTimes)
                PrayerTomorowSection(prayerTimes: $tomorrowPrayerTimes)
                PrayerWeeklySectionView(city: city)
            }
            .padding(.top,10)
            .padding([.leading,.trailing])
            
        }
        .onAppear{
            setUpView()
        }
        
        
    }
    
    private func setUpView() {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            sunTimes = []
            todayPrayersTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
            sunTimes = PrayerTimeHelper.getSunTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
            if let cal = Calendar.current.date(byAdding: .day,value: 1, to: currentDate) {
                tomorrowPrayerTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone,date: cal)
            }
            isUpdate = false
        }
    }
    
    
    private func updateTime() {
        timeNow = TimeHelper.currentTime(for: city.timeZone,dateFormatString: "dd MMMM HH:mm:ss") ?? ""
        getNextPrayerTime()
    }
    
    private func formattedTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: remainingTime) ?? ""
    }
    
    private func getNextPrayerTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double(seconds/3600)
        var nextPrayerTime = Date()
        if  city.timeZone != hours {
            let differentInTimeZone = city.timeZone - hours
            if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                nextPrayerTime = dateTime
            } else {
                print("Error occurred while calculating the date.")
            }
        }
        for prayer in todayPrayersTimes {
            let prayerDateFormatter = DateFormatter()
            prayerDateFormatter.dateFormat = "yyyy/MM/dd"
            let addedCurrentDate = prayerDateFormatter.string(from: nextPrayerTime) + " " + prayer.time + ":00"
            if let prayerTime = dateFormatter.date(from: addedCurrentDate) {
                if prayerTime > nextPrayerTime {
                    print(prayerTime)
                    nextSalah = "\(prayer.name) at \(prayer.time)"
                    selectedPrayer = prayer
                    targetDate = prayerTime
                    newStartTimer()
                    return
                }
            }
        }
        
        if nextSalah.isEmpty {
            nextSalah = "\(tomorrowPrayerTimes[0].name) at \(tomorrowPrayerTimes[0].time)"
            selectedPrayer = todayPrayersTimes.first
            
            if city.timeZone != hours {
                let differentInTimeZone = city.timeZone - abs(hours)
                if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                    print("Date Time :",dateTime)
                    let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)+1) \(todayPrayersTimes[0].time)"
                    let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
                    targetDate = convertedString
                }
            }
            else{
                let nextDate = "\(currentDate.get(.year))-\(currentDate.get(.month))-\(currentDate.get(.day)+1) \(todayPrayersTimes[0].time):00"
                let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm:ss") ?? Date()
                print(convertedString)
                targetDate = convertedString
            }
            
//            startTimer()
            newStartTimer()
        }
    }
    
    func newStartTimer() {
        // Set your start and end dates
        var startDate = Date()
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double(seconds/3600)
        if  city.timeZone != hours {
            let differentInTimeZone = city.timeZone - hours
            if let dateTime = startDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                startDate = dateTime
            } else {
                print("Error occurred while calculating the date.")
            }
        }
        let endDate = targetDate
        // Update the remaining time immediately
        updateTimer(startDate, endDate)
        
        // Set up a timer to update the remaining time every second
        self.timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateTimer(startDate, endDate)
        }
        RunLoop.main.add(timer2!, forMode: .common)
        
    }
    
    func updateTimer(_ startDate: Date, _ endDate: Date) {
        // Calculate the time difference between end date and current date
        var startDate = Date()
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double(seconds/3600)
        if  city.timeZone != hours {
            let differentInTimeZone = city.timeZone - hours
            if let dateTime = startDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                startDate = dateTime
            } else {
                print("Error occurred while calculating the date.")
            }
        }
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate, to: endDate)
        // Update the remaining time
        let hoursCom = components.hour ?? 0
        let minutes = components.minute ?? 0
        let secondsCom = components.second ?? 0
        
        print(components)
        remTime = String(format: "%02d:%02d:%02d", hoursCom, minutes, secondsCom)
        
        // Check if the end date is reached
        if startDate >= endDate {
            // Stop the timer when the end date is reached
            timer2?.invalidate()
            print("Timer Completed")
        }
    }
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            remainingTime = max(self.targetDate.timeIntervalSinceNow, 0)
            if remainingTime == 0 {
                timer.invalidate()
                // Timer reached zero
            }
        }
        .fire()
    }
}

//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}

class TimeZoneHandler {
    var reminderTimer: Timer?
    var reminderDate: Date?
    var remainingTime: TimeInterval = 0
    
    func setReminder(reminderDate: Date, completion: @escaping () -> Void) {
        self.reminderDate = reminderDate
        let currentTime = Date()
        
        let timeDifference = reminderDate.timeIntervalSince(currentTime)
        
        // Check if the reminderDate is in the future
        guard timeDifference > 0 else {
            print("Reminder date should be in the future.")
            return
        }
        
        reminderTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.remainingTime = max(0, self.reminderDate?.timeIntervalSince(Date()) ?? 0)
            if self.remainingTime == 0 {
                timer.invalidate()
                completion()
            }
        }
        RunLoop.current.add(reminderTimer!, forMode: .common)
    }
    
    func cancelReminder() {
        reminderTimer?.invalidate()
    }
    
    func getCurrentDateTime(for country: String) -> String {
        return Date().getCurrentDateTime(for: country)
    }
    
    // Other methods from the previous implementation remain unchanged...
}


