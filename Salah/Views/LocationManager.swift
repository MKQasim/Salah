//
//  LocationManager.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI
import Combine
import CoreLocation
import SwiftUI
import Combine
import UserNotifications

public class LocalPrayTimeSetting: ObservableObject {
    
    @Published var calculationMethod: PrayerTimeSetting.CalculationMethod = .jafari
    @Published var juristicMethod: PrayerTimeSetting.JuristicMethod = .shafii
    @Published var adjustingMethod: PrayerTimeSetting.AdjustingMethod = .angleBased
    @Published var timeFormat: PrayerTimeSetting.TimeFormat = .time24
    
    func setCalculationMethod(_ method: PrayerTimeSetting.CalculationMethod) {
        $calculationMethod.receive(on: DispatchQueue.main).sink { [weak self] value in
            print(value)
            self?.calculationMethod = value
        }
    }
    
    func setJuristicMethod(_ method: PrayerTimeSetting.JuristicMethod) {
        $juristicMethod.receive(on: DispatchQueue.main).sink { [weak self] value in
            self?.juristicMethod = value
        }
    }
    
    func setAdjustingMethod(_ method: PrayerTimeSetting.AdjustingMethod) {
        $adjustingMethod.receive(on: DispatchQueue.main).sink { [weak self] value in
            self?.adjustingMethod = value
        }
    }
    
    func setTimeFormat(_ format: PrayerTimeSetting.TimeFormat) {
        $timeFormat.receive(on: DispatchQueue.main).sink { [weak self] value in
            self?.timeFormat = value
        }
    }
}

class PermissionsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    @Published var notificationPermissionEnabled = false
    @Published var locationPermissionEnabled : Bool = false
    @Published var userCurrentPlace : PrayerPlace?  = nil
    @Published var settingsData: [Setting] = []
    var prayTime: LocalPrayTimeSetting?
    private let notificationCenter = UNUserNotificationCenter.current()
    weak var notificationManager = NotificationManager.shared
    weak var fileStorageManager = FileStorageManager.shared
    weak var locationManager = LocationManager.shared
    
    static let shared = PermissionsManager()
    static var appTerminatedNotification = Notification.Name("AppTerminatedNotification")

    private var cancellables: Set<AnyCancellable> = []

    private override init() {
        super.init()
       
        registerAppLifecycleNotifications()
        settingsData = loadSettingsFromICloud()
        
        Task{
            if let index = self.settingsData.firstIndex(where: { $0.permissionType == .notifications }) {
                // Update the property of the object
                await self.notificationManager?.requestNotification {[weak self]  granted in
                    print("self.notificationManager.isNotificationEnabled", granted)
                    DispatchQueue.main.async { [weak self] in
                        self?.notificationPermissionEnabled = granted
                        self?.settingsData[index].isPermissionEnabled = granted
                    }
                }
            }
            await loadInitialPermissions()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: Self.appTerminatedNotification, object: nil)
    }

    deinit {
        removeAppLifecycleNotifications()
    }
    
    func setPrayTimeInstance(_ prayTime: LocalPrayTimeSetting) {
        DispatchQueue.main.async { [weak self] in
            self?.prayTime = prayTime
        }
        
    }
   
    @MainActor func loadInitialPermissions() {
        if let index = self.settingsData.firstIndex(where: {
            $0.permissionType == .notifications }) {
            // Update the property of the object
            self.notificationManager?.requestNotification { [weak self] granted in
                print("self.notificationManager.isNotificationEnabled", granted)
                DispatchQueue.main.async { [weak self] in
                    self?.notificationPermissionEnabled = granted
                    self?.settingsData[index].isPermissionEnabled = granted
                }
            }
        }
        
        locationManager?.checkLocationPermission { [weak self]
            result in
            switch result {
            case .success(let (isEnabled, prayerPlace)):
                
                DispatchQueue.main.async {
                    self?.locationPermissionEnabled = isEnabled
                    self?.userCurrentPlace = prayerPlace
                    print("self.locationPermissionEnabled", self?.locationPermissionEnabled)
                    print("self.locationPermissionEnabled", self?.userCurrentPlace)
                    if let index = self?.settingsData.firstIndex(where: { $0.permissionType == .location }) {
                        // Update the property of the object
                        self?.settingsData[index].isPermissionEnabled = self?.locationPermissionEnabled
                    }
                    
                }
            case .failure(let error):
                print("Failed to get location details: \(error.localizedDescription)")
            }
        }
    }
    
}

extension PermissionsManager {
    
    @objc func appWillTerminate() {
        // Save settings before the app is terminated
        saveSettingsToICloud()
    }
    
    func saveSettingsToICloud() {
        fileStorageManager?.saveSettings(settingsData)
    }
}

