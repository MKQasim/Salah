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
        ScrollView {
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
    
    
    private func timeZoneDifference() -> Date{
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double(seconds/3600)
        var nextPrayerTime = Date()
        if  city.offSet != hours {
            let differentInTimeZone = city.offSet - abs(hours)
            if let dateTime = nextPrayerTime.dateByAdding(timeZoneOffset: differentInTimeZone) {
                nextPrayerTime = dateTime
            } else {
                print("Error occurred while calculating the date.")
            }
        }
        return nextPrayerTime
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
        
        let nextPrayerTime = timeZoneDifference()

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
            let dateTime = timeZoneDifference()
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
        let startDate = timeZoneDifference()
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
        let startDate = timeZoneDifference()
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

extension Date {
    
    // MARK:- APP SPECIFIC FORMATS
    
    func app_dateFromString(strDate:String, format:String) -> Date? {
        
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let dtDate = dateFormatter.date(from: strDate){
            return dtDate as Date?
        }
        return nil
    }
    
    
    func app_stringFromDate() -> String{
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let strdt = dateFormatter.string(from: self as Date)
        if let dtDate = dateFormatter.date(from: strdt){
            return dateFormatter.string(from: dtDate)
        }
        return "--"
    }
    
    func app_stringFromDate_timeStamp() -> String{
        return "\(self.hourTwoDigit):\(self.minuteTwoDigit) \(self.AM_PM)  \(self.monthNameShort) \(self.dayTwoDigit)"
    }
    
    
    func getUTCFormateDate(localDate: NSDate) -> String {
        
        let dateFormatter:DateFormatter = DateFormatter()
        let timeZone: NSTimeZone = NSTimeZone(name: "UTC")!
        dateFormatter.timeZone = timeZone as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let dateString: String = dateFormatter.string(from: localDate as Date)
        return dateString
    }
    
    
    func combineDateWithTime(date: NSDate, time: NSDate) -> NSDate? {
        let calendar = NSCalendar.current
        
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date as Date)
        
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time as Date)
        
        
        let mergedComponments = NSDateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments as DateComponents) as NSDate?
    }
    
    func getDatesBetweenDates(startDate:NSDate, andEndDate endDate:NSDate) -> [NSDate] {
        let gregorian: NSCalendar = NSCalendar.current as NSCalendar;
        let components = gregorian.components(NSCalendar.Unit.day, from: startDate as Date, to: endDate as Date, options: [])
        var arrDates = [NSDate]()
        for i in 0...components.day!{
            arrDates.append(startDate.addingTimeInterval(60*60*24*Double(i)))
        }
        return arrDates
    }
    
    
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    
    // MARK:- TIME
    var timeWithAMPM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mma"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    
    // MARK:- YEAR
    
    
    var yearFourDigit_Int: Int {
        return Int(self.yearFourDigit)!
    }
    
    var yearOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y"
        return dateFormatter.string(from: self as Date)
    }
    var yearTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"
        return dateFormatter.string(from: self as Date)
    }
    var yearFourDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    // MARK:- MONTH
    
    var monthOneDigit_Int: Int {
        return Int(self.monthOneDigit)!
    }
    var monthTwoDigit_Int: Int {
        return Int(self.monthTwoDigit)!
    }
    
    
    var monthOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        return dateFormatter.string(from: self as Date)
    }
    var monthTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self as Date)
    }
    var monthNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMMM"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- DAY
    
    var dayOneDigit_Int: Int {
        return Int(self.dayOneDigit)!
    }
    var dayTwoDigit_Int: Int {
        return Int(self.dayTwoDigit)!
    }
    
    var dayOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: self as Date)
    }
    var dayTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameShort: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFull: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    var dayNameFirstLetter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    
    
    
    // MARK:- AM PM
    var AM_PM: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- HOUR
    
    
    var hourOneDigit_Int: Int {
        return Int(self.hourOneDigit)!
    }
    var hourTwoDigit_Int: Int {
        return Int(self.hourTwoDigit)!
    }
    var hourOneDigit24Hours_Int: Int {
        return Int(self.hourOneDigit24Hours)!
    }
    var hourTwoDigit24Hours_Int: Int {
        return Int(self.hourTwoDigit24Hours)!
    }
    var hourOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh"
        return dateFormatter.string(from: self as Date)
    }
    var hourOneDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H"
        return dateFormatter.string(from: self as Date)
    }
    var hourTwoDigit24Hours: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: self as Date)
    }
    
    // MARK:- MINUTE
    
    var minuteOneDigit_Int: Int {
        return Int(self.minuteOneDigit)!
    }
    var minuteTwoDigit_Int: Int {
        return Int(self.minuteTwoDigit)!
    }
    
    var minuteOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "m"
        return dateFormatter.string(from: self as Date)
    }
    var minuteTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: self as Date)
    }
    
    
    // MARK:- SECOND
    
    var secondOneDigit_Int: Int {
        return Int(self.secondOneDigit)!
    }
    var secondTwoDigit_Int: Int {
        return Int(self.secondTwoDigit)!
    }
    
    var secondOneDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "s"
        return dateFormatter.string(from: self as Date)
    }
    var secondTwoDigit: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: self as Date)
    }
}
extension Date {
    func time(since fromDate: Date) -> String {
        let earliest = self < fromDate ? self : fromDate
        let latest = (earliest == self) ? fromDate : self
        
        let allComponents: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let components:DateComponents = Calendar.current.dateComponents(allComponents, from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0
        
        let descendingComponents = ["year": year, "month": month, "week": week, "day": day, "hour": hour, "minute": minute, "second": second]
        for (period, timeAgo) in descendingComponents {
            if timeAgo > 0 {
                return "\(timeAgo.of(period)) ago"
            }
        }
        
        return "Just now"
    }
}

extension Int {
    func of(_ name: String) -> String {
        guard self != 1 else { return "\(self) \(name)" }
        return "\(self) \(name)s"
    }
}

import Foundation
import CoreLocation

extension Date {
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func dateAndTimetoString(format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func timeIn24HourFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func startOfMonth() -> Date {
        var components = Calendar.current.dateComponents([.year,.month], from: self)
        components.day = 1
        let firstDateOfMonth: Date = Calendar.current.date(from: components)!
        return firstDateOfMonth
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func nextDate() -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: self)
        return nextDate ?? Date()
    }
    
