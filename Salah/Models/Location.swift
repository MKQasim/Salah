//
//  Location.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import Foundation

// MARK: - PostElement
struct Location: Codable, Identifiable, Hashable {
    var city : String?
    var lat, lng: Double?
    var country: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case city
        case lat,lng
        case country
        case id
    }
    
}

typealias LocationDetails = [Location]