extension PermissionsManager {
    func openLocationSettings() {
        #if os(iOS)
        guard let locationsUrl = URL(string: UIApplication.openSettingsURLString + "location/" + Bundle.main.bundleIdentifier!) else {
            return
        }
        UIApplication.shared.open(locationsUrl)
        #elseif os(macOS)
        guard let locationsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices") else {
            return
        }
        NSWorkspace.shared.open(locationsUrl)
        #endif
    }


    func updatePrayerTimeSetting(_ settingType: DropdownType, value: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let prayTime = self?.prayTime else { return }
           
            switch settingType {
            case .calculationMethod:
                self?.syncCalculationMethod(with: prayTime, value: value)
            case .juristicMethod:
                self?.syncJuristicMethod(with: prayTime, value: value)
            case .adjustingMethod:
                self?.syncAdjustingMethod(with: prayTime, value: value)
            case .timeFormat:
                self?.syncTimeFormat(with: prayTime, value: value)
            }
        }
    }

}


// MARK: - App Lifecycle Notifications
extension PermissionsManager {
    // MARK: - Notifications Lifecycle Registration

    private func registerAppLifecycleNotifications() {
        #if os(iOS)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                Task {
                    await self.appBecameActive()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                Task {
                    await self.appDidEnterBackground()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                Task {
                    await self.appWillEnterForeground()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { _ in
                Task {
                    await self.appWillResignActive()
                }
            }
            .store(in: &cancellables)
        #endif
      
    }

    // MARK: - Private Methods
    
    private func removeAppLifecycleNotifications() {
        #if os(iOS)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        #elseif os(macOS)
        NotificationCenter.default.removeObserver(self, name: NSApplication.didBecomeActiveNotification, object: nil)
        #elseif os(tvOS)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("com.apple.TVTopShelfItemsDidChange"), object: nil)
        #elseif os(watchOS)
        NotificationCenter.default.removeObserver(self, name: WKExtension.applicationDidBecomeActiveNotification, object: nil)
        #endif
    }

}

// MARK: - Notification Permissions
extension PermissionsManager {
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.notificationPermissionEnabled = granted
                self?.saveNotificationPermissionStatus(granted)
            }
        }
    }
    
    private func saveNotificationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "NotificationPermissionStatus")
        // Save the notification permission status to app settings or storage if needed
    }
}



// MARK: - Prayer Time Settings
extension PermissionsManager {
    func syncCalculationMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.CalculationMethod(rawValue: value) {
            prayTime.setCalculationMethod(method)
        }
    }
    
    func syncJuristicMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.JuristicMethod(rawValue: value) {
            prayTime.setJuristicMethod(method)
        }
    }
    
    func syncAdjustingMethod(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let method = PrayerTimeSetting.AdjustingMethod(rawValue: value) {
            prayTime.setAdjustingMethod(method)
        }
    }
    
    func syncTimeFormat(with prayTime: LocalPrayTimeSetting, value: Int) {
        if let format = PrayerTimeSetting.TimeFormat(rawValue: value) {
            prayTime.setTimeFormat(format)
        }
    }
    
    func syncSetting(with prayTime: LocalPrayTimeSetting, setting: Setting) {
        if let dropdownType = setting.settingType?.dropdownType {
            switch dropdownType {
            case .calculationMethod:
                if let calculationMethod = PrayerTimeSetting.CalculationMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setCalculationMethod(calculationMethod)
                }
            case .juristicMethod:
                if let juristicMethod = PrayerTimeSetting.JuristicMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setJuristicMethod(juristicMethod)
                }
            case .adjustingMethod:
                if let adjustingMethod = PrayerTimeSetting.AdjustingMethod(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setAdjustingMethod(adjustingMethod)
                }
            case .timeFormat:
                if let timeFormat = PrayerTimeSetting.TimeFormat(rawValue: setting.selectedOptionIndex ?? 0) {
                    prayTime.setTimeFormat(timeFormat)
                }
            }
        }
    }
}

// MARK: - iCloud Settings
extension PermissionsManager {
    func saveSettingsToUserICloud(_ settings: [Setting]) {
        fileStorageManager?.saveSettings(settings)
    }
    
    func loadSettingsFromICloud() -> [Setting] {
        return fileStorageManager?.loadSettings(locationPermissionEnabled: locationPermissionEnabled) ?? []
    }
}

// MARK: For Notification
extension PermissionsManager {
    
