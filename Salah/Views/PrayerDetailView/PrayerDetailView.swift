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
        ScrollView(.vertical) {
            VStack{
                VStack(spacing:10) {
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title2)
                                .fontWeight(.black)
                            
                            Text("Next Prayer in : \(remTime)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                    }
                    HStack{
                        Image(systemName: "clock.arrow.circlepath").font(.title2)
                            .foregroundColor(.orange)
                        Text("\(nextSalah)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity,alignment:.leading)
                    
                    HStack{
                        Image(systemName: "calendar").font(.title2)
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
            todayPrayersTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.offSet)
            sunTimes = PrayerTimeHelper.getSunTimings(lat: city.lat, long: city.long, timeZone: city.offSet)
            if let cal = Calendar.current.date(byAdding: .day,value: 1, to: currentDate) {
                tomorrowPrayerTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.offSet,date: cal)
            }
            isUpdate = false
        }
    }
    
    
    private func updateTime() {
        // For Gergian Date
//        timeNow = TimeHelper.currentTime(for: city.timeZone,dateFormatString: "MMM d, h:mm a") ?? ""
        // For Islamic Date
        timeNow = TimeHelper.currentTime(for: city.offSet,dateFormatString: "yyyy MMM d HH:mm") ?? ""
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
//        let seconds = TimeZone.current.secondsFromGMT()
//        let hours = Double(seconds/3600)
//        var nextPrayerTime = Date()
//
//        if  city.timeZone != hours {
//            let differentInTimeZone = city.timeZone - hours
//            if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
//                nextPrayerTime = dateTime
//            } else {
//                print("Error occurred while calculating the date.")
//            }
//        }
        
        let nextPrayerTime = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)

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
            let dateTime = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)
            print("Date Time :",dateTime)
            let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)+1) \(todayPrayersTimes[0].time)"
            let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
            targetDate = convertedString
//            if city.timeZone != hours {
//                let differentInTimeZone = city.timeZone - abs(hours)
//                if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
//                    
//                }
//            }
//            else{
//                let nextDate = "\(currentDate.get(.year))-\(currentDate.get(.month))-\(currentDate.get(.day)+1) \(todayPrayersTimes[0].time):00"
//                let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm:ss") ?? Date()
//                print(convertedString)
//                targetDate = convertedString
//            }
            
//            startTimer()
            newStartTimer()
        }
    }
    
    func newStartTimer() {
        // Set your start and end dates
        let startDate = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)
//        let seconds = TimeZone.current.secondsFromGMT()
//        let hours = Double(seconds/3600)
//        if  city.timeZone != hours {
//            let differentInTimeZone = city.timeZone - hours
//            if let dateTime = startDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
//                startDate = dateTime
//            } else {
//                print("Error occurred while calculating the date.")
//            }
//        }
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
        let startDate = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)
//        let seconds = TimeZone.current.secondsFromGMT()
//        let hours = Double(seconds/3600)
//        if  city.timeZone != hours {
//            let differentInTimeZone = city.timeZone - abs(hours)
//            if let dateTime = startDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
//                startDate = dateTime
//            } else {
//                print("Error occurred while calculating the date.")
//            }
//        }
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
            getNextPrayerTime()
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

