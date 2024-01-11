//
//  NavigationItem.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/11/23.
//

import Foundation
import SwiftUI

enum NavigationItem: Hashable {
    case currentLocation
    case nocurrentLocation
    case location(Location)
    case qiblaDirection // Add qiblaDirection case here

    var localizedName: LocalizedStringKey {
        switch self {
        case .currentLocation:
            return LocalizedStringKey("Current Location")
        case .location(let selectedLocation):
            if let city = selectedLocation.city {
                return LocalizedStringKey(city)
            } else {
                return LocalizedStringKey("Unknown City")
            }
        case .nocurrentLocation:
            return LocalizedStringKey("No Current Location")
        case .qiblaDirection: // Handle localization for qiblaDirection if needed
            return LocalizedStringKey("Qibla Direction")
        }
    }
}
