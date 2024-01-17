//
//  AppPrayerTime.swift
//  Salah
//
//  Created by Qassim on 1/2/24.
//

import Foundation


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

