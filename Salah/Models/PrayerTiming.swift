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
    
    enum CodingKeys: String, CodingKey {
        case id, name, time
    }
    
    init(name: String?, time: Date?) {
        self.name = name
        self.time = time
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
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
            let timeString = PrayerTiming.formatDate(timeToEncode)
            try container.encode(timeString, forKey: .time)
        } else {
            // Encode a placeholder value (for example, an empty string)
            try container.encode("", forKey: .time)
        }
    }

    
    static func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // Replace with your desired date format
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Set UTC timezone
        return dateFormatter.string(from: date)
    }
    
    // Your other code...
}
