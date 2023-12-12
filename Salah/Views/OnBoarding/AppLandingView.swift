//
//  AppLandingView.swift
//  Salah
//
//  Created by Qassim on 12/9/23.
//

import SwiftUI

public struct AppLandingView: View {
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var animationAmount = 1.0
    
    public var body: some View {
        NavigationStack{
            VStack{
                VStack{
                    Text("Start with new journey of Salah Tracking")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .multilineTextAlignment(.center)
                    Text("We do not share your location to any third parties servers and really care for your privacy.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom,20)
                Spacer()
                Image(systemName: "paperplane.circle.fill")
                    .foregroundColor(.blue)
                    .font(.largeTitle)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 3),
                        value: animationAmount
                    )
                    .padding(.bottom,20)
                Spacer()
                switch locationManager.locationStatus {
                case .denied:
                    EmptyView()
                case .authorizedAlways, .authorizedWhenInUse:
                    Button(action: locationCheck, label: {
                        Text("Get current location")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                    #if !os(watchOS)
                case .authorized:
                    Button(action: locationCheck, label: {
                        Text("Get current location")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                    #endif
                default:
                    Button(action: {
                        locationManager.requestLocation()
                    }, label: {
                        Text("Allow location permission")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(.gray)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.bottom,8)
                }
            }
            .padding()
        }
        .onAppear{
            animationAmount += 2
        }
    }
    
    func locationCheck() {
        switch locationManager.locationStatus {
        case .notDetermined, .restricted, .denied:
            locationState.isLocation = true
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
            locationState.defaultLatitude = userCoordinates.latitude
            locationState.defaultLongitude = userCoordinates.longitude
            locationState.defaultTimeZone = +1.0
            locationState.isLocation = true
            #if !os(watchOS)
        case .authorized:
            locationManager.requestLocation()
            guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
            locationState.defaultLatitude = userCoordinates.latitude
            locationState.defaultLongitude = userCoordinates.longitude
            locationState.defaultTimeZone = +1.0
            locationState.isLocation = true
            #endif
        default:
            locationState.isLocation = true
        }
    }
}

#Preview {
    AppLandingView()
        .environmentObject(LocationState())
        .environmentObject(LocationManager())
}
