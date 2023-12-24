//
//  PrayerTimeHelper.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import SwiftUI

//class PrayerTimeHelpers{
//    @AppStorage("SetCalculationMethod") private var calculationMethod = 0
//    @AppStorage("SetFajrJuridiction") private var juridictionMethod = 0
//    var prayerTiming = [PrayerTiming]()
//    var nextSalah = ""
//    var selectedPrayer = PrayerTiming(name: "", time: "")
//    var targetDate = Date()
//    
//    static let shared = PrayerTimeHelpers()
//    
//    private init() {
//        // Private initializer to prevent creating multiple instances
//        
//        startTimerToUpdatePrayerTime()
//    }
//    
//     func getSalahTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> [PrayerTiming] {
//        var prayerTiming = [PrayerTiming]()
//        let time = PrayTime()
//        time.setCalcMethod(3)
//        time.setAsrMethod(Int32(1))
//        let mutableNames = time.timeNames!
//        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
//        
//        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
//                                              andMonth: Int32(date.get(.month)),
//                                              andDay: Int32(date.get(.day)),
//                                              andLatitude: lat,
//                                              andLongitude: long,
//                                              andtimeZone: timeZone)!
//        let salahTiming = getTime.compactMap({ $0 as? String })
//        
//        for (index, name) in salahNaming.enumerated() {
//            let newSalahTiming = PrayerTiming(name: name, time: salahTiming[index])
//            
//            if (name != "Sunset" && name != "Sunrise") {
//                prayerTiming.append(newSalahTiming)
//            }
//        }
//         PrayerTimeHelper.shared.prayerTiming = prayerTiming
//        return prayerTiming
//    }
//    
//     func getSunTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> [PrayerTiming]{
//        var sunTimings:[PrayerTiming] = []
//        let time = PrayTime()
//        time.setCalcMethod(3)
//        let mutableNames = time.timeNames!
//        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
//        
//        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
//                                              andMonth: Int32(date.get(.month)),
//                                              andDay: Int32(date.get(.day)),
//                                              andLatitude: lat,
//                                              andLongitude: long,
//                                              andtimeZone: timeZone)!
//        let salahTiming = getTime.compactMap({ $0 as? String })
//        
//        for (index, name) in salahNaming.enumerated() {
//            let newSalahTiming = PrayerTiming(name: name, time: salahTiming[index])
//            
//            if (name == "Sunset" || name == "Sunrise") {
//                sunTimings.append(newSalahTiming)
//            }
//        }
//        return sunTimings
//    }
//    
//    func getNextPrayerTime(city:Cities) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
//        let nextPrayerTime = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)
//
//        for prayer in self.prayerTiming {
//            let prayerDateFormatter = DateFormatter()
//            prayerDateFormatter.dateFormat = "yyyy/MM/dd"
//            let addedCurrentDate = prayerDateFormatter.string(from: nextPrayerTime) + " " + prayer.time + ":00"
//            if let prayerTime = dateFormatter.date(from: addedCurrentDate) {
//                if prayerTime > nextPrayerTime {
//                    print(prayerTime)
//                    nextSalah = "\(prayer.name) at \(prayer.time)"
//                    selectedPrayer = prayer
//                    targetDate = prayerTime
//                    return nextSalah
//                }
//            }
//        }
//        
////        if nextSalah.isEmpty {
////            nextSalah = "\(tomorrowPrayerTimes[0].name) at \(tomorrowPrayerTimes[0].time)"
////            selectedPrayer = todayPrayersTimes.first
////            let dateTime = Date.timeZoneDifference(offsetOfTimeZone: city.offSet)
////            print("Date Time :",dateTime)
////            let nextDate = "\(dateTime.get(.year))-\(dateTime.get(.month))-\(dateTime.get(.day)+1) \(todayPrayersTimes[0].time)"
////            let convertedString = TimeHelper.convertTimeStringToDate(nextDate, format: "yyyy-MM-dd HH:mm") ?? Date()
////            targetDate = convertedString
////            newStartTimer()
////        }
//        return nextSalah
//    }
//
//}
//

import SwiftUI
import Foundation


