//
//  ContentView.swift
//  Salah
//
//  Created by Qassim on 12/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationState = LocationState()
    @StateObject private var locationManger = LocationManager()
    @State private var prayerTimes:[String] = []
    var body: some View {
        Group{
            if !locationState.isLocation {
                MainNavigationView()
//                AppLandingView()
            }else{
                MainNavigationView()
            }
        }
        .environmentObject(locationManger)
        .environmentObject(locationState)
    }
}

#Preview {
    ContentView()
}
