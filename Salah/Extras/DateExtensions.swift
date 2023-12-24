//
//  DateExtensions.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import Foundation

extension Date {
    func timeRemainingString(to date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self, to: date)
        
        guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return "Expired"
        }
        
        if hours > 0 {
            return String(format: "%02f:%02f:%02f", hours, minutes, seconds)
        } else {
            return String(format: "%02f:%02f", minutes, seconds)
        }
    }
    
    func dateByAdding(hours: Int, minutes: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        
        return calendar.date(byAdding: dateComponents, to: self)
    }
    
//    func dateByAdding(timeZoneOffset: Double) -> Date? {
//        let hours = Int(timeZoneOffset)
//        let minutes = Int((timeZoneOffset - Double(hours)) * 60)
//        return dateByAdding(hours: hours, minutes: minutes)
//    }
    
    func adjusted(byHours hours: Int, minutes: Int, seconds: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
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
    
    func getCurrentDateTime(for country: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: country)
        
        let dateString = formatter.string(from: Date())
        return formatter.date(from: dateString)
    }

}

