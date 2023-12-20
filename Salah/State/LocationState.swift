//
//  LocationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation

class LocationState: ObservableObject {
    @Published var currentLocation:Location?
    @Published var isLocation = false
    @Published var cities:[Cities] = []
}
