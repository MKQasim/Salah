//
//  LocationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation

class LocationState: ObservableObject {
    @Published var defaultLatitude = 49.441834
    @Published var defaultLongitude = 11.025047
    @Published var defaultTimeZone = +1.0
    @Published var isLocation = false
    @Published var cities:[Cities] = []
}
