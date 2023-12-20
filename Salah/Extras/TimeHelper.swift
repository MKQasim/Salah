//
//  TimeHelper.swift
//  Salah
//
//  Created by Haaris Iqubal on 14.12.23.
//

import Foundation

class TimeHelper {
    static func currentTime(for timeZone: Double,dateFormatString: String = "LLLL dd, hh:mm:ss a",currentDate: Date = Date()) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormatString
        dateFormatter.calendar = Calendar(identifier: .islamicCivil)
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = Double(seconds/3600)
        
        if  timeZone != hours {
            let differentInTimeZone = timeZone - hours
            if let dateTime = currentDate.dateByAdding(timeZoneOffset: differentInTimeZone) {
                return dateFormatter.string(for: dateTime) ?? ""
            } else {
                print("Error occurred while calculating the date.")
                return ""
            }
        }
        else{
            return dateFormatter.string(for: currentDate)
        }
    }
    
    static func convertTimeStringToDate(_ timeString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let formattedDate = dateFormatter.date(from: timeString)
        return formattedDate
    }
    
}
