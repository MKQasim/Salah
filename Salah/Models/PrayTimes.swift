//
//  PrayTimes.swift
//  Salah
//
//  Created by Qassim on 1/17/24.
//

import Foundation

class PrayTimes {
    // Global Variables
    var calcMethod = PrayerTimeSetting.CalculationMethod.mwl
    var asrJuristic = PrayerTimeSetting.JuristicMethod.shafii
    var dhuhrMinutes: Int = 0
    var adjustHighLats = PrayerTimeSetting.AdjustingMethod.angleBased
    var timeFormat = PrayerTimeSetting.TimeFormat.time24
    
    var lat: Double = 0.0
    var lng: Double = 0.0
    var timeZone: Double = 0.0
    var JDate: Double = 0.0
    
    // Time Names
    var timeNames: [String] = []
    var InvalidTime: String = ""
    
    // Technical Settings
    var numIterations: Int = 0
    
    // Calc Method Parameters
    var methodParams: [AnyHashable: Any] = [:]
    
    // Prayer Time Arrays
    var prayerTimesCurrent: [Any] = []
    var offsets: [Any] = []
    
    // Calculation Methods
    // MARK: - Setters for Prayer Time Settings
    
    // Set the calculation method
    func setCalcMethod(method: PrayerTimeSetting.CalculationMethod) {
        calcMethod = method
        print("Calculation Method: \(calcMethod.rawValue)")
    }
    
    // Set the juristic method for Asr
    func setAsrMethod(method: PrayerTimeSetting.JuristicMethod) {
        asrJuristic = method
        print("Asr Juristic Method: \(asrJuristic.rawValue)")
    }
    
    // Set adjusting method for higher latitudes
    func setHighLatsMethod(method: PrayerTimeSetting.AdjustingMethod) {
        adjustHighLats = method
        print("Adjusting Method for Higher Latitudes: \(adjustHighLats.rawValue)")
    }
    
    // Set the time format
    func setTimeFormat(format: PrayerTimeSetting.TimeFormat) {
        timeFormat = format
        print("Time Format: \(timeFormat.rawValue)")
    }
    
    
    // ... (unchanged functions)
    
    static func == (lhs: PrayTimes, rhs: PrayTimes) -> Bool {
        // Implement your comparison logic here
        return lhs.calcMethod == rhs.calcMethod &&
        lhs.asrJuristic == rhs.asrJuristic &&
        lhs.dhuhrMinutes == rhs.dhuhrMinutes &&
        lhs.adjustHighLats == rhs.adjustHighLats &&
        lhs.timeFormat == rhs.timeFormat &&
        lhs.lat == rhs.lat &&
        lhs.lng == rhs.lng &&
        lhs.timeZone == rhs.timeZone &&
        lhs.JDate == rhs.JDate &&
        lhs.timeNames == rhs.timeNames &&
        lhs.InvalidTime == rhs.InvalidTime &&
        lhs.numIterations == rhs.numIterations
        
    }
    
    // Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(calcMethod)
        hasher.combine(asrJuristic)
        hasher.combine(dhuhrMinutes)
        hasher.combine(adjustHighLats)
        hasher.combine(timeFormat)
        hasher.combine(lat)
        hasher.combine(lng)
        hasher.combine(timeZone)
        hasher.combine(JDate)
        hasher.combine(timeNames)
        hasher.combine(InvalidTime)
        hasher.combine(numIterations)
        
    }
    
    
    
    
    // Trigonometric Functions
    func fixangle(_ a: Double) -> Double {
        var a = a
        a = a - (360 * (floor(a / 360.0)))
        a = a < 0 ? (a + 360) : a
        return a
    }
    
    func fixhour(_ a: Double) -> Double {
        var a = a
        a = a - 24.0 * floor(a / 24.0)
        a = a < 0 ? (a + 24) : a
        return a
    }
    
    func radiansToDegrees(_ alpha: Double) -> Double {
        return ((alpha * 180.0) / Double.pi)
    }
    
    func DegreesToRadians(_ alpha: Double) -> Double {
        return ((alpha * Double.pi) / 180.0)
    }
    
    func dsin(_ d: Double) -> Double {
        return (sin(DegreesToRadians(d)))
    }
    
    func dcos(_ d: Double) -> Double {
        return (cos(DegreesToRadians(d)))
    }
    
    func dtan(_ d: Double) -> Double {
        return (tan(DegreesToRadians(d)))
    }
    
    func darcsin(_ x: Double) -> Double {
        let val = asin(x)
        return radiansToDegrees(val)
    }
    
    func darccos(_ x: Double) -> Double {
        let val = acos(x)
        return radiansToDegrees(val)
    }
    
    func darctan(_ x: Double) -> Double {
        let val = atan(x)
        return radiansToDegrees(val)
    }
    
    func darctan2(y: Double, x: Double) -> Double {
        let val = atan2(y, x)
        return radiansToDegrees(val)
    }
    
    func darccot(_ x: Double) -> Double {
        let val = atan2(1.0, x)
        return radiansToDegrees(val)
    }
    
    // Time-Zone Functions
    func getTimeZone() -> Double {
        let timeZone = TimeZone.current
        let hoursDiff = Double(timeZone.secondsFromGMT()) / 3600.0
        return hoursDiff
    }
    
    func getBaseTimeZone() -> Double {
        let timeZone = TimeZone.current
        let hoursDiff = Double(timeZone.secondsFromGMT()) / 3600.0
        return hoursDiff
    }
    
    func detectDaylightSaving() -> Double {
        let timeZone = TimeZone.current
        let hoursDiff = Double(timeZone.daylightSavingTimeOffset(for: Date())) / 3600.0
        return hoursDiff
    }
    
    // Julian Date Functions
    func julianDate(year: Int, month: Int, day: Int) -> Double {
        var year = year
        var month = month
        
        if month <= 2 {
            year -= 1
            month += 12
        }
        
        let A = floor(Double(year) / 100.0)
        let B = 2 - A + floor(A / 4.0)
        
        let JD = floor(365.25 * (Double(year) + 4716)) + floor(30.6001 * (Double(month) + 1)) + Double(day) + B - 1524.5
        
        return JD
    }
    
    func calcJD(year: Int, month: Int, day: Int) -> Double {
        let J1970 = 2440588.0
        let components = DateComponents(year: year, month: month, day: day)
        let gregorian = Calendar(identifier: .gregorian)
        if let date = gregorian.date(from: components) {
            let ms = date.timeIntervalSince1970
            let days = floor(ms / (1000.0 * 60.0 * 60.0 * 24.0))
            return J1970 + days - 0.5
        }
        return 0.0
    }
    
    //---------------------- Calculation Functions -----------------------
    
    // compute declination angle of sun and equation of time
    func sunPosition(jd: Double) -> [Double] {
        let D = jd - 2451545
        let g = fixangle(357.529 + 0.98560028 * D)
        let q = fixangle(280.459 + 0.98564736 * D)
        let L = fixangle(q + (1.915 * dsin(g)) + (0.020 * dsin(2 * g)))
        
        let e = 23.439 - (0.00000036 * D)
        let d = darcsin(dsin(e) * dsin(L))
        let RA = darctan2(y: dcos(e) * dsin(L), x: dcos(L)) / 15.0
        let correctedRA = fixhour(RA)
        
        let EqT = q / 15.0 - correctedRA
        
        return [d, EqT]
    }
    
    // compute equation of time
    func equationOfTime(jd: Double) -> Double {
        let eq = sunPosition(jd: jd)[1]
        return eq
    }
    
    // compute declination angle of sun
    func sunDeclination(jd: Double) -> Double {
        let d = sunPosition(jd: jd)[0]
        return d
    }
    
    // compute mid-day (Dhuhr, Zawal) time
    func computeMidDay(t: Double) -> Double {
        let T = equationOfTime(jd: JDate + t)
        let Z = fixhour(12 - T)
        return Z
    }
    
    // Compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    func computeAsr(step: Double, t: Double) -> Double {
        let D = sunDeclination(jd: JDate + t)
        let G = -darccot(step + dtan(abs(lat - D)))
        return computeTime(G: G, t: t)
    }
    
    
    // Compute time for a given angle G
    func computeTime(G: Double, t: Double) -> Double {
        let D = sunDeclination(jd: JDate + t)
        let Z = computeMidDay(t: t)
        let V = darccos((-dsin(G) - (dsin(D) * dsin(lat))) / (dcos(D) * dcos(lat))) / 15.0
        
        return Z + (G > 90 ? -V : V)
    }
    
    //---------------------- Misc Functions -----------------------
    
    // Compute the difference between two times
    func timeDiff(_ time1: Double, and time2: Double) -> Double {
        return fixhour(time2 - time1)
    }
    
    //-------------------- Interface Functions --------------------
    
    // Return prayer times for a given date
    
    func getDatePrayerTimes(year: Int, month: Int, day: Int, latitude: Double, longitude: Double, timeZone: Double) -> [Double] {
        lat = latitude
        lng = longitude
        self.timeZone = timeZone
        JDate = julianDate(year: year, month: month, day: day)
        let lonDiff = longitude / (15.0 * 24.0)
        JDate = JDate - lonDiff
        
        let stringTimes = computeDayTimes() // Get prayer times as strings
        let doubleTimes = stringTimes.map { Double($0) ?? 0.0 } // Convert strings to doubles
        
        return doubleTimes
    }
    
    // Return prayer times for a given date
    func getPrayerTimes(date: DateComponents, latitude: Double, longitude: Double, timeZone: Double) -> [Double] {
        let year = date.year!
        let month = date.month!
        let day = date.day!
        return getDatePrayerTimes(year: year, month: month, day: day, latitude: latitude, longitude: longitude, timeZone: timeZone)
    }
    
    // Set the calculation method
    func setCalcMethod(methodID: Int) {
        guard let calculationMethod = PrayerTimeSetting.CalculationMethod(rawValue: methodID) else {
            // Handle the case where the provided methodID is not valid
            print("Invalid Calculation Method ID: \(methodID)")
            return
        }
        calcMethod = calculationMethod
        print("Calculation Method: \(calcMethod.rawValue)")
    }
    
    // Set the juristic method for Asr
    func setAsrMethod(methodID: Int) {
        guard let juristicMethod = PrayerTimeSetting.JuristicMethod(rawValue: methodID), (0...1).contains(methodID) else {
            // Handle the case where the provided methodID is not valid
            print("Invalid Juristic Method ID: \(methodID)")
            return
        }
        asrJuristic = juristicMethod
        print("Asr Juristic Method: \(asrJuristic.rawValue)")
    }
    
    // Set custom values for calculation parameters
    func setCustomParams(params: [Any]) {
        // Make sure 'methodParams' is a variable dictionary
        var customParams = methodParams[PrayerTimeSetting.CalculationMethod.custom] as? [Any] ?? []
        guard let calculationParams = methodParams[calcMethod] as? [Any] else {
            // Handle the case where the custom or calculation parameters are not available
            return
        }
        
        for i in 0..<5 {
            if let jNumber = params[i] as? NSNumber, jNumber.intValue == -1 {
                customParams[i] = calculationParams[i]
            } else {
                customParams[i] = params[i]
            }
        }
        calcMethod = .custom
        methodParams[PrayerTimeSetting.CalculationMethod.custom] = customParams
        // Assign the modified 'customParams' back to methodParams
    }
    
    
    // Set the angle for calculating Fajr
    func setFajrAngle(angle: Double) {
        let params: [Any] = [angle, -1, -1, -1, -1]
        setCustomParams(params: params)
    }
    
    // Set the angle for calculating Maghrib
    func setMaghribAngle(angle: Double) {
        let params: [Any] = [-1, 0, angle, -1, -1]
        setCustomParams(params: params)
    }
    
    // Set the angle for calculating Isha
    func setIshaAngle(angle: Double) {
        let params: [Any] = [-1, -1, -1, 0, angle]
        setCustomParams(params: params)
    }
    
    // Set the minutes after mid-day for calculating Dhuhr
    func setDhuhrMinutes(minutes: Double) {
        dhuhrMinutes = Int(minutes)
    }
    
    // Set the minutes after Sunset for calculating Maghrib
    func setMaghribMinutes(minutes: Double) {
        let params: [Any] = [-1, 1, minutes, -1, -1]
        setCustomParams(params: params)
    }
    
    // Set the minutes after Maghrib for calculating Isha
    func setIshaMinutes(minutes: Double) {
        let params: [Any] = [-1, -1, -1, 1, minutes]
        setCustomParams(params: params)
    }
    
    
    // Convert double hours to 24h format
    func floatToTime24(_ time: Double) -> String {
        if time.isNaN {
            return InvalidTime
        }
        
        let roundedTime = fixhour(time + 0.5 / 60.0) // add 0.5 minutes to round
        let hours = Int(floor(roundedTime))
        let minutes = Int(floor((roundedTime - Double(hours)) * 60.0))
        let seconds = Int(floor((((roundedTime - Double(hours)) * 60.0) - Double(minutes)) * 60.0))
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Convert double hours to 12h format
    func floatToTime12(_ time: Double, noSuffix: Bool) -> String {
        if time.isNaN {
            return InvalidTime
        }
        
        var time = fixhour(time + 0.5 / 60) // add 0.5 minutes to round
        var hours = Int(floor(time))
        let minutes = Int(floor((time - Double(hours)) * 60.0))
        let seconds = Int(floor((((time - Double(hours)) * 60.0) - Double(minutes)) * 60.0))
        var suffix: String
        var result: String?
        
        if hours >= 12 {
            suffix = "pm"
        } else {
            suffix = "am"
        }
        
        hours = (hours + 12) - 1
        var hrs = hours % 12
        hrs += 1
        
        if noSuffix == false {
            result = String(format: "%02d:%02d:%02d %@", hrs, minutes, seconds, suffix)
        } else {
            result = String(format: "%02d:%02d:%02d", hrs, minutes, seconds)
        }
        
        return result!
    }
    
    
    // Convert double hours to 12h format with no suffix
    func floatToTime12NS(_ time: Double) -> String {
        return floatToTime12(time, noSuffix: true)
    }
    
    // Compute prayer times at given julian date
    func computeTimes(_ times: [Double]) -> [Double] {
        var t = dayPortion(times)
        print(calcMethod)
        
        guard let methodParamsArray = methodParams[calcMethod] as? [Double], methodParamsArray.count >= 5 else {
            print("Error: Invalid calculation method or missing parameters.")
            return []
        }
        
        let idk = methodParamsArray[0]
        let Fajr = computeTime(G: 180 - idk, t: t[0])
        let Sunrise = computeTime(G: 180 - 0.833, t: t[1])
        let Dhuhr = computeMidDay(t: t[2])
        let Asr = computeAsr(step: Double(1 + asrJuristic.rawValue), t: t[3])
        let Sunset = computeTime(G: 0.833, t: t[4])
        let Maghrib = computeTime(G: methodParamsArray[2], t: t[5])
        let Isha = computeTime(G: methodParamsArray[4], t: t[6])
        
        var Ctimes = [Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha]
        
        // Print debug information
        print("Ctimes: \(Ctimes)")
        
        // Tune times here
        // Ctimes = tuneTimes(Ctimes)
        
        return Ctimes
    }

    // Compute prayer times at given julian date
    func computeDayTimes() -> [String] {
        var t1: [Double]? = nil
        var t2: [Double]
        var t3: [String]
        var times = [5.0, 6.0, 12.0, 13.0, 18.0, 18.0, 18.0]
        
        for _ in 1...numIterations {
            t1 = computeTimes(times)
        }
        
        // Check if t1 is not nil and has enough elements
        guard let t1 = t1, t1.count == times.count else {
            // Handle the error or return an appropriate value
            return []
        }
        
        t2 = adjustTimes(t1)
        t2 = tuneTimes(t2)
        
        // Set prayerTimesCurrent here!!
        prayerTimesCurrent = t2
        
        t3 = adjustTimesFormat(t2)
        
        return t3
    }
    
    // Tune timings for adjustments
    // Set time offsets
    func tune(_ offsetTimes: NSMutableDictionary) {
        offsets[0] = offsetTimes["fajr"] as? Double ?? 0.0
        offsets[1] = offsetTimes["sunrise"] as? Double ?? 0.0
        offsets[2] = offsetTimes["dhuhr"] as? Double ?? 0.0
        offsets[3] = offsetTimes["asr"] as? Double ?? 0.0
        offsets[4] = offsetTimes["sunset"] as? Double ?? 0.0
        offsets[5] = offsetTimes["maghrib"] as? Double ?? 0.0
        offsets[6] = offsetTimes["isha"] as? Double ?? 0.0
    }
    
    func tuneTimes(_ times: [Double]) -> [Double] {
        var modifiedTimes = times
        
        for i in 0..<times.count {
            if let offset = offsets[i] as? Double {
                let off = offset / 60.0
                let time = times[i] + off
                modifiedTimes[i] = time
            } else {
                // Handle the case where the offset is not a Double (e.g., it might be another type or nil)
                // You may choose to ignore, log, or handle this case accordingly.
            }
        }
        
        return modifiedTimes
    }
    
    
    // Adjust times in a prayer time array
    func adjustTimes(_ times: [Double]) -> [Double] {
        var adjustedTimes = times
        
        for i in 0..<7 {
            var time = times[i] + (timeZone - lng / 15.0)
            adjustedTimes[i] = time
        }
        
        let Dtime = times[2] + (Double(dhuhrMinutes) / 60.0) // Dhuhr
        adjustedTimes[2] = Dtime
        
        if let a = methodParams[NSNumber(value: calcMethod.rawValue)] as? [Double] {
            let val = a[1]
            
            if val == 1 { // Maghrib
                let Dtime1 = times[4] + (a[2] / 60.0)
                adjustedTimes[5] = Dtime1
            }
            
            if a[3] == 1 { // Isha
                let Dtime2 = times[5] + (a[4] / 60.0)
                adjustedTimes[6] = Dtime2
            }
        }
        
        if adjustHighLats != .none {
            adjustedTimes = adjustHighLatTimes(adjustedTimes)
        }
        
        return adjustedTimes
    }
    
    // Convert times array to given time format
    func adjustTimesFormat(_ times: [Double]) -> [String] {
        var formattedTimes = [String]()
        
        if timeFormat == .float {
            return times.map { "\($0)" }
        }
        
        for i in 0..<7 {
            if timeFormat == .time12 {
                formattedTimes.append(floatToTime12(times[i], noSuffix: false))
            } else if timeFormat == .time12NS {
                formattedTimes.append(floatToTime12(times[i], noSuffix: true))
            } else {
                formattedTimes.append(floatToTime24(times[i]))
            }
        }
        
        return formattedTimes
    }
    // Adjust Fajr, Isha, and Maghrib for locations in higher latitudes
    func adjustHighLatTimes(_ times: [Double]) -> [Double] {
        var modifiedTimes = times
        
        let time0 = times[0]
        let time1 = times[1]
        let time4 = times[4]
        let time5 = times[5]
        let time6 = times[6]
        
        let nightTime = timeDiff(time4, and: time1) // sunset to sunrise
        
        if let obj = methodParams[NSNumber(value: calcMethod.rawValue)] as? [Double],
           let adjustMethod = PrayerTimeSetting.AdjustingMethod(rawValue: adjustHighLats.rawValue) {
            
            let FajrDiff = nightPortion(obj[0]) * nightTime
            
            if time0.isNaN || timeDiff(time0, and: time1) > FajrDiff {
                modifiedTimes[0] = time1 - FajrDiff
            }
            
            let IshaAngle = (obj[3] == 0) ? obj[4] : 18
            let IshaDiff = nightPortion(IshaAngle) * nightTime
            
            if time6.isNaN || timeDiff(time4, and: time6) > IshaDiff {
                modifiedTimes[6] = time4 + IshaDiff
            }
            
            let MaghribAngle = (obj[1] == 0) ? obj[2] : 4
            let MaghribDiff = nightPortion(MaghribAngle) * nightTime
            
            if time5.isNaN || timeDiff(time4, and: time5) > MaghribDiff {
                modifiedTimes[5] = time4 + MaghribDiff
            }
        }
        
        return modifiedTimes
    }
    
    // The night portion used for adjusting times in higher latitudes
    func nightPortion(_ angle: Double) -> Double {
        var calc = 0.0
        
        if let adjustMethod = PrayerTimeSetting.AdjustingMethod(rawValue: adjustHighLats.rawValue) {
            switch adjustMethod {
            case .angleBased:
                calc = angle / 60.0
            case .midnight:
                calc = 0.5
            case .oneSeventh:
                calc = 0.14286
            default:
                break
            }
        }
        
        return calc
    }
    
    
    // Convert hours to day portions
    func dayPortion(_ times: [Double]) -> [Double] {
        return times.map { $0 / 24.0 }
    }
    
    deinit {
        prayerTimesCurrent.removeAll()
    }
    
}
