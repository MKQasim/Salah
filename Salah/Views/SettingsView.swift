//
//  SettingsView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//
import SwiftUI
import UserNotifications
import CoreLocation
import WebKit

class FileStorageManager {
    static let shared = FileStorageManager()
    private let settingsFileName = "SalahSettings.JSON"
    
    func saveSettings(_ settings: [Setting]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settings) {
            saveOnDoneDataToDocuments(encoded, jsonFilename: settingsFileName)
        }
    }
    
    func loadSettings(locationPermissionEnabled: Bool?) -> [Setting] {
        let jsonFileURL = getDocumentsDirectory().first!.appendingPathComponent(settingsFileName)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: jsonFileURL.path) {
            do {
                let savedData = try Data(contentsOf: jsonFileURL)
                let decoder = JSONDecoder()
                let loadedSettings = try decoder.decode([Setting].self, from: savedData)
                return loadedSettings
            } catch {
                print("Error loading settings from file: \(error.localizedDescription)")
                // Handle the error if needed
            }
        } else {
            print("File does not exist at:", jsonFileURL.path)
            // If the file doesn't exist, create it or handle its absence
            // fileManager.createFile(atPath: jsonFileURL.path, contents: nil, attributes: nil)
        }
        
        // If file doesn't exist or there's an error loading, return default settings
        return defaultSettings(locationPermissionEnabled: locationPermissionEnabled ?? false)
    }


    
    func saveOnDoneDataToDocuments(_ data: Data, jsonFilename: String = "SalahSettings.JSON") {
        let fileManager = FileManager.default
        let jsonFileURL = getDocumentsDirectory().first!.appendingPathComponent(jsonFilename)
        do {
            if fileManager.fileExists(atPath: jsonFileURL.path){
                
//                try fileManager.removeItem(at: jsonFileURL)
                try data.write(to: jsonFileURL)
            }
            else{
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
    
    func defaultSettings(locationPermissionEnabled: Bool) -> [Setting] {
      
        return [
            Setting(title: "Location Permission", description: "Manage location permission", isPermissionEnabled: locationPermissionEnabled, settingType: .permission(.location), permissionType: .location, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Notification Permission", description: "Manage notification permission", isPermissionEnabled: false, settingType: .permission(.notifications), permissionType: .notifications, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Calculation Method", description: "Choose calculation method", isPermissionEnabled: false, settingType: .dropdown(.calculationMethod), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Juristic Method", description: "Choose juristic method", isPermissionEnabled: false, settingType: .dropdown(.juristicMethod), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Adjusting Method", description: "Choose adjusting method", isPermissionEnabled: false, settingType: .dropdown(.adjustingMethod), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Time Format", description: "Choose time format", isPermissionEnabled: false, settingType: .dropdown(.timeFormat), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
//            Setting(title: "Time Name", description: "Choose time name", isPermissionEnabled: false, settingType: .dropdown(.timeName), permissionType: nil),
            Setting(title: "Privacy", description: "Manage your privacy settings", isPermissionEnabled: false, settingType: .simple("Privacy"), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Account", description: "View and manage your account details", isPermissionEnabled: false, settingType: .simple("Account"), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html"),
            Setting(title: "Help & Support", description: "Get help and support", isPermissionEnabled: false, settingType: .simple("Help & Support"), permissionType: nil, urlLink: "https://mkqasim.github.io/Salah/privacy_policy.html")
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

extension SettingType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .simple(let string):
            hasher.combine("simple")
            hasher.combine(string)
        case .permission(let permissionType):
            hasher.combine("permission")
            hasher.combine(permissionType)
        case .dropdown(let dropdownType):
            hasher.combine("dropdown")
            hasher.combine(dropdownType)
        }
    }
}

extension PermissionType: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .location:
            hasher.combine("location")
        case .notifications:
            hasher.combine("notifications")
        }
    }
}


enum DropdownType: Identifiable, Equatable , Codable{
    case calculationMethod
    case juristicMethod
    case adjustingMethod
    case timeFormat
    
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
      
        }
    }
}

