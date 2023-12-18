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
    let prayTimeObj: PrayTime?
   
    init() {
        prayTimeObj = PrayTime()
        prayTimeObj?.setCalcMethod(3)
        }

  
    func getPrayerTimings(location: Location, timeZone: Double, date: Date = Date(), completion: @escaping (Location?) -> Void) {
        prayTimeObj?.setCalcMethod(3)
        
        print(timeZone)
        print(location.timezone)
       
        guard let returnedArray = prayTimeObj?.getDatePrayerTimes(Int32(date.yearFourDigit) ?? 2023, andMonth: Int32(date.monthTwoDigit) ?? 12, andDay: Int32(date.dayTwoDigit) ?? 17, andLatitude: location.lat ?? 0.0, andLongitude: location.lng ?? 0.0, andtimeZone: timeZone) else {return }
        guard let timeNames = prayTimeObj?.timeNames as? [String] else { return  }
      
        print("prayers timing of the day",returnedArray)
 
        let originalTimeZone = TimeZone(identifier: "UTC")! // Set the original timezone of the times
           
        let updatedTimes = updateTimeZoneForTimes(timeArray: returnedArray as! [String], from: originalTimeZone, to: location.timezone!)
        
        print("returnedArray:\(returnedArray)")
        print("updatedTimes:\(updatedTimes)")
        let salahTiming = updatedTimes.compactMap { $0 }
        let salahNaming = timeNames.compactMap { $0 }
        guard salahNaming.count == updatedTimes.count else {
            print("Names count and times count mismatch")
            completion(nil)
            return
        }
      
        var prayerTimings: [PrayerTiming] = []
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = PrayerTiming(name: name, time: "\(salahTiming[index])")
            guard let timeZone = location.timezone else { return  }
           
            if name == "Sunset" {
                print("SunSet \(salahTiming[index])")
            }else if name == "Sunrise"  {
                print("Sunrise \(salahTiming[index])")
            }else{
                prayerTimings.append(newSalahTiming)
            }
        }
        var updatedLocation = location
        updatedLocation.prayerTimings = prayerTimings
        completion(updatedLocation)
    }

    func updateTimeZoneForTimes(timeArray: [String], from originalTimeZone: TimeZone, to targetTimeZone: TimeZone) -> [String] {
        var updatedTimes: [String] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = originalTimeZone // Set the original timezone
        
        for timeString in timeArray {
            if let timeDate = dateFormatter.date(from: timeString) {
                dateFormatter.timeZone = targetTimeZone // Set the target timezone
                let updatedTime = dateFormatter.string(from: timeDate)
                updatedTimes.append(updatedTime)
            }
        }

        return updatedTimes
    }

//

    func convertDateTimeString(_ originalDateTimeString: String, from originalFormat: String? = "yyyy-MM-dd HH:mm:ss Z", to targetFormat: String? = "MMM dd, yyyy HH:mm:ss Z", originalTimeZone: TimeZone, targetTimeZone: TimeZone) -> String? {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = originalFormat
        originalDateFormatter.timeZone = originalTimeZone
        
        if let originalDate = originalDateFormatter.date(from: originalDateTimeString) {
            let targetDateFormatter = DateFormatter()
            targetDateFormatter.dateFormat = targetFormat
            targetDateFormatter.timeZone = targetTimeZone
            print(targetDateFormatter.string(from: originalDate))
            return targetDateFormatter.string(from: originalDate)
        } else {
            print("Failed to convert original date and time string to Date.")
            return nil
        }
    }
}
