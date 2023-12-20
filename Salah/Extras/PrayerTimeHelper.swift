//
//  PrayerTimeHelper.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//
import Foundation
import CoreLocation

struct PrayerTiming: Codable, Identifiable, Hashable {
    var id = UUID()
    let name: String
    let time: String

    init(name: String, time: String) {
        self.name = name
        self.time = time
    }
}

struct Location: Codable, Identifiable, Hashable {
    var id: Int?
    var city: String?
    var lat, lng: Double?
    var country: String?
    var dateTime: Date?
    var timezone: TimeZone?
    var timezoneDouble: Double?
    var prayerTimings: [PrayerTiming]?

    enum CodingKeys: String, CodingKey {
        case city
        case lat, lng
        case country
        case id
        case dateTime
        case timezone
        case prayerTimings
    }
}

struct PrayerTimeHelper {
    let prayTimeObj: PrayTime
    
    init() {
        prayTimeObj = PrayTime()
        prayTimeObj.setCalcMethod(3)
    }
    
    private func getPrayerTimes(lat: Double, long: Double, timeZone: Double, date: Date) -> [String]? {
        return prayTimeObj.getDatePrayerTimes(
            Int32(date.get(.year)),
            andMonth: Int32(date.get(.month)),
            andDay: Int32(date.get(.day)),
            andLatitude: lat,
            andLongitude: long,
            andtimeZone: timeZone
        )?.compactMap { $0 as? String }
    }
    
    func getSalahTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> (sunTimes: [PrayerTiming], prayerTimes: [PrayerTiming]) {
        guard let prayerTimes = getPrayerTimes(lat: lat, long: long, timeZone: timeZone, date: date) else {
            return ([], [])
        }
        
        let time = PrayTime()
        let mutableNames = time.timeNames as? [String] ?? []
        print(prayerTimes)
        print(mutableNames)
        // Filter out Sunset and Sunrise times from prayerTimes
        let filteredPrayerTimes = prayerTimes.filter { !$0.contains("Sunrise") && !$0.contains("Sunset") }
        
        // Separate sunset and sunrise times
        let sunriseTime = mutableNames.first { $0 == "Sunrise" }
        let sunsetTime = mutableNames.first { $0 == "Sunset" }
        
        
        var sunTimes: [PrayerTiming] = []
        var prayerTimesFiltered: [PrayerTiming] = []
        
        for (index, prayer) in filteredPrayerTimes.enumerated() {
           
            if let sunrise = sunriseTime, index == 1 {
                sunTimes.append(PrayerTiming(name: sunrise, time: prayer))
            }else if let sunset = sunsetTime, index == 4 {
                sunTimes.append(PrayerTiming(name: sunset, time: prayer))
            }else{
                prayerTimesFiltered.append(PrayerTiming(name: mutableNames[index], time: prayer))
            }
        }
        return (sunTimes, prayerTimesFiltered)
    }
}

