//
//  LocationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject{
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var locationStatus: CLAuthorizationStatus?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

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
        case .authorized:
            return "Authorized"
        @unknown default:
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
        guard let location = locations.last else {return}
        lastLocation = location
    }
}
