//
//  QiblaView.swift
//  Salah
//
//  Created by Qassim on 1/9/24.
//
import SwiftUI
import CoreMotion


struct CompassView: View {
    @ObservedObject var locationManager: LocationManager
    var currentLocation: (String, CLLocationCoordinate2D)

    var body: some View {
        VStack {
            Text(currentLocation.0) // This will display the name of the location
                .font(.title)
                .padding()

            ZStack {
                Image("compass") // Your compass background image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees: 360 - locationManager.heading))

                Image("qibla") // Your compass needle image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees: currentLocation.1.direction(to: locationManager.targetLocation) - locationManager.heading))
                    .animation(.easeInOut(duration: 0.5)) // Add this line
            }
        }
        .onAppear {
            locationManager.isCompassViewVisible = true
        }
        .onDisappear {
            locationManager.isCompassViewVisible = false
            locationManager.stopHeadingUpdates() // Add this line
        }
    }
}

struct QiblaView: View {
    @EnvironmentObject var locationState: LocationState
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach($locationState.cities, id: \.self) { location in
                    if let location = location.wrappedValue as? Location {
                        CompassView(locationManager: locationManager, currentLocation: (location.city ?? "", CLLocationCoordinate2D(latitude: location.lat ?? 0.0, longitude: location.lng ?? 0.0)))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Qibla Directions")
    }
}


