//
//  LocationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation

class LocationState: ObservableObject {
    @Published var defaultLatitude = 25.5941
    @Published var defaultLongitude = 85.1376
    @Published var defaultTimeZone = +5.5
    @Published var defaultCityName = "Nuremberg"
    @Published var isLocation = false
    @Published var cities:[Cities] = []
}
