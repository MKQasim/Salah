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
    var timezone: Double? // Updated property for timezone

    enum CodingKeys: String, CodingKey {
        case city
        case lat, lng
        case country
        case id
        case dateTime
        case timezone // Added timezone property in CodingKeys
    }
}

typealias LocationDetails = [Location]
