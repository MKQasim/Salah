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

    
    var body: some View {
        VStack{
            ForEach(prayerTimes, id:\.self
            ){prayer in
                HStack{
                    Text(prayer.name)
                    Text(prayer.time)
                }
                .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).foregroundStyle(.gray))
            }
        }
        .onAppear{
            guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
            let date = Date()
            let time = PrayTime()
            time.setCalcMethod(3)
            let mutableNames = time.timeNames!
            let salahNaming:[String] = mutableNames.compactMap({$0 as? String})
            print(salahNaming)
            let getTime = time.getDatePrayerTimes(Int32(date.get(.year)), andMonth: Int32(date.get(.month)), andDay: Int32(date.get(.day)), andLatitude: userCoordinates.latitude.magnitude, andLongitude: userCoordinates.longitude.magnitude, andtimeZone: 1.0)!
            let salahTiming = getTime.compactMap({$0 as? String})
            print(salahTiming)
            for (index,name) in salahNaming.enumerated() {
                let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
                prayerTimes.append(newSalahTiming)
            }
            
            // Call the function to parse the local JSON data
            /*parseLocalJSON*/()
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
    SalahDetailView()
}