// A function to find the next prayer time from an array of prayers
// Define a typealias for the callback closure
typealias NextPrayerCompletion = (PrayerTiming?) -> Void


class PrayerTimeHelper: ObservableObject {
   
    @AppStorage("SetCalculationMethod") private var calculationMethod = 0
    @AppStorage("SetFajrJuridiction") private var juridictionMethod = 0
    
    @Published var prayerTiming = [PrayerTiming]()
    @Published var nextSalah = ""
    @Published var selectedPrayer = PrayerTiming(name: "", time: "")
    @Published var targetDate = Date()
    @Published var remTime = "00:00:00" // Use @Published to update views
    @Published var selectedLocation: Location?
    @Published var remainingTimes: [String: String] = [:] // For remaining times of prayers
    var timer: Timer? // Timer to update remaining prayer time
    
    static let shared = PrayerTimeHelper()
    
    private init() {
        // Private initializer to prevent creating multiple instances
        
        startTimerToUpdatePrayerTime(for: selectedLocation, callback: {
            remaintime in
            print(remaintime)
        })
    }
    
    // Function to get the remaining times for each prayer
    func getRemainingTimeForPrayers(selectedLocation: Location?) -> [String: String] {
        var remainingTimes: [String: String] = [:]
        
        guard let selectedLocation = selectedLocation else { return remainingTimes }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // Calculate prayer time based on the city's time zone
        guard let sourceTimeZone = TimeZone(secondsFromGMT: 0) else { return ["":""] } // GMT
        guard let destinationTimeZone = TimeZone(secondsFromGMT: Int(selectedLocation.offSet ?? 0.0) * 3600) else { return ["":""]} // Location's time zone
        let currentTime = Date().convert(from: sourceTimeZone, to: destinationTimeZone)
        

        for prayer in self.prayerTiming {
            let prayerDateFormatter = DateFormatter()
            prayerDateFormatter.dateFormat = "yyyy/MM/dd"
            let addedCurrentDate = prayerDateFormatter.string(from: currentTime) + " " + prayer.time + ":00"
            if let prayerTime = dateFormatter.date(from: addedCurrentDate), prayerTime > currentTime {
                let timeDifference = Calendar.current.dateComponents([.hour, .minute, .second], from: currentTime, to: prayerTime)
                let hoursCom = timeDifference.hour ?? 0
                let minutes = timeDifference.minute ?? 0
                let secondsCom = timeDifference.second ?? 0
                let formattedTime = String(format: "%02d:%02d:%02d", hoursCom, minutes, secondsCom)
                remainingTimes[prayer.name] = formattedTime
            }
        }

        return remainingTimes
    }

    // Function to update the remaining prayer time
    func updateRemainingPrayerTime(for location: Location?) {
        guard let selectedLocation = location else { return }
        let remainingTimes = getRemainingTimeForPrayers(selectedLocation: selectedLocation)
        self.remainingTimes = remainingTimes
    }

    // Function to format remaining time
    func formatRemainingTime(_ remainingTime: String) -> String {
        // Implement your formatting logic here
        return remainingTime
    }

    // Function to fetch the prayer timings
    func getSalahTimings(lat: Double, long: Double, offSet: Double, date: Date = Date(), completion: (Location) -> Void) {
        var prayerTiming = [PrayerTiming]()
        let time = PrayTime()
        time.setCalcMethod(3)
        time.setAsrMethod(Int32(1))
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
                                              andMonth: Int32(date.get(.month)),
                                              andDay: Int32(date.get(.day)),
                                              andLatitude: lat,
                                              andLongitude: long,
                                              andtimeZone: offSet)!
        let salahTiming = getTime.compactMap({ $0 as? String })
        
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = PrayerTiming(name: name, time: salahTiming[index])
            
