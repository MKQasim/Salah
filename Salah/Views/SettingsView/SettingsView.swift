//
//  SettingsView.swift
//  Salah
//
//  Created by Qassim on 12/21/23.
//
import SwiftUI
import UserNotifications
import CoreLocation
import UIKit

enum PermissionType {
    case location
    case notifications
    case privacyPolicy
}


class PermissionsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    @Published var notificationPermissionEnabled = false
    @Published var locationPermissionEnabled = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        locationManager.delegate = self
        loadInitialPermissions()
        registerAppLifecycleNotifications()
    }
    
    deinit {
        removeAppLifecycleNotifications()
    }
    
    private func registerAppLifecycleNotifications() {
#if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: UIApplication.didBecomeActiveNotification, object: nil)
#endif
    }
    
    private func removeAppLifecycleNotifications() {
#if os(iOS)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
#endif
    }
    
    @objc func appBecameActive() {
        // Update permissions when the app becomes active
        loadInitialPermissions()
    }
    
    func updateLocationPermission(_ isEnabled: Bool) {
        locationPermissionEnabled = isEnabled
        saveLocationPermissionStatus(isEnabled)
        if isEnabled {
            requestLocationPermission()
        }
    }
    
    func updateNotificationPermission(_ isEnabled: Bool) {
        notificationPermissionEnabled = isEnabled
        saveNotificationPermissionStatus(isEnabled)
        if isEnabled {
            requestNotificationPermission()
        }
    }
    
    private func saveLocationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "LocationPermissionStatus")
        // Save the location permission status to app settings or storage if needed
    }
    
    private func saveNotificationPermissionStatus(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "NotificationPermissionStatus")
        // Save the notification permission status to app settings or storage if needed
    }
    
    func loadInitialPermissions() {
        notificationPermissionEnabled = checkNotificationPermission()
        checkLocationPermission { isEnabled in
            // Handle isEnabled (true/false) here
            self.locationPermissionEnabled = isEnabled
        }
    }
    
    func checkNotificationPermission() -> Bool {
        var isEnabled = false
        notificationCenter.getNotificationSettings { settings in
            isEnabled = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                self.notificationPermissionEnabled = isEnabled
            }
        }
        return isEnabled
    }
    
    func checkLocationPermission(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            var isEnabled = false
                let status = self.locationManager.authorizationStatus
                switch status {
                case .authorizedWhenInUse, .authorizedAlways:
                    isEnabled = true
                default:
                    isEnabled = false
                }
            completion(isEnabled)
        }
    }

    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.notificationPermissionEnabled = granted
            }
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
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
#endif
    }
    
    func openNotificationSettings() {
#if os(iOS)
        guard let notificationsUrl = URL(string: UIApplication.openSettingsURLString + "notifications/") else {
            return
        }
        UIApplication.shared.open(notificationsUrl)
#endif
    }
    
    func createSettingsData() -> [Setting] {
        var settingsData = [
            Setting(title: "Location", description: "Manage your Location settings", isPermissionEnabled: locationPermissionEnabled, permissionType: .location),
            Setting(title: "Notifications", description: "Control notification preferences", isPermissionEnabled: notificationPermissionEnabled, permissionType: .notifications),
            Setting(title: "Privacy", description: "Manage your privacy settings", isPermissionEnabled: false, permissionType: .privacyPolicy),
            Setting(title: "Account", description: "View and manage your account details", isPermissionEnabled: false, permissionType: nil),
            Setting(title: "Help & Support", description: "Get help and support", isPermissionEnabled: false, permissionType: nil)
        ]
        
        return settingsData
    }
}

struct Setting: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var isPermissionEnabled: Bool
    var permissionType: PermissionType?
}

struct SettingsView: View {
    @ObservedObject var permissionsManager = PermissionsManager()
    @State private var settings: [Setting] = []
    
    var body: some View {
            List(settings) { setting in
                SettingsCellView(setting: setting, permissionsManager: permissionsManager)
            }
            .navigationTitle("Settings")
            .listStyle(.plain)
#if !os(watchOS)
            .listRowSeparator(.hidden)
        #endif
            .onAppear {
                settings = permissionsManager.createSettingsData()
            }
        
    }
}

struct SettingsCellView: View {
    var setting: Setting
    @ObservedObject var permissionsManager: PermissionsManager
    
    @State private var showingAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(setting.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(setting.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let permissionType = setting.permissionType {
                switch permissionType {
                case .notifications:
                    Toggle("", isOn: $permissionsManager.notificationPermissionEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: permissionsManager.notificationPermissionEnabled ? .green : .red))
                        .labelsHidden()
                        .onChange(of: permissionsManager.notificationPermissionEnabled) { newValue in
                            permissionsManager.updateNotificationPermission(newValue)
                        }
                        .onTapGesture {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Permission Required"),
                                message: Text(permissionsManager.notificationPermissionEnabled ? "Disable notifications in Settings" : "Enable notifications in Settings"),
                                primaryButton: .default(Text("Settings"), action: {
                                    permissionsManager.openNotificationSettings()
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                case .location:
                    Toggle("", isOn: $permissionsManager.locationPermissionEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: permissionsManager.locationPermissionEnabled ? .green : .red))
                        .labelsHidden()
                        .onChange(of: permissionsManager.locationPermissionEnabled) { newValue in
                            permissionsManager.updateLocationPermission(newValue)
                        }
                        .onTapGesture {
                            showingAlert = true
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(
                                title: Text("Permission Required"),
                                message: Text(permissionsManager.locationPermissionEnabled ? "Disable location in Settings" : "Enable location in Settings"),
                                primaryButton: .default(Text("Settings"), action: {
                                    permissionsManager.openLocationSettings()
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                default:
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.lightGray))
                .shadow(radius: 3)
        )
    }
}

struct PermissionToggle: View {
    @Binding var isEnabled: Bool
    var permissionsManager: PermissionsManager
    
    var body: some View {
        Toggle("", isOn: $isEnabled)
            .toggleStyle(SwitchToggleStyle(tint: isEnabled ? .green : .red))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView()
                .preferredColorScheme(.light)
            SettingsView()
                .preferredColorScheme(.dark)
        }
    }
}
