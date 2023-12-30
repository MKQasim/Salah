//
//  Location.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import Foundation

// MARK: - Location

struct Location: Codable, Identifiable, Hashable {
    var city: String?
    var lat, lng: Double?
    var country: String?
    var id: Int?
    var dateTime: Date?
    var offSet: Double? // Updated property for timezone
    var timeZone : String?
    var todayPrayerTimings : [PrayerTiming]?
    var tomorrowPrayerTimings : [PrayerTiming]?
    var todaySunTimings : [PrayerTiming]?
    var tomorrowSunTimings : [PrayerTiming]?
    var nextPrayer : PrayerTiming?
    var remainingTime : String?
    var timeDifference : Double?
    var targetTime : Date?
    
    enum CodingKeys: String, CodingKey {
        case city
        case lat, lng
        case country
        case id
        case dateTime
        case offSet
        case timeZone // Added timezone property in CodingKeys
        case todayPrayerTimings
        case tomorrowPrayerTimings
        case nextPrayer
        case remainingTime
        case timeDifference
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
           return lhs.city == rhs.city &&
               lhs.lat == rhs.lat &&
               lhs.lng == rhs.lng &&
               lhs.country == rhs.country &&
               lhs.id == rhs.id &&
               lhs.dateTime == rhs.dateTime &&
               lhs.offSet == rhs.offSet &&
               lhs.timeZone == rhs.timeZone &&
               lhs.remainingTime == rhs.remainingTime &&
               lhs.timeDifference == rhs.timeDifference &&
               lhs.targetTime == rhs.targetTime
       }
}

typealias LocationDetails = [Location]