    func previousDate() -> Date {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: self)
        return previousDate ?? Date()
    }
    
    func addMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeMonths(numberOfMonths: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .month, value: -numberOfMonths, to: self)
        return endDate ?? Date()
    }
    
    func removeYears(numberOfYears: Int) -> Date {
        let endDate = Calendar.current.date(byAdding: .year, value: -numberOfYears, to: self)
        return endDate ?? Date()
    }
    
    func getHumanReadableDayString() -> String {
        let weekdays = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
        
        let calendar = Calendar.current.component(.weekday, from: self)
        return weekdays[calendar - 1]
    }
    
    
    func timeSinceDate(fromDate: Date) -> String {
        let earliest = self < fromDate ? self  : fromDate
        let latest = (earliest == self) ? fromDate : self
        
        let components:DateComponents = Calendar.current.dateComponents([.minute,.hour,.day,.weekOfYear,.month,.year,.second], from: earliest, to: latest)
        let year = components.year  ?? 0
        let month = components.month  ?? 0
        let week = components.weekOfYear  ?? 0
        let day = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let seconds = components.second ?? 0
        
        
        if year >= 2{
            return "\(year) years ago"
        }else if (year >= 1){
            return "1 year ago"
        }else if (month >= 2) {
            return "\(month) months ago"
        }else if (month >= 1) {
            return "1 month ago"
        }else  if (week >= 2) {
            return "\(week) weeks ago"
        } else if (week >= 1){
            return "1 week ago"
        } else if (day >= 2) {
            return "\(day) days ago"
        } else if (day >= 1){
            return "1 day ago"
        } else if (hours >= 2) {
            return "\(hours) hours ago"
        } else if (hours >= 1){
            return "1 hour ago"
        } else if (minutes >= 2) {
            return "\(minutes) minutes ago"
        } else if (minutes >= 1){
            return "1 minute ago"
        } else if (seconds >= 3) {
            return "\(seconds) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
