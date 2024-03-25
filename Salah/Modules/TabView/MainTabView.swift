//
//  MainTabView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation

enum Tab: String {
    case locationList = "locationList"
    case locationDetails = "locationDetails"
}

class TabViewModel: ObservableObject {
    @Published var isListMode: Bool = true
    @Published var tapIcon: String = "list.bullet.circle"
    @Published var tapTitle: String = ""
    
    func toggleListMode() {
        isListMode.toggle()
    }
}

