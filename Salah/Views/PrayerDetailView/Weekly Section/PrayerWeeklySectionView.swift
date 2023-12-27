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
    let selectedLocation: Location
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
                Task {
                    await setUpWeeklyPrayersTiming(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, timeZone: selectedLocation.offSet ?? 0.0)
                    isUpdate = false
                }
            }
        }
    }
    
    func setUpWeeklyPrayersTiming(lat: Double, long:Double, timeZone:Double) async{
        
        if Date().dateByAdding(timeZoneOffset: selectedLocation.offSet ?? 0.0) != nil{
            let cal = Calendar.current
            for i in 2...8{
                if let newDate = cal.date(byAdding: .day, value: i, to: Date()) {
                    var oneDaySalah:[PrayerTiming] = []
                    let getDailyPrayerTiming: () = await PrayerTimeHelper.shared.getSalahTimings(location: selectedLocation, date: newDate, completion: { location in
                        guard let getDailyPrayerTiming = location?.prayerTimings else { return  }
                        
                        for getDailyPrayerTime in getDailyPrayerTiming {
                            let newSalahTiming = PrayerTiming(name: getDailyPrayerTime.name, time: getDailyPrayerTime.time)
                            oneDaySalah.append(newSalahTiming)
                        }
                        let dayPrayerTime = PrayerWeekly(date: newDate, dayPrayerTime: oneDaySalah)
                        weeklyPrayerTiming.append(dayPrayerTime)
                    })
                   
                }
                
                
            }
            
            
        }
        
        
    }
    
    
}

#Preview {
    let selectedLocation = Location(prayerTimings: [])
    return PrayerWeeklySectionView(selectedLocation: selectedLocation)
}
