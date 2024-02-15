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

class PermissionsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    
    @Published var notificationPermissionEnabled = false
    @Published var locationPermissionEnabled = false
    @Published var settingsData: [Setting] = []
    var prayTime: LocalPrayTimeSetting?
    private let notificationCenter = UNUserNotificationCenter.current()
     let locationManager = CLLocationManager()
    let notificationManager = NotificationManager.shared
    private let fileStorageManager = FileStorageManager.shared
    
    // Load settings data from UserDefaults or create new settings if not found
    
    static let shared = PermissionsManager()
    static var appTerminatedNotification = Notification.Name("AppTerminatedNotification")

    private var cancellables: Set<AnyCancellable> = []

    private override init() {
        super.init()
       
        locationManager.delegate = self
        registerAppLifecycleNotifications()
        loadSettingsFromICloud()
        Task{
            if let index = self.settingsData.firstIndex(where: { $0.permissionType == .notifications }) {
                // Update the property of the object
                await  self.notificationManager.requestNotification { granted in
                    print("self.notificationManager.isNotificationEnabled", granted)
                    self.notificationPermissionEnabled = granted
                    self.settingsData[index].isPermissionEnabled = granted
                }
            }
            await loadInitialPermissions()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: Self.appTerminatedNotification, object: nil)
    }

    @objc func appWillTerminate() {
        // Save settings before the app is terminated
        saveSettingsToICloud()
    }

    func saveSettingsToICloud() {
        fileStorageManager.saveSettings(settingsData)
    }
    
    deinit {
        removeAppLifecycleNotifications()
    }
    
    func setPrayTimeInstance(_ prayTime: LocalPrayTimeSetting) {
        self.prayTime = prayTime
    }
    
   
    
    private func saveNotificationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "NotificationPermissionStatus")
        // Save the notification permission status to app settings or storage if needed
    }
    
    func updateLocationPermission(_ isEnabled: Bool) {
        locationPermissionEnabled = isEnabled
        saveLocationPermissionStatus(isEnabled)
        if isEnabled {
            requestLocationPermission()
        }
    }
    
    private func saveLocationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "LocationPermissionStatus")
        // Save the location permission status to app settings or storage if needed
    }
   
    @MainActor func loadInitialPermissions() {
        if let index = self.settingsData.firstIndex(where: { $0.permissionType == .notifications }) {
            // Update the property of the object
            self.notificationManager.requestNotification { granted in
                print("self.notificationManager.isNotificationEnabled", granted)
                self.notificationPermissionEnabled = granted
                self.settingsData[index].isPermissionEnabled = granted
            }
        }
        
        checkLocationPermission { isEnabled in
            // Handle isEnabled (true/false) here
            DispatchQueue.main.async {
                self.locationPermissionEnabled = isEnabled
                print("self.locationPermissionEnabled", self.locationPermissionEnabled)
                if let index = self.settingsData.firstIndex(where: { $0.permissionType == .location }) {
                    // Update the property of the object
                    self.settingsData[index].isPermissionEnabled = self.locationPermissionEnabled
                }
            }
        }
    }
    
    func checkLocationPermission(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let status = self.locationManager.authorizationStatus
            var isEnabled = false
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                isEnabled = true
                self.locationPermissionEnabled = true
            case .notDetermined:
                self.locationPermissionEnabled = false
                self.locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                isEnabled = false
                self.locationPermissionEnabled = false
             default:
                isEnabled = false
                self.locationPermissionEnabled = false
                print("checkLocationPermission default")
            }
            DispatchQueue.main.async {
                completion(isEnabled)
            }
        }
    }

    func requestLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermission { isEnabled in
            // Handle isEnabled (true/false) here
            self.locationPermissionEnabled = isEnabled
        }
    }
    
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
        guard let prayTime = prayTime else { return }
        let prayerTimeHelper =  PrayerTimeHelper.shared
        switch settingType {
        case .calculationMethod:
            prayerTimeHelper.syncCalculationMethod(with: prayTime, value: value)
        case .juristicMethod:
            prayerTimeHelper.syncJuristicMethod(with: prayTime, value: value)
        case .adjustingMethod:
            prayerTimeHelper.syncAdjustingMethod(with: prayTime, value: value)
        case .timeFormat:
            prayerTimeHelper.syncTimeFormat(with: prayTime, value: value)
        }
    }
    
    // Function to save settings to UserDefaults
    func saveSettingsToUserICloud(_ settings: [Setting]) {
        fileStorageManager.saveSettings(settings)
    }
    
    // Function to load settings from UserDefaults
    func loadSettingsFromICloud() {
        let loadedSettings = fileStorageManager.loadSettings()
        settingsData = loadedSettings
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

    // Function to request notification permission
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.notificationPermissionEnabled = granted
                // Dispatch UI update to the main thread
                self?.objectWillChange.send()
            }
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

    @MainActor @objc func appBecameActive() {
        loadInitialPermissions()
    }
    
    // MARK: - Notifications Lifecycle Registration
    
    private func registerAppLifecycleNotifications() {
        #if os(iOS)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { _ in
                self.appBecameActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.appDidEnterBackground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                self.appWillEnterForeground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { _ in
                self.appWillResignActive()
            }
            .store(in: &cancellables)
        #elseif os(macOS)
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { _ in
                Task {
                    await self.appBecameActive()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSApplication.willResignActiveNotification)
            .sink { _ in
                Task {
                    await self.appWillResignActive()
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)
            .sink { _ in
                Task {
                    await self.appWillEnterForeground()
                }
            }
            .store(in: &cancellables)
        #elseif os(tvOS)
        NotificationCenter.default.publisher(for: NSNotification.Name("com.apple.TVTopShelfItemsDidChange"))
            .sink { _ in
                self.appBecameActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                self.appDidEnterBackground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { _ in
                self.appWillEnterForeground()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { _ in
                self.appWillResignActive()
            }
            .store(in: &cancellables)
        #elseif os(watchOS)
        NotificationCenter.default.publisher(for: WKExtension.applicationDidBecomeActiveNotification)
            .sink { _ in
                self.appBecameActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: WKExtension.applicationWillResignActiveNotification)
            .sink { _ in
                self.appWillResignActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)
            .sink { _ in
                self.appWillEnterForeground()
            }
            .store(in: &cancellables)
        #endif
    }

    @MainActor @objc func appWillEnterForeground() {
        loadInitialPermissions()
    }
    
    @MainActor @objc func appDidEnterBackground() {
        loadInitialPermissions()
    }

    @MainActor @objc func appWillResignActive() {
        loadInitialPermissions()
    }
    
}




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
