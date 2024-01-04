//
//  PrayerTimeHelper.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import SwiftUI
import Foundation

typealias NextPrayerCompletion = (PrayerTiming?) -> Void

class PrayerTimeHelper: ObservableObject {
    
    @AppStorage("SetCalculationMethod") private var calculationMethod = 0
    @AppStorage("SetFajrJuridiction") private var juridictionMethod = 0
    @Published var prayerTiming = [PrayerTiming]()
    @Published var nextSalah = ""
    @Published var selectedPrayer : PrayerTiming?
    @Published var targetDate = Date()
    @Published var remTime = "00:00:00" // Use @Published to update views
    @Published var selectedLocation: Location?
    @Published var remainingTimes: [String: String] = [:] // For remaining times of prayers
    var timer: Timer? // Timer to update remaining prayer time
    let timeFormatter = DateFormatter()
    var prayerDate = Date()
    static let shared = PrayerTimeHelper()
    
    init() {
        timeFormatter.dateFormat = "HH:mm"
    }
    // Function to format remaining time
    func formatRemainingTime(_ remainingTime: String) -> String {
        // Implement your formatting logic here
        return remainingTime
    }
    // Function to fetch the prayer timings
    func getSalahTimings(location: Location, date: Date = Date(), completion: @escaping (Location?) -> Void) {
        var todayPrayerTiming = [PrayerTiming]()
        var tomorrowPrayerTiming = [PrayerTiming]()
        var todaySunTiming = [PrayerTiming]()
        var tomorrowSunTiming = [PrayerTiming]()
        var nextPrayer: PrayerTiming?
        let offsetSeconds = Int((location.offSet ?? 0.0) * 3600)
        
    
        // Adjust the date by adding the location's offset
        let adjustedDate = Calendar.current.date(byAdding: .second, value: offsetSeconds, to: date) ?? date
        let permissionsManager = PermissionsManager.shared
        let localPrayTimeSetting = permissionsManager.prayTime ?? LocalPrayTimeSetting()
        let allSettings = permissionsManager.settingsData
        
        // Filter the desired settings
        let dropdownSettings = allSettings.filter { $0.settingType?.dropdownType != nil }
        let simpleSettings = allSettings.filter { $0.settingType?.stringValue != nil }
        let permissionSettings = allSettings.filter { $0.settingType?.permissionType != nil }
        let time = PrayTime()
        print(localPrayTimeSetting.calculationMethod.rawValue)
        print(localPrayTimeSetting.juristicMethod.rawValue)
        print(localPrayTimeSetting.timeFormat.rawValue)
        
        time.setCalcMethod(Int32(localPrayTimeSetting.calculationMethod.rawValue))
        time.setAsrMethod(Int32(localPrayTimeSetting.juristicMethod.rawValue))
        time.setTimeFormat(Int32(localPrayTimeSetting.timeFormat.rawValue))
        
        
        
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTodayTime = time.getDatePrayerTimes(Int32(adjustedDate.get(.year)),
                                              andMonth: Int32(adjustedDate.get(.month)),
                                              andDay: Int32(adjustedDate.get(.day)),
                                              andLatitude: location.lat ?? 0.0,
                                              andLongitude: location.lng ?? 0.0,
                                              andtimeZone: location.offSet ?? 0.0)!
        
        let getTomorrowTime = time.getDatePrayerTimes(Int32(adjustedDate.get(.year)),
                                              andMonth: Int32(adjustedDate.get(.month)),
                                              andDay: Int32(adjustedDate.get(.day)),
                                              andLatitude: location.lat ?? 0.0,
                                              andLongitude: location.lng ?? 0.0,
                                              andtimeZone: location.offSet ?? 0.0)!
        let salahTodayTiming = getTodayTime.compactMap({ $0 as? String })
        
        todayPrayerTiming.removeAll()
        
        for (index, name) in salahNaming.enumerated() {
            if let todayTime = PrayerTimeHelper.shared.getDateForTime(salahTodayTiming[index], option: .today) , let tomorrowTime = PrayerTimeHelper.shared.getDateForTime(salahTodayTiming[index], option: .tomorrow){
                let newTodaySalahTiming = PrayerTiming(name: name, time: todayTime, offSet: location.offSet)
                let newTomorrowSalahTiming = PrayerTiming(name: name, time: tomorrowTime, offSet: location.offSet)
                
                if (name != "Sunset" && name != "Sunrise") {
                    todayPrayerTiming.append(newTodaySalahTiming)
                    tomorrowPrayerTiming.append(newTomorrowSalahTiming)
                }
                if (name == "Sunset" || name == "Sunrise") {
                    todaySunTiming.append(newTodaySalahTiming)
                    tomorrowSunTiming.append(newTomorrowSalahTiming)
                }
            }
        }
        
        PrayerTimeHelper.shared.getNextPrayerTime(for: location, todaysPrayerTimes: todayPrayerTiming,tomorrowPrayerTimes: tomorrowPrayerTiming) { nextSalah, difference in
            print(nextSalah, difference)
            
            var loc = Location()
            loc = location
            loc.todayPrayerTimings = todayPrayerTiming
            loc.tomorrowPrayerTimings = tomorrowPrayerTiming
            loc.todaySunTimings = todaySunTiming
            loc.tomorrowSunTimings = todaySunTiming
            loc.nextPrayer = nextSalah
            loc.timeDifference = difference ?? 0.0
            completion(loc)
        }
    }
    
