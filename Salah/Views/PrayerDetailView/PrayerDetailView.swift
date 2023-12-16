//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @State private var currentDate = Date()
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
    @State private var targetDate: Date = Date()
    @State private var selectedLocation: Location?
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

            let prayerTimeHelper = PrayerTimeHelper()

            prayerTimeHelper.getPrayerTimings(lat: city.lat ?? 49.11, long: city.long ?? 11.19, timeZone: +1.0) { location in
                if let location = location {
                    selectedLocation = location
                    print(location.timezone)
                   
                    
                    self.todayPrayersTimes = location.prayerTimings ?? []
                    
                    self.sunTimes = [] // Assuming sun times are fetched along with prayer timings in getPrayerTimings function
                    
//                    if let cal = Calendar.current.date(byAdding: .day, value: 1, to: currentDateWithTimeZone ?? Date()) {
//                        prayerTimeHelper.getPrayerTimings(lat: location.lat ?? 0.0, long: location.lng ?? 0.0, timeZone: Double(location.timezone?.secondsFromGMT() ?? 0), date: cal) { tomorrowLocation in
//                            if let tomorrowLocation = tomorrowLocation {
//                                self.tomorrowPrayerTimes = tomorrowLocation.prayerTimings ?? []
//                            }
//                        }
//                    }
                    
                    self.isUpdate = false
                }
            }
        }
    }

    
    
    private func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = selectedLocation?.timezone
        timeNow = dateFormatter.string(from: selectedLocation?.dateTime ?? Date())
            print("Current time in: \(timeNow)")
        nextSalah = getNextPrayerTime(from: todayPrayersTimes, selectedLocation: selectedLocation ?? Location()) ?? ""
    }
    
    private func formattedTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: remainingTime) ?? ""
    }
    
    func getNextPrayerTime(from todayPrayersTimes: [PrayerTiming], selectedLocation: Location) -> String? {
        guard let timeZone = selectedLocation.timezone else {
            return nil
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = timeZone
        
        let currentDateString = dateFormatter.string(from: Date())
        guard let currentDate = dateFormatter.date(from: currentDateString) else {
            return nil
        }

        for prayer in todayPrayersTimes {
            if let prayerTime = dateFormatter.date(from: "\(currentDateString.split(separator: " ")[0])") {
                if let datePrayer = dateFormatter.date(from: prayer.time){
                    let comparePrayer = datePrayer.time
                    let compareNormalTime = prayerTime.time
                    if comparePrayer > compareNormalTime {
                        print(prayer.name,prayer.time)
                        return "\(prayer.name) at \(prayer.time)"
                    }
                    else{
                        return "Fajr at 02:11"
                    }
                }
                
            }
        }

        return nil
    }


    
//    private func getNextPrayerTime() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.timeZone = selectedLocation?.timezone
//        
//        timeNow = dateFormatter.string(from: selectedLocation?.dateTime ?? Date())
//        // Update the current date with a specific time zone offset (e.g., -5.5 hours)
////        currentDate = currentDate.dateByAdding(timeZoneOffset: 0) ?? Date()
//
//        for prayer in todayPrayersTimes {
//            let addedCurrentDate = dateFormatter.string(from: Date() ?? Date())
//            if let prayerTime = TimeHelper.convertTimeStringToDate(addedCurrentDate, format: "dd/MM/yyyy HH:mm") {
//                if prayerTime > addedCurrentDate {
//                    nextSalah = "\(prayer.name) at \(prayer.time)"
//                    selectedPrayer = prayer
//                    targetDate = prayerTime
//                    startTimer()
//                    return
//                }
//            }
//        }
//        
//        
//        
////        if nextSalah.isEmpty {
////            nextSalah = "\(todayPrayersTimes[0].name) at \(todayPrayersTimes[0].time)"
////            selectedPrayer = todayPrayersTimes.first
////            let dateFormatter = DateFormatter()
////            dateFormatter.dateFormat = "MMMM dd HH:mm:ss"
////            let seconds = TimeZone.current.secondsFromGMT()
////            let hours = Double(seconds/3600)
////            
////            if  city.timeZone != hours {
////                let differentInTimeZone = abs(city.timeZone) - abs(hours)
////                if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
////                    let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)) \(todayPrayersTimes[0].time)"
////                    let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
////                    print(convertedString)
////                    targetDate = convertedString
////                }
////            }
////            else{
////                let nextDate = "\(currentDate.get(.year))-\(currentDate.get(.month))-\(currentDate.get(.day)+1) \(todayPrayersTimes[0].time)"
////                let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
////                targetDate = convertedString
////            }
////            
////            startTimer()
////        }
//    }
//    

    // Function to update date with a specific time zone offset
    func updateDateWithTimeZoneOffset(date: Date, timeZoneOffset: Double) -> Date? {
        // Create a Calendar instance
        let calendar = Calendar.current

        // Define the time zone offset in seconds
        let timeZoneOffsetSeconds = Int(timeZoneOffset * 3600) // Convert hours to seconds

        // Create a DateComponents instance with the time zone offset
        let offsetComponents = DateComponents(second: timeZoneOffsetSeconds)

        // Apply the offset to the date
        if let updatedDate = calendar.date(byAdding: offsetComponents, to: date) {
            return updatedDate
        } else {
            return nil
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
//    let city = Cities(country: "", city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
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



class Time: Comparable, Equatable {
init(_ date: Date) {
    //get the current calender
    let calendar = Calendar.current

    //get just the minute and the hour of the day passed to it
    let dateComponents = calendar.dateComponents([.hour, .minute], from: date)

        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        hour = dateComponents.hour!
        minute = dateComponents.minute!
    }

    init(_ hour: Int, _ minute: Int) {
        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = hour * 3600 + minute * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        self.hour = hour
        self.minute = minute
    }

    var hour : Int
    var minute: Int

    var date: Date {
        //get the current calender
        let calendar = Calendar.current

        //create a new date components.
        var dateComponents = DateComponents()

        dateComponents.hour = hour
        dateComponents.minute = minute

        return calendar.date(byAdding: dateComponents, to: Date())!
    }

    /// the number or seconds since the beggining of the day, this is used for comparisions
    private let secondsSinceBeginningOfDay: Int

    //comparisions so you can compare times
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay == rhs.secondsSinceBeginningOfDay
    }

    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay < rhs.secondsSinceBeginningOfDay
    }

    static func <= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay <= rhs.secondsSinceBeginningOfDay
    }


    static func >= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay >= rhs.secondsSinceBeginningOfDay
    }


    static func > (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay > rhs.secondsSinceBeginningOfDay
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
}
