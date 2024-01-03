//
//  SettingsView.swift
//  Salah
//
//  Created by Qassim on 12/21/23.
//
import SwiftUI
import UserNotifications
import CoreLocation

class FileStorageManager {
    static let shared = FileStorageManager()
    private let settingsFileName = "SalahSettings.JSON"
    
    func saveSettings(_ settings: [Setting]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            saveOnDoneDataToDocuments(encoded, jsonFilename: settingsFileName)
        }
    }
    
    func loadSettings() -> [Setting] {
        let jsonFileURL = getDocumentsDirectory().first!.appendingPathComponent(settingsFileName)
        
        do {
            let savedData = try Data(contentsOf: jsonFileURL)
            let decoder = JSONDecoder()
            let loadedSettings = try decoder.decode([Setting].self, from: savedData)
            return loadedSettings
        } catch {
            print("Error loading settings from file: \(error.localizedDescription)")
            // If file doesn't exist or there's an error loading, save the default settings
            //            saveSettings(defaultSettings())
            return defaultSettings()
        }
    }
    
    func saveOnDoneDataToDocuments(_ data: Data, jsonFilename: String = "SalahSettings.JSON") {
        let fileManager = FileManager.default
        let jsonFileURL = getDocumentsDirectory().first!.appendingPathComponent(jsonFilename)
        do {
            if fileManager.fileExists(atPath: jsonFileURL.path){
                
                try fileManager.removeItem(at: jsonFileURL)
                try data.write(to: jsonFileURL)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDocumentsDirectory() -> [URL] {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths
    }
    
    func defaultSettings() -> [Setting] {
        return [
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
        ]
    }
}


enum SettingType: Identifiable, Equatable , Codable{
    case simple(String)
    case permission(PermissionType)
    case dropdown(DropdownType)
    
    enum CodingKeys: String, CodingKey {
        case type
        case stringValue
        case permissionType
        case dropdownType
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .simple(let string):
            try container.encode("simple", forKey: .type)
            try container.encode(string, forKey: .stringValue)
        case .permission(let permissionType):
            try container.encode("permission", forKey: .type)
            try container.encode(permissionType, forKey: .permissionType)
        case .dropdown(let dropdownType):
            try container.encode("dropdown", forKey: .type)
            try container.encode(dropdownType, forKey: .dropdownType)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        
        switch type {
        case "simple":
            let stringValue = try container.decode(String.self, forKey: .stringValue)
            self = .simple(stringValue)
        case "permission":
            let permissionType = try container.decode(PermissionType.self, forKey: .permissionType)
            self = .permission(permissionType)
        case "dropdown":
            let dropdownType = try container.decode(DropdownType.self, forKey: .dropdownType)
            self = .dropdown(dropdownType)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown setting type")
        }
    }
    
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

enum PermissionType: Identifiable, Equatable, Codable {
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

enum DropdownType: Identifiable, Equatable , Codable{
    case calculationMethod
    case juristicMethod
    case adjustingMethod
    case timeFormat
    case timeName
    
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
            return PrayerTimeSetting.CalculationMethod.allCases.map { $0.stringValue }
        case .juristicMethod:
            return PrayerTimeSetting.JuristicMethod.allCases.map { $0.stringValue }
        case .adjustingMethod:
            return PrayerTimeSetting.AdjustingMethod.allCases.map { $0.stringValue }
        case .timeFormat:
            return PrayerTimeSetting.TimeFormat.allCases.map { $0.stringValue }
        case .timeName:
            return PrayerTimeSetting.TimeName.allCases.map { $0.stringValue }
        }
    }
}

struct Setting: Identifiable, Equatable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isPermissionEnabled
        case settingType
        case isExpanded
        case selectedOptionIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isPermissionEnabled = try container.decodeIfPresent(Bool.self, forKey: .isPermissionEnabled)
        isExpanded = try container.decodeIfPresent(Bool.self, forKey: .isExpanded)
        selectedOptionIndex = try container.decodeIfPresent(Int.self, forKey: .selectedOptionIndex)
        
        if let typeString = try container.decodeIfPresent(SettingType.self, forKey: .settingType) {
            switch typeString {
            case .simple(let string):
                //                let stringValue = try container.decode(String.self, forKey: .title)
                settingType = .simple(string)
            case .permission(let permission):
                settingType = .permission(permission)
            case .dropdown(let dropdown):
                settingType = .dropdown(dropdown)
            default:
                print("Def")
            }
            //            switch typeString {
            //            case "simple":
            //                let stringValue = try container.decode(String.self, forKey: .title)
            //                settingType = .simple(stringValue)
            //            case "permission":
            //                let permissionType = try container.decode(PermissionType.self, forKey: .settingType)
            //                settingType = .permission(permissionType)
            //            case "dropdown":
            //                let dropdownType = try container.decode(DropdownType.self, forKey: .settingType)
            //                settingType = .dropdown(dropdownType)
            //            default:
            //                throw DecodingError.dataCorruptedError(forKey: .settingType, in: container, debugDescription: "Unknown setting type")
            //            }
        }
    }
    
    init(title: String?, description: String?, isPermissionEnabled: Bool?, settingType: SettingType?, isExpanded: Bool? = false, selectedOptionIndex: Int? = 0) {
        self.title = title
        self.description = description
        self.isPermissionEnabled = isPermissionEnabled
        self.settingType = settingType
        self.isExpanded = isExpanded
        self.selectedOptionIndex = selectedOptionIndex
    }
    
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Optional formatting for readability
        
        do {
            let jsonData = try encoder.encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error encoding Setting to JSON: \(error.localizedDescription)")
        }
        
        return nil
    }
}

