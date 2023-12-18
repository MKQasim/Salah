//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import CoreLocation

struct MainNavigationView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState: LocationState
    @Environment (\.horizontalSizeClass) private var horizontalSize
    
    var body: some View {
        Group{
            switch horizontalSize{
            case .compact:
                NavigationStack{
                    TabbarView()
#if !os(macOS)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
#endif
                        .background(
                            AngularGradient(colors: [.journal,.journal2], center: .bottomTrailing)
                        )
                }
            case .regular:
                NavigationSplitDetailView()
            case .none:
                NavigationSplitDetailView()
            default:
                Text("Regular")
            }
        }
        .onAppear{
            location()
            switch locationManager.locationStatus{
            case .authorizedWhenInUse,.authorizedAlways:
                location()
#if !os(watchOS)
            case .authorized:
                location()
#endif
            default:
                location()
            }
        }
    }
    
    func location(){
        locationManager.requestLocation()
        locationState.defaultLatitude = locationManager.lastLocation?.coordinate.latitude ?? 0.0
        locationState.defaultLongitude = locationManager.lastLocation?.coordinate.longitude ?? 0.0
            
        locationManager.lastLocation?.placemark { placemark, error in
                guard let placemark = placemark else {
                    print("Error:", error ?? "nil")
                    return
                }
                locationState.defaultCityName = placemark.city ?? ""
            }
            locationState.isLocation = true
        
        
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}