    func formattedDate(from date: Date, with timeZone: TimeZone) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateString = dateFormatter.string(from: date)
        dateFormatter.timeZone = TimeZone(identifier: "UTC") // Set the correct time zone for parsing
        return dateFormatter.date(from: dateString)
    }
    
    enum DateOption {
        case today
        case tomorrow
    }

    func getDateForTime(_ time: String, option: DateOption) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set UTC timezone
        
        if let timeDate = dateFormatter.date(from: time) {
            let calendar = Calendar.current
            let currentDate = Date()

            switch option {
            case .today:
                // Get components from the current date
                let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
                
                // Combine date components with the timeDate
                if let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                                    minute: calendar.component(.minute, from: timeDate),
                                                    second: 0,
                                                    of: currentDate) {
                    let combinedDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: combinedDate),
                                                         minute: calendar.component(.minute, from: combinedDate),
                                                         second: 0,
                                                         of: currentDate)
                    return combinedDateTime
                }
            case .tomorrow:
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    let components = calendar.dateComponents([.year, .month, .day], from: nextDay)
                    
                    if let combinedDate = calendar.date(bySettingHour: calendar.component(.hour, from: timeDate),
                                                        minute: calendar.component(.minute, from: timeDate),
                                                        second: 0,
                                                        of: nextDay) {
                        let combinedDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: combinedDate),
                                                             minute: calendar.component(.minute, from: combinedDate),
                                                             second: 0,
                                                             of: nextDay)
                        return combinedDateTime
                    }
                }
            }
        }
        return nil
    }

    func getNextPrayerTime(for location: Location, todaysPrayerTimes: [PrayerTiming],tomorrowPrayerTimes: [PrayerTiming], completion: @escaping (PrayerTiming?, Double?) -> Void) {
        var nextPrayerTime: PrayerTiming? = nil
        var minTimeDifference = TimeInterval.greatestFiniteMagnitude
        var currentTimeForComparison = Date()
        // Get the current date and time
        let currentDate = Date().getDateFromDecimalTimeZoneOffset(decimalOffset: location.offSet ?? 0.0)
        
        for prayer in todaysPrayerTimes {
            guard let prayerTime = prayer.time else {
                continue
            }
            
            // Adjust the current date and time by subtracting the location's offset
            currentTimeForComparison = prayer.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: location.offSet ?? 0.0, calendarIdentifier: .gregorian)?.date ?? Date()
            
            if let currentTimeForComparison = currentTimeForComparison as? Date , currentTimeForComparison >= prayerTime {
                // Skip if the current time is equal to or later than the prayer time
                continue
            }
            
            let timeDifference = prayerTime.timeIntervalSince(currentTimeForComparison)
            
            if timeDifference < minTimeDifference {
                minTimeDifference = timeDifference
                nextPrayerTime = prayer
            }
        }
        
        
        if let nextPrayerTime = nextPrayerTime {
            print("found for today: \(nextPrayerTime)")
        } else {
            if let firstPrayerTime = tomorrowPrayerTimes.first?.time {
                let timeDifference = firstPrayerTime.timeIntervalSince(currentTimeForComparison ?? currentDate)
                if timeDifference < minTimeDifference {
                    minTimeDifference = timeDifference
                    nextPrayerTime = tomorrowPrayerTimes.first
                    print("assigned for tomorrow: \(nextPrayerTime)")
                }
            }
        }
        completion(nextPrayerTime, minTimeDifference)
    }

    func formatDate(_ date: Date, calendarIdentifier: Calendar.Identifier? = nil, localeIdentifier: String? = nil, timeZoneOffsetHours: Double? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        
        if let calendarIdentifier = calendarIdentifier {
            dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
            dateFormatter.dateFormat = "dd MMMM yyyy HH:mm" // Islamic calendar format
        } else {
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "HH:mm"
        }
        
        if let localeIdentifier = localeIdentifier {
            dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        if let timeZoneOffsetHours = timeZoneOffsetHours {
            let timeZoneOffsetSeconds = timeZoneOffsetHours * 3600 // Convert hours to seconds
            let timeZone = TimeZone(secondsFromGMT: Int(timeZoneOffsetSeconds))
            dateFormatter.timeZone = timeZone
        }
        
        let dateString = dateFormatter.string(from: date)
        return dateFormatter.date(from: dateString)
    }
    // Example method to calculate time difference
    func getTimeDifference(_ from: Date, _ to: Date) -> TimeInterval {
        return to.timeIntervalSince(from)
    }
    
    func compareTimeStrings(firstTime: String, secondTime: String) -> ComparisonResult? {
        
        timeFormatter.dateFormat = "HH:mm"
        
        // Convert time strings to Date objects
        guard let firstDate = timeFormatter.date(from: firstTime),
              let secondDate = timeFormatter.date(from: secondTime) else {
            return nil // Invalid time format
        }
        
        // Compare the dates
        let comparisonResult = firstDate.compare(secondDate)
        return comparisonResult
    }
    
    func createPrayerDateTime(from time: String, with timeZone: TimeZone) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        
        // Extract hour and minute from the provided time string
        let components = time.components(separatedBy: ":")
        guard let hour = Int(components.first ?? "0"),
              let minute = Int(components.last ?? "0") else {
            return nil
        }
        
        // Get the current date components in the given time zone
        let currentDate = Date()
        dateComponents = calendar.dateComponents(in: timeZone, from: currentDate)
        
        // Set the hour and minute components to the given time
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = 0
        
        print(formattedDate(from: dateComponents.date ?? Date(), with: timeZone))
        
        // Create a new date by using the combined components
        guard let combinedDateTime = calendar.date(from: dateComponents) else {
            return nil
        }
        
        // Check if the resulting time is in the past compared to the current time in the given time zone
        if combinedDateTime < currentDate {
            // If the combined time is in the past, add one day
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: combinedDateTime) else {
                return nil
            }
            return nextDay
        }
        prayerDate = combinedDateTime
        return combinedDateTime
    }
    
    func getNextPrayerDetails(offSet: Double?, from prayerTimes: [PrayerTiming]) -> (nextPrayer: PrayerTiming?, remainingTime: String?, minTimeDifference: Double?) {
        guard let offSet = offSet else { return (nil, nil, nil) }
        
        let timeZone = TimeZone(secondsFromGMT: Int(offSet * 3600))
        
        guard let timeZone = timeZone else { return (nil, nil, nil) }
        
        let currentDateTime = Date()
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "HH:mm"
        
        var earliestPrayer: PrayerTiming? = nil
        var minTimeDifference = TimeInterval.greatestFiniteMagnitude
        for prayerTime in prayerTimes {
            if let prayerDate = dateFormatter.date(from: "\(prayerTime.time)") {
                let components = calendar.dateComponents([.hour, .minute,.second], from: currentDateTime, to: prayerDate)
                if let difference = components.hour, difference >= 0 {
                    let timeDifference = TimeInterval(difference * 3600 + (components.minute ?? 0) * 60)
                    if timeDifference < minTimeDifference {
                        minTimeDifference = timeDifference
                        earliestPrayer = prayerTime
                    }
                }
            }
        }
        
        if let earliestPrayer = earliestPrayer {
            let remainingTime = formatTimeComponents(getTimeComponents(from: minTimeDifference))
            return (earliestPrayer, remainingTime, minTimeDifference)
        }
        
        return (nil, nil, nil)
    }
    
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
            if let time = PrayerTimeHelper.shared.getDateForTime(salahTiming[index], option: .today) {
                let newSalahTiming = PrayerTiming(name: name, time: time)
                if (name == "Sunset" || name == "Sunrise") {
                    sunTimings.append(newSalahTiming)
                }
            }
        }
        return sunTimings
    }
    
    func convertDateToTimeZone(date: Date, timeZone: TimeZone) -> Date {
        let sourceTimeZone = TimeZone(secondsFromGMT: 0) // GMT
        let destinationOffset = timeZone.secondsFromGMT(for: date)
        let sourceOffset = sourceTimeZone?.secondsFromGMT(for: date) ?? 0
        let interval = destinationOffset - sourceOffset
        return date.addingTimeInterval(TimeInterval(interval))
    }
    
    func formatTimeComponents(_ timeComponents: (hours: Int, minutes: Int, seconds: Int)) -> String {
        let formattedHours = String(format: "%02d", timeComponents.hours)
        let formattedMinutes = String(format: "%02d", timeComponents.minutes)
        let formattedSeconds = String(format: "%02d", timeComponents.seconds)
        
        return "\(formattedHours):\(formattedMinutes):\(formattedSeconds)"
    }
    
    func getTimeComponents(from timeDifference: TimeInterval) -> (hours: Int, minutes: Int, seconds: Int) {
        let hours = Int(timeDifference) / 3600
        let minutes = Int(timeDifference) / 60 % 60
        let seconds = Int(timeDifference) % 60
        
        return (hours, minutes, seconds)
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

extension PrayerTimeHelper {
    func syncCalculationMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.CalculationMethod(rawValue: value) {
            prayTime.setCalculationMethod(method)
        }
    }
    
    func syncJuristicMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.JuristicMethod(rawValue: value) {
            prayTime.setJuristicMethod(method)
        }
    }
    
    func syncAdjustingMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.AdjustingMethod(rawValue: value) {
            prayTime.setAdjustingMethod(method)
        }
    }
    
    func syncTimeFormat(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let format = PrayerTimeSetting.TimeFormat(rawValue: value) {
            prayTime.setTimeFormat(format)
        }
    }
    
    func syncTimeName(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let name = PrayerTimeSetting.TimeName(rawValue: value) {
            prayTime.setTimeName(name)
        }
    }
    
    func syncSetting(with prayTime: LocalPrayTimeSetting, setting: Setting) {
        if let dropdownType = setting.settingType?.dropdownType {
            switch dropdownType {
            case .calculationMethod:
                if let calculationMethod = PrayerTimeSetting.CalculationMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setCalculationMethod(calculationMethod)
                }
            case .juristicMethod:
                if let juristicMethod = PrayerTimeSetting.JuristicMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setJuristicMethod(juristicMethod)
                }
            case .adjustingMethod:
                if let adjustingMethod = PrayerTimeSetting.AdjustingMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setAdjustingMethod(adjustingMethod)
                }
            case .timeFormat:
                if let timeFormat = PrayerTimeSetting.TimeFormat(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setTimeFormat(timeFormat)
                }
            case .timeName:
                if let timeName = PrayerTimeSetting.TimeName(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setTimeName(timeName)
                }
            }
        }
    }
}