            if (name != "Sunset" && name != "Sunrise") {
                prayerTiming.append(newSalahTiming)
            }
        }
        self.prayerTiming = prayerTiming
        var loc = Location()
        loc.prayerTimings = prayerTiming
        loc.lat = lat
        loc.lng = long
        loc.offSet = offSet
        // Call the completion handler with the result
        completion(loc)
    }

    
    // Function to fetch the sunrise and sunset timings
    func getSunTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> [PrayerTiming] {
        var sunTimings: [PrayerTiming] = []
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
                                              andMonth: Int32(date.get(.month)),
                                              andDay: Int32(date.get(.day)),
                                              andLatitude: lat,
                                              andLongitude: long,
                                              andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({ $0 as? String })
        
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = PrayerTiming(name: name, time: salahTiming[index])
            
            if (name == "Sunset" || name == "Sunrise") {
                sunTimings.append(newSalahTiming)
            }
        }
        return sunTimings
    }
    
    // Function to get the next upcoming prayer time
    // Define an extension for Date to convert between time zones
  

    // Modify your function to use the convert method
    // A helper function to convert a date to a specific time zone
    func convertDateToTimeZone(date: Date, timeZone: TimeZone) -> Date {
        let sourceTimeZone = TimeZone(secondsFromGMT: 0) // GMT
        let destinationOffset = timeZone.secondsFromGMT(for: date)
        let sourceOffset = sourceTimeZone?.secondsFromGMT(for: date) ?? 0
        let interval = destinationOffset - sourceOffset
        return date.addingTimeInterval(TimeInterval(interval))
    }


    // Updated findNextPrayerTime method using the callback closure
    func findNextPrayerTime(now: Date, selectedLocation: Location, completion: @escaping NextPrayerCompletion) {
        // Convert the current time to the location's time zone
        
        
        guard let locationTimeZone = TimeZone(secondsFromGMT: Int(selectedLocation.offSet ?? 0.0) * 3600) else {
            completion(nil)
            return
        }
        let nowInLocation = convertDateToTimeZone(date: now, timeZone: locationTimeZone)
        
        PrayerTimeHelper.shared.getSalahTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, offSet: selectedLocation.offSet ?? 0.0, completion: { location in
            
            
            
            // Initialize the next prayer and the minimum difference variables
            var nextPrayer: PrayerTiming? = nil
            var minDiff = Double.infinity
            guard let prayers = location.prayerTimings else {
                completion(nil)
                return
            }
            
            // Loop through the prayers array
            for prayer in prayers {
                // Convert the prayer time string to a time interval
                guard let timeInterval = timeIntervalFromTimeString(timeString: prayer.time) else {
                    completion(nil)
                    return
                }
                
                // Convert the time interval to a date
                let prayerTime = dateFromTimeInterval(timeInterval: timeInterval, date: now)
                
                // Convert the prayer time to the location's time zone
                let prayerTimeInLocation = convertDateToTimeZone(date: prayerTime, timeZone: locationTimeZone)
                
                // Calculate the difference between the current time and the prayer time in seconds
                let diff = prayerTimeInLocation.timeIntervalSince(nowInLocation)
                
                // If the difference is positive and smaller than the minimum difference, update the next prayer and the minimum difference
                if diff >= 0 && diff < minDiff {
                    nextPrayer = prayer
                    minDiff = diff
                }
            }
            
            // Call the completion handler with the next prayer or nil if none is found
            completion(nextPrayer)
        })
        
       
    }

    // A function to get the start of the day for a given date
    func startOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components)!
    }

    // A function to convert a time interval to a date
    func dateFromTimeInterval(timeInterval: TimeInterval, date: Date) -> Date {
        // Get the start of the day for the given date
        let start = startOfDay(for: date)
        
        // Add the time interval to the start of the day
        let result = start.addingTimeInterval(timeInterval)
        
        // Return the date
        return result
    }

    // A function to convert a time string to a time interval
    func timeIntervalFromTimeString(timeString: String) -> TimeInterval? {
        // Split the time string by colon
        let parts = timeString.split(separator: ":")
        
        // Check if the parts are valid
        if parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) {
            // Calculate the time interval in seconds
            let timeInterval = TimeInterval(hour * 3600 + minute * 60)
            
            // Return the time interval
            return timeInterval
        } else {
            // Return nil if the parts are invalid
            return nil
        }
    }

    func startTimerToUpdatePrayerTime(for location: Location?, callback: @escaping (String?) -> Void) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
            PrayerTimeHelper.shared.calculateRemainingTimeUntilNextPrayer(now: Date(), selectedLocation: location ?? Location()) { remainingTime in
                // Update the callback with the latest remaining time
                callback(remainingTime)
            }
        }
        timer?.fire()
    }

    
    func getTimeComponents(from timeString: String) -> (hour: Int, minute: Int, second: Int)? {
        let components = timeString.components(separatedBy: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              let second = Int(0) as? Int else {
            return nil
        }
        return (hour, minute, second)
    }


    // Function to update the timer
    func calculateRemainingTimeUntilNextPrayer(now: Date, selectedLocation: Location, completion: @escaping (String?) -> Void) {
        // Check if there's a next prayer and get its time
        findNextPrayerTime(now: now, selectedLocation: selectedLocation) { nextPrayer in
            // Handle the result received in the closure
            if let prayer = nextPrayer {
                guard let nextTime = prayer.time as? String else {
                    completion(nil)
                    return
                }

                guard let prayerTimeComponents = self.getTimeComponents(from: nextTime) else {
                    completion(nil)
                    return
                }

                // Get the current date and time
                let currentDate = Date()

                // Add the offset to the current date based on the selected location's time zone
                let timeZoneOffset = TimeInterval(selectedLocation.offSet ?? 0.0) * 3600
                let adjustedCurrentDate = currentDate.addingTimeInterval(timeZoneOffset)

                // Create a calendar
                let calendar = Calendar.current

                // Set the date components for the next prayer
                var dateComponents = DateComponents()
                dateComponents.hour = prayerTimeComponents.hour
                dateComponents.minute = prayerTimeComponents.minute
                dateComponents.second = prayerTimeComponents.second

                // Create a new date with the hour and minute of the next prayer
                guard let nextPrayerDate = calendar.date(bySettingHour: dateComponents.hour ?? 0,
                                                         minute: dateComponents.minute ?? 0,
                                                         second: dateComponents.second ?? 0,
                                                         of: adjustedCurrentDate) else {
                    completion(nil)
                    return
                }

                // Calculate the time difference between the current date and time and the next prayer time
                let timeDifference = nextPrayerDate.timeIntervalSince(adjustedCurrentDate)

                guard timeDifference > 0 else {
                    completion("Prayer time has passed")
                    return
                }

                // Convert time difference to components
                let hours = Int(timeDifference) / 3600
                let minutes = Int(timeDifference) % 3600 / 60
                let seconds = Int(timeDifference) % 60

                let formattedHours = String(format: "%02d", hours)
                let formattedMinutes = String(format: "%02d", minutes)
                let formattedSeconds = String(format: "%02d", seconds)

                var remainingTime = "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
                completion(remainingTime)
            } else {
                completion(nil)
            }
        }
    }

    func currentTime(for timeZone: TimeZone, dateFormatString: String = "LLLL dd, hh:mm:ss a", currentDate: Date = Date()) -> (String?,Date?) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormatString
            dateFormatter.calendar = Calendar(identifier: .islamicCivil)
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // use a fixed time zone
            // Get the seconds from GMT for the given date and time zone
            let seconds = timeZone.secondsFromGMT(for: currentDate)
            
            // Create a new date by adding the seconds to the current date
            let adjustedDate = currentDate.addingTimeInterval(TimeInterval(seconds))
            
            // Return the formatted string for the adjusted date
            return (dateFormatter.string(from: adjustedDate), adjustedDate) // use string(from:) instead of "\(adjustedDate)"
        }
    
    // Function to convert a time string to a Date object
    func convertTimeStringToDate(_ timeString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let formattedDate = dateFormatter.date(from: timeString)
        return formattedDate
    }
    
    // Function to stop the timer
    func stopTimer() {
        timer?.invalidate()
    }
}

extension Date {
    func convert(from sourceTimeZone: TimeZone, to destinationTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(destinationTimeZone.secondsFromGMT(for: self) - sourceTimeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}
extension Date {
    func dateByAdding(timeZoneOffset: Double) -> Date? {
        let delta = TimeInterval(timeZoneOffset * 3600)
        return addingTimeInterval(delta)
    }
}
