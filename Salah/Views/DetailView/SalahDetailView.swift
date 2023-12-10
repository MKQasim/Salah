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

struct SalahDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @State private var prayerTimes:[SalahTiming] = []
    @State private var sunTimes:[SalahTiming] = []
    @State var isUpdate = true
    
    let city: Cities
    
    let column = [GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150))]
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
      @State var timeNow = ""
      let dateFormatter = DateFormatter()
    
    var body: some View {
        ZStack{
            Color.orange.ignoresSafeArea(.all)
            ScrollView{
                
                Text("Currently: " + timeNow)
                      .onReceive(timer) { _ in
                        self.timeNow = dateFormatter.string(from: Date())
                      }
                      .onAppear(perform: {dateFormatter.dateFormat = "LLLL dd, hh:mm:ss a"})
                
                Text(city.city)
                    .font(.largeTitle)
                    .fontWeight(.black)
                
                SalahSunTimeSection(sunTimes: $sunTimes)
                
                SalahDailySectionView(prayerTimes: $prayerTimes)
                
                Section("Weekly Timing") {
                    Text("H")
                }
            }
            .padding()
        }
        .onAppear{
            if isUpdate{
                getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
                isUpdate = false
            }
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


//#Preview {
//    SalahDetailView(lat: 43.22, long: 24.33, timeZone: +4.0)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}

