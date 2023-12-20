//
//  Cities.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import Foundation

struct Cities: Identifiable, Hashable {
    var id = UUID()
    let city: String
    let lat: Double
    let long: Double
    let offSet: Double
}
