//
//  PrayerWeeklySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/12/23.
//

import SwiftUI

struct PrayerWeeklySectionView: View {
    let city: Cities
    @State private var weeklyPrayerTiming: [[SalahTiming]] = []
    @State var isUpdate = true

    var body: some View {
        VStack{
            Section(header: Text("Weekly Timeing").bold()) {
                ForEach(weeklyPrayerTiming, id: \.self){item in
                    
                    HStack{
                        ScrollView(.horizontal,showsIndicators: false){
                            HStack{
                                ForEach(item, id: \.self){
                                    oneDaySalah in
                                    VStack{
                                        Text(oneDaySalah.name)
                                        
                                        Text(oneDaySalah.time)
                                        
                                    }
                                    .padding()
                                    .background(.thinMaterial)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear{
            if isUpdate{
                getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
                isUpdate = false
            }
        }
    }
    
    func getSalahTimings(lat: Double, long:Double, timeZone:Double){
        //        guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
        let time = PrayTime()
        time.setCalcMethod(3)
        
        if let date = Date().dateByAdding(timeZoneOffset: city.timeZone){
            let cal = Calendar.current
            for i in 1...7{
                if let newDate = cal.date(byAdding: .day, value: i, to: Date()) {
                    let mutableNames = time.timeNames!
                    let salahNaming:[String] = mutableNames.compactMap({$0 as? String})
                    let getTime = time.getDatePrayerTimes(Int32(newDate.get(.year)), andMonth: Int32(newDate.get(.month)), andDay: Int32(newDate.get(.day)), andLatitude: lat, andLongitude: long, andtimeZone: timeZone)!
                    let salahTiming = getTime.compactMap({$0 as? String})
                    var oneDaySalah:[SalahTiming] = []
                    for (index,name) in salahNaming.enumerated(){
                        let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
                        oneDaySalah.append(newSalahTiming)
                    }
                    weeklyPrayerTiming.append(oneDaySalah)
                        }
                
                
            }
            
            
        }
        
        
    }
    

}

#Preview {
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.2, timeZone: 1.0)
    return PrayerWeeklySectionView(city: city)
}
