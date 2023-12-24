//
//  PrayerTiming.swift
//  Salah
//
//  Created by Haaris Iqubal on 15.12.23.
//

import Foundation

struct PrayerTiming: Identifiable, Hashable , Codable {
    var id = UUID()
    let name: String
    let time: String
}
