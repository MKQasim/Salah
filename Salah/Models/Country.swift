//
//  Country.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation


// MARK: - PostElement
struct Country: Codable, Identifiable, Hashable {
    var country: String
    var id:Int

    enum CodingKeys: String, CodingKey {
        case country
        case id
    }
}
