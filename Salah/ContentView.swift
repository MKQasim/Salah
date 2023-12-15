//
//  ContentView.swift
//  Salah
//
//  Created by Qassim on 12/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var locationState = LocationState()
    @StateObject var navigationState = NavigationState()
    @StateObject var locationManager = LocationManager()
    @StateObject var notificationManager = NotificationManager()
    
    @State private var prayerTimes:[String] = []
    var body: some View {
        MainNavigationView() 
//        PermissionBoard()
        .environmentObject(locationManager)
        .environmentObject(notificationManager)
        .environmentObject(locationState)
        .environmentObject(navigationState)
        .onAppear{
            notificationManager.getNotificationSetting()
            locationManager.requestLocation()
            switch locationManager.locationStatus{
            case .authorizedWhenInUse,.authorizedAlways:
                location()
                #if !os(watchOS)
            case .authorized:
                location()
                #endif
            default:
                locationState.isLocation = true
            }
        }
    }
    
    func location(){
        locationManager.requestLocation()
        guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
        locationState.defaultLatitude = userCoordinates.latitude
        locationState.defaultLongitude = userCoordinates.longitude
        locationState.isLocation = true
    }
}

#Preview {
    ContentView()
}
