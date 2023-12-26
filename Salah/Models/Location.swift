//
//  Location.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import Foundation

// MARK: - PostElement

struct Location: Codable, Identifiable, Hashable {
    var city: String?
    var lat, lng: Double?
    var country: String?
    var id: Int?
    var dateTime: Date?
    var offSet: Double? // Updated property for timezone
    var timeZone : TimeZone?
    var prayerTimings : [PrayerTiming]?
    var nextPrayer : PrayerTiming?
    var remainingTime : String?
    var timeDifference : Double?
    enum CodingKeys: String, CodingKey {
        case city
        case lat, lng
        case country
        case id
        case dateTime
        case offSet
        case timeZone // Added timezone property in CodingKeys
        case prayerTimings
        case nextPrayer
        case remainingTime
        case timeDifference
    }
}

typealias LocationDetails = [Location]
