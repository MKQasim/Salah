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
    @ObservedObject var locationManager = LocationManager()
    @StateObject var notificationManager = NotificationManager()
    @State private var prayerTimes:[String] = []
    
    var body: some View {
        MainNavigationView()
            .onAppear{
                switch locationManager.locationStatus{
                case .authorizedWhenInUse,.authorizedAlways:
                    location()
    #if !os(watchOS)
                case .authorized:
                    location()
    #endif
                default:
                    print("Not det")
                }
            }
            .environmentObject(locationManager)
            .environmentObject(notificationManager)
            .environmentObject(locationState)
            .environmentObject(navigationState)
        
    }
    
    func location(){
        locationManager.requestLocation()
        if let lastLocation = locationManager.lastLocation {
            var location = Location()
            lastLocation.placemark { placemark, error in
                    guard let placemark = placemark else {
                        print("Error:", error ?? "nil")
                        return
                    }
                if let secondsFromGMT = Double(placemark.timeZone?.secondsFromGMT() ?? 0) as? Double {
                    location.offSet = secondsFromGMT / 3600
                }
                location.lat = lastLocation.coordinate.latitude
                location.lng = lastLocation.coordinate.longitude
                location.city = placemark.locality
                location.country = placemark.country
                location.dateTime = Date()
                location.timeZone = placemark.timeZone
                locationState.currentLocation = location
                locationState.isLocation = true
                }
                
        }
    }
    
   
}

#Preview {
    ContentView()
}
