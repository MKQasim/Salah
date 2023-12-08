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

    var lat:Double
    var long:Double
    var timeZone:Double
    
    init(lat: Double, long: Double, timeZone: Double) {
        self.lat = lat
        self.long = long
        self.timeZone = timeZone
    }
    
    let column = [GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150)),GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        ZStack{
            Color.mint.ignoresSafeArea(.all)
            ScrollView{
                ForEach(sunTimes, id: \.self){
                    sunTime in
                    Text(sunTime.name)
                    Text(sunTime.time)
                }
                Section("Timings"){
                    LazyVGrid(columns: column){
                        ForEach(prayerTimes, id:\.self
                        ){prayer in
                            VStack{
                                Text(prayer.name)
                                    .foregroundStyle(.white)
                                    .font(.title)
                                    .fontWeight(.black)
                                Text(prayer.time)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).foregroundStyle(.thinMaterial))
                            .padding(2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear{
            getSalahTimings(lat: lat, long: long, timeZone: timeZone)
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
            }
            else{
                sunTimes.append(newSalahTiming)
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


#Preview {
    SalahDetailView(lat: 43.22, long: 24.33, timeZone: +4.0)
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}

