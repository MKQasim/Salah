//
//  PrayerTiming.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import Foundation


struct PrayerTiming: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String?
    var time: Date? // Updated property type to Date
    var offSet : Double?
    
    enum CodingKeys: String, CodingKey {
        case id, name, time , offSet
    }
    
    init(name: String?, time: Date? , offSet: Double? = 0.0) {
        self.name = name
        self.time = time
        self.offSet = offSet
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.offSet = try container.decode(Double.self, forKey: .offSet)
        // Initialize time as nil
        self.time = nil
        
        // Decode the time string to a Date
        let timeString = try container.decode(String.self, forKey: .time)
        if let date = getDateForTime(timeString) {
            self.time = date // Assign the obtained date to self.time
        } else {
            throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "Date string cannot be decoded.")
        }
    }

    
    func getDateForTime(_ time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set UTC timezone
        
        if let timeDate = dateFormatter.date(from: time) {
            let currentDate = Date()
            let calendar = Calendar.current
            
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
        }
        return nil
    }
    
    // Add an encoding method if needed
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        // Check if 'time' is nil; if not, encode it; otherwise, encode a placeholder value
        if let timeToEncode = time {
            let timeString = formatDate(timeToEncode) as? String
            try container.encode(timeString, forKey: .time)
        } else {
            // Encode a placeholder value (for example, an empty string)
            try container.encode("", forKey: .time)
        }
    }
    
    func formatDateString(_ date: Date, calendarIdentifier: Calendar.Identifier? = nil, localeIdentifier: String? = nil, timeZoneOffsetHours: Double? = nil) -> String {
        let dateFormatter = DateFormatter()
        
        if let calendarIdentifier = calendarIdentifier {
            dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
            dateFormatter.dateFormat = "dd MMMM yyyy HH:mm" // Islamic calendar format
        } else {
            // Default to Gregorian calendar if no specific calendar is provided
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "HH:mm" // Default format
        }
        
        if let localeIdentifier = localeIdentifier {
            dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Setting the time zone to GMT
        
        return dateFormatter.string(from: date)
    }


    func formatDate(_ date: Date, calendarIdentifier: Calendar.Identifier? = nil, localeIdentifier: String? = nil, timeZoneOffsetHours: Double? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        
        if let calendarIdentifier = calendarIdentifier {
            dateFormatter.calendar = Calendar(identifier: calendarIdentifier)
            dateFormatter.dateFormat = "dd MMMM yyyy HH:mm" // Islamic calendar format
        } else {
            // Default to Gregorian calendar if no specific calendar is provided
            dateFormatter.calendar = Calendar(identifier: .gregorian)
            dateFormatter.dateFormat = "HH:mm" // Default format
        }
        
        if let localeIdentifier = localeIdentifier {
            dateFormatter.locale = Locale(identifier: localeIdentifier)
        }
        
        var modifiedDate = date // Start with the original date
        
        if let timeZoneOffsetHours = timeZoneOffsetHours {
            let offsetSeconds = timeZoneOffsetHours * 3600 // Convert hours to seconds
            modifiedDate = date.addingTimeInterval(offsetSeconds) // Apply the offset to the date
        }
        
        let dateString = dateFormatter.string(from: modifiedDate)
        return dateFormatter.date(from: dateString)
    }
    
    func updatedDateFormatAndTimeZone(for date: Date, withTimeZoneOffset offset: Double, calendarIdentifier: Calendar.Identifier) -> (date: Date, formattedString: String)? {
        if let timeZone = TimeZone(secondsFromGMT: Int(offset * 3600)) {
            var calendar = Calendar(identifier: calendarIdentifier)
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = calendar
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = timeZone
            let formattedString = dateFormatter.string(from: date)
            return (date: date, formattedString: formattedString)
        } else {
            print("Invalid offset provided.")
            return nil
        }
    }
    
    func updatedDateFormatAndTimeZoneString(for date: Date, withTimeZoneOffset offset: Double, calendarIdentifier: Calendar.Identifier) -> (date: Date, formattedString: String)? {
        if let timeZone = TimeZone(secondsFromGMT: Int(offset * 3600)) {
            var calendar = Calendar(identifier: calendarIdentifier)
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = calendar
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.timeZone = timeZone
            let formattedString = dateFormatter.string(from: date)
            guard let formattedDate = dateFormatter.date(from: formattedString) else {return nil}
            return (date: formattedDate, formattedString: formattedString)
        } else {
            print("Invalid offset provided.")
            return nil
        }
    }

}
