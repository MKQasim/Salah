//
//  PrayerTimeHelper.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/13/23.
//

import Foundation

class PrayerTimeHelper {
    static func getSalahTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> [SalahTiming] {
        var prayerTiming:[SalahTiming] = []
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
                                              andMonth: Int32(date.get(.month)),
                                              andDay: Int32(date.get(.day)),
                                              andLatitude: lat,
                                              andLongitude: long,
                                              andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({ $0 as? String })
        
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
            
            if (name != "Sunset" && name != "Sunrise") {
                prayerTiming.append(newSalahTiming)
            }
        }
        return prayerTiming
    }
    
    static func getSunTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date()) -> [SalahTiming]{
        var sunTimings:[SalahTiming] = []
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
                                              andMonth: Int32(date.get(.month)),
                                              andDay: Int32(date.get(.day)),
                                              andLatitude: lat,
                                              andLongitude: long,
                                              andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({ $0 as? String })
        
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
            
            if (name == "Sunset" || name == "Sunrise") {
                sunTimings.append(newSalahTiming)
            }
        }
        return sunTimings
    }
}
