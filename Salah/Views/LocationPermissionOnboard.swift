//
//  LocationPermissionOnboard.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
#if os(iOS)
import CoreLocationUI
import CoreLocation
#endif

import Foundation
import CoreLocation

extension LocationManager {
    func getLocationDetails(completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let location = lastLocation else {
            completion(.failure(NSError(domain: "Location not available", code: 0, userInfo: nil)))
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first,
                  let city = placemark.locality,
                  let country = placemark.country else {
                completion(.failure(NSError(domain: "Location details not found", code: 1, userInfo: nil)))
                return
            }
            
            completion(.success((city, country)))
        }
    }
}

// MARK: - LocationPermissionOnboard View
struct LocationPermissionOnboard: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @State private var animationAmount = 1.0
    @State private var isChoosingCity = false
    @State private var navigateToContentView = false
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            VStack {
                welcomeText
                Spacer()
                animatedImage
                Spacer()
                locationButton
                chooseCityButton
            }
            .padding()
#if os(iOS)
            .fullScreenCover(isPresented: $navigateToContentView) {
                ContentView()
                    .edgesIgnoringSafeArea(.all)
            }
#endif
            .onAppear(perform: onAppear)
            .onChange(of: viewModel.permissionManager.locationManager?.lastLocation, perform: onLocationChange)
            .onChange(of: navigateToContentView, perform: onNavigateToContentViewChange)
            .sheet(isPresented: $isChoosingCity) {
                ChooseCityView(onDismiss: onChooseCityViewDismiss)
            }
#if os(macOS)
            .sheet(isPresented: $navigateToContentView) {
                ContentView()
                    .edgesIgnoringSafeArea(.all)
            }
#endif
        }
    }
    
    // MARK: - Subviews
    private var welcomeText: some View {
        VStack {
            Text("Start with a new journey of Salah Tracking")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
            Text("We do not share your location with any third-party servers and really care about your privacy.")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }
    
    private var animatedImage: some View {
        Image(systemName: "paperplane.circle.fill")
            .foregroundColor(.blue)
            .font(.largeTitle)
            .scaleEffect(animationAmount)
            .animation(
                .easeInOut(duration: 3),
                value: animationAmount
            )
            .padding(.bottom, 20)
    }
    
    private var locationButton: some View {
        switch viewModel.permissionManager.locationManager?.locationStatus {
        case .denied:
            return AnyView(Button(action: {}) {
                EmptyView()
            }.disabled(true))
        case .authorizedAlways, .authorizedWhenInUse:
            return AnyView(Button(action: locationCheck) {
                Text("Get current location")
            }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.bottom, 8))
        default:
            return AnyView(Button(action: requestLocationPermission) {
                Text("Allow location permission")
            }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.bottom, 8))
        }
    }
    
    
    private var chooseCityButton: some View {
        Button(action: { isChoosingCity = true }) {
            Text("Don't want to share location")
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Actions
    private func onAppear() {
        
        
        animationAmount += 2
        
        // Check if onboarding is completed
        if UserDefaults.standard.bool(forKey: "OnboardingCompleted") {
            // If onboarding is completed, navigate directly to ContentView
            navigateToContentView = true
        }
    }
    
    private func onLocationChange(_ newValue: CLLocation?) {
        print(newValue)
    }
    
    private func onNavigateToContentViewChange(_ newValue: Bool) {
        if newValue {
            // Set flag to indicate onboarding is completed
            UserDefaults.standard.set(true, forKey: "OnboardingCompleted")
        }
    }
    
    private func onChooseCityViewDismiss() {
        // After dismissing ChooseCityView, navigate to ContentView
        navigateToContentView = true
    }
    
    private func locationCheck() {
        switch viewModel.permissionManager.locationManager?.locationStatus {
        case .notDetermined, .restricted, .denied:
            viewModel.isLocation = false
        case .authorizedAlways, .authorizedWhenInUse:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                navigateToContentView = true
            }
            viewModel.isLocation = true
        default:
            viewModel.isLocation = false
        }
    }
    
    private func requestLocationPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewModel.permissionManager.locationManager?.requestLocation()
            navigateToContentView = true
        }
    }
}

#Preview {
    LocationPermissionOnboard()
        .environmentObject(LocationManager.shared)
}
