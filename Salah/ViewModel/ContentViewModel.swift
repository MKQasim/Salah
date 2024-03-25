//
//  ContentViewModel.swift
//  Salah
//
//  Created by Muhammad's on 18.03.24.
//


import Foundation
import SwiftUI
import SwiftData
import Combine

// MARK: - ContentViewModel

extension Date {
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func toLocalTime(timeZone: String) -> Date {
        let timezone = TimeZone(identifier: timeZone)
        let seconds = TimeInterval((timezone?.secondsFromGMT(for: self)) ?? 0)
        return Date(timeInterval: seconds, since: self)
    }
    
    func getIslamicDate(from date: Date, timeZone: TimeZone) -> String {
        // Create an Islamic calendar
        var islamicCalendar = Calendar(identifier: .islamicCivil)
        islamicCalendar.timeZone = timeZone
        
        // Get the Islamic date components
        let islamicComponents = islamicCalendar.dateComponents([.year, .month, .day], from: date)
        
        // Format the Islamic date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ar_SA") // Set locale to Arabic for day names
        dateFormatter.calendar = islamicCalendar
        dateFormatter.dateFormat = "EEEE dd MMMM yyyy" // Format the date as desired
        
        // Convert the Islamic components to a Date object and then format it
        if let islamicDate = islamicCalendar.date(from: islamicComponents) {
            return dateFormatter.string(from: islamicDate)
        } else {
            return "Unknown" // Return a placeholder if date conversion fails
        }
    }

    
    func getIslamicDateTime(from date: Date, timeZone: TimeZone) -> String {
        // Create an Islamic calendar
        var islamicCalendar = Calendar(identifier: .islamicCivil)
        islamicCalendar.timeZone = timeZone
        
        // Get the Islamic date components
        let islamicComponents = islamicCalendar.dateComponents([.year, .month, .day], from: date)
        
        // Format the Islamic date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ar_SA") // Set locale to Arabic for day names
        dateFormatter.calendar = islamicCalendar
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm:ss" // Format the date and time as desired
             // Format the date as desired
        
        // Convert the Islamic components to a Date object and then format it
        if let islamicDate = islamicCalendar.date(from: islamicComponents) {
            return dateFormatter.string(from: islamicDate)
        } else {
            return "Unknown" // Return a placeholder if date conversion fails
        }
    }

//    // Example usage:
//    let date = Date() // Your date object
//    let islamicDate = getIslamicDate(from: date, timeZone: TimeZone(identifier: "Europe/Berlin")!)
//    print("Islamic Date: \(islamicDate)")
}


class ContentViewModel: ObservableObject {
    @Published var rawlocations: [PrayerPlace] = []
    @Published private(set) var locations: [PrayerPlace] = []
    @Published private(set) var dblocations: [PrayerPlace] = []
    @Published var filteredLocations: [PrayerPlace] = []
    @Published var selectedItem: PrayerPlace? = nil
    @Published var isQiblaSelected: Bool = false
    @Published var tabViewModel : TabViewModel = TabViewModel()
    @Published var isLoading: Bool = false
    @Published var progress: Double = 0.0
    @Published var addedLocationsCount: Int = 0
    @Published var totalLocations: Int = 0
    @Published var prayer : Prayer?
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isChooseCityViewPresented : Bool = false
    @Published var isSettingsViewPresented : Bool = false
    @Published var isLocation = false
    @Published var navigationPath: NavigationPath = NavigationPath()
    var permissionManager = PermissionsManager.shared
    private var context: ModelContext
    private var jsonDecoder = JSONDecoder()
    @Published var currentDate = Date()
    
    init(context: ModelContext) {
        prayer = Prayer()
        self.context = context
        context.autosaveEnabled = false
        Task {
            loadLocationsFromContext()
            permissionManager.locationManager?.requestLocationPermission()
        }
    }
}
// MARK: - Location Management
extension ContentViewModel {
    private func loadLocationsFromContext() {
        Task {
            do {
                
                let locations = try context.fetch(FetchDescriptor<PrayerPlace>())
                print(locations.count)
                DispatchQueue.main.async {
                    self.locations = locations
                    if self.selectedItem == nil {
                        self.selectedItem = locations.first
                    }
                    self.addedLocationsCount = locations.count
                }
            } catch {
                print("Failed to fetch locations: \(error)")
            }
        }
    }


    
    func updateLocations(with newLocation: PrayerPlace?) {
        guard let newLocation = newLocation else { return  }
        if !locations.contains(where: { $0.city == newLocation.city }) {
            locations.append(newLocation)
        }
        
        if let selectedItem = selectedItem,
           let index = locations.firstIndex(where: { $0.city == selectedItem.city }) {
            let current = locations.remove(at: index)
            locations.insert(current, at: 0)
        }
    }
}

