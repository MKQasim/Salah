//
//  ContentView.swift
//  Salah
//
//  Created by Qassim on 12/6/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationState = LocationState()
    @StateObject var navigationState = NavigationState()
    @StateObject var locationManager = LocationManager()
    @StateObject var notificationManager = NotificationManager()
    
    @State private var prayerTimes:[String] = []
    var body: some View {
        MainNavigationView()
            .environmentObject(locationManager)
            .environmentObject(notificationManager)
            .environmentObject(locationState)
            .environmentObject(navigationState)
        
    }
    
   
}

#Preview {
    ContentView()
}