struct Setting: Identifiable, Equatable, Codable  , Hashable{
    var id = UUID()
    var title: String?
    var description: String?
    var isPermissionEnabled: Bool?
    var settingType: SettingType? // Use SettingType enum to define setting types
    var isExpanded: Bool? = false
    var selectedOptionIndex: Int? = 0
    var permissionType: PermissionType? // Include the permission type
    var urlLink : String?
    
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
        case permissionType
        case urlLink
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isPermissionEnabled = try container.decodeIfPresent(Bool.self, forKey: .isPermissionEnabled)
        isExpanded = try container.decodeIfPresent(Bool.self, forKey: .isExpanded)
        selectedOptionIndex = try container.decodeIfPresent(Int.self, forKey: .selectedOptionIndex)
        urlLink = try container.decodeIfPresent(String.self, forKey: .urlLink)
        if let permissionType =  try container.decodeIfPresent(PermissionType.self, forKey: .permissionType) {
            switch permissionType {
            case .location:
                self.permissionType  = .location
            case .notifications:
                self.permissionType = .notifications
            default:
                print("default permissionType")
            }
        }
        if let typeString = try container.decodeIfPresent(SettingType.self, forKey: .settingType) {
            switch typeString {
            case .simple(let string):
                settingType = .simple(string)
            case .permission(let permission):
                settingType = .permission(permission)
            case .dropdown(let dropdown):
                settingType = .dropdown(dropdown)
            default:
                print("Def")
            }
        }
    }
    
    init(title: String?, description: String?, isPermissionEnabled: Bool?, settingType: SettingType?, isExpanded: Bool? = false, selectedOptionIndex: Int? = 0 , permissionType : PermissionType? , urlLink : String?) {
        self.title = title
        self.description = description
        self.isPermissionEnabled = isPermissionEnabled
        self.settingType = settingType
        self.isExpanded = isExpanded
        self.selectedOptionIndex = selectedOptionIndex
        self.permissionType = permissionType
        self.urlLink = urlLink
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
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(isPermissionEnabled)
        hasher.combine(settingType)
        hasher.combine(isExpanded)
        hasher.combine(selectedOptionIndex)
        hasher.combine(permissionType)
        hasher.combine(urlLink)
    }
}

// Equatable conformance
extension Setting {
    static func == (lhs: Setting, rhs: Setting) -> Bool {
        return lhs.id == rhs.id &&
            lhs.title == rhs.title &&
            lhs.description == rhs.description &&
            lhs.isPermissionEnabled == rhs.isPermissionEnabled &&
            lhs.settingType == rhs.settingType &&
            lhs.isExpanded == rhs.isExpanded &&
            lhs.selectedOptionIndex == rhs.selectedOptionIndex &&
            lhs.permissionType == rhs.permissionType &&
            lhs.urlLink == rhs.urlLink
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

protocol AppLifecycle {
    var didBecomeActiveNotification: NSNotification.Name { get }
}

struct DropdownSettingsRow: View {
    @Binding var setting: Setting
    @State private var isExpanded = false
    @ObservedObject var localPrayTimeSetting: LocalPrayTimeSetting
    var updateSettingsManager: ((Setting) -> Void)?
    var permissionsManager = PermissionsManager.shared
    
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
                        .pickerStyle(WheelPickerStyle())
                        .onChange(of: setting.selectedOptionIndex) { newValue in
                            if let newValue = newValue, newValue >= 0, newValue < options.count {
                                setting.selectedOptionIndex = newValue
                            }
                        }
                    }
                    
                    Button("Done") {
                        isExpanded = false
                        updateSetting(selectedOptionIndex: setting.selectedOptionIndex ?? 0)
                    }
                    .padding(.top, 8)
                    .foregroundColor(.secondary)
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
            #elseif os(macOS)
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
                        .onChange(of: setting.selectedOptionIndex) { newValue in
                            if let newValue = newValue, newValue >= 0, newValue < options.count {
                                setting.selectedOptionIndex = newValue
                            }
                        }
                    }
                    
                    Button("Done") {
                        isExpanded = false
                        updateSetting(selectedOptionIndex: setting.selectedOptionIndex ?? 0)
                    }
                    .padding(.top, 8)
                    .foregroundColor(.sky2)
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
            #elseif os(watchOS)
            // A simplified interface for watchOS
            VStack {
                Text(setting.title ?? "")
                    .font(.headline)
                
                Text(setting.description ?? "")
                    .font(.subheadline)
            }
            #endif
        }
        
        
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondary)
                .shadow(radius: 2)
        )
        .padding(.vertical, 4)
    }
    
    func updateSetting(selectedOptionIndex: Int) {
        DispatchQueue.main.async {
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
                }
            }
        }
      
    }
}


struct SettingsView: View {
    @ObservedObject var permissionsManager = PermissionsManager.shared
    @State private var dropdownSettings: [Setting] = []
    @State private var simpleSettings: [Setting] = []
    @State private var permissionSettings: [Setting] = []
    let localPrayTimeSetting = LocalPrayTimeSetting() // Create an instance of PrayTime
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack{
//            VStack(alignment: .leading){
//                HStack{
//                    Button(action: {
//                        self.presentationMode.wrappedValue.dismiss()
//                    }) {
//                        Image(systemName: "arrow.backward")
//                            
//                    }.buttonStyle(.automatic)
//                    Spacer()
//                }
//            }
           
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
                        PermissionSettingsRow(
                            setting: $permissionSettings[index],
                            permissionsManager: permissionsManager,
                            updateSettingsManager: { updatedSetting in
                                // Handle updated setting here
                                // This closure will be called when the toggle changes
                                let updatedSettingsArray = permissionsManager.updateSettingAndGetUpdatedArray(updatedSetting: updatedSetting)
                                permissionsManager.saveSettingsToUserICloud(updatedSettingsArray)
                                // Add logic to update permission settings
                            }
                        )
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 50)
                    
                }
            }

        }.id(permissionsManager.settingsData)
        .frame(width: 400, alignment: .center)
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

