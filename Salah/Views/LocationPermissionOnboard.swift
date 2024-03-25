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

class ContentViewModels: ObservableObject {
    @Published var locationManager = LocationManagers()
}




class LocationManagers: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManagers() // Shared singleton instance
       
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var isLocationEnabled: Bool = false
   
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            // Handle case where location services are not enabled
            print("Location services are not enabled.")
            return
        }
        
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            DispatchQueue.main.async { [weak self] in
                self?.manager.startUpdatingLocation()
            }
        case .notDetermined:
            // Request authorization if not determined
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            // Handle case where authorization is denied or restricted
            print("Location authorization denied or restricted.")
        @unknown default:
            fatalError("Unhandled case.")
        }
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print(location.coordinate.latitude)
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        isLocationEnabled = status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

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

struct LocationTest: View {
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var cityName: String = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching Location...")
            } else {
                Text("City: \(cityName)")
                    .padding()
                
                Text("Current Location: \(viewModel.permissionManager.locationManager?.lastLocation?.coordinate.latitude ?? 0), \(viewModel.permissionManager.locationManager?.lastLocation?.coordinate.longitude ?? 0)")
                    .padding()
                
                Button(action: {
                    viewModel.permissionManager.locationManager?.requestLocationPermission()
//                    viewModel.locationManager.requestLocationAuthorization()
                }) {
                    Text("Request Location Authorization")
                }
                .padding()
                
                Button(action: {
                    isLoading = true
                    viewModel.permissionManager.locationManager?.checkLocationPermission { result in
                        isLoading = false
                        switch result {
                        case .success(let (isEnabled, prayerPlace)):
                            cityName = prayerPlace?.city ?? ""
                        case .failure(let error):
                            print("Failed to get location details: \(error.localizedDescription)")
                        }
                    }
                }) {
                    Text("Get Location Details")
                }
                .padding()
                
                Button(action: {
                    viewModel.permissionManager.locationManager?.stopLocationUpdates()
                }) {
                    Text("Start Updating Location")
                }
                .padding()
                
                Button(action: {
                    viewModel.permissionManager.locationManager?.stopLocationUpdates()
                }) {
                    Text("Stop Updating Location")
                }
                .padding()
            }
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
            .fullScreenCover(isPresented: $navigateToContentView) {
                ContentView()
                    .edgesIgnoringSafeArea(.all)
            }
            .onAppear(perform: onAppear)
            .onChange(of: viewModel.permissionManager.locationManager?.lastLocation, perform: onLocationChange)
            .onChange(of: navigateToContentView, perform: onNavigateToContentViewChange)
            .sheet(isPresented: $isChoosingCity) {
                ChooseCityView(onDismiss: onChooseCityViewDismiss)
            }
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
