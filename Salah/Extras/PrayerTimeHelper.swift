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

class PrayerTimeHelper {
    let prayTimeObj: PrayTime
    let geocoder: CLGeocoder

    init() {
        prayTimeObj = PrayTime()
        geocoder = CLGeocoder()
    }

    func getPrayerTimings(lat: Double, long: Double, timeZone: Double, date: Date = Date(), completion: @escaping (Location?) -> Void) {
        prayTimeObj.setCalcMethod(3)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
      
        guard let prayerDate = Calendar.current.date(from: dateComponents),
              let returnedArray = prayTimeObj.getPrayerTimes(dateComponents, andLatitude: lat, andLongitude: long, andtimeZone: timeZone) as? [String],
              let timeNames = prayTimeObj.timeNames as? [String] else {
            print("Empty")
            completion(nil)
            return
        }
      
        let salahNaming = timeNames.compactMap { $0 }
        let salahTiming = returnedArray.compactMap { $0 }
      
        guard salahNaming.count == salahTiming.count else {
            print("Names count and times count mismatch")
            completion(nil)
            return
        }
      
        var prayerTimings: [PrayerTiming] = []
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = PrayerTiming(name: name, time: salahTiming[index])

            if name != "Sunset" && name != "Sunrise" {
                prayerTimings.append(newSalahTiming)
            }
        }

        reverseGeocode(lat: lat, long: long) { location in
            guard var location = location else {
                completion(nil)
                return
            }

            location.prayerTimings = prayerTimings
            completion(location)
        }
    }


    private func reverseGeocode(lat: Double, long: Double, completion: @escaping (Location?) -> Void) {
        let location = CLLocation(latitude: lat, longitude: long)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first,
                  error == nil else {
                completion(nil)
                return
            }
            
            if let timeZone = placemark.timeZone, let country = placemark.country {
                let currentTime = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = timeZone
                dateFormatter.dateFormat = "HH:mm"
                let localTime = dateFormatter.string(from: currentTime)
                
                if let locality = placemark.locality, let date = dateFormatter.date(from: localTime) {
                    let reversedLocation = Location(id: nil, city: locality, lat: lat, lng: long, country: country, dateTime: date, timezone: timeZone, prayerTimings: [])
                    completion(reversedLocation)
                } else {
                    // Handle the case where locality is nil or date conversion fails
                    completion(nil)
                }
            } else {
                // Handle the case where timezone or country is nil
                completion(nil)
            }
        }
    }

}
