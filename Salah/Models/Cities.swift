//
//  Cities.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import Foundation

// MARK: - LocationElement
struct Cities: Codable , Identifiable , Hashable {
    let city, cityASCII: String?
    let lat, lng: Double?
    let country: String?
    let id: Int?
    let timeZone: String?

    enum CodingKeys: String, CodingKey {
        case city
        case cityASCII = "city_ascii"
        case lat, lng, country, id, timeZone
    }
}

typealias Locations = [Cities]