    // Function to update notification permission and request it if necessary
    func updateNotificationPermission(_ isEnabled: Bool) {
        notificationPermissionEnabled = isEnabled
        saveNotificationPermissionStatus(isEnabled)
        if isEnabled {
            requestNotificationPermission()
        }
        // Dispatch UI update to the main thread
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    // Function to open notification settings
    func openNotificationSettings() {
        #if os(iOS)
        guard let notificationsUrl = URL(string: UIApplication.openSettingsURLString + "notifications/") else {
            return
        }
        UIApplication.shared.open(notificationsUrl)
        #elseif os(macOS)
        guard let notificationsUrl = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else {
            return
        }
        NSWorkspace.shared.open(notificationsUrl)
        #elseif os(watchOS)
        guard let notificationsUrl = URL(string: "tel://") else {
            return
        }
        WKExtension.shared().openSystemURL(notificationsUrl)
        #endif
    }
    
 
    
    @objc func appWillEnterForeground() {
        Task {
            await loadInitialPermissions()
        }
    }
    
    @objc func appDidEnterBackground() {
        Task {
            await loadInitialPermissions()
        }
    }

    @objc func appWillResignActive() {
      
        
        Task {
            await loadInitialPermissions()
        }
    }
    
    
    @objc func appBecameActive() {
        Task {
            await loadInitialPermissions()
        }
    }

   
}

import Foundation
import Combine
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var locationPermissionEnabled : Bool = false
    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation? = nil
    @Published var userLocation = CLLocationCoordinate2D()
    @Published var targetLocation = CLLocationCoordinate2D(latitude: 21.4225, longitude: 39.8262)
    @Published var currentHeading: CLHeading?
    @Published var heading: Double = 0.0
    @Published var qiblaDirection: Double = 0.0
    @Published var userCurrentPlace: PrayerPlace? = nil
    @Published var isCompassViewVisible = false {
        didSet {
            if isCompassViewVisible {
                startHeadingUpdates()
            } else {
                stopHeadingUpdates()
            }
        }
    }

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        userLocation = location.coordinate
        
        let makkah = CLLocation(latitude: 21.4225241, longitude: 39.8261818)
        let qiblaDirection = location.coordinate.direction(to: makkah.coordinate)
        DispatchQueue.main.async { [weak self] in
            self?.qiblaDirection = qiblaDirection
        }
        
        // Print the last location to check if it's being updated
        print("Last location: \(lastLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        
        if status == .authorized {
            requestLocationPermission()
        }
    }
    
    func updateLocationPermission(_ isEnabled: Bool) {
        locationPermissionEnabled = isEnabled
        saveLocationPermissionStatus(isEnabled)
        if isEnabled {
            requestLocationPermission()
        }
    }
    
    func requestLocationPermission() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

        if let manager = locationManager as? CLLocationManager{
            switch manager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                DispatchQueue.main.async { [weak self] in
                    self?.locationManager.startUpdatingLocation()
                }
            @unknown default:
                break
            }
        }else {
            print("Location services are not enabled.")
        }
    }

    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission { [weak self] result in
            // Handle isEnabled (true/false) here
            switch result {
            case .success(let (isEnabled, prayerPlace)):
                self?.locationPermissionEnabled = isEnabled
                self?.userCurrentPlace = prayerPlace
            case .failure(let error):
                print("Failed to get location details: \(error.localizedDescription)")
            }
        }
    }
    
    func saveLocationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "LocationPermissionStatus")
    }
    
    func checkLocationPermission(completion: @escaping (Result<(Bool, PrayerPlace?), Error>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let status = self?.locationManager.authorizationStatus else {
                completion(.failure(NSError(domain: "Location permission status not available", code: 0, userInfo: nil)))
                return
            }
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                self?.getPrayerPlace(completion: completion)
            case .notDetermined:
                self?.locationPermissionEnabled = false
                self?.locationManager.requestWhenInUseAuthorization()
                completion(.success((true, self?.userCurrentPlace)))
            case .denied, .restricted:
                self?.locationPermissionEnabled = false
                completion(.success((false, self?.userCurrentPlace)))
            @unknown default:
                self?.locationPermissionEnabled = false
                print("Unknown authorization status.")
                completion(.success((false, self?.userCurrentPlace)))
            }
        }
    }
}

// MARK: - Prayer Place
extension LocationManager {
    func getPrayerPlace(completion: @escaping (Result<(Bool, PrayerPlace?), Error>) -> Void) {
        
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
                  let country = placemark.country ,
                  let timezone = placemark.timeZone?.identifier
            else {
                completion(.failure(NSError(domain: "Location details not found", code: 1, userInfo: nil)))
                return
            }
            
            let prayerPlace = PrayerPlace(id: UUID().hashValue, lat: location.coordinate.latitude, lng: location.coordinate.longitude, city: city, country: country, timeZoneIdentifier: timezone)
            print(prayerPlace.city)
            
            completion(.success((true, prayerPlace)))
        }
    }
}

extension LocationManager {
    
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
}

// MARK: - Location Updates
extension LocationManager {
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - Heading Updates
extension LocationManager {
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