// MARK: - Prayer Management
extension ContentViewModel {
    func fetchPrayers(location: PrayerPlace?) {
        guard let location = location else { return  }
        isLoading = true
        let group = DispatchGroup()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var weekPrayers: [[PrayerTiming]] = []

            let date = Date()
            let calendar = Calendar.current

            let year: Int = calendar.component(.year, from: date)
            let month: Int = calendar.component(.month, from: date)
            let day: Int = calendar.component(.day, from: date)

            guard let timeZone = TimeZone(identifier: location.timeZoneIdentifier ?? "Europe/Berlin") else {
                fatalError("Invalid timezone identifier")
            }
            let tZone: Float = Float(timeZone.secondsFromGMT(for: date)) / 3600.0

            let queue = DispatchQueue(label: "com.yourapp.threadsafe")

            for i in 0..<7 {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    let (dayPrayers, _) = self.getPrayerTimes(dayOffset: i, location: location, year: year, month: month, day: day, tZone: tZone)
                    queue.async {
                        weekPrayers.append(dayPrayers)
                        group.leave()
                    }
                }
            }

            group.wait()

            DispatchQueue.main.async {
                self.prayer?.id = location.id
                self.prayer?.nextPrayer = self.getTodayPrayers(location: location, year: year, month: month, day: day, tZone: tZone).nextPrayer
                
                
                let today = Date().getIslamicDate(from: Calendar.current.date(byAdding: .day, value: 0, to: date) ?? Date(), timeZone: timeZone)
                
                let tomorrow = Date().getIslamicDate(from: Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date(), timeZone: timeZone)
                
                
                self.prayer?.today = Day(id: 0, date:today, prayerTimings: weekPrayers[0], sunTimings: self.getTodayPrayers(location: location, year: year, month: month, day: day, tZone: tZone).sunTimings)
                
                
                
                self.prayer?.tomorrow = Day(id: 1, date: tomorrow, prayerTimings: weekPrayers[1], sunTimings: self.getTomorrowPrayers(location: location, year: year, month: month, day: day, tZone: tZone))
                
                var weekly: [Day] = []
                for i in 0..<7 {
                    
                    let date = Date().getIslamicDate(from: Calendar.current.date(byAdding: .day, value: i, to: date) ?? Date(), timeZone: timeZone)
                    
                    weekly.append(Day(id: i, date: date, prayerTimings: weekPrayers[i], sunTimings: []))
                }
                self.prayer?.weekly = weekly
                
                
                self.isLoading = false
            }
        }
    }
    
    func getPrayerTimes(dayOffset: Int, location: PrayerPlace?, year: Int, month: Int, day: Int, tZone: Float) -> ([PrayerTiming], [PrayerTiming]) {
        guard let location = location else { return ([],[]) }
        var prayers: [PrayerTiming] = []
        var sunTimings: [PrayerTiming] = []

        let prayerKit: KQPrayerTime = KQPrayerTime(lat: location.lat ?? 0.0 , lng: location.lng ?? 0.0 )
        prayerKit.calculationMethod = .MWL
        prayerKit.asrJuristic = .Shafii
        prayerKit.outputFormat = .Time24
        
        

        if let times = prayerKit.getDatePrayerTimes(year: year, month: month, day: day + dayOffset, latitude: location.lat  ?? 0.0, longitude: location.lng  ?? 0.0, tZone: tZone) as? [TimeNames : Any]{
            let sortedTimes = times.sorted { $0.key.rawValue < $1.key.rawValue }
            for (pName, timeValue) in sortedTimes {
                let prayerTiming = PrayerTiming(name: "\(pName)", time: timeValue as? String, timeZoneIdentifier: location.timeZoneIdentifier)
                if pName.toString() == "Sunrise" || pName.toString() == "Sunset" {
                    sunTimings.append(prayerTiming)
                } else {
                    prayers.append(prayerTiming)
                }
            }
        }
        return (prayers, sunTimings)
    }

    func getTodayPrayers(location: PrayerPlace?, year: Int, month: Int, day: Int, tZone: Float) -> (nextPrayer: PrayerTiming?, todayPrayers: [PrayerTiming], sunTimings: [PrayerTiming]) {
        let (prayers, sunTimings) = getPrayerTimes(dayOffset: 0, location: location, year: year, month: month, day: day, tZone: tZone)
        
        // Filter out sun timings from today's prayers
        let todayPrayers = prayers.filter { $0.name?.lowercased() != "sunrise" && $0.name?.lowercased() != "sunset" }
        
        // Find the next coming prayer
       
        // Update it on the main thread
        if let timeZone = location?.timeZoneIdentifier {
            DispatchQueue.main.async {
                self.currentDate = Date().toGlobalTime().toLocalTime(timeZone: timeZone)
            }
        }
        
        let currentTime = Calendar.current.dateComponents([.hour, .minute,.second], from: currentDate)
        let currentHour = currentTime.hour ?? 0
        let currentMinute = currentTime.minute ?? 0
        let currentTotalMinutes = currentHour * 60 + currentMinute
        
        var nextPrayer: PrayerTiming?
        for prayer in todayPrayers {
            if let prayerTime = prayer.time {
                let components = prayerTime.components(separatedBy: ":")
                if components.count == 2, let hour = Int(components[0]), let minute = Int(components[1]) {
                    let totalMinutes = hour * 60 + minute
                    if totalMinutes > currentTotalMinutes {
                        nextPrayer = prayer
                        print(nextPrayer?.name ?? "", nextPrayer?.time ?? "")
                        break
                    }
                }
            }
        }
        
        // If Ishah prayer time has passed and next prayer is not available today, find next prayer in tomorrow's list
        if nextPrayer == nil, let ishahTime = todayPrayers.last(where: { $0.name?.lowercased() == "isha" })?.time {
            let ishahComponents = ishahTime.components(separatedBy: ":")
            if let ishahHour = Int(ishahComponents[0]), let ishahMinute = Int(ishahComponents[1]), currentHour > ishahHour || (currentHour == ishahHour && currentMinute > ishahMinute) {
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                let tomorrowComponents = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
                let (tomorrowPrayers, _) = getPrayerTimes(dayOffset: 1, location: location, year: tomorrowComponents.year ?? 0, month: tomorrowComponents.month ?? 0, day: tomorrowComponents.day ?? 0, tZone: tZone)
                nextPrayer = tomorrowPrayers.first
                print(nextPrayer?.name ?? "", nextPrayer?.time ?? "")
            }
        }
        
        return (nextPrayer, todayPrayers, sunTimings)
    }


    func getTomorrowPrayers(location: PrayerPlace?, year: Int, month: Int, day: Int, tZone: Float) -> [PrayerTiming] {
        return getPrayerTimes(dayOffset: 1, location: location, year: year, month: month, day: day, tZone: tZone).1
    }
    
}

