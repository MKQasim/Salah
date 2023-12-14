//
//  NavigationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/11/23.
//

import Foundation

class NavigationState:ObservableObject{
    @Published var tabbarSelection:NavigationItem = .currentLocation
    @Published var sidebarSelection: NavigationItem?
}