class LocalPrayTimeSetting: ObservableObject {
    
    @Published var calculationMethod: PrayerTimeSetting.CalculationMethod = .jafari
    @Published var juristicMethod: PrayerTimeSetting.JuristicMethod = .shafii
    @Published var adjustingMethod: PrayerTimeSetting.AdjustingMethod = .none
    @Published var timeFormat: PrayerTimeSetting.TimeFormat = .time24
    @Published var timeName: PrayerTimeSetting.TimeName = .timeName1
    
    func setCalculationMethod(_ method: PrayerTimeSetting.CalculationMethod) {
        calculationMethod = method
    }
    
    func setJuristicMethod(_ method: PrayerTimeSetting.JuristicMethod) {
        juristicMethod = method
    }
    
    func setAdjustingMethod(_ method: PrayerTimeSetting.AdjustingMethod) {
        adjustingMethod = method
    }
    
    func setTimeFormat(_ format: PrayerTimeSetting.TimeFormat) {
        timeFormat = format
    }
    
    func setTimeName(_ name: PrayerTimeSetting.TimeName) {
        timeName = name
    }
}

extension Date {
    func dateByAdding(timeZoneOffset: Double) -> Date? {
        let delta = TimeInterval(timeZoneOffset * 3600)
        return addingTimeInterval(delta)
    }
}
