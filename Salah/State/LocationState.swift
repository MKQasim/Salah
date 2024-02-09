//
//  LocationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation

class LocationState: ObservableObject {
    @Published var currentLocation: Location?
    @Published var isLocation = false
    @Published var cities: [Location] = []

    func updateCities(with newLocation: Location) {
        // Check if the city is already in the list
        if !cities.contains(where: { $0.city == newLocation.city }) {
            // If the city is not in the list, add it
            cities.append(newLocation)
        }
        
        // If the current location is set, move it to the first position
        if let currentLocation = currentLocation,
           let index = cities.firstIndex(where: { $0.city == currentLocation.city }) {
            let current = cities.remove(at: index)
            cities.insert(current, at: 0)
        }
    }
}

