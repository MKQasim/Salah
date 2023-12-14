//
//  NavigationItem.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/11/23.
//

import Foundation
import SwiftUI

enum NavigationItem: Hashable{
    case currentLocation
    case nocurrentLocation
    case city(Cities)
    
    var localizedName:LocalizedStringKey{
        switch self {
        case .currentLocation:
            return "Current Location"
        case .city(_):
            return "City"
        case .nocurrentLocation:
            return "No Current Location"
        }
    }
}
