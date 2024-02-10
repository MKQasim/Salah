//
//  LocationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation? = nil
    @Published var userLocation = CLLocationCoordinate2D()
    @Published var targetLocation = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    @Published var currentHeading: CLHeading?
    @Published var heading: Double = 0
    @Published var qiblaDirection: Double = 0
    
    @Published var isCompassViewVisible = false {
           didSet {
               if isCompassViewVisible {
                   startHeadingUpdates()
               } else {
                   stopHeadingUpdates()
               }
           }
       }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager.headingFilter = 1
            locationManager.startUpdatingHeading()
        }
    }

    func startHeadingUpdates() {
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func stopHeadingUpdates() {
        if CLLocationManager.headingAvailable() {
            #if os(iOS)
            locationManager.stopUpdatingHeading()
            #endif
        }
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        DispatchQueue.main.async {
            self.heading = newHeading.trueHeading
            self.currentHeading = newHeading
        }
        let trueHeading = newHeading.trueHeading
        let magneticHeading = newHeading.magneticHeading
        manager.stopUpdatingLocation()
//        print("True Heading: \(trueHeading), Magnetic Heading: \(magneticHeading)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        userLocation = location.coordinate
        let makkah = CLLocation(latitude: 21.4225241, longitude: 39.8261818)
        let qiblaDirection = location.coordinate.direction(to: makkah.coordinate)
        DispatchQueue.main.async {
            self.qiblaDirection = qiblaDirection
        }
        manager.stopUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
    }
}

extension CLLocationCoordinate2D {
    func direction(to point: CLLocationCoordinate2D) -> Double {
        let fromLat = self.latitude.degreesToRadians
        let fromLon = self.longitude.degreesToRadians
        let toLat = point.latitude.degreesToRadians
        let toLon = point.longitude.degreesToRadians
        let direction = atan2(sin(toLon - fromLon) * cos(toLat), cos(fromLat) * sin(toLat) - sin(fromLat) * cos(toLat) * cos(toLon - fromLon))
        return (direction.radiansToDegrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
}