// MARK: - Item Management
extension ContentViewModel {
    func addItem(_ location: PrayerPlace) {
        Task {
            if self.locations.contains(where: { $0.id == location.id }) || self.locations.count >= 7 {
                self.alertMessage = "Maximum limit of 7 locations reached or location already added. Cannot add more."
                self.showAlert = true
                return
            }
            
            DispatchQueue.main.async{
                self.locations.append(location)
            }
            context.insert(location)
            selectedItem = location
            await saveContext()
        }
    }

    func deleteItem(_ item: PrayerPlace) {
        Task {
            guard let index = locations.firstIndex(where: { $0.id == item.id }) else {
                return
            }
            
            DispatchQueue.main.async{
                self.locations.remove(at: index)
            }
            
            context.delete(item)
            await saveContext()
        }
    }
}

// MARK: - View Management
extension ContentViewModel {
    func qiblaView() {
        Task {
            DispatchQueue.main.async { [weak self] in
                self?.isQiblaSelected.toggle()
                print("Toggled isQiblaSelected. New value: \(self?.isQiblaSelected ?? false)")
            }
        }
    }
}

// MARK: - Context Management
extension ContentViewModel {
    func saveContext() async {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    func getIndexForSelectedItemId() -> Int? {
        guard let selectedItemId = selectedItem else {
            return nil
        }
        return locations.firstIndex { $0.id == selectedItem?.id }
    }
    
    func getItemForSelectedItemId() -> PrayerPlace? {
        guard let selectedItemId = selectedItem else {
            return nil
        }
        return locations.first { $0.id == selectedItem?.id }
    }
}




final class Theme: ObservableObject {
    @Published 
    var primeryColor : Color = .orange
}


struct Day: Codable, Identifiable, Hashable {
    var id: Int
    var date: String
    var prayerTimings: [PrayerTiming]
    var sunTimings: [PrayerTiming]
    
