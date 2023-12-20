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
    let dayPrayerTime:[PrayerTiming]
}

struct PrayerWeeklySectionView: View {
    let city: Cities
    @State private var weeklyPrayerTiming: [PrayerWeekly] = []
    @State var isUpdate = true
    
    var body: some View {
        LazyVGrid(columns: [.init(.flexible(maximum: .infinity))],pinnedViews: .sectionHeaders){
            Section(header: SectionHeaderView(title: "Weekly Salah Timings")) {
                ForEach(weeklyPrayerTiming, id: \.self){item in
                    VStack{
                        Section(header: VStack{
                            Text(item.date, style: .date)
                                .foregroundStyle(.gray)
                        }.frame(maxWidth: .infinity,alignment: .leading)
                        ){
                            ViewThatFits{
                                HStack{
                                    ForEach(item.dayPrayerTime, id: \.self){
                                        oneDaySalah in
                                        
                                        PrayerDailyCellView(prayer: oneDaySalah)
                                    }
                                }
                                .frame(maxWidth: .infinity,alignment: .leading)
                                ScrollView(.horizontal, showsIndicators: false){
                                    LazyHStack{
                                        ForEach(item.dayPrayerTime, id: \.self){
                                            oneDaySalah in
                                            
                                            PrayerDailyCellView(prayer: oneDaySalah)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                
                            }
                        }
                        
                    }
                }
                .padding(4)
            }
        }
        .onAppear{
            if isUpdate{
                setUpWeeklyPrayersTiming(lat: city.lat, long: city.long, timeZone: city.offSet)
                isUpdate = false
            }
        }
    }
    
    func setUpWeeklyPrayersTiming(lat: Double, long:Double, timeZone:Double){
        
        if Date().dateByAdding(timeZoneOffset: city.offSet) != nil{
            let cal = Calendar.current
            for i in 2...8{
                if let newDate = cal.date(byAdding: .day, value: i, to: Date()) {
                    var oneDaySalah:[PrayerTiming] = []
                    let getDailyPrayerTiming = PrayerTimeHelper.getSalahTimings(lat: lat, long: long, timeZone: timeZone, date: newDate)
                    for getDailyPrayerTime in getDailyPrayerTiming {
                        let newSalahTiming = PrayerTiming(name: getDailyPrayerTime.name, time: getDailyPrayerTime.time)
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
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.2, offSet: 1.0)
    return PrayerWeeklySectionView(city: city)
}
