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
                    print("")
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
            var offset = 0.0
            lastLocation.placemark { placemark, error in
                    guard let placemark = placemark else {
                        print("Error:", error ?? "nil")
                        return
                    }
                if let secondsFromGMT = Double(placemark.timeZone?.secondsFromGMT() ?? 0) as? Double {
                    offset = secondsFromGMT / 3600
                }
                var location = Location(city: placemark.city, lat: placemark.location?.coordinate.latitude, lng: placemark.location?.coordinate.longitude, country: placemark.country, dateTime: Date(), offSet: offset, timeZone: placemark.timeZone, todayPrayerTimings:[])
                locationState.currentLocation = location
                locationState.isLocation = true
                }
                
        }
    }
    
   
}

#Preview {
    ContentView()
}
