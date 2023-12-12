//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct SalahTiming: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let time: String
}

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @State private var prayerTimes:[SalahTiming] = []
    @State private var sunTimes:[SalahTiming] = []
    @State var isUpdate = true
    
    let city: Cities
    
    let column = [GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150))]
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeNow = ""
    @State var nextSalah = ""
    var dateFormatter = DateFormatter()
    
    var body: some View {
        ZStack{
            Color.orange.ignoresSafeArea(.all)
            ScrollView{
                
                Text("Currently: " + timeNow)
                    .onReceive(timer) { _ in
                        self.timeNow = currentTime(for: city.timeZone) ?? ""
                    }
                    .onAppear(perform: {dateFormatter.dateFormat = "LLLL dd, hh:mm:ss a"})
                
                Text("Remaining : " + nextSalah)
                    .onReceive(timer){_ in
                        
                    }
                
                Text(city.city)
                    .font(.largeTitle)
                    .fontWeight(.black)
                
                PrayerHeaderSection(sunTimes: $sunTimes)
                
                PrayerDailySectionView(prayerTimes: $prayerTimes)
                
                Section("Next Salah"){
                    Text(nextSalah)
                }
                
                Section("Weekly Timing") {
                    PrayerWeeklySectionView(city: city)
                }
            }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(city.city)
            #endif
        }
        .onAppear{
            if isUpdate{
                getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
                isUpdate = false
            }
            getNextPrayerTime()
        }
    }
    
    private func getNextPrayerTime() {
        let currentDate = Date().dateByAdding(timeZoneOffset: city.timeZone)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
            for prayer in prayerTimes {
                let addedCurrentDate = dateFormatter.string(from: currentDate!) + " " + prayer.time
                if let prayerTime = convertTimeStringToDate(addedCurrentDate, format: "dd/MM/yyyy HH:mm"){
                    if prayerTime > currentDate! {
                        print(currentDate,prayerTime)
                        nextSalah = "\(prayer.name) at \(prayer.time)"
                        print(prayer)
                        break
                    }
                }
    }
        if nextSalah.isEmpty {
            nextSalah = "\(prayerTimes[0].name) at \(prayerTimes[0].time)"
        }
    }
    
    
    
    private func remainingTimeToNextPrayer(from time: String) -> String {
        guard let prayerDate = convertTimeStringToDate(time, format: "HH:mm") else {
            return "Unknown"
        }
        let now = Date()
        return now.timeRemainingString(to: prayerDate)
    }

    private func convertTimeStringToDate(_ timeString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: timeString)
    }
    
    func currentTime(for timeZone: Double) -> String? {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL dd, hh:mm:ss a"
        if let dateTime = currentDate.dateByAdding(timeZoneOffset:timeZone) {
            return dateFormatter.string(for: dateTime) ?? ""
        } else {
            print("Error occurred while calculating the date.")
            return ""
        }
        
    }
    
    func getSalahTimings(lat: Double, long:Double, timeZone:Double){
        //        guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
        let date = Date()
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming:[String] = mutableNames.compactMap({$0 as? String})
        //        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)), andMonth: Int32(date.get(.month)), andDay: Int32(date.get(.day)), andLatitude: userCoordinates.latitude.magnitude, andLongitude: userCoordinates.longitude.magnitude, andtimeZone: 1.0)!
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)), andMonth: Int32(date.get(.month)), andDay: Int32(date.get(.day)), andLatitude: lat, andLongitude: long, andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({$0 as? String})
        for (index,name) in salahNaming.enumerated() {
            let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
            if (name != "Sunset" && name != "Sunrise"){
                prayerTimes.append(newSalahTiming)
                isUpdate = true
            }
            else{
                sunTimes.append(newSalahTiming)
                isUpdate = true
            }
        }
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    func adjusted(byHours hours: Int, minutes: Int, seconds: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
}

extension Date {
    func dateByAdding(hours: Int, minutes: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        
        return calendar.date(byAdding: dateComponents, to: self)
    }
    
    func dateByAdding(timeZoneOffset: Double) -> Date? {
        let hours = Int(timeZoneOffset)
        let minutes = Int((timeZoneOffset - Double(hours)) * 60)
        return dateByAdding(hours: hours, minutes: minutes)
    }
}




#Preview {
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.32, timeZone: +1.0)
    return PrayerDetailView(city: city)
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}

