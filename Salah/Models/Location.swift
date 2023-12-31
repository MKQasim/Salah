//
//  Location.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import Foundation

struct Location: Codable, Identifiable, Hashable {
    var city: String?
    var lat, lng: Double?
    var country: String?
    var id: Int?
    var dateTime: Date?
    var offSet: Double?
    var timeZone: String?
    var todayPrayerTimings: [PrayerTiming]?
    var tomorrowPrayerTimings: [PrayerTiming]?
    var todaySunTimings: [PrayerTiming]?
    var tomorrowSunTimings: [PrayerTiming]?
    var nextPrayer: PrayerTiming?
    var remainingTime: String?
    var timeDifference: Double?
    var targetTime: Date?
    
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
    
    func hash(into hasher: inout Hasher) {
        var hasher = hasher
        hasher.combine(city)
        hasher.combine(lat)
        hasher.combine(lng)
        hasher.combine(country)
        hasher.combine(id)
        hasher.combine(dateTime)
        hasher.combine(offSet)
        hasher.combine(timeZone)
        hasher.combine(remainingTime)
        hasher.combine(timeDifference)
        hasher.combine(targetTime)
    }
}

