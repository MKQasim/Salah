//
//  PrayerPlace.swift
//  Salah
//
//  Created by Muhammad's on 02.03.24.
//

import Foundation
import SwiftData

@Model
final class PrayerPlace: Identifiable, Codable {
    var id: Int?
    var lat: Double?
    var lng: Double?
    var city: String?
    var country: String?
    var timeZoneIdentifier: String?
    
    init(id: Int, lat: Double, lng: Double, city: String, country: String, timeZoneIdentifier: String) {
        self.id = id
        self.lat = lat
        self.lng = lng
        self.city = city
        self.country = country
        self.timeZoneIdentifier = timeZoneIdentifier
    }
    
    enum CodingKeys: String, CodingKey {
        case id, lat, lng, city, country, timeZoneIdentifier
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.lng = try container.decode(Double.self, forKey: .lng)
        self.city = try container.decode(String.self, forKey: .city)
        self.country = try container.decode(String.self, forKey: .country)
        self.timeZoneIdentifier = try container.decode(String.self, forKey: .timeZoneIdentifier)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
        try container.encode(city, forKey: .city)
        try container.encode(country, forKey: .country)
        try container.encode(timeZoneIdentifier, forKey: .timeZoneIdentifier)
    }
}