    static func == (lhs: Day, rhs: Day) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Prayer: Codable, Identifiable, Hashable {
    var id: Int?
    var today: Day?
    var tomorrow: Day?
    var weekly: [Day]?
    var nextPrayer: PrayerTiming?
    
    static func == (lhs: Prayer, rhs: Prayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct PrayerTiming: Identifiable, Hashable, Codable {
    var id = UUID()
    let name: String?
    var time: String? // Updated property type to Date
    var timeZoneIdentifier : String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, time , timeZoneIdentifier
    }
    
    init(name: String?, time: String? , timeZoneIdentifier: String?) {
        self.name = name
        self.time = time
        self.timeZoneIdentifier = timeZoneIdentifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.timeZoneIdentifier = try container.decode(String.self, forKey: .timeZoneIdentifier)
        self.time = try container.decode(String.self, forKey: .time)
        
    }
}


typealias NextPrayerCompletion = (PrayerTiming?) -> Void

public enum PrayerTimeSetting {
   public enum CalculationMethod: Int {
        case jafari = 0
        case karachi
        case isna
        case mwl
        case makkah
        case egypt
        case custom
        case tehran
        
        // Retrieve associated string for each enum case
       public var stringValue: String {
            switch self {
            case .jafari:
                return "Ithna Ashari"
            case .karachi:
                return "University of Islamic Sciences"
            case .isna:
                return "Islamic Society of North America"
            case .mwl:
                return "Muslim World League"
            case .makkah:
                return "Umm al-Qura, Makkah"
            case .egypt:
                return "Egyptian General Authority of Survey"
            case .custom:
                return "Custom Setting"
            case .tehran:
                return "Institute of Geophysics, University of Tehran"
            }
        }
    }
    
    public enum JuristicMethod: Int {
        case shafii = 0
        case hanafi
        
        public  var stringValue: String {
            switch self {
            case .shafii:
                return "Shafii (standard)"
            case .hanafi:
                return "Hanafi"
            }
        }
    }
    
    public enum AdjustingMethod: Int {
        case none = 0
        case midnight
        case oneSeventh
        case angleBased
        
        public  var stringValue: String {
            switch self {
            case .none:
                return "No adjustment"
            case .midnight:
                return "Middle of night"
            case .oneSeventh:
                return "1/7th of night"
            case .angleBased:
                return "Angle/60th of night"
            }
        }
    }
    
    public enum TimeFormat: Int {
        case time24 = 0
        case time12
        case time12NS
        case float
        
        public var stringValue: String {
            switch self {
            case .time24:
                return "24-hour format"
            case .time12:
                return "12-hour format"
            case .time12NS:
                return "12-hour format with no suffix"
            case .float:
                return "Floating point number"
            }
        }
    }
    
}

extension PrayerTimeSetting.CalculationMethod {
    static var allCases: [PrayerTimeSetting.CalculationMethod] {
        return [.jafari, .karachi, .isna, .mwl, .makkah, .egypt, .custom, .tehran]
    }
}

extension PrayerTimeSetting.JuristicMethod {
    static var allCases: [PrayerTimeSetting.JuristicMethod] {
        return [.shafii, .hanafi]
    }
}

extension PrayerTimeSetting.AdjustingMethod {
    static var allCases: [PrayerTimeSetting.AdjustingMethod] {
        return [.none, .midnight, .oneSeventh, .angleBased]
    }
}

extension PrayerTimeSetting.TimeFormat {
    static var allCases: [PrayerTimeSetting.TimeFormat] {
        return [.time24, .time12, .time12NS, .float]
    }
}


enum CalculationMethod {
    /// Muslim World League
    case MWL
    /// Islamic Society of North America
    case ISNA
    /// Egyptian General Authority of Survey
    case Egypt
    /// Umm al-Qura University, Makkah
    case Makkah
    /// University of Islamic Science, Karachi
    case Karachi
    /// Institute of Geophysics, University of Tehran
    case Tehran
    /// Shia Ithna Ashari, Leva Research Institute, Qum
    case Jafari
    /// Custom, these can be changed as user sets.
    case Custom
}

enum JuristicMethod {
    /// Shafi'i, Maliki, Ja'fari, and Hanbali
    case Shafii
    /// Hanafi
    case Hanafi
    
    func toInt()->Int {
        switch self {
        case .Shafii: return 0
        case .Hanafi: return 1
        }
    }
}

enum HigherLatutudeAdjustment {
    case None
    case MidNight
    case OneSeventh
    case AngleBased
}

enum OutputTimeFormat {
    case Time24
    case Time12
    case Time12NoSuffix
    case Float
    case Date
}

enum TimeNames : Int {
    case Fajr    = 0
    case Sunrise = 1
    case Dhuhr   = 2
    case Asr     = 3
    case Sunset  = 4
    case Maghrib = 5
    case Isha    = 6
    
    func toString()->String {
        switch(self) {
        case .Fajr    : return "Fajr"
        case .Sunrise : return "Sunrise"
        case .Dhuhr   : return "Dhuhr"
        case .Asr     : return "Asr"
        case .Sunset  : return "Sunset"
        case .Maghrib : return "Maghrib"
        case .Isha    : return "Isha"
        }
    }
}

struct Coordinate {
    var latitude:Double
    var longitude:Double
    
    init(lat:Double, lng:Double){
        latitude = lat
        longitude = lng
    }
}

class KQPrayerTime {
    
    private static let gregorianCalendar = Calendar(identifier: .gregorian)
    private static let calendarComponentsDMY = Set([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day])
    private static let DefaultDayTimes:[TimeNames: Double] = [
        TimeNames.Fajr    : 5.0,
        TimeNames.Sunrise : 6.0,
        TimeNames.Dhuhr   : 12.0,
        TimeNames.Asr     : 13.0,
        TimeNames.Sunset  : 18.0,
        TimeNames.Maghrib : 18.0,
        TimeNames.Isha    : 18.0
    ]
    
    //------------------------------------------------------
    // MARK: - Technical Settings
    //------------------------------------------------------
    
    /// number of iterations needed to compute times
    var numIterations:Int = 1
    
    /**
    Required parameters for calculation methods.
    None but the `.Custom` parameters should be changed where appropriate.
    Mostly, you should not be touching is directly.
    
    **Note:**
    Parameters are five-element arrays with following values:
    
     methodParams[method] = @[fa, ms, mv, is, iv];
     ------------------------------------------------------
     fa:  fajr angle
     ms:  maghrib selector (0 = angle; 1 = minutes after sunset)
     mv:  maghrib parameter value (in angle or minutes)
     is:  isha selector (0 = angle; 1 = minutes after maghrib)
     iv:  isha parameter value (in angle or minutes)
    */
    var methodParams:[CalculationMethod: [Float]] = [
        .MWL     : [18  , 1, 0  , 0, 17  ],
        .ISNA    : [15  , 1, 0  , 0, 15  ],
        .Egypt   : [19.5, 1, 0  , 0, 17.5],
        .Makkah  : [18.5, 1, 0  , 1, 90  ],
        .Karachi : [18  , 1, 0  , 0, 18  ],
        .Tehran  : [17.7, 0, 4.5, 0, 14  ],
        .Jafari  : [16  , 0, 4  , 0, 14  ],
        .Custom  : [18  , 1, 0  , 0, 17  ]
    ];
    
    //------------------------------------------------------
    // MARK: - Properties
    //------------------------------------------------------
    
    var offsets:[TimeNames: Double] = [
        .Fajr    : 0,
        .Sunrise : 0,
        .Dhuhr   : 0,
        .Asr     : 0,
        .Sunset  : 0,
        .Maghrib : 0,
        .Isha    : 0
    ];
    
    
    /// Once 'computePrayerTimes' is called,
    /// computed values are stored here for reuse
    var currentPrayerTimes:[TimeNames: Double]?
    
    /// Prayer calculation methods.
    /// See `CalculationMethod` enums for more details
    var calculationMethod      = CalculationMethod.MWL
    /// Asr method, `Shafii` or `Hanafii`
    var asrJuristic            = JuristicMethod.Shafii
    /// Adjustment options for Higher Latitude
    var highLatitudeAdjustment = HigherLatutudeAdjustment.MidNight
    /// Prayer time output format.
    var outputFormat           = OutputTimeFormat.Time24
    
    // Not sure if it should be replaced by offsets[.Dhuhr]
    var dhuhrMinutes:Float = 0
    
    /// Coordinate of the place, times will be calculated for.
    var coordinate:Coordinate! {
        didSet {
            calculateJulianDate()
        }
    }
    
    /// Timezone of the place, times will be calculated for.
    var timeZone:Float   = KQPrayerTime.systemTimeZone()
    
    /// Date for which prayer times will be calculated.
    /// Defaults to today, when not set.
    var calcDate:Date! {
        didSet {
            calculateJulianDate()
        }
    }
    
    private lazy var jDate:Double = KQPrayerTime.julianDate(from: Date())
    
    //------------------------------------------------------
    // MARK: - Constructor
    //------------------------------------------------------
    
    init(lat:Double, lng:Double){
        coordinate = Coordinate(lat: lat, lng: lng)
        calcDate = Date()
    }
    
    //------------------------------------------------------
    // MARK: - Utility Methods (Type Methods)
    //------------------------------------------------------
    
    class func systemTimeZone()->Float {
        let timeZone = TimeZone.current
        return Float(timeZone.secondsFromGMT())/3600.0
    }
    
    class func dayLightSavingOffset()->Double {
        let timeZone = TimeZone.current
        return Double(timeZone.daylightSavingTimeOffset(for: Date()))
    }
    
    //------------------------------------------------------
    // MARK: - Public Methods: Get prayer times
    //------------------------------------------------------
    
    /// Return prayer times for a given date, latitude, longitude and timeZone
    func getDatePrayerTimes(year:Int, month:Int, day:Int, latitude:Double, longitude:Double, tZone:Float)->[TimeNames: Any] {
        coordinate = Coordinate(lat: latitude, lng: longitude)
        
        var comp = DateComponents()
        comp.year = year
        comp.month = month
        comp.day = day
        calcDate = KQPrayerTime.gregorianCalendar.date(from: comp)
        
        timeZone = tZone
        
        jDate = KQPrayerTime.julianDate(year: year, month: month, day: day)
        
        let lonDiff = longitude / (15.0 * 24.0)
        jDate = jDate - lonDiff;
        return computeDayTimes()
    }
    
    /// Returns prayer times for a date(or today) when everything is set
    func getPrayerTimes()->[TimeNames: Any]? {
        // If coordinate is not set, cannot obtain prayer times
        if coordinate == nil {
            return nil
        }
        
        // If date is not set, set today as calcDate
        if calcDate == nil {
            calcDate = Date()
        }
        
        // jDate should be autometically set already
        return computeDayTimes()
    }
    
    //------------------------------------------------------
    // MARK: - Public Methods: Configurations
    //------------------------------------------------------
    
    /// Set custom values for calculation parameters
    func setCustomParams(_ params:[Float]) {
        var cust = methodParams[CalculationMethod.Custom]!
        var curr = methodParams[calculationMethod]!
        for i in 0..<5 {
            let j = params[i];
            cust[i] = (j == -1) ? curr[i] : j
        }
        methodParams[CalculationMethod.Custom] = cust
        calculationMethod = CalculationMethod.Custom
    }
    
    /// Set the angle for calculating Fajr
    func setFajrAngle(angle:Float) {
        setCustomParams([angle, -1.0, -1.0, -1.0, -1.0])
    }
    
    /// Set the angle for calculating Maghrib
    func setMaghribAngle(angle:Float) {
        setCustomParams([-1.0, 0.0, angle, -1.0, -1.0])
    }
    
    /// Set the angle for calculating Isha
    func setIshaAngle(angle:Float) {
        setCustomParams([-1.0, -1.0, -1.0, 0.0, angle])
    }
    
    /// Set the minutes after Sunset for calculating Maghrib
    func setMaghribMinutes(minutes:Float) {
        setCustomParams([-1.0, 1.0, minutes, -1.0, -1.0])
    }
    
    /// Set the minutes after Maghrib for calculating Isha
    func setIshaMinutes(minutes:Float) {
        setCustomParams([-1.0, -1.0, -1.0, 1.0, minutes])
    }
    
    //------------------------------------------------------
    // MARK: - Public Methods: Format Conversion
    //------------------------------------------------------
    
    /// Convert float hours to (hours, minutes)
    func floatToHourMinute(_ time:Double)->(hours:Int, minutes:Int)? {
        if time.isNaN {
            return nil
        }
        
        let ttime = fixHour(time + 0.5 / 60.0)  // add 0.5 minutes to round
        let hours = Int(floor(time))
        let minutes = Int(floor((ttime - Double(hours)) * 60.0))
        
        return (hours: hours, minutes: minutes)
    }
    
    /// Convert float hours to 24h format
    func floatToTime24(_ time:Double)->String {
        if let (hours, minutes) = floatToHourMinute(time) {
            return NSString(format: "%02d:%02d", hours, minutes) as String
        } else {
            return "---"
        }
    }
    
    /// Convert float hours to 12h format
    func floatToTime12(_ time:Double, noSuffix:Bool)->String {
        if let (hours, minutes) = floatToHourMinute(time) {
            return NSString(format: "%02d:%02d%@", (hours % 12), minutes, (noSuffix ? "" : ((hours > 12) ? " pm" : " am")) ) as String
        } else {
            return "---"
        }
    }
    
    /// Convert float hours to 12h format with no suffix
    func floatToTime12NS(_ time:Double)->String {
        return floatToTime12(time, noSuffix: true)
    }
    
    /// Convert float hours to NSDate
    func floatToNSDate(_ time:Double)->Date? {
        if let (hours, minutes) = floatToHourMinute(time) {
            var components = KQPrayerTime.gregorianCalendar.dateComponents(KQPrayerTime.calendarComponentsDMY, from: calcDate)
            components.hour = hours
            components.minute = minutes
            return KQPrayerTime.gregorianCalendar.date(from: components)
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------
    // MARK: - Julian Date Calculation
    //------------------------------------------------------
    
    private func calculateJulianDate() {
        if let date = calcDate {
            if let latlng = coordinate {
                jDate = KQPrayerTime.julianDate(from: date)
                jDate = jDate - (latlng.longitude / (15.0 * 24.0))
            }
        }
    }
    
    private class func julianDate(from date:Date)->Double {
        let components = KQPrayerTime.gregorianCalendar.dateComponents(KQPrayerTime.calendarComponentsDMY, from: Date())
        return julianDate(year: components.year ?? 0,
                          month: components.month ?? 0,
                          day: components.day ?? 0)
    }
    
    private class func julianDate(year:Int, month:Int, day:Int)->Double {
        var yyear = year, mmonth = month, dday = day
        if mmonth < 2 {
            yyear -= 1
            mmonth += 12
        }
        
        let A = floor(Double(yyear)/100.0)
        let B = 2.0 - A + floor(A/4.0)
        
        return floor(365.25 * (Double(yyear) + 4716.0))
            + floor(30.6001 * (Double(mmonth) + 1.0))
            + Double(dday) + B - 1524.5
    }
    
    //------------------------------------------------------
    // MARK: - Calculation Functions
    //------------------------------------------------------
    
    // References:
    // http://praytimes.org/calculation/
    
    // compute declination angle of sun and equation of time
    private func sunPosition(_ jd:Double)->(Double, Double) {
        let D = jd - 2451545.0;
        let g = DMath.fixAngle(357.529 + 0.98560028 * D)
        let q = DMath.fixAngle(280.459 + 0.98564736 * D)
        let L = DMath.fixAngle(q + (1.915 * DMath.dSin(g)) + (0.020 * DMath.dSin(2 * g)))
        
        //double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos: (2*g)];
        let e = 23.439 - (0.00000036 * D)
        var RA = DMath.dArcTan2(DMath.dCos(e) * DMath.dSin(L), x: DMath.dCos(L)) / 15.0
        RA = fixHour(RA);
        
        let d = DMath.dArcSin(DMath.dSin(e) * DMath.dSin(L))
        let EqT = q / 15.0 - RA;
        
        return (d, EqT);
    }
    
    // compute equation of time
    private func equationOfTime(_ jd:Double)->Double {
        let (_, EqT) = sunPosition(jd)
        return EqT
    }
    
    // compute declination angle of sun
    private func sunDeclination(_ jd:Double)->Double {
        let (d, _) = sunPosition(jd)
        return d
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    private func computeMidDay(_ t:Double)->Double {
        let T = equationOfTime(jDate + t)
        return fixHour(12 - T)
    }
    
    // compute time for a given angle G
    private func computeTime(_ G:Double, t:Double)->Double {
        let D:Double = sunDeclination(jDate + t)
        let Z:Double = computeMidDay(t)
        let V:Double = DMath.dArcCos((-DMath.dSin(G) - (DMath.dSin(D) * DMath.dSin(coordinate!.latitude))) / (DMath.dCos(D) * DMath.dCos(coordinate!.latitude))) / 15.0
        
        if G > 90 {
            return Z - V
        } else {
            return Z + V
        }
    }
    
    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    private func computeAsr(step:Double, t:Double)->Double {
        let d = sunDeclination(jDate + t)
        let g = -DMath.dArcCot(step + DMath.dTan(abs(coordinate!.latitude - d)))
        return computeTime(g, t: t)
    }
    
    //------------------------------------------------------
    // MARK: - Misc Functions
    //------------------------------------------------------
    
    // compute the difference between two times
    private func timeDiff(_ time1:Double, time2:Double)->Double {
        return fixHour(time2 - time1)
    }

    //------------------------------------------------------
    // MARK: - Compute Prayer Times
    //------------------------------------------------------
    
    // compute prayer times at given julian date
    private func computeTimes(_ times:[TimeNames: Double])->[TimeNames: Double] {
        var t = dayPortion(times)
        var params = methodParams[calculationMethod]!
        
        let idk = params[0]
        let fajr:Double    = computeTime((180.0 - Double(idk)), t: t[.Fajr]!)
        let sunrise:Double = computeTime((180.0 - 0.833), t: t[.Sunrise]!)
        let dhuhr:Double   = computeMidDay(t[.Dhuhr]!)
        let asr:Double     = computeAsr(step: Double(1 + asrJuristic.toInt()), t: t[.Asr]!)
        let sunset:Double  = computeTime(0.833, t: t[.Sunset]!)
        let maghrib:Double = computeTime(Double(params[2]), t: t[.Maghrib]!)
        let isha:Double    = computeTime(Double(params[4]), t: t[.Isha]!)
        
        let cTimes = [
            TimeNames.Fajr    : fajr,
            TimeNames.Sunrise : sunrise,
            TimeNames.Dhuhr   : dhuhr,
            TimeNames.Asr     : asr,
            TimeNames.Sunset  : sunset,
            TimeNames.Maghrib : maghrib,
            TimeNames.Isha    : isha
        ]
        
        //Tune times here
        //Ctimes = [self tuneTimes:Ctimes];
        
        return cTimes;
    }
    
    // compute prayer times at given julian date
    private func computeDayTimes()->[TimeNames: Any] {
        //default times
        let times = KQPrayerTime.DefaultDayTimes;
        
        // Compute minimum once
        var t1 = computeTimes(times)
        
        // If need more iterations...
        if numIterations > 1 {
            for _ in 2...numIterations {
                t1 = computeTimes(times)
            }
        }
        
        var t2 = adjustTimes(t1)
        t2 = tuneTimes(t2)
        
        //Set prayerTimesCurrent here!!
        currentPrayerTimes = t2
        
        let t3 = adjustTimesFormat(t2)
        
        return t3
    }
    
    // Tune timings for adjustments
    // Set time offsets
    private func tune(offsetTimes:[TimeNames: Double]) {
        offsets = offsetTimes;
    }
    
    private func tuneTimes(_ times:[TimeNames: Double])->[TimeNames: Double] {
        var ttimes = times
        for (pName, time) in times {
            //if(i==5)
            //NSLog(@"Normal: %d - %@", i, [times objectAtIndex:i]);
            let off = offsets[pName]! / 60.0
            let oTime = time + off
            ttimes[pName] = oTime
            //if(i==5)
            //NSLog(@"Modified: %d - %@", i, [times objectAtIndex:i]);
        }
        
        return ttimes;
    }
    
    // range reduce hours to 0..23
    private func fixHour(_ a:Double)->Double {
        return DMath.wrap(a, min: 0, max: 24)
    }
    
    // adjust times in a prayer time array
    private func adjustTimes(_ times:[TimeNames: Double])->[TimeNames: Double] {
        var ttimes = times
        var dTime1:Double
        var dTime2:Double
        
        for (timeName, time) in ttimes {
            ttimes[timeName] = time + (Double(timeZone) - coordinate!.longitude / 15.0);
        }
        
        ttimes[TimeNames.Dhuhr] = ttimes[TimeNames.Dhuhr]! + (Double(dhuhrMinutes) / 60.0); //Dhuhr
        
        var params = methodParams[calculationMethod]!
        let val = params[1]
        
        if (val == 1.0) { // Maghrib
            dTime1 = ttimes[TimeNames.Sunset]! + Double(params[2] / 60.0)
            ttimes[TimeNames.Maghrib] = dTime1
        }
        
        if params[3] == 1 { // Isha
            dTime2 = ttimes[TimeNames.Maghrib]! + Double(params[4] / 60.0)
            ttimes[TimeNames.Isha] = dTime2
        }
        
        if (highLatitudeAdjustment != HigherLatutudeAdjustment.None){
            ttimes = adjustHighLatTimes(ttimes)
        }
        return ttimes;
    }
    
    // convert times array to given time format
    private func adjustTimesFormat(_ times:[TimeNames: Double])->[TimeNames: Any] {
        var ttimes:[TimeNames: Any] = [TimeNames: Any]()
        
        for (timeName, time) in times {
            if (outputFormat == OutputTimeFormat.Float) {
                ttimes[timeName] = time as AnyObject
            } else if (outputFormat == OutputTimeFormat.Time12) {
                ttimes[timeName] = floatToTime12(time, noSuffix: false)
            } else if (outputFormat == OutputTimeFormat.Time12NoSuffix) {
                ttimes[timeName] = floatToTime12(time, noSuffix:true)
            } else if (outputFormat == OutputTimeFormat.Time24){
                ttimes[timeName] = floatToTime24(time)
            } else {
                // floatToNSDate can return nil, if time is invalid
                ttimes[timeName] = floatToNSDate(time)
            }
        }
        return ttimes;
    }
    
    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    private func adjustHighLatTimes(_ times:[TimeNames: Double])->[TimeNames: Double] {
        var ttimes = times
        let params = methodParams[calculationMethod]!
        
        let nightTime = timeDiff(ttimes[TimeNames.Sunset]!, time2:ttimes[TimeNames.Sunrise]!) // sunset to sunrise
        
        // Adjust Fajr
        let fajrDiff = nightPortion(angle: Double(params[0])) * nightTime;
        if (ttimes[TimeNames.Fajr]!.isNaN || timeDiff(ttimes[TimeNames.Fajr]!, time2: ttimes[TimeNames.Sunrise]!) > fajrDiff) {
            ttimes[TimeNames.Fajr] = ttimes[TimeNames.Sunrise]! - fajrDiff
        }
        
        // Adjust Isha
        let ishaAngle:Double = (params[3] == 0.0) ? Double(params[4]) : 18.0
        let ishaDiff:Double = nightPortion(angle: ishaAngle) * nightTime
        if (ttimes[TimeNames.Isha]!.isNaN || timeDiff(ttimes[TimeNames.Sunset]!, time2: ttimes[TimeNames.Isha]!) > ishaDiff) {
            ttimes[TimeNames.Isha] = ttimes[TimeNames.Sunset]! + ishaDiff
        }
        
        // Adjust Maghrib
        let maghribAngle:Double = (params[1] == 0.0) ? Double(params[2]) : 4.0
        let maghribDiff:Double = nightPortion(angle: maghribAngle) * nightTime
        if (ttimes[TimeNames.Maghrib]!.isNaN || timeDiff(ttimes[TimeNames.Sunset]!, time2: ttimes[TimeNames.Maghrib]!) > maghribDiff) {
            ttimes[TimeNames.Maghrib] = ttimes[TimeNames.Sunset]! + maghribDiff
        }
        
        return ttimes;
    }
    
    // the night portion used for adjusting times in higher latitudes
    private func nightPortion(angle:Double)->Double {
        var calc:Double
        
        switch highLatitudeAdjustment {
        case .None       : calc = 0.0
        case .AngleBased : calc = angle / 60.0
        case .MidNight   : calc = 0.5
        case .OneSeventh : calc = 0.14286
        }
        
        return calc;
    }
    
    // convert hours to day portions
    private func dayPortion(_ times:[TimeNames: Double])->[TimeNames: Double] {
        var ttimes = [TimeNames: Double]()
        for (pName, time) in times {
            let timeH = time / 24.0
            ttimes[pName] = timeH
        }
        return ttimes
    }
    
}

// ------------------------------------------------------
// MARK: - Trigonometric Functions
// ------------------------------------------------------

class DMath {
    class func wrap(_ a:Double, min:Double, max:Double)->Double {
        var aa = a
        let range = max - min
        aa.formTruncatingRemainder(dividingBy: range)
        if aa < min { aa += range }
        if aa > max { aa -= range }
        return aa
    }
    
    // range reduce angle in degrees.
    class func fixAngle(_ a:Double)->Double {
        return wrap(a, min: 0, max: 360)
    }
    
    // radian to degree
    class func radiansToDegrees(_ alpha:Double) ->Double{
        return ((alpha*180.0)/Double.pi);
    }
    
    // deree to radian
    class func degreesToRadians(_ alpha:Double)->Double {
        return ((alpha*Double.pi)/180.0);
    }
    
    // degree sin
    class func dSin(_ d:Double)->Double {
        return sin(degreesToRadians(d))
    }
    
    // degree cos
    class func dCos(_ d:Double)->Double {
        return cos(degreesToRadians(d))
    }
    
    // degree tan
    class func dTan(_ d:Double)->Double {
        return tan(degreesToRadians(d))
    }
    
    // degree arcsin
    class func dArcSin(_ x:Double)->Double {
        let val = asin(x)
        return radiansToDegrees(val)
    }
    
    // degree arccos
    class func dArcCos(_ x:Double)->Double {
        let val = acos(x);
        return radiansToDegrees(val)
    }
    
    // degree arctan
    class func dArcTan(_ x:Double)->Double {
        let val = atan(x);
        return radiansToDegrees(val)
    }
    
    // degree arctan2
    class func dArcTan2(_ y:Double, x:Double)->Double {
        let val = atan2(y, x);
        return radiansToDegrees(val)
    }
    
    // degree arccot
    class func dArcCot(_ x:Double)->Double {
        let val = atan2(1.0, x);
        return radiansToDegrees(val)
    }
}

