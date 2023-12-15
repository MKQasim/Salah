//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI

struct SalahTiming: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let time: String
}

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    let currentDate = Date()
    let city: Cities
    // MARK: View States
    @State private var todayPrayersTimes: [SalahTiming] = []
    @State private var tomorrowPrayerTimes: [SalahTiming] = []
    @State private var sunTimes: [SalahTiming] = []
    @State private var selectedPrayer: SalahTiming? = nil
    @State private var isUpdate = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var targetDate: Date = Date()
    
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
                            
                            
                            Text("Comming in : \(formattedTime())")
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
            // Example usage
            let handler = TimeZoneHandler()

            print(handler.remainingTime)
            print(handler.reminderDate)
            print(handler.reminderTimer)
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
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for prayer in todayPrayersTimes {
            let addedCurrentDate = dateFormatter.string(from: currentDate) + " " + prayer.time
            if let prayerTime = TimeHelper.convertTimeStringToDate(addedCurrentDate, format: "dd/MM/yyyy HH:mm") {
                if prayerTime > currentDate {
                    nextSalah = "\(prayer.name) at \(prayer.time)"
                    selectedPrayer = prayer
                    targetDate = prayerTime
                    startTimer()
                    return
                }
            }
        }
        
        if nextSalah.isEmpty {
            nextSalah = "\(todayPrayersTimes[0].name) at \(todayPrayersTimes[0].time)"
            selectedPrayer = todayPrayersTimes.first
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd HH:mm:ss"
            let seconds = TimeZone.current.secondsFromGMT()
            let hours = Double(seconds/3600)
            
            if  city.timeZone != hours {
                let differentInTimeZone = abs(city.timeZone) - abs(hours)
                if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                    let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)) \(todayPrayersTimes[0].time)"
                    let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
                    print(convertedString)
                    targetDate = convertedString
                }
            }
            else{
                let nextDate = "\(currentDate.get(.year))-\(currentDate.get(.month))-\(currentDate.get(.day)+1) \(todayPrayersTimes[0].time)"
                let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
                targetDate = convertedString
            }
            
            startTimer()
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

#Preview {
    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
    return PrayerDetailView(city: city)
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}

import Foundation

extension Date {
    static func localTime(for country: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: country)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }

    func convertUTCtoGMT() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }

    static func convertGMTtoUTC(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }

    func updateDateTimeFormat(fromFormat: String, toFormat: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromFormat
        dateFormatter.timeZone = TimeZone.current
        if let date = dateFormatter.date(from: dateFormatter.string(from: self)) {
            dateFormatter.dateFormat = toFormat
            return dateFormatter.string(from: date)
        }
        return nil
    }

    func getTimeDifference(from secondDate: Date) -> TimeInterval {
        return secondDate.timeIntervalSince(self)
    }

    func getCurrentDateTime(for country: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: country)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}

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