struct PermissionSettingsRow: View {
    @Binding var setting: Setting
    @ObservedObject var permissionsManager: PermissionsManager
    var updateSettingsManager: ((Setting) -> Void)?
    
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
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 0))
            
            Spacer()
            
            if let permissionType = setting.settingType?.permissionType {
                switch permissionType {
                case .location:
                    PermissionToggle(
                        setting: $setting, permissionsManager: permissionsManager,
                                     updatePermission: { _ in
                                        updatePermissionSetting(permissionType: permissionType)
                                        updateSettingsManager?(setting)
                                     })
                        .frame(width: 50)
                        .padding(10)
                        .onTapGesture {
                            permissionsManager.openLocationSettings()
                        }
                case .notifications:
                    PermissionToggle(
                        setting: $setting, permissionsManager: permissionsManager,
                                     updatePermission: { _ in
                                        updatePermissionSetting(permissionType: permissionType)
                                        updateSettingsManager?(setting)
                                     })
                        .frame(width: 50)
                        .padding(10)
                        .onTapGesture {
                            permissionsManager.openNotificationSettings()
                        }
                }
            }
            else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }.id(setting)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondary)
                .shadow(radius: 2)
        )
        .padding(.vertical, 4)
    }
    
    private func isEnabledBinding(for permissionType: PermissionType) -> Binding<Bool> {
        switch permissionType {
        case .location:
            print($permissionsManager.locationPermissionEnabled)
            return $permissionsManager.locationPermissionEnabled
        case .notifications:
            return $permissionsManager.notificationPermissionEnabled
        }
    }
    
    private func updatePermissionSetting(permissionType: PermissionType) {
        if let index = permissionsManager.settingsData.firstIndex(where: { $0.id == setting.id }) {
            print(permissionsManager.locationPermissionEnabled)
            
            if permissionType == .location {
                permissionsManager.openLocationSettings()
                setting.isPermissionEnabled = permissionsManager.locationPermissionEnabled
                print("Updated \(permissionType)", setting.isPermissionEnabled)
            }else if permissionType == .notifications{
                permissionsManager.openNotificationSettings()
                setting.isPermissionEnabled =  permissionsManager.notificationPermissionEnabled
                print("Updated \(permissionType)", setting.isPermissionEnabled)
            }
            print("\(permissionType)",setting.isPermissionEnabled)
            permissionsManager.settingsData[index] = setting
            let settingsArray = permissionsManager.updateSettingAndGetUpdatedArray(updatedSetting: setting)
            permissionsManager.saveSettingsToUserICloud(settingsArray)
        }
    }
}

struct PermissionToggle: View {
    @Binding var setting: Setting
    var permissionsManager: PermissionsManager
    var updatePermission: (PermissionType) -> Void
    
    var body: some View {
        Toggle("", isOn: Binding(
            get: { setting.isPermissionEnabled ?? false },
            set: { isEnabled in
                setting.isPermissionEnabled = isEnabled
                if let permissionType = setting.settingType?.permissionType {
                    updatePermission(permissionType)
                }
            })
        )
        .toggleStyle(SwitchToggleStyle(tint: setting.isPermissionEnabled ?? false ? .green : .red))
        .onChange(of: setting.isPermissionEnabled) { oldValue,newValue in
            print(newValue)
            if let permissionType = setting.settingType?.permissionType {
                updatePermission(permissionType)
            }
        }
        .onTapGesture {
            if let permissionType = setting.settingType?.permissionType {
                updatePermission(permissionType)
            }
        }
    }
}


#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

struct WebView: ViewRepresentable {
    let request: URLRequest
    @Binding var title: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.load(request)
    }
    #elseif os(iOS)
    func makeUIView(context: Context) -> WKWebView  {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
    #endif

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.title") { (response, error) in
                if let title = response as? String {
                    DispatchQueue.main.async {
                        self.parent.title = title
                    }
                }
            }
        }
    }
}

struct SimpleSettingsRow: View {
    @Binding var setting: Setting
    @State private var title: String = ""
    
    var body: some View {
        if let validURL = URL(string: setting.urlLink ?? "https://mkqasim.github.io/Salah/privacy-policy.html") {
            NavigationLink(destination: WebView(request: URLRequest(url: validURL), title: $title).navigationTitle(Text(title))) {
                VStack(alignment: .leading){
                    Text(setting.title ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(setting.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.secondary)
                        .shadow(radius: 2)
                )
                .padding(.vertical, 4)
            .padding(.horizontal, 10)
        }
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
