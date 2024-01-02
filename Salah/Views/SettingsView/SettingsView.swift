//
//  SettingsView.swift
//  Salah
//
//  Created by Qassim on 12/21/23.
//
import SwiftUI
import UserNotifications
import CoreLocation


enum SettingType: Identifiable, Equatable {
    case simple(String)
    case permission(PermissionType)
    case dropdown(DropdownType)
    
    var id: String {
        switch self {
        case .simple(let string):
            return "simple_\(string)"
        case .permission(let permissionType):
            return "\(permissionType)"
        case .dropdown(let dropdownType):
            return "\(dropdownType)"
        }
    }
    
    var stringValue: String? {
        switch self {
        case .simple(let string):
            return string
        default:
            return nil
        }
    }
    
    var permissionType: PermissionType? {
        if case let .permission(permissionType) = self {
            return permissionType
        }
        return nil
    }
    
    var dropdownType: DropdownType? {
        if case let .dropdown(dropdownType) = self {
            return dropdownType
        }
        return nil
    }
}



enum PermissionType: Identifiable, Equatable {
    case location
    case notifications
    
    var id: String {
        switch self {
        case .location:
            return "location"
        case .notifications:
            return "notifications"
        }
    }
    
    var stringValue: String {
        switch self {
        case .location:
            return "Location Permission"
        case .notifications:
            return "Notification Permission"
        }
    }
}


enum DropdownType: Identifiable, Equatable {
    case calculationMethod
    case juristicMethod
    case adjustingMethod
    case timeFormat
    case timeName
    // Add more dropdown types as required
    
    var id: String {
        switch self {
        case .calculationMethod:
            return "calculationMethod"
        case .juristicMethod:
            return "juristicMethod"
        case .adjustingMethod:
            return "adjustingMethod"
        case .timeFormat:
            return "timeFormat"
        case .timeName:
            return "timeName"
        }
    }
    
    var options: [String] {
        switch self {
        case .calculationMethod:
            return ["Option 1", "Option 2", "Option 3"]
        case .juristicMethod:
            return ["Option A", "Option B", "Option C"]
        case .adjustingMethod:
            return ["Option X", "Option Y", "Option Z"]
        case .timeFormat:
            return ["Option Alpha", "Option Beta", "Option Gamma"]
        case .timeName:
            return ["Option Apple", "Option Banana", "Option Orange"]
        }
    }
}

struct Setting: Identifiable, Equatable {
    var id = UUID()
    var title: String?
    var description: String?
    var isPermissionEnabled: Bool?
    var settingType: SettingType? // Use SettingType enum to define setting types
    var isExpanded: Bool? = false
    var selectedOptionIndex: Int? = 0
    
    var optionsForDropdown: [String]? {
        if case let .dropdown(dropdownType) = settingType {
            return dropdownType.options
        }
        return nil
    }
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
            Setting(title: "Location Permission", description: "Manage location permission", isPermissionEnabled: false, settingType: .permission(.location)),
            Setting(title: "Notification Permission", description: "Manage notification permission", isPermissionEnabled: false, settingType: .permission(.notifications)),
            Setting(title: "Calculation Method", description: "Choose calculation method", isPermissionEnabled: false, settingType: .dropdown(.calculationMethod)),
            Setting(title: "Juristic Method", description: "Choose juristic method", isPermissionEnabled: false, settingType: .dropdown(.juristicMethod)),
            Setting(title: "Adjusting Method", description: "Choose adjusting method", isPermissionEnabled: false, settingType: .dropdown(.adjustingMethod)),
            Setting(title: "Time Format", description: "Choose time format", isPermissionEnabled: false, settingType: .dropdown(.timeFormat)),
            Setting(title: "Time Name", description: "Choose time name", isPermissionEnabled: false, settingType: .dropdown(.timeName)),
            Setting(title: "Privacy", description: "Manage your privacy settings", isPermissionEnabled: false, settingType: .simple("Privacy")),
            Setting(title: "Account", description: "View and manage your account details", isPermissionEnabled: false, settingType: .simple("Account")),
            Setting(title: "Help & Support", description: "Get help and support", isPermissionEnabled: false, settingType: .simple("Help & Support"))
            
            // Add more settings as needed
        ]
        return settingsData
    }
}

struct SettingsView: View {
    @ObservedObject var permissionsManager = PermissionsManager()
    @State private var dropdownSettings: [Setting] = []
    @State private var simpleSettings: [Setting] = []
    @State private var permissionSettings: [Setting] = []

    var body: some View {
        List {
            Section(header: Text("Prayer Settings")) {
                ForEach(dropdownSettings.indices, id: \.self) { index in
                    DropdownSettingsRow(setting: $dropdownSettings[index])
                }
            }
            
            Section(header: Text("Permission Settings")) {
                ForEach(permissionSettings.indices, id: \.self) { index in
                    PermissionSettingsRow(setting: $permissionSettings[index], permissionsManager: permissionsManager)
                }
            }
            
            Section(header: Text("About")) {
                ForEach(simpleSettings.indices, id: \.self) { index in
                    SimpleSettingsRow(setting: $simpleSettings[index])
                }
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListRowHeight, 0) // Reduces the default space between items
        .navigationTitle("Settings")
        #if os(iOS)
        .listRowSeparatorTint(.clear) // Hides the list separators
        #endif
        .onAppear {
            let allSettings = permissionsManager.createSettingsData()
            dropdownSettings = allSettings.filter { $0.settingType?.dropdownType != nil }
            simpleSettings = allSettings.filter { $0.settingType?.stringValue != nil }
            permissionSettings = allSettings.filter { $0.settingType?.permissionType != nil }
        }
    }
}


struct DropdownSettingsRow: View {
    @Binding var setting: Setting
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
#if os(iOS)
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack {
                    if let options = setting.optionsForDropdown {
                        Picker(selection: $setting.selectedOptionIndex, label: Text("")) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Text(options[index])
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: setting.selectedOptionIndex) { newValue in
                            if newValue ?? 0 >= 0 && newValue ?? 0 < options.count {
                                setting.selectedOptionIndex = newValue
                                print("Selected value: \(options[newValue ?? 0])")
                            }
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setting.title ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(setting.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }.padding(10)
            }
#endif
        }
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
        )
        .padding(.vertical, 4)
    }
}

struct SimpleSettingsRow: View {
    @Binding var setting: Setting

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading) { // Ensuring text is aligned to leading edge
                Text(setting.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(setting.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.secondary)
            .padding(10)
        }
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
        )
        .padding(.vertical, 4) // Adjusted vertical padding here
    }
}

struct PermissionSettingsRow: View {
    @Binding var setting: Setting
    @ObservedObject var permissionsManager: PermissionsManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(setting.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(setting.description ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 0)) // Adjusted text padding
            
            Spacer() // To push the switch to the right
            
            if let permissionType = setting.settingType?.permissionType {
                switch permissionType {
                case .location, .notifications:
                    PermissionToggle(isEnabled: permissionType == .location ? $permissionsManager.locationPermissionEnabled : $permissionsManager.notificationPermissionEnabled,
                                     permissionsManager: permissionsManager)
                        .frame(width: 50) // Adjusted switch frame width
                        .padding(10)
                        .onTapGesture {
                            permissionsManager.openLocationSettings()
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
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
        )
        .padding(.vertical, 4) // Adjusted vertical padding here
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
