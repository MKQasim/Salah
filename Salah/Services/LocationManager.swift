//
//  LocationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation? = nil
    @Published var userLocation = CLLocationCoordinate2D()
    @Published var locations: [(String, CLLocationCoordinate2D)] = [
           ("Berlin", CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)),
           ("New York", CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)),
           ("London", CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)),
           ("Paris", CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)),
           ("Tokyo", CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)),
           ("Sydney", CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093)),
           ("Dubai", CLLocationCoordinate2D(latitude: 25.276987, longitude: 55.296249)),
           ("Cape Town", CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241)),
           ("Rio de Janeiro", CLLocationCoordinate2D(latitude: -22.9068, longitude: -43.1729)),
           ("Moscow", CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)),
           ("Mumbai", CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)),
           // Add more locations here...
       ]
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "Unknown"
        }
        switch status {
        case .notDetermined:
            return "Not Determine"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        #if !os(watchOS)
        case .authorized:
            return "Authorized"
        #endif
        default:
            return "Unknown"
        }
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        manager.stopUpdatingLocation()
    }
}