extension Setting {
    // Method to create Setting object from JSON string
    static func fromJSONString(_ jsonString: String) -> Setting? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        do {
            let setting = try decoder.decode(Setting.self, from: jsonData)
            return setting
        } catch {
            print("Error decoding JSON into Setting: \(error.localizedDescription)")
            return nil
        }
    }
}

class PermissionsManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {
    @Published var notificationPermissionEnabled = false
    @Published var locationPermissionEnabled = false
    var prayTime: LocalPrayTimeSetting?
    private let notificationCenter = UNUserNotificationCenter.current()
    private let locationManager = CLLocationManager()
    private let fileStorageManager = FileStorageManager.shared
    
    // Load settings data from UserDefaults or create new settings if not found
    var settingsData: [Setting] = []
    
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        locationManager.delegate = self
        loadInitialPermissions()
        registerAppLifecycleNotifications()
        loadSettingsFromICloud()
    }
    
    deinit {
        removeAppLifecycleNotifications()
    }
    
    func setPrayTimeInstance(_ prayTime: LocalPrayTimeSetting) {
        self.prayTime = prayTime
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
    
    func updatePrayerTimeSetting(_ settingType: DropdownType, value: Int) {
        guard let prayTime = prayTime else { return }
        let prayerTimeHelper = PrayerTimeHelper()
        
        switch settingType {
        case .calculationMethod:
            prayerTimeHelper.syncCalculationMethod(with: prayTime, value: value)
        case .juristicMethod:
            prayerTimeHelper.syncJuristicMethod(with: prayTime, value: value)
        case .adjustingMethod:
            prayerTimeHelper.syncAdjustingMethod(with: prayTime, value: value)
        case .timeFormat:
            prayerTimeHelper.syncTimeFormat(with: prayTime, value: value)
        case .timeName:
            prayerTimeHelper.syncTimeName(with: prayTime, value: value)
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
        // Process loadedSettings as needed after loading from UserDefaults
        // For example, update UI or perform actions based on loadedSettings
    }
}

struct SettingsView: View {
    @ObservedObject var permissionsManager = PermissionsManager()
    @State private var dropdownSettings: [Setting] = []
    @State private var simpleSettings: [Setting] = []
    @State private var permissionSettings: [Setting] = []
    let localPrayTimeSetting = LocalPrayTimeSetting() // Create an instance of PrayTime
    
    var body: some View {
        List {
            Section(header: Text("Prayer Settings")) {
                ForEach(dropdownSettings.indices, id: \.self) { index in
                    DropdownSettingsRow(
                        setting: $dropdownSettings[index],
                        localPrayTimeSetting: localPrayTimeSetting,
                        updateSettingsManager: { updatedSetting in
                            guard let settingType = updatedSetting.settingType , let dropdownType = settingType.dropdownType as? DropdownType else { return  }
                            print(updatedSetting.selectedOptionIndex)
                            let updatedSettingsArray = permissionsManager.updateSettingAndGetUpdatedArray(updatedSetting: updatedSetting)
                            permissionsManager.saveSettingsToUserICloud(updatedSettingsArray)
                           
                            permissionsManager.updatePrayerTimeSetting(dropdownType, value: updatedSetting.selectedOptionIndex ?? 0)
                        }, permissionsManager: permissionsManager
                    )
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
            permissionsManager.setPrayTimeInstance(localPrayTimeSetting)
            let allSettings = permissionsManager.settingsData
            dropdownSettings = allSettings.filter { $0.settingType?.dropdownType != nil }
            simpleSettings = allSettings.filter { $0.settingType?.stringValue != nil }
            permissionSettings = allSettings.filter { $0.settingType?.permissionType != nil }
        }
    }
}
extension PermissionsManager {
    func updateSettingAndGetUpdatedArray(updatedSetting: Setting) -> [Setting] {
        // Find the index of the setting that needs to be updated
        if let index = settingsData.firstIndex(where: { $0.id == updatedSetting.id }) {
            // Update the setting object in the array
            settingsData[index] = updatedSetting
        }
        // Return the updated array
        return settingsData
    }
}


struct DropdownSettingsRow: View {
    @Binding var setting: Setting
    @State private var isExpanded = false
    @ObservedObject var localPrayTimeSetting: LocalPrayTimeSetting
    var updateSettingsManager: ((Setting) -> Void)?
    var permissionsManager: PermissionsManager
    
    let prayerTimeHelpers = PrayerTimeHelper()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
#if os(iOS)
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack {
                    if let options = setting.optionsForDropdown {
                        Picker(selection: Binding<Int>(
                            get: { setting.selectedOptionIndex ?? 0 },
                            set: { newValue in
                                setting.selectedOptionIndex = newValue
                            }
                        ), label: Text("")) {
                            ForEach(0..<options.count, id: \.self) { index in
                                Text(options[index])
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: setting.selectedOptionIndex) { newValue in
                            if let newValue = newValue, newValue >= 0, newValue < options.count {
//                                updateSetting(selectedOptionIndex: newValue)
                                setting.selectedOptionIndex = newValue
                            }
                        }
                    }
                    
                    Button("Done") {
                        isExpanded = false
                        updateSetting(selectedOptionIndex: setting.selectedOptionIndex ?? 0)
                    }
                    .padding(.top, 8)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        isExpanded = false
                        updateSetting(selectedOptionIndex: setting.selectedOptionIndex ?? 0)
                    }
                }
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
    
    func updateSetting(selectedOptionIndex: Int) {
        if let dropdownType = setting.settingType?.dropdownType {
            switch dropdownType {
            case .calculationMethod:
                if let updatedCalculationMethod = PrayerTimeSetting.CalculationMethod(rawValue: selectedOptionIndex) {
                    localPrayTimeSetting.calculationMethod = updatedCalculationMethod
                    setting.selectedOptionIndex = selectedOptionIndex
                    updateSettingsManager?(setting)
                }
            case .juristicMethod:
                if let updatedJuristicMethod = PrayerTimeSetting.JuristicMethod(rawValue: selectedOptionIndex) {
                    localPrayTimeSetting.juristicMethod = updatedJuristicMethod
                    setting.selectedOptionIndex = selectedOptionIndex
                    updateSettingsManager?(setting)
                }
            case .adjustingMethod:
                if let updatedAdjustingMethod = PrayerTimeSetting.AdjustingMethod(rawValue: selectedOptionIndex) {
                    localPrayTimeSetting.adjustingMethod = updatedAdjustingMethod
                    setting.selectedOptionIndex = selectedOptionIndex
                    updateSettingsManager?(setting)
                }
            case .timeFormat:
                if let updatedTimeFormat = PrayerTimeSetting.TimeFormat(rawValue: selectedOptionIndex) {
                    localPrayTimeSetting.timeFormat = updatedTimeFormat
                    setting.selectedOptionIndex = selectedOptionIndex
                    updateSettingsManager?(setting)
                }
            case .timeName:
                if let updatedTimeName = PrayerTimeSetting.TimeName(rawValue: selectedOptionIndex) {
                    localPrayTimeSetting.timeName = updatedTimeName
                    setting.selectedOptionIndex = selectedOptionIndex
                    updateSettingsManager?(setting)
                }
            }
        }
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
