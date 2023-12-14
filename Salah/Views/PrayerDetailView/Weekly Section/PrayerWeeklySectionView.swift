//
//  PrayerWeeklySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/12/23.
//

import SwiftUI

struct PrayerWeekly:Identifiable, Hashable{
    var id = UUID()
    let date: Date
    let dayPrayerTime:[SalahTiming]
}

struct PrayerWeeklySectionView: View {
    let city: Cities
    @State private var weeklyPrayerTiming: [PrayerWeekly] = []
    @State var isUpdate = true

    var body: some View {
        LazyVGrid(columns: [.init(.flexible(maximum: .infinity))],pinnedViews: .sectionHeaders){
            Section(header: VStack{
                Text("Weekly Prayers Times").font(.title3).bold()
            }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
            ) {
                ForEach(weeklyPrayerTiming, id: \.self){item in
                    HStack{
                        ScrollView(.horizontal,showsIndicators: false){
                            Section(header: Text(item.date, style: .date)){
                                HStack{
                                    ForEach(item.dayPrayerTime, id: \.self){
                                        oneDaySalah in
                                        
                                        PrayerDailyCellView(prayer: oneDaySalah)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        .onAppear{
            if isUpdate{
                setUpWeeklyPrayersTiming(lat: city.lat, long: city.long, timeZone: city.timeZone)
                isUpdate = false
            }
        }
    }
    
    func setUpWeeklyPrayersTiming(lat: Double, long:Double, timeZone:Double){
        
        if let date = Date().dateByAdding(timeZoneOffset: city.timeZone){
            let cal = Calendar.current
            for i in 1...7{
                if let newDate = cal.date(byAdding: .day, value: i, to: Date()) {
                    var oneDaySalah:[SalahTiming] = []
                    let getDailyPrayerTiming = PrayerTimeHelper.getSalahTimings(lat: lat, long: long, timeZone: timeZone, date: newDate)
                    for getDailyPrayerTime in getDailyPrayerTiming {
                        let newSalahTiming = SalahTiming(name: getDailyPrayerTime.name, time: getDailyPrayerTime.time)
                        oneDaySalah.append(newSalahTiming)
                    }
                    let dayPrayerTime = PrayerWeekly(date: newDate, dayPrayerTime: oneDaySalah)
                    weeklyPrayerTiming.append(dayPrayerTime)
                        }
                
                
            }
            
            
        }
        
        
    }
    

}

#Preview {
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.2, timeZone: 1.0)
    return PrayerWeeklySectionView(city: city)
}
