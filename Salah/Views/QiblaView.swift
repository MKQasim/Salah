//
//  QiblaView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

// MARK: - QiblaView
struct QiblaView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    var body: some View {
        // Details view
        ScrollView {
            VStack {
                Text("Qibla At \(viewModel.selectedItem?.city ?? "") , \(viewModel.selectedItem?.timeZoneIdentifier ?? "")")
                    .padding()
                    .font(.subheadline)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .background(
                        LinearGradient(gradient: Gradient(colors: [.gray, .blue]),
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(radius: 10)
                    .cornerRadius(10)
                    .onTapGesture {
                        print("Location tapped")
                    }
                if let location = viewModel.selectedItem as? PrayerPlace {
                    CompassView(currentLocation: (location.city ?? "", CLLocationCoordinate2D(latitude: location.lat ?? 0.0, longitude: location.lng ?? 0.0)))
                }
            }
        }
        .onAppear {
            print(viewModel.selectedItem?.timeZoneIdentifier)
        }
        .id(viewModel.selectedItem)
        .navigationTitle("Qibla View")
    }
}


import SwiftUI
import CoreMotion


struct CompassView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    var currentLocation: (String, CLLocationCoordinate2D)
    @ObservedObject var locationManager = LocationManager.shared
    var body: some View {
        VStack {
            Text(currentLocation.0) // This will display the name of the location
                .font(.title)
                .padding()
            // Add a status Text view
            Text(getStatusText())
                .font(.title)
                .foregroundColor(getStatusColor())
                .padding()
            ZStack {
                Image("compass") // Your compass background image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees:360 - locationManager.heading), anchor: .center)
                    .colorMultiply(getStatusColor()) // Apply color to the compass image
                
                Image("qibla") // Your compass needle image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees:  currentLocation.1.direction(to: locationManager.targetLocation ) - (locationManager.heading ) ))
                    .animation(.easeInOut, value: 0.5)
                    .colorMultiply(getStatusColor()) // Apply color to the qibla image
            }
        }
        .onAppear {
            locationManager.startLocationUpdates()
            locationManager.startHeadingUpdates()
        }
        .onDisappear {
            locationManager.stopLocationUpdates()
            locationManager.stopHeadingUpdates()
        }
    }
    
    // Function to determine status text
    func getStatusText() -> String {
        let direction = currentLocation.1.direction(to: locationManager.targetLocation) - locationManager.heading
        if direction >= 0 && direction <= 1 {
            return "You are heading to the Kibla"
        } else if direction < 30 {
            return "You are slightly off, adjust your direction for Kibla"
        } else {
            return "You need to update your direction"
        }
    }
    
    // Function to determine status color
    func getStatusColor() -> Color {
        let direction = currentLocation.1.direction(to: locationManager.targetLocation) - locationManager.heading
        if direction >= 0 && direction <= 1 {
            return .green
        } else if direction < 30 {
            return .orange
        } else {
            return .red
        }
    }
}

