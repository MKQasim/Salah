//
//  LocationState.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/8/23.
//

import Foundation

class LocationState: ObservableObject {
    @Published var latitude = 49.441834
    @Published var longitude = 11.025047
    @Published var isLocation = false
}
